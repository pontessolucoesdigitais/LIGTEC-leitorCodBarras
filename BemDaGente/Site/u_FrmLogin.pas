unit u_FrmLogin;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes, Vcl.Controls,
  IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl, IWCompText,
  IWVCLComponent, IWBaseLayoutComponent, IWBaseContainerLayout,
  IWContainerLayout, IWTemplateProcessorHTML, IWCompEdit, IWCompButton;

type
  TFrmLogin = class(TIWAppForm)
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    txtSenha: TIWEdit;
    txtUsuario: TIWEdit;
    btnEntrar: TIWButton;
  public
  end;

implementation

{$R *.dfm}


initialization
  TFrmLogin.SetAsMainForm;

end.
