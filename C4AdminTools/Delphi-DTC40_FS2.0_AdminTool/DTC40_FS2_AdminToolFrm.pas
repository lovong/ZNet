unit DTC40_FS2_AdminToolFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.Menus, System.Actions, Vcl.ActnList,

  Vcl.FileCtrl,
  System.IOUtils, System.DateUtils, System.TypInfo,

  Z.Core, Z.PascalStrings, Z.UPascalStrings, Z.UnicodeMixedLib, Z.Status,
  Z.ListEngine, Z.GHashList, Z.Expression, Z.OpCode, Z.Parsing, Z.DFE, Z.TextDataEngine,
  Z.Json, Z.Geometry2D, Z.Geometry3D, Z.Number,
  Z.MemoryStream, Z.Cipher, Z.Notify, Z.IOThread,
  Z.Net,
  Z.Net.DoubleTunnelIO,
  Z.Net.DoubleTunnelIO.NoAuth,
  Z.Net.DoubleTunnelIO.VirtualAuth,
  Z.Net.DataStoreService,
  Z.Net.DataStoreService.NoAuth,
  Z.Net.DataStoreService.VirtualAuth,
  Z.Net.DataStoreService.Common,
  Z.ZDB.ObjectData_LIB, Z.ZDB, Z.ZDB.Engine, Z.ZDB.LocalManager,
  Z.ZDB.FileIndexPackage_LIB, Z.ZDB.FilePackage_LIB, Z.ZDB.ItemStream_LIB, Z.ZDB.HashField_LIB, Z.ZDB.HashItem_LIB,
  Z.ZDB2.Custom, Z.ZDB2, Z.ZDB2.DFE, Z.ZDB2.HS, Z.ZDB2.HV, Z.ZDB2.Json, Z.ZDB2.MS64, Z.ZDB2.NM, Z.ZDB2.TE, Z.ZDB2.FileEncoder,
  Z.Net.C4, Z.Net.C4_FS2,
  Z.Net.PhysicsIO;

type
  TDTC40_FS2_AdminToolForm = class(TForm, IC40_PhysicsTunnel_Event)
    logMemo: TMemo;
    botSplitter: TSplitter;
    TopBarPanel: TPanel;
    JoinHostEdit: TLabeledEdit;
    JoinPortEdit: TLabeledEdit;
    DependEdit: TLabeledEdit;
    BuildDependNetButton: TButton;
    resetDependButton: TButton;
    serviceComboBox: TComboBox;
    queryButton: TButton;
    DTC4PasswdEdit: TLabeledEdit;
    netTimer: TTimer;
    cliPanel: TPanel;
    listToolBarPanel: TPanel;
    SearchEdit: TLabeledEdit;
    SearchButton: TButton;
    NumEdit: TLabeledEdit;
    FileListView: TListView;
    UploadFileOpenDialog: TOpenDialog;
    ActionList_: TActionList;
    MainMenu_: TMainMenu;
    File1: TMenuItem;
    Action_UploadFile: TAction;
    UploadFile1: TMenuItem;
    FS_Info_Label: TLabel;
    PopupMenu_: TPopupMenu;
    Action_DownloadFile: TAction;
    Download1: TMenuItem;
    Action_RemoveFile: TAction;
    Removefile1: TMenuItem;
    Download2: TMenuItem;
    Removefile2: TMenuItem;
    UploadFile2: TMenuItem;
    Action_exit: TAction;
    Exit1: TMenuItem;
    IncRefButton: TButton;
    decFileRefButton: TButton;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure netTimerTimer(Sender: TObject);
    procedure queryButtonClick(Sender: TObject);
    procedure DTC4PasswdEditChange(Sender: TObject);
    procedure BuildDependNetButtonClick(Sender: TObject);
    procedure resetDependButtonClick(Sender: TObject);
    procedure FileListViewCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
    procedure SearchButtonClick(Sender: TObject);
    procedure IncRefButtonClick(Sender: TObject);
    procedure decFileRefButtonClick(Sender: TObject);
    procedure Action_DownloadFileExecute(Sender: TObject);
    procedure Action_RemoveFileExecute(Sender: TObject);
    procedure Action_UploadFileExecute(Sender: TObject);
    procedure Action_exitExecute(Sender: TObject);
  private
    procedure DoStatus_backcall(Text_: SystemString; const ID: Integer);
    procedure ReadConfig;
    procedure WriteConfig;
    procedure Do_QueryResult(Sender: TC40_PhysicsTunnel; L: TC40_InfoList);
    procedure DoConnected;
    procedure DoDisconnect;
    function FileItemIsBusy: Boolean;
    procedure Do_FS_Search(Sender: TC40_FS2_Client; arry_: TC40_FS2_Client.TFS2_FileInfo_Array);
    procedure SearchFile(filter: U_String; MaxNum: Integer);
  private
    // IDTC40_PhysicsTunnel_Event
    procedure C40_PhysicsTunnel_Connected(Sender: TC40_PhysicsTunnel);
    procedure C40_PhysicsTunnel_Disconnect(Sender: TC40_PhysicsTunnel);
    procedure C40_PhysicsTunnel_Build_Network(Sender: TC40_PhysicsTunnel; Custom_Client_: TC40_Custom_Client);
    procedure C40_PhysicsTunnel_Client_Connected(Sender: TC40_PhysicsTunnel; Custom_Client_: TC40_Custom_Client);
  public
    ValidService: TC40_InfoList;
    CurrentClient: TC40_FS2_Client;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  DTC40_FS2_AdminToolForm: TDTC40_FS2_AdminToolForm;

implementation

{$R *.dfm}


type
  TFile_Item = class(TListItem)
  public
    FileName: SystemString;
    FileTime: TDateTime;
    FileRef: Integer;
    Size: Int64;
    MD5: TMD5;
    Busy: Boolean;
    SaveDirectory: U_String;
    procedure Do_FS_GetFile_Done(Sender: TC40_FS2_Client; Stream: TMS64; info_: U_String; Successed: Boolean);
    constructor Create(AOwner: TListItems); override;
    destructor Destroy; override;
  end;

constructor TFile_Item.Create(AOwner: TListItems);
begin
  inherited;
  FileName := '';
  FileTime := 0;
  FileRef := 0;
  Size := 0;
  MD5 := NullMD5;
  Busy := False;
  SaveDirectory := '';
end;

destructor TFile_Item.Destroy;
begin
  inherited;
end;

procedure TFile_Item.Do_FS_GetFile_Done(Sender: TC40_FS2_Client; Stream: TMS64; info_: U_String; Successed: Boolean);
var
  fn: SystemString;
begin
  if Successed then
    begin
      SubItems[4] := 'done.';
      fn := umlCombineFileName(SaveDirectory, info_);
      Stream.SaveToFile(fn);
      DoStatus('"%s" download done.', [fn]);
    end
  else
    begin
      SubItems[4] := info_;
    end;
  Busy := False;
end;

procedure TDTC40_FS2_AdminToolForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  WriteConfig;
  CloseAction := caFree;
end;

procedure TDTC40_FS2_AdminToolForm.netTimerTimer(Sender: TObject);
begin
  C40Progress;
end;

procedure TDTC40_FS2_AdminToolForm.queryButtonClick(Sender: TObject);
var
  tunnel_: TC40_PhysicsTunnel;
begin
  tunnel_ := C40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(JoinHostEdit.Text, EStrToInt(JoinPortEdit.Text, 0));
  tunnel_.QueryInfoM(Do_QueryResult);
end;

procedure TDTC40_FS2_AdminToolForm.DTC4PasswdEditChange(Sender: TObject);
begin
  Z.Net.C4.C40_Password := DTC4PasswdEdit.Text;
end;

procedure TDTC40_FS2_AdminToolForm.BuildDependNetButtonClick(Sender: TObject);
var
  info: TC40_Info;
begin
  if serviceComboBox.ItemIndex < 0 then
      exit;
  info := TC40_Info(serviceComboBox.Items.Objects[serviceComboBox.ItemIndex]);
  Z.Net.C4.C40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(info, info.ServiceTyp, self);
end;

procedure TDTC40_FS2_AdminToolForm.resetDependButtonClick(Sender: TObject);
begin
  C40Clean;
end;

procedure TDTC40_FS2_AdminToolForm.FileListViewCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TFile_Item;
end;

procedure TDTC40_FS2_AdminToolForm.SearchButtonClick(Sender: TObject);
begin
  SearchFile(SearchEdit.Text, EStrToInt(NumEdit.Text, 100));
end;

procedure TDTC40_FS2_AdminToolForm.IncRefButtonClick(Sender: TObject);
var
  i: Integer;
  itm: TFile_Item;
begin
  if CurrentClient = nil then
      exit;
  if FileListView.SelCount <= 0 then
      exit;

  for i := 0 to FileListView.Items.Count - 1 do
    begin
      itm := FileListView.Items[i] as TFile_Item;
      if itm.Selected then
        begin
          CurrentClient.FS2_IncFileRef(itm.FileName, 1);
        end;
    end;
end;

procedure TDTC40_FS2_AdminToolForm.decFileRefButtonClick(Sender: TObject);
var
  i: Integer;
  itm: TFile_Item;
begin
  if CurrentClient = nil then
      exit;
  if FileListView.SelCount <= 0 then
      exit;

  for i := 0 to FileListView.Items.Count - 1 do
    begin
      itm := FileListView.Items[i] as TFile_Item;
      if itm.Selected then
        begin
          CurrentClient.FS2_IncFileRef(itm.FileName, -1);
        end;
    end;
end;

procedure TDTC40_FS2_AdminToolForm.Action_DownloadFileExecute(Sender: TObject);
var
  d: string;
  i: Integer;
  itm: TFile_Item;
begin
  if CurrentClient = nil then
      exit;
  if FileListView.SelCount <= 0 then
      exit;
  d := TPath.GetLibraryPath;
  if not SelectDirectory('download to.', '', d, [sdNewFolder, sdNewUI]) then
      exit;

  for i := 0 to FileListView.Items.Count - 1 do
    begin
      itm := FileListView.Items[i] as TFile_Item;
      if itm.Selected then
        begin
          itm.Busy := True;
          itm.SaveDirectory := d;
          CurrentClient.FS2_GetFile_M(True, itm.FileName, itm.Do_FS_GetFile_Done);
          itm.SubItems[3] := 'busy.';
        end;
    end;
end;

procedure TDTC40_FS2_AdminToolForm.Action_RemoveFileExecute(Sender: TObject);
var
  i: Integer;
  itm: TFile_Item;
begin
  if CurrentClient = nil then
      exit;
  if FileListView.SelCount <= 0 then
      exit;
  if MessageDlg('remove?', mtWarning, [mbYes, mbNo], 0) <> mrYes then
      exit;

  for i := 0 to FileListView.Items.Count - 1 do
    begin
      itm := FileListView.Items[i] as TFile_Item;
      if itm.Selected then
        begin
          CurrentClient.FS2_RemoveFile(itm.FileName);
        end;
    end;
end;

procedure TDTC40_FS2_AdminToolForm.Action_UploadFileExecute(Sender: TObject);
var
  i: Integer;
  fn: U_String;
  fs: TCore_FileStream;
begin
  if CurrentClient = nil then
      exit;
  if not UploadFileOpenDialog.Execute then
      exit;

  for i := 0 to UploadFileOpenDialog.Files.Count - 1 do
    begin
      fn := UploadFileOpenDialog.Files[i];
      if umlGetFileSize(fn) < CurrentClient.MaxFileSize then
        begin
          fs := TCore_FileStream.Create(fn, fmOpenRead or fmShareDenyNone);
          CurrentClient.FS2_PostFile_P(umlGetFileName(fn), fs, True, procedure(Sender: TC40_FS2_Client; info_: U_String)
            begin
              DoStatus('"%s" upload done.', [info_.Text]);
            end);
        end
      else
          DoStatus('The %s file size > remote file limit: %d', [fn.Text, CurrentClient.MaxFileSize]);
    end;
end;

procedure TDTC40_FS2_AdminToolForm.Action_exitExecute(Sender: TObject);
begin
  Close;
end;

procedure TDTC40_FS2_AdminToolForm.DoStatus_backcall(Text_: SystemString; const ID: Integer);
begin
  if logMemo.Lines.Count > 2000 then
      logMemo.Clear;
  logMemo.Lines.Add(DateTimeToStr(now) + ' ' + Text_);
end;

procedure TDTC40_FS2_AdminToolForm.ReadConfig;
var
  fn: U_String;
  TE: THashTextEngine;
begin
  fn := umlChangeFileExt(Application.ExeName, '.conf');
  if not umlFileExists(fn) then
      exit;
  TE := THashTextEngine.Create;
  TE.LoadFromFile(fn);
  JoinHostEdit.Text := TE.GetDefaultValue('Main', JoinHostEdit.Name, JoinHostEdit.Text);
  JoinPortEdit.Text := TE.GetDefaultValue('Main', JoinPortEdit.Name, JoinPortEdit.Text);
  DisposeObject(TE);
end;

procedure TDTC40_FS2_AdminToolForm.WriteConfig;
var
  fn: U_String;
  TE: THashTextEngine;
begin
  fn := umlChangeFileExt(Application.ExeName, '.conf');

  TE := THashTextEngine.Create;

  TE.SetDefaultValue('Main', JoinHostEdit.Name, JoinHostEdit.Text);
  TE.SetDefaultValue('Main', JoinPortEdit.Name, JoinPortEdit.Text);

  TE.SaveToFile(fn);
  DisposeObject(TE);
end;

procedure TDTC40_FS2_AdminToolForm.Do_QueryResult(Sender: TC40_PhysicsTunnel; L: TC40_InfoList);
var
  arry: TC40_Info_Array;
  i: Integer;
begin
  arry := L.SearchService(ExtractDependInfo(DependEdit.Text));
  for i := low(arry) to high(arry) do
      ValidService.Add(arry[i].Clone);

  serviceComboBox.Clear;
  for i := 0 to ValidService.Count - 1 do
      serviceComboBox.AddItem(Format('"%s" host "%s" port %d', [ValidService[i].ServiceTyp.Text, ValidService[i].PhysicsAddr.Text, ValidService[i].PhysicsPort]), ValidService[i]);

  if serviceComboBox.Items.Count > 0 then
      serviceComboBox.ItemIndex := 0;
end;

procedure TDTC40_FS2_AdminToolForm.DoConnected;
begin
  SearchButtonClick(SearchButton);
  FS_Info_Label.Caption := Format('Done connection. Max File size is %s for "%s" Service.',
    [umlSizeToStr(CurrentClient.MaxFileSize).Text, CurrentClient.ClientInfo.ServiceTyp.Text]);
end;

procedure TDTC40_FS2_AdminToolForm.DoDisconnect;
begin
  FS_Info_Label.Caption := 'No connection.';
  SysPost.PostExecuteP_NP(1.0, procedure
    begin
      serviceComboBox.Clear;
      FileListView.Clear;
    end);
end;

function TDTC40_FS2_AdminToolForm.FileItemIsBusy: Boolean;
var
  itm: TFile_Item;
  i: Integer;
begin
  Result := True;
  for i := 0 to FileListView.Items.Count - 1 do
    begin
      itm := FileListView.Items[i] as TFile_Item;
      if itm.Busy then
          exit;
    end;
  Result := False;
end;

procedure TDTC40_FS2_AdminToolForm.Do_FS_Search(Sender: TC40_FS2_Client; arry_: TC40_FS2_Client.TFS2_FileInfo_Array);
var
  itm: TFile_Item;
  i: Integer;
begin
  FileListView.Items.BeginUpdate;
  FileListView.Items.Clear;
  for i := 0 to length(arry_) - 1 do
    begin
      itm := FileListView.Items.Add as TFile_Item;
      itm.FileName := arry_[i].FileName;
      itm.FileTime := arry_[i].FileTime;
      itm.FileRef := arry_[i].FileRef;
      itm.Size := arry_[i].Size;
      itm.MD5 := arry_[i].MD5;
      itm.Caption := IntToStr(i) + ' - ' + itm.FileName;
      itm.SubItems.Add(DateTimeToStr(itm.FileTime));
      itm.SubItems.Add(umlSizeToStr(itm.Size));
      itm.SubItems.Add(umlMD5ToStr(itm.MD5));
      itm.SubItems.Add(umlIntToStr(itm.FileRef));
      itm.SubItems.Add('idle');
    end;
  FileListView.Items.EndUpdate;
  FileListView.Height := FileListView.Height - 1;
end;

procedure TDTC40_FS2_AdminToolForm.SearchFile(filter: U_String; MaxNum: Integer);
begin
  if CurrentClient = nil then
      exit;
  if FileItemIsBusy then
      DoStatus('download is busy.');
  CurrentClient.FS2_SearchM(filter, MaxNum, Do_FS_Search);
end;

procedure TDTC40_FS2_AdminToolForm.C40_PhysicsTunnel_Connected(Sender: TC40_PhysicsTunnel);
begin

end;

procedure TDTC40_FS2_AdminToolForm.C40_PhysicsTunnel_Disconnect(Sender: TC40_PhysicsTunnel);
begin
  if Sender.DependNetworkClientPool.IndexOf(CurrentClient) >= 0 then
    begin
      DoDisconnect;
      ValidService.Clear;
      CurrentClient := nil;
    end;
end;

procedure TDTC40_FS2_AdminToolForm.C40_PhysicsTunnel_Build_Network(Sender: TC40_PhysicsTunnel; Custom_Client_: TC40_Custom_Client);
begin

end;

procedure TDTC40_FS2_AdminToolForm.C40_PhysicsTunnel_Client_Connected(Sender: TC40_PhysicsTunnel; Custom_Client_: TC40_Custom_Client);
var
  info: TC40_Info;
begin
  if serviceComboBox.ItemIndex < 0 then
      exit;
  info := TC40_Info(serviceComboBox.Items.Objects[serviceComboBox.ItemIndex]);
  if info.Same(Custom_Client_.ClientInfo) and (Custom_Client_ is TC40_FS2_Client) then
    begin
      CurrentClient := TC40_FS2_Client(Custom_Client_);
      SysPost.PostExecuteM_NP(0.5, DoConnected);
    end;
end;

constructor TDTC40_FS2_AdminToolForm.Create(AOwner: TComponent);
var
  i: Integer;
  p: PC40_RegistedData;
  depend_: U_String;
begin
  inherited Create(AOwner);
  C40_QuietMode := False;
  AddDoStatusHook(self, DoStatus_backcall);

  DTC4PasswdEdit.Text := Z.Net.C4.C40_Password;
  ReadConfig;
  ValidService := TC40_InfoList.Create(True);
  CurrentClient := nil;

  depend_ := '';
  for i := 0 to C40_Registed.Count - 1 do
    begin
      p := C40_Registed[i];
      if p^.ClientClass.InheritsFrom(TC40_FS2_Client) then
        begin
          if depend_.L > 0 then
              depend_.Append('|');
          depend_.Append(p^.ServiceTyp);
        end;
    end;
  DependEdit.Text := depend_;
end;

destructor TDTC40_FS2_AdminToolForm.Destroy;
begin
  C40Clean;
  RemoveDoStatusHook(self);
  inherited Destroy;
end;

end.
