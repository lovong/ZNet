program _3_UserDB_Service;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  System.SysUtils,
  Z.Core,
  Z.PascalStrings,
  Z.UnicodeMixedLib,
  Z.Notify,
  Z.Status,
  Z.Net,
  Z.Net.PhysicsIO,
  Z.Net.C4,
  Z.Net.C4_FS,
  Z.Net.C4_UserDB,
  Z.Net.C4_Var;

const
  // 调度服务器端口公网地址,可以是ipv4,ipv6,dns
  // 公共地址,不能给127.0.0.1这类
  Internet_DP_Addr_ = '127.0.0.1';
  // 调度服务器端口
  Internet_DP_Port_ = 8387;

  // 本地服务器公网地址
  Internet_LocalService_Addr_ = '127.0.0.1';
  Internet_LocalService_Port_ = 8385;

var
  FS: TC40_FS_Client = nil;

type
  // C4网络是扩散式的,一个链接会爬取出许多关联的链接,使用接口来监听
  TMonitorMySAAS = class(TCore_InterfacedObject, IC40_PhysicsTunnel_Event)
    procedure C40_PhysicsTunnel_Connected(Sender: TC40_PhysicsTunnel);
    procedure C40_PhysicsTunnel_Disconnect(Sender: TC40_PhysicsTunnel);
    procedure C40_PhysicsTunnel_Build_Network(Sender: TC40_PhysicsTunnel; Custom_Client_: TC40_Custom_Client);
    procedure C40_PhysicsTunnel_Client_Connected(Sender: TC40_PhysicsTunnel; Custom_Client_: TC40_Custom_Client);
  end;

procedure TMonitorMySAAS.C40_PhysicsTunnel_Connected(Sender: TC40_PhysicsTunnel);
begin
  // 创建物理链接
end;

procedure TMonitorMySAAS.C40_PhysicsTunnel_Disconnect(Sender: TC40_PhysicsTunnel);
begin
  // 物理链接中断
  if Sender.DependNetworkClientPool.IndexOf(FS) >= 0 then
      FS := nil;
end;

procedure TMonitorMySAAS.C40_PhysicsTunnel_Build_Network(Sender: TC40_PhysicsTunnel; Custom_Client_: TC40_Custom_Client);
begin
  // 创建p2pVM隧道
end;

procedure TMonitorMySAAS.C40_PhysicsTunnel_Client_Connected(Sender: TC40_PhysicsTunnel; Custom_Client_: TC40_Custom_Client);
begin
  // p2pVM隧道握手完成
  if Custom_Client_ is TC40_FS_Client then
    begin
      FS := Custom_Client_ as TC40_FS_Client;
      DoStatus('已找到文件支持服务: %s', [Custom_Client_.ClientInfo.ServiceTyp.Text]);
    end;
end;

begin
  // 打开Log信息
  Z.Net.C4.C40_QuietMode := False;

  // 创建dp和用户数据库服务
  with Z.Net.C4.TC40_PhysicsService.Create(Internet_LocalService_Addr_, Internet_LocalService_Port_, Z.Net.PhysicsIO.TPhysicsServer.Create) do
    begin
      BuildDependNetwork('dp|UserDB');
      StartService;
    end;

  // 接通调度端和文件服务
  Z.Net.C4.C40_PhysicsTunnelPool.GetOrCreatePhysicsTunnel(Internet_DP_Addr_, Internet_DP_Port_, 'dp|FS', TMonitorMySAAS.Create);
  FS := nil;

  // 主循环
  while True do
    begin
      Z.Net.C4.C40Progress;
      TCompute.Sleep(1);
    end;

end.
