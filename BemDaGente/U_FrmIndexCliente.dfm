inherited FrmIndexCliente: TFrmIndexCliente
  OnCreate = IWAppFormCreate
  OnDestroy = IWAppFormDestroy
  DesignLeft = 8
  DesignTop = 8
  object PesquisaProblema: TIWEdit [2]
    Left = 24
    Top = 104
    Width = 121
    Height = 21
    ExtraTagParams.Strings = (
      'placeholder="Informe parte do Problema..."')
    Css = 'form-control'
    RenderSize = False
    StyleRenderOptions.RenderSize = False
    StyleRenderOptions.RenderPosition = False
    StyleRenderOptions.RenderFont = False
    StyleRenderOptions.RenderZIndex = False
    StyleRenderOptions.RenderVisibility = False
    StyleRenderOptions.RenderStatus = False
    StyleRenderOptions.RenderAbsolute = False
    StyleRenderOptions.RenderPadding = False
    StyleRenderOptions.RenderBorder = False
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    FriendlyName = 'PesquisaProblema'
    SubmitOnAsyncEvent = True
    TabOrder = 2
  end
  object PesquisaSolucao: TIWEdit [3]
    Left = 24
    Top = 131
    Width = 121
    Height = 21
    ExtraTagParams.Strings = (
      'placeholder="Informe parte da Solu'#231#227'o..."')
    Css = 'form-control'
    RenderSize = False
    StyleRenderOptions.RenderSize = False
    StyleRenderOptions.RenderPosition = False
    StyleRenderOptions.RenderFont = False
    StyleRenderOptions.RenderZIndex = False
    StyleRenderOptions.RenderVisibility = False
    StyleRenderOptions.RenderStatus = False
    StyleRenderOptions.RenderAbsolute = False
    StyleRenderOptions.RenderPadding = False
    StyleRenderOptions.RenderBorder = False
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    FriendlyName = 'PesquisaSolucao'
    SubmitOnAsyncEvent = True
    TabOrder = 3
  end
  object Chamados: TIWLabel [4]
    Left = 24
    Top = 176
    Width = 66
    Height = 16
    RenderSize = False
    StyleRenderOptions.RenderSize = False
    StyleRenderOptions.RenderPosition = False
    StyleRenderOptions.RenderFont = False
    StyleRenderOptions.RenderZIndex = False
    StyleRenderOptions.RenderVisibility = False
    StyleRenderOptions.RenderStatus = False
    StyleRenderOptions.RenderAbsolute = False
    StyleRenderOptions.RenderPadding = False
    StyleRenderOptions.RenderBorder = False
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    HasTabOrder = False
    FriendlyName = 'Chamados'
    Caption = 'Chamados'
    RawText = True
  end
  object Pesquisa: TIWLabel [5]
    Left = 24
    Top = 203
    Width = 55
    Height = 16
    RenderSize = False
    StyleRenderOptions.RenderSize = False
    StyleRenderOptions.RenderPosition = False
    StyleRenderOptions.RenderFont = False
    StyleRenderOptions.RenderZIndex = False
    StyleRenderOptions.RenderVisibility = False
    StyleRenderOptions.RenderStatus = False
    StyleRenderOptions.RenderAbsolute = False
    StyleRenderOptions.RenderPadding = False
    StyleRenderOptions.RenderBorder = False
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    HasTabOrder = False
    FriendlyName = 'Chamados'
    Caption = 'Pesquisa'
    RawText = True
  end
  object BTNSENHA: TIWButton [6]
    Left = 24
    Top = 489
    Width = 105
    Height = 25
    Caption = 'BTNSENHA'
    Color = clBtnFace
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    FriendlyName = 'BTNSENHA'
    TabOrder = 4
    OnClick = BTNSENHAClick
  end
  object SenhaAtual: TIWEdit [7]
    Left = 24
    Top = 391
    Width = 121
    Height = 21
    Css = 'form-control'
    RenderSize = False
    StyleRenderOptions.RenderSize = False
    StyleRenderOptions.RenderPosition = False
    StyleRenderOptions.RenderFont = False
    StyleRenderOptions.RenderZIndex = False
    StyleRenderOptions.RenderVisibility = False
    StyleRenderOptions.RenderStatus = False
    StyleRenderOptions.RenderAbsolute = False
    StyleRenderOptions.RenderPadding = False
    StyleRenderOptions.RenderBorder = False
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    FriendlyName = 'SenhaAtual'
    SubmitOnAsyncEvent = True
    TabOrder = 5
    PasswordPrompt = True
  end
  object NovaSenha: TIWEdit [8]
    Left = 24
    Top = 418
    Width = 121
    Height = 21
    Css = 'form-control'
    RenderSize = False
    StyleRenderOptions.RenderSize = False
    StyleRenderOptions.RenderPosition = False
    StyleRenderOptions.RenderFont = False
    StyleRenderOptions.RenderZIndex = False
    StyleRenderOptions.RenderVisibility = False
    StyleRenderOptions.RenderStatus = False
    StyleRenderOptions.RenderAbsolute = False
    StyleRenderOptions.RenderPadding = False
    StyleRenderOptions.RenderBorder = False
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    FriendlyName = 'NovaSenha'
    SubmitOnAsyncEvent = True
    TabOrder = 6
    PasswordPrompt = True
  end
  object NovaSenha2: TIWEdit [9]
    Left = 24
    Top = 445
    Width = 121
    Height = 21
    Css = 'form-control'
    RenderSize = False
    StyleRenderOptions.RenderSize = False
    StyleRenderOptions.RenderPosition = False
    StyleRenderOptions.RenderFont = False
    StyleRenderOptions.RenderZIndex = False
    StyleRenderOptions.RenderVisibility = False
    StyleRenderOptions.RenderStatus = False
    StyleRenderOptions.RenderAbsolute = False
    StyleRenderOptions.RenderPadding = False
    StyleRenderOptions.RenderBorder = False
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    FriendlyName = 'NovaSenha'
    SubmitOnAsyncEvent = True
    TabOrder = 7
    PasswordPrompt = True
  end
  object IDSOLICITACAO: TIWDBLookupComboBox [10]
    Left = 600
    Top = 32
    Width = 121
    Height = 21
    Css = 'form-control'
    RenderSize = False
    StyleRenderOptions.RenderSize = False
    StyleRenderOptions.RenderPosition = False
    StyleRenderOptions.RenderFont = False
    StyleRenderOptions.RenderZIndex = False
    StyleRenderOptions.RenderVisibility = False
    StyleRenderOptions.RenderStatus = False
    StyleRenderOptions.RenderAbsolute = False
    StyleRenderOptions.RenderPadding = False
    StyleRenderOptions.RenderBorder = False
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    TabOrder = 8
    AutoEditable = False
    DataField = 'IDSOLICITACAO'
    DataSource = dsChamado
    FriendlyName = 'IDSOLICITACAO'
    KeyField = 'IDSOLICITACAO'
    ListField = 'DESCRICAO'
    ListSource = dsSolicitacao
    DisableWhenEmpty = True
    NoSelectionText = '-- N'#227'o Selecionado --'
  end
  object IDPRODUTO: TIWDBLookupComboBox [11]
    Left = 600
    Top = 59
    Width = 121
    Height = 21
    Css = 'form-control'
    RenderSize = False
    StyleRenderOptions.RenderSize = False
    StyleRenderOptions.RenderPosition = False
    StyleRenderOptions.RenderFont = False
    StyleRenderOptions.RenderZIndex = False
    StyleRenderOptions.RenderVisibility = False
    StyleRenderOptions.RenderStatus = False
    StyleRenderOptions.RenderAbsolute = False
    StyleRenderOptions.RenderPadding = False
    StyleRenderOptions.RenderBorder = False
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    TabOrder = 9
    AutoEditable = False
    DataField = 'IDPRODUTO'
    DataSource = dsChamado
    FriendlyName = 'IWDBLookupComboBox1'
    KeyField = 'IDPRODUTO'
    ListField = 'DESCRICAO'
    ListSource = dsProdutos
    DisableWhenEmpty = True
    NoSelectionText = '-- N'#227'o Selecionado --'
  end
  object NOMESOLICITANTE: TIWDBEdit [12]
    Left = 600
    Top = 113
    Width = 121
    Height = 21
    Css = 'form-control'
    RenderSize = False
    StyleRenderOptions.RenderSize = False
    StyleRenderOptions.RenderPosition = False
    StyleRenderOptions.RenderFont = False
    StyleRenderOptions.RenderZIndex = False
    StyleRenderOptions.RenderVisibility = False
    StyleRenderOptions.RenderStatus = False
    StyleRenderOptions.RenderAbsolute = False
    StyleRenderOptions.RenderPadding = False
    StyleRenderOptions.RenderBorder = False
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    FriendlyName = 'NOMESOLICITANTE'
    MaxLength = 30
    SubmitOnAsyncEvent = True
    TabOrder = 11
    AutoEditable = False
    DataField = 'NOMESOLICITANTE'
    PasswordPrompt = False
    DataSource = dsChamado
  end
  object DEPTOSOLICITANTE: TIWDBEdit [13]
    Left = 600
    Top = 140
    Width = 121
    Height = 21
    Css = 'form-control'
    RenderSize = False
    StyleRenderOptions.RenderSize = False
    StyleRenderOptions.RenderPosition = False
    StyleRenderOptions.RenderFont = False
    StyleRenderOptions.RenderZIndex = False
    StyleRenderOptions.RenderVisibility = False
    StyleRenderOptions.RenderStatus = False
    StyleRenderOptions.RenderAbsolute = False
    StyleRenderOptions.RenderPadding = False
    StyleRenderOptions.RenderBorder = False
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    FriendlyName = 'DEPTOSOLICITANTE'
    MaxLength = 30
    SubmitOnAsyncEvent = True
    TabOrder = 12
    AutoEditable = False
    DataField = 'DEPTOSOLICITANTE'
    PasswordPrompt = False
    DataSource = dsChamado
  end
  object DESCRICAOSOLICITACAO: TIWDBMemo [14]
    Left = 600
    Top = 167
    Width = 121
    Height = 37
    ExtraTagParams.Strings = (
      'rows="5"')
    Css = 'form-control'
    RenderSize = False
    StyleRenderOptions.RenderSize = False
    StyleRenderOptions.RenderPosition = False
    StyleRenderOptions.RenderFont = False
    StyleRenderOptions.RenderZIndex = False
    StyleRenderOptions.RenderVisibility = False
    StyleRenderOptions.RenderStatus = False
    StyleRenderOptions.RenderAbsolute = False
    StyleRenderOptions.RenderPadding = False
    StyleRenderOptions.RenderBorder = False
    BGColor = clNone
    Editable = True
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    InvisibleBorder = False
    HorizScrollBar = False
    VertScrollBar = True
    Required = False
    TabOrder = 13
    SubmitOnAsyncEvent = True
    AutoEditable = False
    DataField = 'DESCRICAOSOLICITACAO'
    DataSource = dsChamado
    FriendlyName = 'DESCRICAOSOLICITACAO'
  end
  object PRIORIDADE: TIWDBComboBox [15]
    Left = 600
    Top = 86
    Width = 121
    Height = 21
    Css = 'form-control'
    RenderSize = False
    StyleRenderOptions.RenderSize = False
    StyleRenderOptions.RenderPosition = False
    StyleRenderOptions.RenderFont = False
    StyleRenderOptions.RenderZIndex = False
    StyleRenderOptions.RenderVisibility = False
    StyleRenderOptions.RenderStatus = False
    StyleRenderOptions.RenderAbsolute = False
    StyleRenderOptions.RenderPadding = False
    StyleRenderOptions.RenderBorder = False
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    ItemsHaveValues = True
    TabOrder = 10
    AutoEditable = False
    DataField = 'PRIORIDADE'
    DataSource = dsChamado
    FriendlyName = 'PRIORIDADE'
    ItemIndex = 0
    Items.Strings = (
      'Baixa=Baixa'
      'M'#233'dia=Media'
      'Alta=Alta')
    NoSelectionText = '-- N'#227'o Selecionado --'
  end
  object BtnCancelar: TIWButton [16]
    Left = 600
    Top = 224
    Width = 75
    Height = 25
    Caption = 'BtnCancelar'
    Color = clBtnFace
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    FriendlyName = 'BtnCancelar'
    TabOrder = 14
    OnClick = BtnCancelarClick
  end
  object BtnGravar: TIWButton [17]
    Left = 681
    Top = 224
    Width = 75
    Height = 25
    Caption = 'BtnGravar'
    Color = clBtnFace
    Font.Color = clNone
    Font.Size = 10
    Font.Style = []
    FriendlyName = 'BtnCancelar'
    TabOrder = 15
    OnClick = BtnGravarClick
  end
  inherited IWTemplateProcessorHTML1: TIWTemplateProcessorHTML
    MasterTemplate = 'MasterCliente.html'
    Left = 512
    Top = 408
  end
  object dsChamado: TDataSource
    DataSet = DM.FDQChamadosCad
    Left = 776
    Top = 40
  end
  object dsSolicitacao: TDataSource
    DataSet = DM.FDQSolicitacoes
    Left = 776
    Top = 96
  end
  object dsProdutos: TDataSource
    DataSet = DM.FDQProdutos
    Left = 776
    Top = 152
  end
end
