type
  MPtrUInt = nativeUInt;
  MPtr = Pointer;
  PMPtrUInt = ^MPtrUInt;

var
  OriginMM: TMemoryManagerEx;
  HookMM: TMemoryManagerEx;
  CurrentHookThread: TCore_Thread;

procedure BeginMemoryHook;
begin
  if (MemoryHooked.V) or (CurrentHookThread <> nil) then
      RaiseInfo('illegal BeginMemoryHook');

  CurrentHookThread := TCore_Thread.CurrentThread;
  HookPtrList.FastClear;
  MemoryHooked.V := True;
end;

procedure BeginMemoryHook(cacheLen: Integer);
begin
  if (MemoryHooked.V) or (CurrentHookThread <> nil) then
      RaiseInfo('illegal BeginMemoryHook');

  CurrentHookThread := TCore_Thread.CurrentThread;
  if length(HookPtrList.ListBuffer^) <> cacheLen then
      HookPtrList.SetHashBlockCount(cacheLen)
  else
      HookPtrList.FastClear;

  MemoryHooked.V := True;
end;

procedure EndMemoryHook;
begin
  if not MemoryHooked.V then
      RaiseInfo('illegal EndMemoryHook');

  MemoryHooked.V := False;
  CurrentHookThread := nil;
end;

function GetHookMemorySize: nativeUInt;
begin
  Result := HookPtrList.Total;
end;

function GetHookMemorySize(p: Pointer): nativeUInt;
begin
  Result := HookPtrList[p];
end;

function GetHookMemoryMinimizePtr: Pointer;
begin
  Result := HookPtrList.MinimizePtr;
end;

function GetHookMemoryMaximumPtr: Pointer;
begin
  Result := HookPtrList.MaximumPtr;
end;

function GetHookPtrList: TPointerHashNativeUIntList;
begin
  Result := HookPtrList;
end;

function GetMemoryHooked: TAtomBool;
begin
  Result := MemoryHooked;
end;

function Hash_GetMem(Size: NativeInt): MPtr;
begin
  Result := OriginMM.GetMem(DeltaStep(Size, C_MH_MemoryDelta));
  if (not MemoryHooked.V) or (not GlobalMemoryHook.V) or (Result = nil) or (CurrentHookThread <> TCore_Thread.CurrentThread) then
      Exit;
  MemoryHooked.V := False;
  GlobalMemoryHook.V := False;
  HookPtrList.Add(Result, Size, False);
  MemoryHooked.V := True;
  GlobalMemoryHook.V := True;
end;

function Hash_FreeMem(p: MPtr): Integer;
begin
  Result := OriginMM.FreeMem(p);
  if (not MemoryHooked.V) or (not GlobalMemoryHook.V) or (p = nil) or (CurrentHookThread <> TCore_Thread.CurrentThread) then
      Exit;
  MemoryHooked.V := False;
  GlobalMemoryHook.V := False;
  HookPtrList.Delete(p);
  MemoryHooked.V := True;
  GlobalMemoryHook.V := True;
end;

function Hash_ReallocMem(p: MPtr; Size: NativeInt): MPtr;
begin
  Result := OriginMM.ReallocMem(p, DeltaStep(Size, C_MH_MemoryDelta));
  if (not MemoryHooked.V) or (not GlobalMemoryHook.V) or (CurrentHookThread <> TCore_Thread.CurrentThread) then
      Exit;
  MemoryHooked.V := False;
  GlobalMemoryHook.V := False;
  if p <> nil then
    begin
      if HookPtrList.Delete(p) then
        if Result <> nil then
            HookPtrList.Add(Result, Size, False);
    end
  else if Result <> nil then
      HookPtrList.Add(Result, Size, False);
  MemoryHooked.V := True;
  GlobalMemoryHook.V := True;
end;

function Hash_AllocMem(Size: NativeInt): MPtr;
begin
  Result := OriginMM.AllocMem(DeltaStep(Size, C_MH_MemoryDelta));
  if (not MemoryHooked.V) or (not GlobalMemoryHook.V) or (Result = nil) or (CurrentHookThread <> TCore_Thread.CurrentThread) then
      Exit;
  MemoryHooked.V := False;
  GlobalMemoryHook.V := False;
  HookPtrList.Add(Result, Size, False);
  MemoryHooked.V := True;
  GlobalMemoryHook.V := True;
end;

procedure InstallMemoryHook;
begin
  HookPtrList := TPointerHashNativeUIntList.CustomCreate(32);
  CurrentHookThread := nil;

  GetMemoryManager(OriginMM);
  HookMM := OriginMM;

  MemoryHooked := TAtomBool.Create(False);

  HookMM.GetMem := Hash_GetMem;
  HookMM.FreeMem := Hash_FreeMem;
  HookMM.ReallocMem := Hash_ReallocMem;
  HookMM.AllocMem := Hash_AllocMem;

  SetMemoryManager(HookMM);
end;

procedure UnInstallMemoryHook;
begin
  SetMemoryManager(OriginMM);
  DisposeObject(HookPtrList);
  MemoryHooked.Free;
  MemoryHooked := nil;
end;
