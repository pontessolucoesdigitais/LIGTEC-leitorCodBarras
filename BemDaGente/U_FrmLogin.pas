unit U_FrmLogin;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes, Vcl.Controls, IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl, IWCompEdit,
  IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout, IWContainerLayout, IWTemplateProcessorHTML, IWCompButton,
  IWHTMLTag, IWCompText, IWCompLabel;

type
  TFrmLogin = class(TIWAppForm)
    IWCNPJ: TIWEdit;
    IWLOGIN: TIWEdit;
    IWSENHA: TIWEdit;
    Processor: TIWTemplateProcessorHTML;
    IWBTNLOGAR: TIWButton;
    MensagemSenha: TIWLabel;
    CodigoRecuperadoSenha: TIWEdit;
    BTNEsqueciSenha: TIWButton;
    BTNVerificaCodigo: TIWButton;
    BTNTrocaSenha: TIWButton;
    NovaSenha: TIWEdit;
    NovaSenha2: TIWEdit;
    mBody: TIWText;
    procedure IWBTNLOGARClick(Sender: TObject);
    procedure IWCNPJHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure IWLOGINHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure IWSENHAHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
    procedure IWAppFormCreate(Sender: TObject);
    procedure BTNEsqueciSenhaAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure BTNVerificaCodigoAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure BTNTrocaSenhaAsyncClick(Sender: TObject;
      EventParams: TStringList);
    procedure NovaSenha2AsyncExit(Sender: TObject; EventParams: TStringList);
  public

  private
    TipoUsuario, CodigoRecuperaEmail : string;
  end;

implementation

{$R *.dfm}

uses ServerController, SweetAlerts, mimemess, IniFiles, TypInfo;



procedure TFrmLogin.BTNEsqueciSenhaAsyncClick(Sender: TObject;
  EventParams: TStringList);
var
  i : integer;
  email, nome : string;
begin
  //
  // Verifica se � Funcionario ou Cliente
  //
  Controller.DM.FDQQuery.Close;
  Controller.DM.FDQQuery.SQL.Clear;
  Controller.DM.FDQQuery.SQL.Add('Select * from Funcionarios ');
  Controller.DM.FDQQuery.SQL.Add('Where Usuario = '''+IWLOGIN.Text+''' ');
  Controller.DM.FDQQuery.Open;
  if Controller.DM.FDQQuery.RecordCount > 0 then
  begin
    TipoUsuario := 'Funcionario';
    email := Controller.DM.FDQQuery.FieldByName('Email').AsString;
    nome  := Controller.DM.FDQQuery.FieldByName('NomeFuncionario').AsString;
  end
  else
  begin
    Controller.DM.FDQQuery.Close;
    Controller.DM.FDQQuery.SQL.Clear;
    Controller.DM.FDQQuery.SQL.Add('Select * from CLIENTES ');
    Controller.DM.FDQQuery.SQL.Add('Where CNPJCPF = '''+IWCNPJ.Text+''' and ');
    Controller.DM.FDQQuery.SQL.Add('      Email = '''+IWLOGIN.Text+''' ');
    Controller.DM.FDQQuery.Open;
    if Controller.DM.FDQQuery.RecordCount > 0 then
    begin
      TipoUsuario := 'Cliente';
      email := Controller.DM.FDQQuery.FieldByName('Email').AsString;
      nome  := Controller.DM.FDQQuery.FieldByName('RazaoSocial').AsString;
    end
    else
    begin
      AddToInitProc(swalError('ATEN��O','Aten��o!!! Usu�rio n�o encontrado em nossa Base de Dados !'));
      Exit;
    end;
  end;


  //
  // PEGA OS DADOS DA CONTA DE EMAIL
  //
  Controller.DM.FDQQuery.Close;
  Controller.DM.FDQQuery.SQL.Clear;
  Controller.DM.FDQQuery.SQL.Add('Select * from Licenca ');
  Controller.DM.FDQQuery.Open;

  Controller.DM.FDQQuery.First;


  //
  // MONTA O ENVIO DO EMAIL
  //
  Controller.EMAIL.Clear;
  Controller.EMAIL.IsHTML := true;
  Controller.EMAIL.Subject := 'Recupera��o de Senha '+TipoUsuario+' SisHelpDesk ( Urgente )';
  Controller.EMAIL.From := Controller.DM.FDQQuery.FieldByName('EMAILORIGEM').asString;
  Controller.EMAIL.FromName := Controller.DM.FDQQuery.FieldByName('NOMEORIGEM').asString;
  Controller.EMAIL.Host := Controller.DM.FDQQuery.FieldByName('SMTP').asString; // troque pelo seu servidor smtp
  Controller.EMAIL.Username := Controller.DM.FDQQuery.FieldByName('USUARIO').asString;
  Controller.EMAIL.Password := Controller.DM.FDQQuery.FieldByName('SENHA').asString;
  Controller.EMAIL.Port := Controller.DM.FDQQuery.FieldByName('PORTA').asString; // troque pela porta do seu servidor smtp
  Controller.EMAIL.SetTLS := (Controller.DM.FDQQuery.FieldByName('TLS').asString = 'SIM');
  Controller.EMAIL.SetSSL := (Controller.DM.FDQQuery.FieldByName('SSL').asString = 'SIM');  // Verifique se o seu servidor necessita SSL
  Controller.EMAIL.AddAddress(email, nome);
  //Controller.EMAIL.AddCC('outro_email@gmail.com'); // opcional
  //Controller.EMAIL.AddReplyTo('um_email'); // opcional
  //Controller.EMAIL.AddBCC('um_email'); // opcional
  Controller.EMAIL.Priority := MP_high;
  //Controller.EMAIL.ReadingConfirmation := True; // solicita confirma��o de leitura

  // Sempre que acabar de usar um query ou qq outra forma de consulta a uma tabela do banco
  // fazer seu fechamento
  Controller.DM.FDQQuery.Close;

  CodigoRecuperaEmail := Copy(Controller.MD5(FormatDateTime('ssnnhhddmmyyyy', Now)),1,10);

  Controller.FindReplaceMemo('<$CODIGO$>', CodigoRecuperaEmail, mBody);

  Controller.EMAIL.Body.Assign(mBody.Lines);

  Controller.EMAIL.Send(false);

  MensagemSenha.Text := 'Aten��o!!! Foi enviado um email para "'+email+'" com o c�digo de recupera��o de sua senha, acesse seu provedor de email e digite abaixo o c�digo recebido.';

  WebApplication.CallBackResponse.AddJavaScriptToExecute('$(''#EsqueciSenha'').modal(''show'');');
end;



procedure TFrmLogin.BTNTrocaSenhaAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if NovaSenha.Text <> NovaSenha2.Text then
  begin
    NovaSenha.Text := '';
    NovaSenha2.Text := '';
    NovaSenha.SetFocus;
    WebApplication.CallBackResponse.AddJavaScriptToExecute(swalError('ATEN��O','Senhas digitadas n�o Conferem, tente novamente !'));
    Exit;
  end;

  //
  // GRAVA A NOVA SENHA
  //
  Controller.DM.FDQQuery.Close;
  Controller.DM.FDQQuery.SQL.Clear;
  if TipoUsuario = 'Cliente' then
  begin
    Controller.DM.FDQQuery.SQL.Add('Update CLIENTES set ');
    Controller.DM.FDQQuery.SQL.Add('       Senha = '''+Controller.MD5(NovaSenha.Text)+''' '); //'''+FormatDateTime('mm.dd.yyyy hh:nn:ss', Now)+''' ');
    Controller.DM.FDQQuery.SQL.Add('WHERE (Email = '''+IWLOGIN.Text+''') ');
  end
  else
  begin
    Controller.DM.FDQQuery.SQL.Add('Update FUNCIONARIOS set ');
    Controller.DM.FDQQuery.SQL.Add('       Senha = '''+Controller.MD5(NovaSenha.Text)+''' '); //'''+FormatDateTime('mm.dd.yyyy hh:nn:ss', Now)+''' ');
    Controller.DM.FDQQuery.SQL.Add('Where Usuario = '''+IWLOGIN.Text+''' ');
  end;
  Controller.DM.FDQQuery.ExecSQL;

  WebApplication.CallBackResponse.AddJavaScriptToExecute('$(''#TrocaSenha'').modal(''hide'');');

  WebApplication.CallBackResponse.AddJavaScriptToExecute(swalSuccess('ATEN��O','Parab�ns, senha trocada com sucesso !'));
end;



procedure TFrmLogin.BTNVerificaCodigoAsyncClick(Sender: TObject;
  EventParams: TStringList);
begin
  if CodigoRecuperaEmail <> CodigoRecuperadoSenha.Text then
  begin
    CodigoRecuperadoSenha.Text := '';
    AddToInitProc(swalError('ATEN��O','C�digo de Verifica��o n�o Confere, tente novamente !'));
    Exit;
  end;

  WebApplication.CallBackResponse.AddJavaScriptToExecute('$(''#EsqueciSenha'').modal(''hide'');');
  WebApplication.CallBackResponse.AddJavaScriptToExecute('$(''#TrocaSenha'').modal(''show'');');
end;



procedure TFrmLogin.IWAppFormCreate(Sender: TObject);
begin
  //
  // Ler o valor dos cookies se tiver
  //
  IWCNPJ.Text := WebApplication.Request.CookieFields.Values['IWCNPJ'];
  IWLOGIN.Text := WebApplication.Request.CookieFields.Values['IWLOGIN'];

  IWSENHA.SetFocus();

  if (IWCNPJ.Text = '') then
    IWCNPJ.SetFocus();
  if (IWLOGIN.Text = '') then
    IWLOGIN.SetFocus();
end;



procedure TFrmLogin.IWBTNLOGARClick(Sender: TObject);
var
  xSQL : String;
begin
  //
  // PEGA OS DADOS DA LICEN�A
  //
  Controller.DM.FDQQuery2.Close;
  Controller.DM.FDQQuery2.SQL.Clear;
  Controller.DM.FDQQuery2.SQL.Add('Select * from Licenca ');
  Controller.DM.FDQQuery2.Open;
  Controller.xCliente := Controller.DM.FDQQuery2.FieldByName('NOMELICENCA').asString + '<small> CNPJ: '+Controller.DM.FDQQuery2.FieldByName('CNPJ').asString+'</small>';


  //
  // CHECA O LOGIN FUNCIONARIOS
  //
  Controller.DM.FDQQuery.Close;
  Controller.DM.FDQQuery.SQL.Clear;
  Controller.DM.FDQQuery.SQL.Add('Select * from Funcionarios ');
  Controller.DM.FDQQuery.SQL.Add('Where Usuario = '''+IWLOGIN.Text+''' and ');
  Controller.DM.FDQQuery.SQL.Add('      Senha = '''+Controller.MD5(IWSenha.Text)+''' ');
  Controller.DM.FDQQuery.Open;

  if Controller.DM.FDQQuery.RecordCount > 0 then
  begin
    //
    // CHECA SE CAMPOS FORAM PREENCHIDOS ANTES DE LOGAR
    //
    if (IWLogin.Text = '') then
    begin
      IWLogin.SetFocus;
      Abort;
    end;


    //
    // Adiciona valor ao Cookie ou cria se nao existir duracao de 30 dias
    //
    Webapplication.Response.Cookies.AddCookie('IWCNPJ', IWCNPJ.Text, '/', now + 30);
    Webapplication.Response.Cookies.AddCookie('IWLOGIN', IWLOGIN.Text, '/', now + 30);


    //
    // PEGA O NOME DO USUARIO
    //
    Controller.xUsuario    := UpperCase(IWLOGIN.Text);
    Controller.xCodUsuario := Controller.DM.FDQQuery.FieldByName('IDFUNCIONARIO').AsInteger;


    //
    // PEGA OS DADOS DO ULTIMO ACESSO
    //
    if not Controller.DM.FDQQuery.FieldByName('DataUltimoAcesso').IsNull then
      Controller.xDataUltimoAcesso := FormatDateTime('dd/mm/yyyy', Controller.DM.FDQQuery.FieldByName('DataUltimoAcesso').asDateTime) + ' �s ' + FormatDateTime('hh:nn', Controller.DM.FDQQuery.FieldByName('DataUltimoAcesso').asDateTime) + ' hs.'
    else
      Controller.xDataUltimoAcesso := '1� acesso';


    //
    // GRAVA DATA DO ACESSO ATUAL
    //
    Controller.DM.FDQQuery2.Close;
    Controller.DM.FDQQuery2.SQL.Clear;
    Controller.DM.FDQQuery2.SQL.Add('Update FUNCIONARIOS set ');
    Controller.DM.FDQQuery2.SQL.Add('       DATAULTIMOACESSO = CURRENT_TIMESTAMP '); //'''+FormatDateTime('mm.dd.yyyy hh:nn:ss', Now)+''' ');
    Controller.DM.FDQQuery2.SQL.Add('WHERE (Usuario = '''+IWLOGIN.Text+''') ');
    Controller.DM.FDQQuery2.ExecSQL;

    //
    // ABRE A TELA INICIAL
    //
    Controller.AcaoMenu('Iniciar');
    Abort;
  end
  else
  begin
    //
    // SE N�O � FUNCIONARIO ENT�O TESTA SE � CLIENTE
    //
    Controller.DM.FDQQuery.Close;
    Controller.DM.FDQQuery.SQL.Clear;
    Controller.DM.FDQQuery.SQL.Add('Select * from CLIENTES ');
    Controller.DM.FDQQuery.SQL.Add('Where CNPJ = '''+IWCNPJ.Text+''' and ');
    Controller.DM.FDQQuery.SQL.Add('      Email = '''+IWLOGIN.Text+''' and ');
    Controller.DM.FDQQuery.SQL.Add('      Senha = '''+Controller.MD5(IWSenha.Text)+''' ');
    Controller.DM.FDQQuery.Open;

    if Controller.DM.FDQQuery.RecordCount > 0 then
    begin
      //
      // Adiciona valor ao Cookie ou cria se nao existir duracao de 30 dias
      //
      Webapplication.Response.Cookies.AddCookie('IWCNPJ', IWCNPJ.Text, '', now + 30);
      Webapplication.Response.Cookies.AddCookie('IWLOGIN', IWLOGIN.Text, '', now + 30);


      //
      // MONTA O NOME DO CLIENTE e CODIGO PARA A TELA INICIAL
      //
      Controller.xCliente := Controller.DM.FDQQuery.FieldByName('RAZAOSOCIAL').asString + '<small> CNPJ: '+Controller.DM.FDQQuery.FieldByName('CNPJ').asString+'</small>';
      Controller.xCodCliente := Controller.DM.FDQQuery.FieldByName('IDCLIENTE').AsInteger;

      //
      // PEGA O NOME DO USUARIO
      //
      Controller.xUsuario := IWLOGIN.Text;


      //
      // PEGA OS DADOS DO ULTIMO ACESSO
      //
      if not Controller.DM.FDQQuery.FieldByName('DataUltimoAcesso').IsNull then
        Controller.xDataUltimoAcesso := FormatDateTime('dd/mm/yyyy', Controller.DM.FDQQuery.FieldByName('DataUltimoAcesso').asDateTime) + ' �s ' + FormatDateTime('hh:nn', Controller.DM.FDQQuery.FieldByName('DataUltimoAcesso').asDateTime) + ' hs.'
      else
        Controller.xDataUltimoAcesso := '1� acesso';


      //
      // GRAVA DATA DO ACESSO ATUAL
      //
      Controller.DM.FDQQuery2.Close;
      Controller.DM.FDQQuery2.SQL.Clear;
      Controller.DM.FDQQuery2.SQL.Add('Update CLIENTES set ');
      Controller.DM.FDQQuery2.SQL.Add('       DATAULTIMOACESSO = CURRENT_TIMESTAMP '); //'''+FormatDateTime('mm.dd.yyyy hh:nn:ss', Now)+''' ');
      Controller.DM.FDQQuery2.SQL.Add('WHERE (EMAIL = '''+IWLOGIN.Text+''') and ');
      Controller.DM.FDQQuery2.SQL.Add('      (CNPJ = '''+IWCNPJ.Text+''') ');
      Controller.DM.FDQQuery2.ExecSQL;

      //
      // ABRE A TELA INICIAL
      //
      Controller.AcaoMenu('IniciarCliente');
      Abort;
    end
    else
    begin
      Controller.DM.FDQQuery.Close;
      Controller.DM.FDQQuery2.Close;
      AddToInitProc(swalError('ATEN��O','Aten��o!!! CNPJ, Usuario e ou Senha Inv�lido(s) !'));


      //
      // CHECA SE CAMPOS FORAM PREENCHIDOS ANTES DE LOGAR
      //
      IWSENHA.SetFocus;
      if (IWCNPJ.Text = '') then
      begin
        IWCNPJ.SetFocus;
        Abort;
      end;
      if (IWLogin.Text = '') then
      begin
        IWLogin.SetFocus;
        Abort;
      end;


    end;
  end;
end;



procedure TFrmLogin.IWCNPJHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  ATag.Add('placeholder="Informe o CNPJ da Empresa"');
  ATag.Add('data-inputmask="''mask'': ''99.999.999/9999-99''" data-mask');
//            data-inputmask="'mask': '(999) 999-9999'" data-mask
end;



procedure TFrmLogin.IWLOGINHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  ATag.Add('placeholder="Informe o EMail/Usu�rio da Empresa"');
end;



procedure TFrmLogin.IWSENHAHTMLTag(ASender: TObject; ATag: TIWHTMLTag);
begin
  ATag.Add('placeholder="Informe a Senha do Usu�rio"');
end;



procedure TFrmLogin.NovaSenha2AsyncExit(Sender: TObject;
  EventParams: TStringList);
begin
  if NovaSenha.Text <> NovaSenha2.Text then
  begin
    NovaSenha.Text := '';
    NovaSenha2.Text := '';
    NovaSenha.SetFocus;
    WebApplication.CallBackResponse.AddJavaScriptToExecute(swalError('ATEN��O','Aten��o!!! Senhas digitadas n�o Conferem, tente novamente !'));
  end;
end;



initialization
  TFrmLogin.SetAsMainForm;

end.
