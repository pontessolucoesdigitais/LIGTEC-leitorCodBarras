unit U_FrmIndexCliente;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, U_FrmPadrao, IWVCLComponent,
  IWBaseLayoutComponent, IWBaseContainerLayout, IWContainerLayout,
  IWTemplateProcessorHTML, IWCompButton, IWVCLBaseControl, IWBaseControl,
  IWBaseHTMLControl, IWControl, IWCompEdit, IWCompLabel, IWCompMemo,
  IWDBStdCtrls, Data.DB, IWCompListbox;

type
  TFrmIndexCliente = class(TFrmPadrao)
    PesquisaProblema: TIWEdit;
    PesquisaSolucao: TIWEdit;
    Chamados: TIWLabel;
    Pesquisa: TIWLabel;
    BTNSENHA: TIWButton;
    SenhaAtual: TIWEdit;
    NovaSenha: TIWEdit;
    NovaSenha2: TIWEdit;
    IDSOLICITACAO: TIWDBLookupComboBox;
    IDPRODUTO: TIWDBLookupComboBox;
    NOMESOLICITANTE: TIWDBEdit;
    dsChamado: TDataSource;
    dsSolicitacao: TDataSource;
    dsProdutos: TDataSource;
    DEPTOSOLICITANTE: TIWDBEdit;
    DESCRICAOSOLICITACAO: TIWDBMemo;
    PRIORIDADE: TIWDBComboBox;
    BtnCancelar: TIWButton;
    BtnGravar: TIWButton;
    procedure IWBTNACAOAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure IWAppFormCreate(Sender: TObject);
    procedure BTNSENHAClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure IWAppFormDestroy(Sender: TObject);
    procedure BtnGravarClick(Sender: TObject);
  private
    { Private declarations }
    procedure MontaChamadosAbertos;
    procedure MontaChamadosFechados;
  public
    { Public declarations }
  end;

var
  FrmIndexCliente: TFrmIndexCliente;

implementation

{$R *.dfm}

uses ServerController, SweetAlerts;

procedure TFrmIndexCliente.MontaChamadosAbertos;
var
  html, xPrioridade : string;
  i, Abertos, Fechados : Integer;
begin
  //
  // Verifica a qtde de chamados abertos e fechados
  //
  Controller.DM.FDQQuery.Close;
  Controller.DM.FDQQuery.SQL.Clear;
  Controller.DM.FDQQuery.SQL.Add('Select Situacao, Count(*) as Total from Chamados ');
  Controller.DM.FDQQuery.SQL.Add('Where IDCLIENTE = '+Controller.xCodCliente.ToString);
  Controller.DM.FDQQuery.SQL.Add('Group by Situacao ');
  Controller.DM.FDQQuery.SQL.Add('Order by Situacao ');
  Controller.DM.FDQQuery.Open();

  Abertos  := 0;
  Fechados := 0;

  Controller.DM.FDQQuery.First;
  while not Controller.DM.FDQQuery.Eof do
  begin
    if Controller.DM.FDQQuery.FieldByName('Situacao').AsString = 'Aberto' then
      Abertos := Controller.DM.FDQQuery.FieldByName('Total').AsInteger;
    if Controller.DM.FDQQuery.FieldByName('Situacao').AsString = 'Fechado' then
      Fechados := Controller.DM.FDQQuery.FieldByName('Total').AsInteger;

    Controller.DM.FDQQuery.Next;
  end;
  Controller.DM.FDQQuery.Close;

  html := '';
  html := html + '    <div class="box box-primary"> ' + SLineBreak;
  html := html + '        <div class="box-header with-border"> ' + SLineBreak;
  html := html + '            <h3 class="box-title"><i class="fa fa-commenting-o"></i> Listagem dos Chamados em Aberto</h3> ' + SLineBreak;
  html := html + '            <div class="box-tools pull-right"> ' + SLineBreak;
  html := html + '                <div class="btn-group"> ' + SLineBreak;
  html := html + '                    <button type="buttom" class="btn btn-primary btn-sm" onclick="SetaAcao(''Inclu'', '''');"> ' + SLineBreak;
  html := html + '                        <i class="fa fa-plus" aria-hidden="true"></i><span class="hidden-xs hidden-sm"> Cadastrar</span> ' + SLineBreak;
  html := html + '                    </button> ' + SLineBreak;
  html := html + '                </div> ' + SLineBreak;
  html := html + '            </div> ' + SLineBreak;
  html := html + '        </div> ' + SLineBreak;
  html := html + '        <div class="box-body"> ' + SLineBreak;
  html := html + '            <div class="row"> ' + SLineBreak;
  html := html + '                <div class="col-xs-12" align="center"> ' + SLineBreak;
  html := html + '                    <a href="javascript: SetaAcao(''Abert'', '''');"> ' + SLineBreak;
  html := html + '                        <span data-toggle="tooltip" title="Clique para visualizar" class="badge bg-blue">'+Controller.iif(Abertos > 0, Abertos.ToString+' Novos Chamados','N�o h� Novos Chamados')+'</span> ' + SLineBreak;
  html := html + '                    </a> ' + SLineBreak;
  html := html + '                    <a href="javascript: SetaAcao(''Fecha'', '''');"> ' + SLineBreak;
  html := html + '                        <span data-toggle="tooltip" title="Clique para visualizar" class="badge bg-red">'+Controller.iif(Fechados > 0, Fechados.ToString+' Chamados Fechados','N�o h� Chamados Fechados')+'</span> ' + SLineBreak;
  html := html + '                    </a> ' + SLineBreak;
  html := html + '                </div> ' + SLineBreak;
  html := html + '            </div> ' + SLineBreak;
  html := html + '            <div class="box-group" id="accordion"> ' + SLineBreak;
  html := html + '                <br /> ' + SLineBreak;

  //
  // Monta todos os chamados 1 a 1
  //
  Controller.DM.FDQQuery.Close;
  Controller.DM.FDQQuery.SQL.Clear;
  Controller.DM.FDQQuery.SQL.Add('Select c.*, cl.RazaoSocial, cl.email, cl.fonefixo, cl.fonecelular, s.descricao as NomeSolicitacao, ');
  Controller.DM.FDQQuery.SQL.Add('       p.descricao as NomeProduto, f.nomefuncionario ');
  Controller.DM.FDQQuery.SQL.Add('from Chamados c left join ');
  Controller.DM.FDQQuery.SQL.Add('     Clientes cl on c.idcliente = cl.idcliente left join ');
  Controller.DM.FDQQuery.SQL.Add('     Solicitacoes s on c.idsolicitacao = s.idsolicitacao left join ');
  Controller.DM.FDQQuery.SQL.Add('     Produtos p on c.idproduto = p.idproduto left join ');
  Controller.DM.FDQQuery.SQL.Add('     Funcionarios f on c.idfuncionariosolucao = f.idfuncionario ');
  Controller.DM.FDQQuery.SQL.Add('Where c.IDCliente = '+Controller.xCodCliente.ToString+' and c.Situacao = ''Aberto'' ');
  Controller.DM.FDQQuery.SQL.Add('Order by Cast(DataHoraAbertura as Date) desc, Prioridade, IDChamado ');
  Controller.DM.FDQQuery.Open();

  i := 1;
  Controller.DM.FDQQuery.First;
  while not Controller.DM.FDQQuery.Eof do
  begin
    if Controller.DM.FDQQuery.FieldByName('Prioridade').AsString = 'Alta' then
      xPrioridade := 'bg-red';
    if Controller.DM.FDQQuery.FieldByName('Prioridade').AsString = 'Media' then
      xPrioridade := 'bg-yellow';
    if Controller.DM.FDQQuery.FieldByName('Prioridade').AsString = 'Baixa' then
      xPrioridade := 'bg-aqua-active';


    html := html + '                <div class="panel box box-primary"> ' + SLineBreak;
    html := html + '                    <div class="box-header with-border"> ' + SLineBreak;
    html := html + '                        <h4 class="box-title"> ' + SLineBreak;
    html := html + '                            <a data-toggle="collapse" data-parent="#accordion" href="#collapse'+i.ToString+'"> ' + SLineBreak;
    html := html + '                                <span data-toggle="tooltip" title="Prioridade" class="badge '+xPrioridade+'">'+Controller.DM.FDQQuery.FieldByName('Prioridade').AsString+'</span>&nbsp;&nbsp;<br class="hidden-sm hidden-md hidden-lg" /> ' + SLineBreak;
    html := html + '                                <span data-toggle="tooltip" title="Data e Hora Abertura do Chamado"> ' + SLineBreak;
    html := html + '                                    <i class="fa fa-fw fa-calendar"></i> '+FormatDateTime('dd/mm/yy hh:nn', Controller.DM.FDQQuery.FieldByName('DataHoraAbertura').AsDateTime)+' &nbsp;&nbsp;&nbsp;&nbsp;<br class="hidden-sm hidden-md hidden-lg" /> ' + SLineBreak;
    html := html + '                                </span> ' + SLineBreak;
    html := html + '                                <span data-toggle="tooltip" title="Nome do M�dulo do Sistema"> ' + SLineBreak;
    html := html + '                                    <i class="fa fa-fw fa-laptop"></i> '+Controller.DM.FDQQuery.FieldByName('NomeProduto').AsString+' &nbsp;&nbsp;&nbsp;&nbsp;<br class="hidden-sm hidden-lg" /> ' + SLineBreak;
    html := html + '                                </span> ' + SLineBreak;
    html := html + '                                <span data-toggle="tooltip" title="Nome do Usu�rio"> ' + SLineBreak;
    html := html + '                                    <i class="fa fa-fw fa-user"></i> '+Controller.DM.FDQQuery.FieldByName('NOMESOLICITANTE').AsString+' ' + SLineBreak;
    html := html + '                                </span> ' + SLineBreak;
    html := html + '                            </a> ' + SLineBreak;
    html := html + '                        </h4> ' + SLineBreak;
    html := html + '                    </div> ' + SLineBreak;
    html := html + '                    <div id="collapse'+i.ToString+'" class="panel-collapse collapse"> ' + SLineBreak;
    html := html + '                        <div class="box-body"> ' + SLineBreak;
//    html := html + '                            <br /> ' + SLineBreak;
    html := html + '                            <div class="box box-primary"> ' + SLineBreak;
    html := html + '                                <div class="box-header with-border"> ' + SLineBreak;
    html := html + '                                    <h3 class="box-title">Dados do Chamado</h3> ' + SLineBreak;
    html := html + '                                </div> ' + SLineBreak;
    html := html + '                                <div class="box-body"> ' + SLineBreak;
    html := html + '                                    <dl class="dl-horizontal"> ' + SLineBreak;
    html := html + '                                        <dt>Prioridade:</dt> ' + SLineBreak;
    html := html + '                                        <dd><span class="badge '+xPrioridade+'">'+Controller.DM.FDQQuery.FieldByName('Prioridade').AsString+'</span></dd> ' + SLineBreak;
    html := html + '                                        <br /> ' + SLineBreak;
    html := html + '                                        <dt>N� Chamado:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('IDChamado').AsString+'</dd> ' + SLineBreak;
    html := html + '                                        <dt>Cliente:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('RazaoSocial').AsString+'</dd> ' + SLineBreak;
    html := html + '                                        <dt>Data / Hora Abertura:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+FormatDateTime('dd/mm/yyyy hh:nn:ss', Controller.DM.FDQQuery.FieldByName('DataHoraAbertura').AsDateTime)+' hs</dd> ' + SLineBreak;
    html := html + '                                        <br /> ' + SLineBreak;
    html := html + '                                        <dt>Nome Solicitante:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('NomeSolicitante').AsString+'</dd> ' + SLineBreak;
    html := html + '                                        <dt>Depto Solicitante:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('DeptoSolicitante').AsString+'</dd> ' + SLineBreak;
    html := html + '                                        <br /> ' + SLineBreak;
    html := html + '                                        <dt>Solicita��o:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('NomeSolicitacao').AsString+'</dd> ' + SLineBreak;
    html := html + '                                        <dt>Produto:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('NomeProduto').AsString+'</dd> ' + SLineBreak;
    html := html + '                                        <br /> ' + SLineBreak;
    html := html + '                                        <dt>Descri��o do Problema:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('DescricaoSolicitacao').AsString+'</dd> ' + SLineBreak;
    html := html + '                                        <br /> ' + SLineBreak;
    html := html + '                                        <dt>Solu��o:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('SolucaoSolicitacao').AsString+'</dd> ' + SLineBreak;
    html := html + '                                        <br /> ' + SLineBreak;
    html := html + '                                        <dt>Nome do Atendente:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('NomeFuncionario').AsString+'</dd> ' + SLineBreak;
    html := html + '                                    </dl> ' + SLineBreak;
    html := html + '                                </div> ' + SLineBreak;
    html := html + '                            </div> ' + SLineBreak;
    html := html + '                        </div> ' + SLineBreak;
    html := html + '                    </div> ' + SLineBreak;
    html := html + '                </div> ' + SLineBreak;

    i := i + 1;
    Controller.DM.FDQQuery.Next;
  end;
  Controller.DM.FDQQuery.Close;

  html := html + '            </div> ' + SLineBreak;
  html := html + '        </div> ' + SLineBreak;
  html := html + '    </div> ' + SLineBreak;

  Chamados.Caption := html;
end;


procedure TFrmIndexCliente.MontaChamadosFechados;
var
  html, xPrioridade : string;
  i, Abertos, Fechados : Integer;
begin
  //
  // Verifica a qtde de chamados abertos e fechados
  //
  Controller.DM.FDQQuery.Close;
  Controller.DM.FDQQuery.SQL.Clear;
  Controller.DM.FDQQuery.SQL.Add('Select Situacao, Count(*) as Total from Chamados ');
  Controller.DM.FDQQuery.SQL.Add('Group by Situacao ');
  Controller.DM.FDQQuery.SQL.Add('Order by Situacao ');
  Controller.DM.FDQQuery.Open();

  Abertos  := 0;
  Fechados := 0;

  Controller.DM.FDQQuery.First;
  while not Controller.DM.FDQQuery.Eof do
  begin
    if Controller.DM.FDQQuery.FieldByName('Situacao').AsString = 'Aberto' then
      Abertos := Controller.DM.FDQQuery.FieldByName('Total').AsInteger;
    if Controller.DM.FDQQuery.FieldByName('Situacao').AsString = 'Fechado' then
      Fechados := Controller.DM.FDQQuery.FieldByName('Total').AsInteger;

    Controller.DM.FDQQuery.Next;
  end;
  Controller.DM.FDQQuery.Close;

  html := '';
  html := html + '    <div class="box box-danger"> ' + SLineBreak;
  html := html + '        <div class="box-header with-border"> ' + SLineBreak;
  html := html + '            <h3 class="box-title"><i class="fa fa-commenting-o"></i> Listagem dos Chamados j� Fechados</h3> ' + SLineBreak;
  html := html + '        </div> ' + SLineBreak;
  html := html + '        <div class="box-body"> ' + SLineBreak;
  html := html + '            <div class="row"> ' + SLineBreak;
  html := html + '                <div class="col-xs-12" align="center"> ' + SLineBreak;
  html := html + '                    <a href="javascript: SetaAcao(''Abert'', '''');"> ' + SLineBreak;
  html := html + '                        <span data-toggle="tooltip" title="Clique para visualizar" class="badge bg-blue">'+Controller.iif(Abertos > 0, Abertos.ToString+' Novos Chamados','N�o h� Novos Chamados')+'</span> ' + SLineBreak;
  html := html + '                    </a> ' + SLineBreak;
  html := html + '                    <a href="javascript: SetaAcao(''Fecha'', '''');"> ' + SLineBreak;
  html := html + '                        <span data-toggle="tooltip" title="Clique para visualizar" class="badge bg-red">'+Controller.iif(Fechados > 0, Fechados.ToString+' Chamados Fechados','N�o h� Chamados Fechados')+'</span> ' + SLineBreak;
  html := html + '                    </a> ' + SLineBreak;
  html := html + '                </div> ' + SLineBreak;
  html := html + '            </div> ' + SLineBreak;
  html := html + '            <div class="box-group" id="accordion"> ' + SLineBreak;
  html := html + '                <br /> ' + SLineBreak;

  //
  // Monta todos os chamados 1 a 1
  //
  Controller.DM.FDQQuery.Close;
  Controller.DM.FDQQuery.SQL.Clear;
  Controller.DM.FDQQuery.SQL.Add('Select c.*, cl.RazaoSocial, cl.email, cl.fonefixo, cl.fonecelular, s.descricao as NomeSolicitacao, ');
  Controller.DM.FDQQuery.SQL.Add('       p.descricao as NomeProduto, f.nomefuncionario ');
  Controller.DM.FDQQuery.SQL.Add('from Chamados c left join ');
  Controller.DM.FDQQuery.SQL.Add('     Clientes cl on c.idcliente = cl.idcliente left join ');
  Controller.DM.FDQQuery.SQL.Add('     Solicitacoes s on c.idsolicitacao = s.idsolicitacao left join ');
  Controller.DM.FDQQuery.SQL.Add('     Produtos p on c.idproduto = p.idproduto left join ');
  Controller.DM.FDQQuery.SQL.Add('     Funcionarios f on c.idfuncionariosolucao = f.idfuncionario ');
  Controller.DM.FDQQuery.SQL.Add('Where c.IDCliente = '+Controller.xCodCliente.ToString+' and c.Situacao = ''Fechado'' ');
  Controller.DM.FDQQuery.SQL.Add('Order by Cast(DataHoraAbertura as Date) desc, Prioridade, IDChamado ');
  Controller.DM.FDQQuery.Open();

  i := 1;
  Controller.DM.FDQQuery.First;
  while not Controller.DM.FDQQuery.Eof do
  begin
    if Controller.DM.FDQQuery.FieldByName('Prioridade').AsString = 'Alta' then
      xPrioridade := 'bg-red';
    if Controller.DM.FDQQuery.FieldByName('Prioridade').AsString = 'Media' then
      xPrioridade := 'bg-yellow';
    if Controller.DM.FDQQuery.FieldByName('Prioridade').AsString = 'Baixa' then
      xPrioridade := 'bg-aqua-active';

    html := html + '                <div class="panel box box-danger"> ' + SLineBreak;
    html := html + '                    <div class="box-header with-border"> ' + SLineBreak;
    html := html + '                        <h4 class="box-title"> ' + SLineBreak;
    html := html + '                            <a data-toggle="collapse" data-parent="#accordion" href="#collapse'+i.ToString+'"> ' + SLineBreak;
    html := html + '                                <span data-toggle="tooltip" title="Prioridade" class="badge '+xPrioridade+'">'+Controller.DM.FDQQuery.FieldByName('Prioridade').AsString+'</span>&nbsp;&nbsp;<br class="hidden-sm hidden-md hidden-lg" /> ' + SLineBreak;
    html := html + '                                <span data-toggle="tooltip" title="Data e Hora Abertura do Chamado"> ' + SLineBreak;
    html := html + '                                    <i class="fa fa-fw fa-calendar"></i> '+FormatDateTime('dd/mm/yy hh:nn', Controller.DM.FDQQuery.FieldByName('DataHoraAbertura').AsDateTime)+' &nbsp;&nbsp;&nbsp;&nbsp;<br class="hidden-sm hidden-md hidden-lg" /> ' + SLineBreak;
    html := html + '                                </span> ' + SLineBreak;
    html := html + '                                <span data-toggle="tooltip" title="Nome do M�dulo do Sistema"> ' + SLineBreak;
    html := html + '                                    <i class="fa fa-fw fa-laptop"></i> '+Controller.DM.FDQQuery.FieldByName('NomeProduto').AsString+' &nbsp;&nbsp;&nbsp;&nbsp;<br class="hidden-sm hidden-lg" /> ' + SLineBreak;
    html := html + '                                </span> ' + SLineBreak;
    html := html + '                                <span data-toggle="tooltip" title="Nome do Usu�rio"> ' + SLineBreak;
    html := html + '                                    <i class="fa fa-fw fa-user"></i> '+Controller.DM.FDQQuery.FieldByName('NOMESOLICITANTE').AsString+' ' + SLineBreak;
    html := html + '                                </span> ' + SLineBreak;
    html := html + '                            </a> ' + SLineBreak;
    html := html + '                        </h4> ' + SLineBreak;
    html := html + '                    </div> ' + SLineBreak;
    html := html + '                    <div id="collapse'+i.ToString+'" class="panel-collapse collapse"> ' + SLineBreak;
    html := html + '                        <div class="box-body"> ' + SLineBreak;
//    html := html + '                            <br /> ' + SLineBreak;
    html := html + '                            <div class="box box-danger"> ' + SLineBreak;
    html := html + '                                <div class="box-header with-border"> ' + SLineBreak;
    html := html + '                                    <h3 class="box-title">Dados do Chamado</h3> ' + SLineBreak;
    html := html + '                                </div> ' + SLineBreak;
    html := html + '                                <div class="box-body"> ' + SLineBreak;
    html := html + '                                    <dl class="dl-horizontal"> ' + SLineBreak;
    html := html + '                                        <dt>Prioridade:</dt> ' + SLineBreak;
    html := html + '                                        <dd><span class="badge '+xPrioridade+'">'+Controller.DM.FDQQuery.FieldByName('Prioridade').AsString+'</span></dd> ' + SLineBreak;
    html := html + '                                        <br /> ' + SLineBreak;
    html := html + '                                        <dt>N� Chamado:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('IDChamado').AsString+'</dd> ' + SLineBreak;
    html := html + '                                        <dt>Cliente:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('RazaoSocial').AsString+'</dd> ' + SLineBreak;
    html := html + '                                        <dt>Data / Hora Abertura:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+FormatDateTime('dd/mm/yyyy hh:nn:ss', Controller.DM.FDQQuery.FieldByName('DataHoraAbertura').AsDateTime)+' hs</dd> ' + SLineBreak;
    html := html + '                                        <br /> ' + SLineBreak;
    html := html + '                                        <dt>Nome Solicitante:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('NomeSolicitante').AsString+'</dd> ' + SLineBreak;
    html := html + '                                        <dt>Depto Solicitante:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('DeptoSolicitante').AsString+'</dd> ' + SLineBreak;
    html := html + '                                        <br /> ' + SLineBreak;
    html := html + '                                        <dt>Solicita��o:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('NomeSolicitacao').AsString+'</dd> ' + SLineBreak;
    html := html + '                                        <dt>Produto:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('NomeProduto').AsString+'</dd> ' + SLineBreak;
    html := html + '                                        <br /> ' + SLineBreak;
    html := html + '                                        <dt>Descri��o do Problema:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('DescricaoSolicitacao').AsString+'</dd> ' + SLineBreak;
    html := html + '                                        <br /> ' + SLineBreak;
    html := html + '                                        <dt>Solu��o:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('SolucaoSolicitacao').AsString+'</dd> ' + SLineBreak;
    html := html + '                                        <br /> ' + SLineBreak;
    html := html + '                                        <dt>Nome do Atendente:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+Controller.DM.FDQQuery.FieldByName('NomeFuncionario').AsString+'</dd> ' + SLineBreak;
    html := html + '                                        <dt>Data / Hora Solu��o:</dt> ' + SLineBreak;
    html := html + '                                        <dd>'+FormatDateTime('dd/mm/yyyy hh:nn:ss', Controller.DM.FDQQuery.FieldByName('DataHoraSolucao').AsDateTime)+' hs</dd> ' + SLineBreak;
    html := html + '                                    </dl> ' + SLineBreak;
    html := html + '                                </div> ' + SLineBreak;
    html := html + '                            </div> ' + SLineBreak;
    html := html + '                        </div> ' + SLineBreak;
    html := html + '                    </div> ' + SLineBreak;
    html := html + '                </div> ' + SLineBreak;

    i := i + 1;
    Controller.DM.FDQQuery.Next;
  end;
  Controller.DM.FDQQuery.Close;

  html := html + '            </div> ' + SLineBreak;
  html := html + '        </div> ' + SLineBreak;
  html := html + '    </div> ' + SLineBreak;

  Chamados.Caption := html;
end;

procedure TFrmIndexCliente.BtnCancelarClick(Sender: TObject);
begin
  inherited;
  Controller.DM.FDQChamadosCad.Cancel;
end;

procedure TFrmIndexCliente.BtnGravarClick(Sender: TObject);
begin
  inherited;

  Controller.DM.FDQChamadosCadIDCHAMADO.AsInteger := Controller.DM.FB_ReturnNextCOD_ByGenerator('COD_CHAMADO');

  try
    Controller.DM.FDQChamadosCad.Post;
    AddToInitProc(swalSuccess('CONFIRMA��O', 'Cadastro do Chamado realizado com sucesso !'));
    Controller.DM.FDQChamadosCad.Close;
    MontaChamadosAbertos;
  except
    AddToInitProc(swalAlert('ATEN��O','Ocorreu um erro na grava��o do Chamado tente novamente !'));
  end;
end;

procedure TFrmIndexCliente.BTNSENHAClick(Sender: TObject);
begin
  inherited;

  //
  //  CHECA SENHA ATUAL
  //
  Controller.DM.FDQQuery1.Close;
  Controller.DM.FDQQuery1.SQL.Clear;
  Controller.DM.FDQQuery1.SQL.Add('Select * from Clientes ');
  Controller.DM.FDQQuery1.SQL.Add('Where IDCliente = '+Controller.xCodCliente.ToString+' and ');
  Controller.DM.FDQQuery1.SQL.Add('      Senha     = '''+Controller.MD5(SenhaAtual.Text)+''' ');
  Controller.DM.FDQQuery1.Open;

  if Controller.DM.FDQQuery1.RecordCount <= 0 then
  begin
    AddToInitProc(swalError('Aten��o', 'Senha Atual Inv�lida !!!'));
    Exit;
  end;
  Controller.DM.FDQQuery1.Close;

  if NovaSenha.Text <> NovaSenha2.Text then
  begin
    AddToInitProc(swalError('Aten��o', 'Novas Senhas n�o conferem, tente novamente...'));
    Refresh;
    Exit;
  end;

  //
  //  GRAVA NOVA SENHA
  //
  Controller.DM.FDQQuery.Close;
  Controller.DM.FDQQuery.SQL.Clear;
  Controller.DM.FDQQuery.SQL.Add('Update Clientes set Senha = '''+Controller.MD5(NovaSenha.Text)+''' ');
  Controller.DM.FDQQuery.SQL.Add('Where IDCliente = '+Controller.xCodCliente.ToString);
  Controller.DM.FDQQuery.ExecSQL;
  Controller.DM.FDQQuery.Close;

  AddToInitProc(swalSuccess('Confirma��o', 'Senha trocada com sucesso !!!'));
end;

procedure TFrmIndexCliente.IWAppFormCreate(Sender: TObject);
begin
  inherited;
  Controller.DM.FDQSolicitacoes.Close;
  Controller.DM.FDQSolicitacoes.Open();

  Controller.DM.FDQProdutos.Close;
  Controller.DM.FDQProdutos.Open();

  Chamados.Text := '';
  Pesquisa.Text := '';
  MontaChamadosAbertos;
end;

procedure TFrmIndexCliente.IWAppFormDestroy(Sender: TObject);
begin
  inherited;
  Controller.DM.FDQChamadosCad.Close;
  Controller.DM.FDQSolicitacoes.Close;
  Controller.DM.FDQProdutos.Close;
end;

procedure TFrmIndexCliente.IWBTNACAOAsyncClick(Sender: TObject;
  EventParams: TStringList);
var
  html : String;
  filtro : String;
  where : string;
begin
  inherited;


  //
  // Limpa tela de pesquisa
  //
  if IWAcao.Text = 'Limpa' then
  begin
    Pesquisa.Text := '';
  end;


  //
  // Efetua a Pesquisa
  //
  if IWAcao.Text = 'Pesqu' then
  begin
    //
    // Monta todos os chamados filtrados
    //
    Controller.DM.FDQQuery.Close;
    Controller.DM.FDQQuery.SQL.Clear;
    Controller.DM.FDQQuery.SQL.Add('Select c.*, cl.RazaoSocial, cl.email, cl.fonefixo, cl.fonecelular, s.descricao as NomeSolicitacao, ');
    Controller.DM.FDQQuery.SQL.Add('       p.descricao as NomeProduto, f.nomefuncionario ');
    Controller.DM.FDQQuery.SQL.Add('from Chamados c left join ');
    Controller.DM.FDQQuery.SQL.Add('     Clientes cl on c.idcliente = cl.idcliente left join ');
    Controller.DM.FDQQuery.SQL.Add('     Solicitacoes s on c.idsolicitacao = s.idsolicitacao left join ');
    Controller.DM.FDQQuery.SQL.Add('     Produtos p on c.idproduto = p.idproduto left join ');
    Controller.DM.FDQQuery.SQL.Add('     Funcionarios f on c.idfuncionariosolucao = f.idfuncionario ');
    Controller.DM.FDQQuery.SQL.Add('Where c.Situacao = ''Fechado'' ');

    where := '';
    if PesquisaProblema.Text <> '' then
    begin
      filtro := PesquisaProblema.Text;
      where := where + ' Upper(c.DescricaoSolicitacao) CONTAINING  '''+UpperCase(filtro)+''' ';
    end;

    if PesquisaSolucao.Text <> '' then
    begin
      filtro := PesquisaSolucao.Text;
      if where <> '' then where := where + ' or ';
      where := where + ' Upper(c.SolucaoSolicitacao) CONTAINING '''+UpperCase(filtro)+''' ';
    end;

    if where <> '' then
      Controller.DM.FDQQuery.SQL.Add(' and '+where);

    Controller.DM.FDQQuery.SQL.Add('Order by Cast(DataHoraAbertura as Date) desc, Prioridade, IDChamado ');
    Controller.DM.FDQQuery.Open();

    html := '';
    Controller.DM.FDQQuery.First;
    while not Controller.DM.FDQQuery.Eof do
    begin
      if html <> '' then
        html := html + '                                        <hr> ' + SLineBreak;

      html := html + '                                        <div class="row"> ' + SLineBreak;
      html := html + '                                            <div class="col-md-5"> ' + SLineBreak;
      html := html + '                                                <div class="form-group"> ' + SLineBreak;
      html := html + '                                                    <label>Data Solicita��o</label> ' + SLineBreak;
      html := html + '                                                    <input type="text" class="form-control" disabled value="'+FormatDateTime('dd/mm/yyyy hh:nn:ss', Controller.DM.FDQQuery.FieldByName('DataHoraAbertura').AsDateTime)+' hs"> ' + SLineBreak;
      html := html + '                                                </div> ' + SLineBreak;
      html := html + '                                            </div> ' + SLineBreak;
      html := html + '                                            <div class="col-md-7"> ' + SLineBreak;
      html := html + '                                                <div class="form-group"> ' + SLineBreak;
      html := html + '                                                    <label>Nome Solicitante</label> ' + SLineBreak;
      html := html + '                                                    <input type="text" class="form-control" disabled value="'+Controller.DM.FDQQuery.FieldByName('NomeSolicitante').AsString+'"> ' + SLineBreak;
      html := html + '                                                </div> ' + SLineBreak;
      html := html + '                                            </div> ' + SLineBreak;
      html := html + '                                            <div class="col-md-4"> ' + SLineBreak;
      html := html + '                                                <div class="form-group"> ' + SLineBreak;
      html := html + '                                                    <label>Depto Solicitante</label> ' + SLineBreak;
      html := html + '                                                    <input type="text" class="form-control" disabled value="'+Controller.DM.FDQQuery.FieldByName('DeptoSolicitante').AsString+'"> ' + SLineBreak;
      html := html + '                                                </div> ' + SLineBreak;
      html := html + '                                            </div> ' + SLineBreak;
      html := html + '                                            <div class="col-md-4"> ' + SLineBreak;
      html := html + '                                                <div class="form-group"> ' + SLineBreak;
      html := html + '                                                    <label>Nome do Produto</label> ' + SLineBreak;
      html := html + '                                                    <input type="text" class="form-control" disabled value="'+Controller.DM.FDQQuery.FieldByName('NomeSolicitacao').AsString+'"> ' + SLineBreak;
      html := html + '                                                </div> ' + SLineBreak;
      html := html + '                                            </div> ' + SLineBreak;
      html := html + '                                            <div class="col-md-4"> ' + SLineBreak;
      html := html + '                                                <div class="form-group"> ' + SLineBreak;
      html := html + '                                                    <label>Solicita��o</label> ' + SLineBreak;
      html := html + '                                                    <input type="text" class="form-control" disabled value="'+Controller.DM.FDQQuery.FieldByName('NomeProduto').AsString+'"> ' + SLineBreak;
      html := html + '                                                </div> ' + SLineBreak;
      html := html + '                                            </div> ' + SLineBreak;
      html := html + '                                        </div> ' + SLineBreak;
      html := html + '                                        <div class="row"> ' + SLineBreak;
      html := html + '                                            <div class="col-md-6"> ' + SLineBreak;
      html := html + '                                                <div class="form-group"> ' + SLineBreak;
      html := html + '                                                    <label>Descri��o do Problema</label> ' + SLineBreak;
      html := html + '                                                    <textarea class="form-control" disabled>'+Controller.DM.FDQQuery.FieldByName('DescricaoSolicitacao').AsString+'</textarea> ' + SLineBreak;
      html := html + '                                                </div> ' + SLineBreak;
      html := html + '                                            </div> ' + SLineBreak;
      html := html + '                                            <div class="col-md-6"> ' + SLineBreak;
      html := html + '                                                <div class="form-group"> ' + SLineBreak;
      html := html + '                                                    <label>Descri��o da Solu��o</label> ' + SLineBreak;
      html := html + '                                                    <textarea class="form-control" disabled>'+Controller.DM.FDQQuery.FieldByName('SolucaoSolicitacao').AsString+'</textarea> ' + SLineBreak;
      html := html + '                                                </div> ' + SLineBreak;
      html := html + '                                            </div> ' + SLineBreak;
      html := html + '                                        </div> ' + SLineBreak;

      Controller.DM.FDQQuery.Next;
    end;
    Controller.DM.FDQQuery.Close;

    if html = '' then
    begin
      html := html + '                                        <div class="row"> ' + SLineBreak;
      html := html + '                                            <div class="col-md-12" align="center"> ' + SLineBreak;
      html := html + '                                                N�O H� CHAMADOS COM ESSES FILTROS !!!' + SLineBreak;
      html := html + '                                            </div> ' + SLineBreak;
      html := html + '                                        </div> ' + SLineBreak;
    end;

    Pesquisa.Text := html;
  end;


  // Clicou em Chamados Abertos
  if Trim(Copy(IWAcao.Text,1,5)) = 'Abert' then
  begin
    MontaChamadosAbertos();
  end;


  // Clicou em Chamados Fechados
  if Trim(Copy(IWAcao.Text,1,5)) = 'Fecha' then
  begin
    MontaChamadosFechados();
  end;


  // Clicou em Novo Chamado
  if Trim(Copy(IWAcao.Text,1,5)) = 'Senha' then
  begin
    WebApplication.CallBackResponse.AddJavaScriptToExecute('$(''#ModalSenha'').modal(''show'');');
  end;


  // Clicou em Novo Chamado
  if Trim(Copy(IWAcao.Text,1,5)) = 'Inclu' then
  begin
    Controller.DM.FDQChamadosCad.Close;
    Controller.DM.FDQChamadosCad.Open();
    Controller.DM.FDQChamadosCad.Append;

    Controller.DM.FDQChamadosCadIDCLIENTE.Value := Controller.xCodCliente;
    Controller.DM.FDQChamadosCadDATAHORAABERTURA.AsDateTime := now;
    Controller.DM.FDQChamadosCadSITUACAO.Value := 'Aberto';
    Controller.DM.FDQChamadosCadPRIORIDADE.Value := 'Baixa';


    WebApplication.CallBackResponse.AddJavaScriptToExecute('$(''#ModalChamado'').modal(''show'');');
  end;

end;

end.
