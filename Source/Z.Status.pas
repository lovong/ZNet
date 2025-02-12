{ ****************************************************************************** }
{ * Status IO                                                                  * }
{ ****************************************************************************** }
unit Z.Status;

{$I Z.Define.inc}

interface

uses
{$IFNDEF FPC}
{$IF Defined(WIN32) or Defined(WIN64)}
  Windows,
{$ELSEIF not Defined(Linux)}
  FMX.Types,
{$IFEND}
{$IFEND FPC}
  SysUtils, Classes, SyncObjs,
{$IFDEF FPC}
  Z.FPC.GenericList, fgl,
{$ELSE FPC}
  System.Generics.Collections,
{$ENDIF FPC}
  Z.PascalStrings, Z.UPascalStrings, Z.UnicodeMixedLib, Z.Core;

type
{$IFDEF FPC}
  TDoStatus_P = procedure(Text_: SystemString; const ID: Integer) is nested;
{$ELSE FPC}
  TDoStatus_P = reference to procedure(Text_: SystemString; const ID: Integer);
{$ENDIF FPC}
  TDoStatus_M = procedure(Text_: SystemString; const ID: Integer) of object;
  TDoStatus_C = procedure(Text_: SystemString; const ID: Integer);

procedure AddDoStatusHook(TokenObj: TCore_Object; OnNotify: TDoStatus_M);
procedure AddDoStatusHookM(TokenObj: TCore_Object; OnNotify: TDoStatus_M);
procedure AddDoStatusHookC(TokenObj: TCore_Object; OnNotify: TDoStatus_C);
procedure AddDoStatusHookP(TokenObj: TCore_Object; OnNotify: TDoStatus_P);
procedure DeleteDoStatusHook(TokenObj: TCore_Object);
procedure RemoveDoStatusHook(TokenObj: TCore_Object);
procedure DisableStatus;
procedure EnabledStatus;

procedure DoStatus(Text_: SystemString; const ID: Integer); overload;
procedure DoStatus(const v: Pointer; siz, width: NativeInt); overload;
procedure DoStatus(prefix: SystemString; v: Pointer; siz, width: NativeInt); overload;
procedure DoStatus(const v: TCore_Strings); overload;
procedure DoStatus(const v: Int64); overload;
procedure DoStatus(const v: Integer); overload;
procedure DoStatus(const v: Single); overload;
procedure DoStatus(const v: Double); overload;
procedure DoStatus(const v: Pointer); overload;
procedure DoStatus(const v: SystemString; const Args: array of const); overload;
procedure DoError(v: SystemString; const Args: array of const); overload;
procedure DoStatus(const v: SystemString); overload;
procedure DoStatus(const v: TPascalString); overload;
procedure DoStatus(const v: TUPascalString); overload;
procedure DoStatus(const v: TMD5); overload;
procedure DoStatus; overload;

procedure DoStatusNoLn(const v: TPascalString); overload;
procedure DoStatusNoLn(const v: SystemString; const Args: array of const); overload;
procedure DoStatusNoLn; overload;

function StrInfo(s: TPascalString): string; overload;
function StrInfo(s: TUPascalString): string; overload;
function BytesInfo(s: TBytes): string; overload;

var
  LastDoStatus: SystemString;
  IDEOutput: Boolean;
  ConsoleOutput: Boolean;
  OnDoStatusHook: TDoStatus_C;
  StatusThreadID: Boolean;

implementation

procedure bufHashToString(hash: Pointer; Size: NativeInt; var output: TPascalString);
const
  HexArr: array [0 .. 15] of SystemChar = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
var
  i: Integer;
begin
  output.Len := Size * 2;
  for i := 0 to Size - 1 do
    begin
      output.buff[i * 2] := HexArr[(PByte(nativeUInt(hash) + i)^ shr 4) and $0F];
      output.buff[i * 2 + 1] := HexArr[PByte(nativeUInt(hash) + i)^ and $0F];
    end;
end;

procedure DoStatus(Text_: SystemString; const ID: Integer);
begin
  try
      OnDoStatusHook(Text_, ID);
  except
  end;
end;

procedure DoStatus(const v: Pointer; siz, width: NativeInt);
var
  s: TPascalString;
  i: Integer;
  n: SystemString;
begin
  bufHashToString(v, siz, s);
  n := '';
  for i := 1 to s.Len div 2 do
    begin
      if n <> '' then
          n := n + #32 + s[i * 2 - 1] + s[i * 2]
      else
          n := s[i * 2 - 1] + s[i * 2];

      if i mod (width div 2) = 0 then
        begin
          DoStatus(n);
          n := '';
        end;
    end;
  if n <> '' then
      DoStatus(n);
end;

procedure DoStatus(prefix: SystemString; v: Pointer; siz, width: NativeInt);
var
  s: TPascalString;
  i: Integer;
  n: SystemString;
begin
  bufHashToString(v, siz, s);
  n := '';
  for i := 1 to s.Len div 2 do
    begin
      if n <> '' then
          n := n + #32 + s[i * 2 - 1] + s[i * 2]
      else
          n := s[i * 2 - 1] + s[i * 2];

      if i mod (width div 2) = 0 then
        begin
          DoStatus(prefix + n);
          n := '';
        end;
    end;
  if n <> '' then
      DoStatus(prefix + n);
end;

procedure DoStatus(const v: TCore_Strings);
var
  i: Integer;
  o: TCore_Object;
begin
  for i := 0 to v.Count - 1 do
    begin
      o := v.Objects[i];
      if o <> nil then
          DoStatus('%s<%s>', [v[i], o.ClassName])
      else
          DoStatus(v[i]);
    end;
end;

procedure DoStatus(const v: Int64);
begin
  DoStatus(IntToStr(v));
end;

procedure DoStatus(const v: Integer);
begin
  DoStatus(IntToStr(v));
end;

procedure DoStatus(const v: Single);
begin
  DoStatus(FloatToStr(v));
end;

procedure DoStatus(const v: Double);
begin
  DoStatus(FloatToStr(v));
end;

procedure DoStatus(const v: Pointer);
begin
  DoStatus(Format('0x%p', [v]));
end;

procedure DoStatus(const v: SystemString; const Args: array of const);
begin
  DoStatus(Format(v, Args));
end;

procedure DoError(v: SystemString; const Args: array of const);
begin
  DoStatus(Format(v, Args), 2);
end;

procedure DoStatus(const v: SystemString);
begin
  DoStatus(v, 0);
end;

procedure DoStatus(const v: TPascalString);
begin
  DoStatus(v.Text, 0);
end;

procedure DoStatus(const v: TUPascalString);
begin
  DoStatus(v.Text, 0);
end;

procedure DoStatus(const v: TMD5);
begin
  DoStatus(umlMD5ToString(v).Text);
end;

type
  TStatusProcStruct = record
    TokenObj: TCore_Object;
    OnStatusM: TDoStatus_M;
    OnStatusC: TDoStatus_C;
    OnStatusP: TDoStatus_P;
  end;

  PStatusProcStruct = ^TStatusProcStruct;

  TStatusStruct = record
    s: SystemString;
    th: TCore_Thread;
    TriggerTime: TTimeTick;
    ID: Integer;
  end;

  PStatusStruct = ^TStatusStruct;

  TStatusNoLnStruct = record
    s: TPascalString;
    th: TCore_Thread;
    TriggerTime: TTimeTick;
  end;

  PStatusNoLnStruct = ^TStatusNoLnStruct;

  TStatusProcList = {$IFDEF FPC}specialize {$ENDIF FPC} TGenericsList<PStatusProcStruct>;
  TStatusStructList = {$IFDEF FPC}specialize {$ENDIF FPC} TGenericsList<PStatusStruct>;
  TStatusNoLnStructList = {$IFDEF FPC}specialize {$ENDIF FPC} TGenericsList<PStatusNoLnStruct>;

var
  StatusActive: Boolean;
  HookStatusProcs: TStatusProcList;
  StatusStructList: TStatusStructList;
  StatusCritical: TCriticalSection;
  StatusNoLnStructList: TStatusNoLnStructList;
  Hooked_OnCheckThreadSynchronize: TOnCheckThreadSynchronize;

function GetOrCreateStatusNoLnData_(th_: TCore_Thread): PStatusNoLnStruct;
var
  tk: TTimeTick;
  i: Integer;
begin
  tk := GetTimeTick();
  Result := nil;
  i := 0;
  while i < StatusNoLnStructList.Count do
    begin
      if StatusNoLnStructList[i]^.th = th_ then
        begin
          Result := StatusNoLnStructList[i];
          Result^.TriggerTime := tk;

          if i > 0 then
              StatusNoLnStructList.Exchange(i, 0);
          inc(i);
        end
      else if tk - StatusNoLnStructList[i]^.TriggerTime > C_Tick_Minute then
        begin
          Dispose(StatusNoLnStructList[i]);
          StatusNoLnStructList.Delete(i);
        end
      else
          inc(i);
    end;

  if Result = nil then
    begin
      new(Result);
      Result^.s := '';
      Result^.th := th_;
      Result^.TriggerTime := tk;
      StatusNoLnStructList.Add(Result);
    end;
end;

function GetOrCreateStatusNoLnData(): PStatusNoLnStruct;
begin
  Result := GetOrCreateStatusNoLnData_(TCore_Thread.CurrentThread);
end;

procedure DoStatusNoLn(const v: TPascalString);
var
  L, i: Integer;
  StatusNoLnData: PStatusNoLnStruct;
  pSS: PStatusStruct;
begin
  StatusCritical.Acquire;
  StatusNoLnData := GetOrCreateStatusNoLnData();
  try
    L := v.Len;
    i := 1;
    while i <= L do
      begin
        if CharIn(v[i], [#13, #10]) then
          begin
            if StatusNoLnData^.s.Len > 0 then
              begin
                new(pSS);
                pSS^.s := StatusNoLnData^.s.Text;
                pSS^.th := TCore_Thread.CurrentThread;
                pSS^.TriggerTime := GetTimeTick;
                pSS^.ID := 0;
                StatusStructList.Add(pSS);
                StatusNoLnData^.s := '';
              end;
            repeat
                inc(i);
            until (i > L) or (not CharIn(v[i], [#13, #10]));
          end
        else
          begin
            StatusNoLnData^.s.Append(v[i]);
            inc(i);
          end;
      end;
  finally
      StatusCritical.Release;
  end;
end;

procedure DoStatusNoLn(const v: SystemString; const Args: array of const);
begin
  DoStatusNoLn(Format(v, Args));
end;

procedure DoStatusNoLn;
var
  StatusNoLnData: PStatusNoLnStruct;
  s: SystemString;
begin
  StatusCritical.Acquire;
  StatusNoLnData := GetOrCreateStatusNoLnData();
  s := StatusNoLnData^.s;
  StatusNoLnData^.s := '';
  StatusCritical.Release;
  if Length(s) > 0 then
      DoStatus(s);
end;

function StrInfo(s: TPascalString): string;
begin
  Result := BytesInfo(s.Bytes);
end;

function StrInfo(s: TUPascalString): string;
begin
  Result := BytesInfo(s.Bytes);
end;

function BytesInfo(s: TBytes): string;
begin
  Result := umlStringOf(s);
end;

procedure _InternalOutput(const Text_: U_String; const ID: Integer);
var
  i: Integer;
  p: PStatusProcStruct;
  n: U_String;
begin
  if Text_.Exists(#10) then
    begin
      n := Text_.DeleteChar(#13);
      _InternalOutput(umlGetFirstStr_Discontinuity(n, #10), ID);
      n := umlDeleteFirstStr_Discontinuity(n, #10);
      _InternalOutput(n, ID);
      exit;
    end;
  if (StatusActive) and (HookStatusProcs.Count > 0) then
    begin
      LastDoStatus := Text_;
      for i := HookStatusProcs.Count - 1 downto 0 do
        begin
          p := HookStatusProcs[i];
          try
            if Assigned(p^.OnStatusM) then
                p^.OnStatusM(Text_, ID);
            if Assigned(p^.OnStatusC) then
                p^.OnStatusC(Text_, ID);
            if Assigned(p^.OnStatusP) then
                p^.OnStatusP(Text_, ID);
          except
          end;
        end;
    end;

{$IFNDEF FPC}
  if (StatusActive) and ((IDEOutput) or (ID = 2)) and (DebugHook <> 0) then
    begin
{$IF Defined(WIN32) or Defined(WIN64)}
      OutputDebugString(PWideChar('"' + Text_ + '"'));
{$ELSEIF not Defined(Linux)}
      FMX.Types.Log.d('"' + Text_ + '"');
{$IFEND}
    end;
{$IFEND FPC}
  if (StatusActive) and ((ConsoleOutput) or (ID = 2)) and (IsConsole) then
      Writeln(Text_.Text);
end;

procedure CheckDoStatus(th: TCore_Thread);
var
  i: Integer;
  pSS: PStatusStruct;
begin
  if StatusCritical = nil then
      exit;
  if (th = nil) or (th.ThreadID <> MainThreadID) then
      exit;
  StatusCritical.Acquire;
  try
    if StatusStructList.Count > 0 then
      begin
        for i := 0 to StatusStructList.Count - 1 do
          begin
            pSS := StatusStructList[i];
            _InternalOutput(pSS^.s, pSS^.ID);
            pSS^.s := '';
            Dispose(pSS);
          end;
        StatusStructList.Clear;
      end;
  finally
      StatusCritical.Release;
  end;
end;

procedure DoStatus;
begin
  CheckDoStatus(TCore_Thread.CurrentThread);
end;

procedure InternalDoStatus(Text_: SystemString; const ID: Integer);
var
  th: TCore_Thread;
  pSS: PStatusStruct;
begin
  th := TCore_Thread.CurrentThread;
  if (th = nil) or (th.ThreadID <> MainThreadID) then
    begin
      new(pSS);
      if StatusThreadID then
          pSS^.s := '[' + IntToStr(th.ThreadID) + '] ' + Text_
      else
          pSS^.s := Text_;
      pSS^.th := th;
      pSS^.TriggerTime := GetTimeTick();
      pSS^.ID := ID;
      StatusCritical.Acquire;
      StatusStructList.Add(pSS);
      StatusCritical.Release;
      exit;
    end;

  CheckDoStatus(th);
  _InternalOutput(Text_, ID);
end;

procedure AddDoStatusHook(TokenObj: TCore_Object; OnNotify: TDoStatus_M);
begin
  AddDoStatusHookM(TokenObj, OnNotify);
end;

procedure AddDoStatusHookM(TokenObj: TCore_Object; OnNotify: TDoStatus_M);
var
  p: PStatusProcStruct;
begin
  new(p);
  p^.TokenObj := TokenObj;
  p^.OnStatusM := OnNotify;
  p^.OnStatusC := nil;
  p^.OnStatusP := nil;
  HookStatusProcs.Add(p);
end;

procedure AddDoStatusHookC(TokenObj: TCore_Object; OnNotify: TDoStatus_C);
var
  p: PStatusProcStruct;
begin
  new(p);
  p^.TokenObj := TokenObj;
  p^.OnStatusM := nil;
  p^.OnStatusC := OnNotify;
  p^.OnStatusP := nil;
  HookStatusProcs.Add(p);
end;

procedure AddDoStatusHookP(TokenObj: TCore_Object; OnNotify: TDoStatus_P);
var
  p: PStatusProcStruct;
begin
  new(p);
  p^.TokenObj := TokenObj;
  p^.OnStatusM := nil;
  p^.OnStatusC := nil;
  p^.OnStatusP := OnNotify;
  HookStatusProcs.Add(p);
end;

procedure DeleteDoStatusHook(TokenObj: TCore_Object);
var
  i: Integer;
  p: PStatusProcStruct;
begin
  i := 0;
  while i < HookStatusProcs.Count do
    begin
      p := HookStatusProcs[i];
      if p^.TokenObj = TokenObj then
        begin
          Dispose(p);
          HookStatusProcs.Delete(i);
        end
      else
          inc(i);
    end;
end;

procedure RemoveDoStatusHook(TokenObj: TCore_Object);
begin
  DeleteDoStatusHook(TokenObj);
end;

procedure DisableStatus;
begin
  StatusActive := False;
end;

procedure EnabledStatus;
begin
  StatusActive := True;
end;

procedure DoCheckThreadSynchronize;
begin
  DoStatus();
  if Assigned(Hooked_OnCheckThreadSynchronize) then
      Hooked_OnCheckThreadSynchronize();
end;

procedure _DoInit;
begin
  HookStatusProcs := TStatusProcList.Create;
  StatusStructList := TStatusStructList.Create;
  StatusCritical := TCriticalSection.Create;
  StatusNoLnStructList := TStatusNoLnStructList.Create;

  StatusActive := True;
  LastDoStatus := '';
  IDEOutput := False;
  ConsoleOutput := True;
  OnDoStatusHook := {$IFDEF FPC}@{$ENDIF FPC}InternalDoStatus;
  StatusThreadID := True;

  Hooked_OnCheckThreadSynchronize := Z.Core.OnCheckThreadSynchronize;
  Z.Core.OnCheckThreadSynchronize := {$IFDEF FPC}@{$ENDIF FPC}DoCheckThreadSynchronize;
end;

procedure _DoFree;
var
  i: Integer;
  pSS: PStatusStruct;
begin
  for i := 0 to HookStatusProcs.Count - 1 do
      Dispose(PStatusProcStruct(HookStatusProcs[i]));
  DisposeObject(HookStatusProcs);

  for i := 0 to StatusStructList.Count - 1 do
    begin
      pSS := StatusStructList[i];
      pSS^.s := '';
      Dispose(pSS);
    end;
  DisposeObject(StatusStructList);

  for i := 0 to StatusNoLnStructList.Count - 1 do
      Dispose(StatusNoLnStructList[i]);
  DisposeObject(StatusNoLnStructList);

  DisposeObject(StatusCritical);

  StatusActive := True;
  StatusCritical := nil;
end;

initialization

_DoInit;

finalization

_DoFree;

end.
