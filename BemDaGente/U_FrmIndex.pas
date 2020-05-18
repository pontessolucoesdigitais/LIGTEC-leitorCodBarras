unit U_FrmIndex;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, U_FrmPadrao, IWVCLComponent,
  IWBaseLayoutComponent, IWBaseContainerLayout, IWContainerLayout,
  IWTemplateProcessorHTML, IWCompButton, IWVCLBaseControl, IWBaseControl,
  IWBaseHTMLControl, IWControl, IWCompEdit, IWCompLabel;

type
  TFrmIndex = class(TFrmPadrao)
    procedure IWAppFormCreate(Sender: TObject);
    procedure IWTemplateProcessorHTML1UnknownTag(const AName: string;
      var VValue: string);
  private
    { Private declarations }
    TotalChamados : Integer;
  public
    { Public declarations }
  end;

var
  FrmIndex: TFrmIndex;

implementation

{$R *.dfm}

uses SweetAlerts, ServerController, System.Math, funcoes,
  System.DateUtils;

procedure TFrmIndex.IWAppFormCreate(Sender: TObject);
begin
  inherited;
  //
  //  MONTAGEM DO MENU VINDO DO BANCO DE DADOS
  //

  Controller.DM.FDQMenu.Close;
  Controller.DM.FDQMenu.Open;

  //Home

  Controller.MenuPrincipal := ' <ul class="sidebar-menu" data-widget="tree"> ' + #13 + #10 +
                              '    <li class="header">Menu Principal</li> ' + #13 + #10 +
                              '    <li> ' + #13 + #10 +
                              '      <a href="javascript: SetaAcao(''Menu'', ''Iniciar'');"> ' + #13 + #10 +
                              '        <i class="fa fa-lg fa-fw fa-home"></i> ' + #13 + #10 +
                              '        <span class="menu-item-parent"> In�cio </span>' + #13 + #10 +
                              '      </a> ' + #13 + #10 +
                              '    </li> '+#13+#10;
  Controller.DM.FDQMenu.First;

  while not Controller.DM.FDQMenu.Eof do
  begin
    if Controller.DM.FDQMenuNIVELMENU.AsString = 'Menu Nivel 1' then
    begin
      //          <li>
      //						<a href="#"><i class="fa fa-lg fa-fw fa-puzzle-piece"></i> <span class="menu-item-parent">App Views</span></a>
      //						<ul>

      Controller.MenuPrincipal := Controller.MenuPrincipal + '          <li class="treeview"> ' + #13 + #10 +
                                                             '            <a href="javascript: void(0);"> ' + #13 + #10 +
                                                             '              <i class="'+Controller.DM.FDQMenuICONE.AsString+'">&nbsp;</i>&nbsp; ' + #13 + #10 +
                                                             '                <span>'+Controller.DM.FDQMenuDESCRICAO.AsString + '</span> ' + #13 + #10 +
                                                             '              <span class="pull-right-container"> ' + #13 + #10 +
                                                             '                <i class="fa fa-angle-left pull-right"></i>  ' + #13 + #10 +
                                                             '               </span>          ' + #13 + #10 +
                                                             '            </a> ' + #13 + #10 +
                                                             '            <ul class="treeview-menu"> ' + #13 + #10;
    end;



    if Controller.DM.FDQMenuNIVELMENU.AsString = 'Item Nivel 1' then
    begin
//            <li><a href="index2.html"><i class="fa fa-circle-o"></i> Dashboard v2</a></li>
      Controller.MenuPrincipal := Controller.MenuPrincipal + '							<li> ' + #13 + #10 +
                                                             '							  <a href="javascript: SetaAcao(''Menu'', '''+Controller.DM.FDQMenuNOMEFORM.AsString+''');"> ' + #13 + #10 +
                                                             '              <i class="'+Controller.DM.FDQMenuICONE.AsString+'">&nbsp;</i>&nbsp; ' + #13 + #10 +
                                                             '							    '+Controller.DM.FDQMenuDESCRICAO.AsString + #13 + #10 +
                                                             '							  </a> ' + #13 + #10 +
                                                             '							</li> ' + #13 + #10;
    end;

    if Controller.DM.FDQMenuNIVELMENU.AsString = 'Item' then
    begin
      //							<li>
      //								<a href="projects.html"><i class="fa fa-file-text-o"></i><span class="menu-item-parent"> Projects</span></a>
      //							</li>
      Controller.MenuPrincipal := Controller.MenuPrincipal + '							<li> ' + #13 + #10 +
                                                             '							  <a href="javascript: SetaAcao(''Menu'', '''+Controller.DM.FDQMenuNOMEFORM.AsString+''');"> ' + #13 + #10 +
                                                             '                  <i class="'+Controller.DM.FDQMenuICONE.AsString+'"></i> &nbsp;' + #13 + #10 +
                                                             '							    <span class="menu-item-parent"> '+Controller.DM.FDQMenuDESCRICAO.AsString + '</span> '+ #13 + #10 +
                                                             '							  </a> ' + #13 + #10 +
                                                             '							</li> ' + #13 + #10;
    end;

    if Controller.DM.FDQMenuNIVELMENU.AsString = 'Menu Nivel 2' then
    begin
      //							<li>                     n�o coloquei imagem para os itens, mas podemos colocar
      //								<a href="#"><i class="fa fa-comments"></i> Forum Layout</a>
      //								<ul>
      Controller.MenuPrincipal := Controller.MenuPrincipal + '							<li> ' + #13 + #10 +
                                                             '							  <a href="javascript: void(0);"> ' + #13 + #10 +
                                                             '							    '+Controller.DM.FDQMenuDESCRICAO.AsString + #13 + #10 +
                                                             '							  </a> ' + #13 + #10 +
                                                             '                <ul> ' + #13 + #10;
    end;

    if Controller.DM.FDQMenuNIVELMENU.AsString = 'Item Nivel 2' then
    begin
      //									<li><a href="forum.html">General View</a></li>
      Controller.MenuPrincipal := Controller.MenuPrincipal + '									<li> ' + #13 + #10 +
                                                             '									  <a href="javascript: SetaAcao(''Menu'', '''+Controller.DM.FDQMenuNOMEFORM.AsString+''');"> ' + #13 + #10 +
                                                             '									    '+Controller.DM.FDQMenuDESCRICAO.AsString + #13 + #10 +
                                                             '									  </a> ' + #13 + #10 +
                                                             '									</li> ' + #13 + #10;
    end;

    if Controller.DM.FDQMenuNIVELMENU.AsString = 'Menu Nivel 3' then
    begin
      Controller.MenuPrincipal := Controller.MenuPrincipal + '						    	<li> ' + #13 + #10 +
                                                             '							      <a href="javascript: void(0);"> ' + #13 + #10 +
                                                             '							        '+Controller.DM.FDQMenuDESCRICAO.AsString + #13 + #10 +
                                                             '							      </a> ' + #13 + #10 +
                                                             '                    <ul> ' + #13 + #10;
    end;

    if Controller.DM.FDQMenuNIVELMENU.AsString = 'Item Nivel 3' then
    begin
      Controller.MenuPrincipal := Controller.MenuPrincipal + '                      <li> ' + #13 + #10 +
                                                             '                        <a href="javascript: SetaAcao(''Menu'', '''+Controller.DM.FDQMenuNOMEFORM.AsString+''');" class="menu-item" data-i18n="nav.'+Controller.DM.FDQMenuITEM.AsString+'"> ' + #13 + #10 +
                                                             '                          '+Controller.DM.FDQMenuDESCRICAO.AsString + #13 + #10 +
                                                             '                        </a> ' + #13 + #10 +
                                                             '                      </li> ' + #13 + #10;
    end;

    if Controller.DM.FDQMenuNIVELMENU.AsString = 'Fim Menu 1' then
    begin
      Controller.MenuPrincipal := Controller.MenuPrincipal + '            </ul> ' + #13 + #10 +
                                                             '          </li> ' + #13 + #10;
    end;

    if Controller.DM.FDQMenuNIVELMENU.AsString = 'Fim Menu 2' then
    begin
      Controller.MenuPrincipal := Controller.MenuPrincipal + '                </ul> ' + #13 + #10 +
                                                             '              </li> ' + #13 + #10;
    end;

    if Controller.DM.FDQMenuNIVELMENU.AsString = 'Fim Menu 3' then
    begin
      Controller.MenuPrincipal := Controller.MenuPrincipal + '                    </ul> ' + #13 + #10 +
                                                             '                  </li> ' + #13 + #10;
    end;

    Controller.DM.FDQMenu.Next;
  end;
  Controller.MenuPrincipal := Controller.MenuPrincipal + '  </ul> ' + #13 + #10;
  Controller.MenuPrincipal := Controller.MenuPrincipal + '</nav> ' + #13 + #10;
  Controller.DM.FDQMenu.Close;
  //  FIM MONTAGEM MENU

end;

procedure TFrmIndex.IWTemplateProcessorHTML1UnknownTag(const AName: string;
  var VValue: string);
var
  i : integer;
begin
  inherited;

  if AName = 'Widget1' then   // {%Widget1%}
  begin
    // Widget 1 Chamados Cadastrados no M�s
    Controller.DM.FDQQuery.Close;
    Controller.DM.FDQQuery.SQL.Clear;
    Controller.DM.FDQQuery.SQL.Add('Select Count(idChamado) as Total from CHAMADOS ');
    Controller.DM.FDQQuery.SQL.Add('Where DATAHORAABERTURA >= '''+FormatDateTime('dd.mm.yyyy', StrToDate('01'+Copy(DateToStr(Now),3,8)))+''' ');
    Controller.DM.FDQQuery.Open;
    VValue := Controller.DM.FDQQuery.FieldByName('Total').AsString;
    TotalChamados := Controller.DM.FDQQuery.FieldByName('Total').AsInteger;
    Controller.DM.FDQQuery.Close;
  end;


  if AName = 'Widget2' then
  begin
    // Widget 2 Chamados em Aberto no M�s
    Controller.DM.FDQQuery.Close;
    Controller.DM.FDQQuery.SQL.Clear;
    Controller.DM.FDQQuery.SQL.Add('Select Count(idChamado) as Total from CHAMADOS ');
    Controller.DM.FDQQuery.SQL.Add('Where DATAHORAABERTURA >= '''+FormatDateTime('dd.mm.yyyy', StrToDate('01'+Copy(DateToStr(Now),3,8)))+''' and ');
    Controller.DM.FDQQuery.SQL.Add('      CAST((current_timestamp - CAST(DATAHORAABERTURA AS TIMESTAMP))*24 AS INTEGER) < 24 and ');
    Controller.DM.FDQQuery.SQL.Add('      SITUACAO = ''Aberto'' ');
    Controller.DM.FDQQuery.Open;
    VValue := Controller.DM.FDQQuery.FieldByName('Total').AsString;
    Controller.DM.FDQQuery.Close;
  end;


  if AName = 'Widget3' then
  begin
    // Widget 3 Chamados Cadastrados no M�s
    Controller.DM.FDQQuery.Close;
    Controller.DM.FDQQuery.SQL.Clear;
    Controller.DM.FDQQuery.SQL.Add('Select Count(idChamado) as Total from CHAMADOS ');
    Controller.DM.FDQQuery.SQL.Add('Where DATAHORAABERTURA >= '''+FormatDateTime('dd.mm.yyyy', StrToDate('01'+Copy(DateToStr(Now),3,8)))+''' and ');
    Controller.DM.FDQQuery.SQL.Add('      CAST((current_timestamp - CAST(DATAHORAABERTURA AS TIMESTAMP))*24 AS INTEGER) >= 24 and ');
    Controller.DM.FDQQuery.SQL.Add('      SITUACAO = ''Aberto'' ');
    Controller.DM.FDQQuery.Open;
    VValue := Controller.DM.FDQQuery.FieldByName('Total').AsString;
    Controller.DM.FDQQuery.Close;
  end;


  if AName = 'Widget4' then
  begin
    // Widget 4 Chamados Cadastrados no M�s
    Controller.DM.FDQQuery.Close;
    Controller.DM.FDQQuery.SQL.Clear;
    Controller.DM.FDQQuery.SQL.Add('Select Count(idChamado) as Total from CHAMADOS ');
    Controller.DM.FDQQuery.SQL.Add('Where DATAHORAABERTURA >= '''+FormatDateTime('dd.mm.yyyy', StrToDate('01'+Copy(DateToStr(Now),3,8)))+''' and ');
    Controller.DM.FDQQuery.SQL.Add('      SITUACAO = ''Fechado'' ');
    Controller.DM.FDQQuery.Open;
    VValue := Controller.DM.FDQQuery.FieldByName('Total').AsString;
    Controller.DM.FDQQuery.Close;
  end;

  if AName = 'TituloGrafico' then
    VValue := 'Chamadas de 01'+Copy(DateToStr(Now),3,8)+' a '+DateToStr(Now);

  if AName = 'Ranking' then
  begin
    // Widget de Ranking
    Controller.DM.FDQQuery.Close;
    Controller.DM.FDQQuery.SQL.Clear;
    Controller.DM.FDQQuery.SQL.Add('Select s.idsolicitacao, s.descricao, ');
    Controller.DM.FDQQuery.SQL.Add('       (Select Count(*) from CHAMADOS c ');
    Controller.DM.FDQQuery.SQL.Add('        Where c.DATAHORAABERTURA >= '''+FormatDateTime('dd.mm.yyyy', StrToDate('01'+Copy(DateToStr(Now),3,8)))+''' and ');
    Controller.DM.FDQQuery.SQL.Add('              c.idsolicitacao = s.idsolicitacao) as Total ');
    Controller.DM.FDQQuery.SQL.Add('From solicitacoes s ');
    Controller.DM.FDQQuery.SQL.Add('Order by s.idsolicitacao ');
    Controller.DM.FDQQuery.Open;

    Controller.DM.FDQQuery.First;

    i := 1;
    VValue := '';
    while not Controller.DM.FDQQuery.Eof do
    begin
//      VValue := VValue + '											<div class="progress-group"> '+SLineBreak+
//                         '												  <span class="progress-text">'+Controller.DM.FDQQuery.FieldByName('Descricao').AsString+'</span> '+SLineBreak+
//                         '												  <span class="progress-number"><b>'+Controller.DM.FDQQuery.FieldByName('Total').AsString+'</b>/'+TotalChamados.ToString+'</span> '+SLineBreak+
//                         '												  <div class="progress sm"> '+SLineBreak+
//                         '													  <div class="progress-bar '+Controller.IIf(i=1,'progress-bar-aqua',Controller.IIf(i=2,'progress-bar-red',Controller.IIf(i=3,'progress-bar-green',Controller.IIf(i=4,'progress-bar-yellow','progress-bar-yellow'))))+'" style="width: '+Controller.IIf(TotalChamados > 0, IntToStr(Ceil(Controller.DM.FDQQuery.FieldByName('Total').AsInteger/TotalChamados*100)), '0')+'%"></div> '+SLineBreak+
//                         '												  </div> '+SLineBreak+
//                         '											</div> '+SLineBreak;

      VValue := VValue + '											<div class="progress-group"> '+SLineBreak+
                         '												  <span class="progress-text">'+Controller.DM.FDQQuery.FieldByName('Descricao').AsString+'</span> '+SLineBreak+
                         '												  <span class="progress-number"><b>'+Controller.DM.FDQQuery.FieldByName('Total').AsString+'</b>/'+TotalChamados.ToString+'</span> '+SLineBreak+
                         '												  <div class="progress sm"> '+SLineBreak+
                         '													  <div class="progress-bar '+Controller.IIf(i=1,'progress-bar-aqua',Controller.IIf(i=2,'progress-bar-red',Controller.IIf(i=3,'progress-bar-green',Controller.IIf(i=4,'progress-bar-yellow','progress-bar-yellow'))))+
                         '                                 " style="width: ';

      If TotalChamados > 0 then
        VValue := VValue + IntToStr(Ceil(Controller.DM.FDQQuery.FieldByName('Total').AsInteger/TotalChamados*100)) + '%"></div> '+SLineBreak
      else
        VValue := VValue + '0%"></div> '+SLineBreak;

      VValue := VValue + '												  </div> '+SLineBreak;
      VValue := VValue + '											</div> '+SLineBreak;
      i := i + 1;
      Controller.DM.FDQQuery.Next;
    end;
    Controller.DM.FDQQuery.Close;
  end;


  if AName = 'LabelGrafico' then
  begin
    // '01/jan', '02/jan', '03/jan', '04/jan', '05/jan', '06/jan', '07/jan', '08/jan', '09/jan'
    Controller.DM.FDQQuery.Close;
    Controller.DM.FDQQuery.SQL.Clear;
    Controller.DM.FDQQuery.SQL.Add('Select Cast(DATAHORAABERTURA as Date) as Data, Count(*) as Total from CHAMADOS ');
    Controller.DM.FDQQuery.SQL.Add('Where Cast(DATAHORAABERTURA as Date) >= ''01.'+Copy(DateToStr(Now),4,2)+'.'+Copy(DateToStr(Now),7,4)+''' ');
    Controller.DM.FDQQuery.SQL.Add('Group by Cast(DATAHORAABERTURA as Date) ');
    Controller.DM.FDQQuery.Open;
    Controller.DM.FDQQuery.First;

    VValue := '';
    while not Controller.DM.FDQQuery.Eof do
    begin
      if VValue <> '' then VValue := VValue + ', ';
      VValue := VValue + '''' + Copy(Controller.DM.FDQQuery.FieldByName('Data').AsString,1,2) + '/' + Copy(Month(MonthOf(now)),1,3) + '''';
      Controller.DM.FDQQuery.Next;
    end;
    Controller.DM.FDQQuery.Close;
  end;


  if AName = 'DataGrafico' then
  begin
    // 100, 159, 80, 81, 56, 55, 40, 60, 130, 140, 102
    Controller.DM.FDQQuery.Close;
    Controller.DM.FDQQuery.SQL.Clear;
    Controller.DM.FDQQuery.SQL.Add('Select Cast(DATAHORAABERTURA as Date) as Data, Count(*) as Total from CHAMADOS ');
    Controller.DM.FDQQuery.SQL.Add('Where Cast(DATAHORAABERTURA as Date) >= ''01.'+Copy(DateToStr(Now),4,2)+'.'+Copy(DateToStr(Now),7,4)+''' ');
    Controller.DM.FDQQuery.SQL.Add('Group by Cast(DATAHORAABERTURA as Date) ');
    Controller.DM.FDQQuery.Open;
    Controller.DM.FDQQuery.First;

    VValue := '';
    while not Controller.DM.FDQQuery.Eof do
    begin

      if VValue <> '' then VValue := VValue + ', ';
      VValue := VValue + Controller.DM.FDQQuery.FieldByName('Total').AsString;

      Controller.DM.FDQQuery.Next;
    end;
    Controller.DM.FDQQuery.Close;
  end;

end;

end.