program SisHelpDesk;

uses
  IWRtlFix,
  IWJclStackTrace,
  IWJclDebug,
  Forms,
  IWStart,
  U_FrmLogin in 'U_FrmLogin.pas' {FrmLogin: TIWAppForm},
  ServerController in 'ServerController.pas' {IWServerController: TIWServerControllerBase},
  UserSessionUnit in 'UserSessionUnit.pas' {IWUserSession: TIWUserSessionBase},
  Extenso in 'Extenso.pas',
  funcoes in 'funcoes.PAS',
  SweetAlerts in 'SweetAlerts.pas',
  U_DM in 'U_DM.pas' {DM: TDataModule},
  U_FrmPadrao in 'U_FrmPadrao.pas' {FrmPadrao: TIWAppForm},
  U_FrmIndex in 'U_FrmIndex.pas' {FrmIndex: TIWAppForm},
  U_FrmConfiguracoes in 'U_FrmConfiguracoes.pas' {FrmConfiguracoes: TIWAppForm},
  U_FrmClientes in 'U_FrmClientes.pas' {FrmClientes: TIWAppForm},
  U_FrmFuncionarios in 'U_FrmFuncionarios.pas' {FrmFuncionarios: TIWAppForm},
  U_FrmProdutos in 'U_FrmProdutos.pas' {FrmProdutos: TIWAppForm},
  U_FrmSolicitacoes in 'U_FrmSolicitacoes.pas' {FrmSolicitacoes: TIWAppForm},
  U_FrmAcompChamados in 'U_FrmAcompChamados.pas' {FrmAcompChamados: TIWAppForm},
  U_FrmPesquisar in 'U_FrmPesquisar.pas' {FrmPesquisar: TIWAppForm},
  U_FrmIndexCliente in 'U_FrmIndexCliente.pas' {FrmIndexCliente: TIWAppForm},
  U_FrmClientesDBGrid in 'U_FrmClientesDBGrid.pas' {FrmClientesDBGrid: TIWAppForm};

{$R *.res}

begin
  TIWStart.Execute(True);
end.
