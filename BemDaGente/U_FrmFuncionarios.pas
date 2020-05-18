unit U_FrmFuncionarios;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, U_FrmPadrao, IWVCLComponent,
  IWBaseLayoutComponent, IWBaseContainerLayout, IWContainerLayout,
  IWTemplateProcessorHTML, IWCompButton, IWVCLBaseControl, IWBaseControl,
  IWBaseHTMLControl, IWControl, IWCompEdit, IWDBStdCtrls, Data.DB, IWCompLabel, IWHTMLTag,
  IWBaseComponent, IWBaseHTMLComponent,
  IWBaseHTML40Component, IWCompExtCtrls, IWCompListbox;

type
  TFrmFuncionarios = class(TFrmPadrao)
    BtnExcluir: TIWButton;
    dsFuncionariosCad: TDataSource;
    IDFUNCIONARIO: TIWDBEdit;
    NOMEFUNCIONARIO: TIWDBEdit;
    CPF: TIWDBEdit;
    RG: TIWDBEdit;
    CEP: TIWDBEdit;
    ENDERECO: TIWDBEdit;
    NUMERO: TIWDBEdit;
    COMPLEMENTO: TIWDBEdit;
    BAIRRO: TIWDBEdit;
    CIDADE: TIWDBEdit;
    ESTADO: TIWDBEdit;
    FONEFIXO: TIWDBEdit;
    FONECELULAR: TIWDBEdit;
    EMAIL: TIWDBEdit;
    BtnSenha: TIWButton;
    TituloModal: TIWLabel;
    edUSUARIO: TIWDBEdit;
    DATAULTACESSO: TIWDBEdit;
    BtnGravar: TIWButton;
    BtnCancelar: TIWButton;
    Filtro: TIWEdit;
    BtnImprimir: TIWButton;
    IWModalWindow1: TIWModalWindow;
    Ordenacao: TIWComboBox;
    procedure IWTemplateProcessorHTML1UnknownTag(const AName: string;
      var VValue: string);
    procedure BtnExcluirClick(Sender: TObject);
    procedure BtnSenhaClick(Sender: TObject);
    procedure BtnGravarClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure FONEFIXOHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure FONECELULARHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure CEPHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure IWBTNACAOAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure CPFHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure IWAppFormCreate(Sender: TObject);
    procedure BtnImprimirClick(Sender: TObject);
    procedure FiltroHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmFuncionarios: TFrmFuncionarios;

implementation

{$R *.dfm}

uses ServerController, SweetAlerts, U_Dm, System.Math, funcoes, System.DateUtils;


procedure TFrmFuncionarios.BtnCancelarClick(Sender: TObject);
begin
  inherited;
  //
  // CANCELAR EDICAO OU INCLUSAO DO RESGISTRO
  //
  Controller.DM.FDQFuncionariosCad.Cancel;

end;

procedure TFrmFuncionarios.BtnExcluirClick(Sender: TObject);
begin
  inherited;

  // Rotina de Exclusao do Registro selecionado

  Controller.DM.FDQQuery.Close;
  Controller.DM.FDQQuery.SQL.Clear;
  Controller.DM.FDQQuery.SQL.Add('Delete from Funcionarios ');
  Controller.DM.FDQQuery.SQL.Add('Where IDFuncionario = '+Trim(Copy(IWAcao.Text,6,50)));
  Controller.DM.FDQQuery.ExecSQL;
  Controller.DM.FDQQuery.Close;

  AddToInitProc(swalSuccess('Confirma��o', 'C�digo '+Trim(Copy(IWAcao.Text,6,50))+' excluido com sucesso !!!'))
end;

procedure TFrmFuncionarios.BtnGravarClick(Sender: TObject);
begin
  inherited;
  //
  // VERIFICA CAMPOS OBRIGATORIOS ANTES DE GRAVAR
  //
  if Length(Controller.DM.FDQFuncionariosCadNOMEFUNCIONARIO.Value) < 5 then
  begin
    AddToInitProc(swalError('Aten��o', 'Nome do Funcion�rio precisa ter pelo menos 5 caracteres !'));
    NomeFuncionario.SetFocus;
    Abort;
  end;

  //
  // GRAVA RESGISTRO
  //
  if Controller.GLBPK <=0 then
    Controller.DM.FDQFuncionariosCadIDFUNCIONARIO.AsInteger := Controller.DM.FB_ReturnNextCOD_ByGenerator('COD_FUNCIONARIO');

  try
    Controller.DM.FDQFuncionariosCad.Post;

    if Controller.GLBCrud = 'Altera��o' then
      AddToInitProc(swalSuccess('CONFIRMA��O', 'Altera��o realizada com sucesso !'))
    else
      AddToInitProc(swalSuccess('CONFIRMA��O', 'Cadastro realizado com sucesso !'));

  except
    AddToInitProc(swalAlert('ATEN��O','Ocorreu um erro na grava��o do registro !'));
  end;
end;

procedure TFrmFuncionarios.BtnImprimirClick(Sender: TObject);
var
  xDataRel : String;
  xLogotipo : String;
begin
  inherited;

  Controller.DM.FDQQuery.Close;
  Controller.DM.FDQQuery.SQL.Clear;
  Controller.DM.FDQQuery.SQL.Add('Select * from Funcionarios ');

  // Filtro
  if Filtro.Text <> '' then
  begin
    Controller.DM.FDQQuery.SQL.Add('Where Cidade like ''%'+Filtro.Text+'%'' ');
  end;

  // ORDENACAO
  if Ordenacao.SelectedValue = 'C�digo' then
    Controller.DM.FDQQuery.SQL.Add('Order by IDFuncionario ');
  if Ordenacao.SelectedValue = 'Nome Funcion�rio' then
    Controller.DM.FDQQuery.SQL.Add('Order by NomeFuncionario ');

  Controller.DM.FDQQuery.Open();

//  frxReport1.Report.LoadFromFile('../../../Relatorios/RelFuncionariosSimples.fr3');

  //
  // Executando o Relat�rio para a Exporta��o
  //
  xDataRel := WebApplication.AppID + FormatDateTime('yyyymmddhhmmsszzz', Now);

  Controller.GLBNomeRelatorio := '../../../RelatoriosPDF/' + xDataRel + '.PDF';
//                            ../../../RelatoriosPDF/;


  with IWModalWindow1 do begin
    Reset;
    Autosize := False;
    Title := 'Visualizando o PDF do Relat�rio';
    Draggable := False;
    WindowWidth := 95;
    WindowHeight := 95;
    Src := Controller.GLBNomeRelatorio;
    OnAsyncClick := nil;
    Show;
  end;
end;

procedure TFrmFuncionarios.BtnSenhaClick(Sender: TObject);
begin
  inherited;
  // Colocar o codigo para resetar a senha aqui
  // MD5 da senha padrao 1234: >>  81dc9bdb52d04dc20036dbd8313ed055  <<
  Controller.DM.FDQQuery.Close;
  Controller.DM.FDQQuery.SQL.Clear;
  Controller.DM.FDQQuery.SQL.Add('Update Funcionarios set Senha = ''81dc9bdb52d04dc20036dbd8313ed055'' ');
  Controller.DM.FDQQuery.SQL.Add('Where IDFuncionario = '+Trim(Copy(IWAcao.Text,6,50)));
  Controller.DM.FDQQuery.ExecSQL;
  Controller.DM.FDQQuery.Close;

  AddToInitProc(swalSuccess('Confirma��o', 'Senha resetada para o C�d.: '+Trim(Copy(IWAcao.Text,6,50))+' !!!'))
end;

procedure TFrmFuncionarios.CEPHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  inherited;
  ATag.Add('data-inputmask="''mask'': ''99999-999''" data-mask');
end;

procedure TFrmFuncionarios.CPFHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  inherited;
  ATag.Add('data-inputmask="''mask'': ''999.999.999-99''" data-mask');
end;

procedure TFrmFuncionarios.FiltroHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  inherited;
  ATag.Add('placeholder="Digite parte do nome da cidade"');
end;

procedure TFrmFuncionarios.FONECELULARHTMLTag(ASender: TObject;
  ATag: TIWHTMLTag);
begin
  inherited;
  ATag.Add('data-inputmask="''mask'': ''(99) 99999-9999''" data-mask');
end;

procedure TFrmFuncionarios.FONEFIXOHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  inherited;
  ATag.Add('data-inputmask="''mask'': ''(99) 9999-9999''" data-mask');
end;

procedure TFrmFuncionarios.IWAppFormCreate(Sender: TObject);
begin
  inherited;
  Controller.DM.FDQQuery.Close;
  Controller.DM.FDQQuery.SQL.Clear;
  Controller.DM.FDQQuery.SQL.Add('Select * from Funcionarios');
  Controller.DM.FDQQuery.Open;
end;

procedure TFrmFuncionarios.IWBTNACAOAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  inherited;

  // Clicou em Incluir
  if Trim(Copy(IWAcao.Text,1,5)) = 'Inc' then
  begin
    Controller.GLBPK := -1;
    Controller.GLBCrud := 'Inclus�o';
    // Atualizo o IWLabel que esta como RawText, assim atualizo o nome do t�tulo no Modal
    TituloModal.Text := Controller.GLBCrud;

    Controller.DM.FDQFuncionariosCad.Close;
    Controller.DM.FDQFuncionariosCad.Open;
    Controller.DM.FDQFuncionariosCad.Insert;

    Controller.DM.FDQFuncionariosCadIDFUNCIONARIO.Value := -1;

    WebApplication.CallBackResponse.AddJavaScriptToExecute('$(''#Cadastro'').modal(''show'');');
  end;


  // Clicou em Alterar
  if Trim(Copy(IWAcao.Text,1,5)) = 'Alt' then
  begin
    Controller.GLBPK := StrToInt(Trim(Copy(IWAcao.Text,6,50)));
    Controller.GLBCrud := 'Altera��o';
    // Atualizo o IWLabel que esta como RawText, assim atualizo o nome do t�tulo no Modal
    TituloModal.Text := Controller.GLBCrud;

    Controller.DM.FDQFuncionariosCad.Close;
    Controller.DM.FDQFuncionariosCad.ParamByName('IDFuncionario').AsInteger := Controller.GLBPK;
    Controller.DM.FDQFuncionariosCad.Open;
    Controller.DM.FDQFuncionariosCad.Edit;

    WebApplication.CallBackResponse.AddJavaScriptToExecute('$(''#Cadastro'').modal(''show'');');
  end;


  // Clicou em Excluir
  if Trim(Copy(IWAcao.Text,1,5)) = 'Exc' then
  begin
    WebApplication.CallBackResponse.AddJavaScriptToExecute(swalConfirm('CONFIRMA��O', 'Deseja excluir o funcion�rio n� '+Trim(Copy(IWAcao.Text,6,50)), 'warning', 'Excluir', 'Cancelar', 'BTNEXCLUIR'));
  end;


  // Clicou em Trocar Senha
  if Trim(Copy(IWAcao.Text,1,5)) = 'Senha' then
  begin
    WebApplication.CallBackResponse.AddJavaScriptToExecute(swalConfirm('CONFIRMA��O', 'Deseja resetar a Senha do funcion�rio n� '+Trim(Copy(IWAcao.Text,6,50)), 'warning', 'Resetar', 'Cancelar', 'BTNSENHA'));
  end;


  // Clicou em Trocar Senha
  if Trim(Copy(IWAcao.Text,1,5)) = 'Impr' then
  begin
    WebApplication.CallBackResponse.AddJavaScriptToExecute('$(''#Relatorios'').modal(''show'');');
  end;
end;

procedure TFrmFuncionarios.IWTemplateProcessorHTML1UnknownTag(
  const AName: string; var VValue: string);
var
  html : String;
begin
  inherited;

  if AName = 'Grid' then
  begin
    //
    // MONTA A TABLE GRID DO CADASTRO
    //
    Controller.DM.FDQQuery.Close;
    Controller.DM.FDQQuery.SQL.Clear;
    Controller.DM.FDQQuery.SQL.Add('Select * from Funcionarios ');
    Controller.DM.FDQQuery.SQL.Add('Order by IDFuncionario ');
    Controller.DM.FDQQuery.Open();

    html := '';
    html := html + '<table id="GRID" class="table table-bordered table-striped table-hover"> '+SLineBreak+
                   '    <thead> '+SLineBreak+
                   '        <tr> '+SLineBreak+
                   '            <th style="text-align: center;">C�digo</th> '+SLineBreak+
                   '            <th>Nome do Funcion�rio</th> '+SLineBreak+
                   '            <th>C.P.F.</th> '+SLineBreak+
                   '            <th>Fone Fixo</th> '+SLineBreak+
                   '            <th>Celular</th> '+SLineBreak+
                   '            <th style="text-align: center;">A��es</th> '+SLineBreak+
                   '        </tr> '+SLineBreak+
                   '    </thead> '+SLineBreak+
                   '    <tbody> '+SLineBreak;

    Controller.DM.FDQQuery.First;
    while not Controller.DM.FDQQuery.Eof do
    begin
      html := html + '        <tr> '+SLineBreak+
                     '            <td align="center">'+Controller.DM.FDQQuery.FieldByName('IDFUNCIONARIO').AsString+'</td> '+SLineBreak+
                     '            <td>'+Controller.DM.FDQQuery.FieldByName('NOMEFUNCIONARIO').AsString+'</td> '+SLineBreak+
                     '            <td>'+Controller.DM.FDQQuery.FieldByName('CPF').AsString+'</td> '+SLineBreak+
                     '            <td>'+Controller.DM.FDQQuery.FieldByName('FONEFIXO').AsString+'</td> '+SLineBreak+
                     '            <td>'+Controller.DM.FDQQuery.FieldByName('FONECELULAR').AsString+'</td> '+SLineBreak+
                     '            <td align="center"> '+SLineBreak+
                     '                <button type="buttom" class="btn btn-xs btn-warning" data-toggle="tooltip" data-placement="top" title="Alterar Registro" onclick="SetaAcao(''Alt'', '''+Controller.DM.FDQQuery.FieldByName('IDFUNCIONARIO').AsString+''');"> '+SLineBreak+
                     '                    <i class="fa fa-pencil"></i> '+SLineBreak+
                     '                </button> '+SLineBreak+
                     '                <button type="buttom" class="btn btn-xs btn-danger" data-toggle="tooltip" data-placement="top" title="Excluir Registro" onclick="SetaAcao(''Exc'', '''+Controller.DM.FDQQuery.FieldByName('IDFUNCIONARIO').AsString+''');"> '+SLineBreak+
                     '                    <i class="fa fa-trash"></i> '+SLineBreak+
                     '                </button> '+SLineBreak+
                     '                <button type="buttom" class="btn btn-xs btn-info" data-toggle="tooltip" data-placement="top" title="Resetar Senha" onclick="SetaAcao(''Senha'', '''+Controller.DM.FDQQuery.FieldByName('IDFUNCIONARIO').AsString+''');"> '+SLineBreak+
                     '                    <i class="fa fa-key"></i> '+SLineBreak+
                     '                </button> '+SLineBreak+
                     '            </td> '+SLineBreak+

                     '        </tr> '+SLineBreak;
      Controller.DM.FDQQuery.Next;
    end;
    Controller.DM.FDQQuery.Close;

    html := html + '    </tbody> '+SLineBreak;

    //
    // DESMARQUE ABAIXO SE QUISER O CABE�ALHO NO FINAL DO DATATABLE REPETIDO
    //

//    html := html + '    <tfoot> '+SLineBreak+
//                   '        <tr> '+SLineBreak+
//                   '            <th style="text-align: center;">C�digo</th> '+SLineBreak+
//                   '            <th>Nome do Funcion�rio</th> '+SLineBreak+
//                   '            <th>C.P.F.</th> '+SLineBreak+
//                   '            <th>Fone Fixo</th> '+SLineBreak+
//                   '            <th>Celular</th> '+SLineBreak+
//                   '            <th style="text-align: center;">A��es</th> '+SLineBreak+
//                   '        </tr> '+SLineBreak+
//                   '    </tfoot> '+SLineBreak;

    html := html + '</table> '+SLineBreak;

    VValue := html;
    html := '';
  end;

end;

end.

