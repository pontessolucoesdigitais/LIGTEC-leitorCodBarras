Imports System.IO
Imports System.Net
Imports System.Runtime.InteropServices
Imports WIA

Public Class frmPrincipal

    Dim di As New DirectoryInfo(My.Settings.localArmazenamento)
    Dim diLote As New DirectoryInfo(My.Settings.localArmazenamento)

    Dim InitialZoom As Integer = 100
    Public Enum Exec
        OLECMDID_OPTICAL_ZOOM = 63
    End Enum
    Private Enum execOpt
        OLECMDEXECOPT_DODEFAULT = 0
        OLECMDEXECOPT_PROMPTUSER = 1
        OLECMDEXECOPT_DONTPROMPTUSER = 2
        OLECMDEXECOPT_SHOWHELP = 3
    End Enum

    Dim dic As New Dictionary(Of Int32, item)

    Private Sub frmPrincipal_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        Application.DoEvents()
        CarregaForm()
    End Sub

    Private Sub btnScan_Click(sender As Object, e As EventArgs) Handles btnScan.Click

        btnScan.Enabled = False
        diLote = Nothing
        diLote = New DirectoryInfo(di.FullName & "\imagens\" & lblLote.Text)
        dic.Clear()

        For iAux As Integer = 1 To 100

            Dim pnl As Panel = DirectCast(Controls.Find("pnl" & iAux.ToString.PadLeft(2, "0"), True)(0), Panel)
            pnl.BackgroundImage = Nothing

        Next

        If Not di.Exists Then
            di.Create()
        End If

        If Not diLote.Exists Then
            diLote.Create()
            Directory.CreateDirectory(diLote.FullName & "\ori")

        Else

            If MsgBox("Lote já carregado anteriormente. Deseja substiuir?", vbQuestion + vbYesNo) = MsgBoxResult.No Then
                MsgBox("Verifique o número do lote atual", vbExclamation)
                btnScan.Enabled = True
                Exit Sub
            Else
                Try
                    diLote.Delete(True)
                    diLote.Create()
                    Directory.CreateDirectory(diLote.FullName & "\ori")
                Catch ex As Exception
                    btnScan.Enabled = True
                    MsgBox(ex.Message, vbExclamation)
                End Try
            End If
        End If
        ProcessaImgScanner()

    End Sub

    Public Class item

        Private mIndex As Integer
        Public Property Index() As Integer
            Get
                Return mIndex
            End Get
            Set(ByVal value As Integer)
                mIndex = value
            End Set
        End Property

        Private mCodBarras As String
        Public Property CodBarras() As String
            Get
                Return mCodBarras
            End Get
            Set(ByVal value As String)
                mCodBarras = value
            End Set
        End Property

        Private mPathImg As String
        Public Property PathImg() As String
            Get
                Return mPathImg
            End Get
            Set(ByVal value As String)
                mPathImg = value
            End Set
        End Property

        Private mPathImgBrowser As String
        Public Property PathImgBrowser() As String
            Get
                Return mPathImgBrowser
            End Get
            Set(ByVal value As String)
                mPathImgBrowser = value
            End Set
        End Property

        Private mTexto As String
        Public Property Text() As String
            Get
                Return mTexto
            End Get
            Set(ByVal value As String)
                mTexto = value
            End Set
        End Property

        Public Sub New(index As Integer, codBarras As String, pathImg As String, texto As String)
            mIndex = index
            mCodBarras = codBarras
            mTexto = texto
            mPathImg = pathImg
            mPathImgBrowser = pathImg.Substring(pathImg.IndexOf("imagens"))

        End Sub

    End Class

    Private Sub CarregaForm()
        lblLote.Text = My.Settings.loteAtual.ToString.PadLeft(4, "0")
        lblNumInical.Text = NumeroConcurso

        lblNumInical.Text = NumeroConcurso.ToString.PadLeft(3, "0")
        lblRegional.Text = RegionalLogada.Nome

        lblLocalArmazenamento.Text = My.Settings.localArmazenamento

        'lblTamanhoLeitura.Text = My.Settings.tamanhoLeitura
        'lblLocalArmazenamento.Text = My.Settings.localArmazenamento

    End Sub

    Private Sub pictureBox1_Click(ByVal sender As Object, ByVal e As EventArgs)
    End Sub

    Dim iCont As Integer = 0

    Dim blnValidacaoLote As Boolean = False

    Private Sub panel1_Paint(sender As Object, e As PaintEventArgs) Handles panel1.Paint

    End Sub

    Private Sub tmrScanner_Tick(sender As Object, e As EventArgs) Handles tmrScanner.Tick
        lstListOfScanner.Items.Clear()

        Try
            Dim deviceManager = New DeviceManager()

            For i As Integer = 1 To deviceManager.DeviceInfos.Count

                If deviceManager.DeviceInfos(i).Type <> WiaDeviceType.ScannerDeviceType Then
                    Continue For
                End If

                lstListOfScanner.Items.Add(deviceManager.DeviceInfos(i).Properties("Name").Value())
            Next

            If deviceManager.DeviceInfos.Count > 0 Then
                tmrScanner.Interval = 60000
            End If


        Catch ex As COMException
            MessageBox.Show(ex.Message)
        End Try

    End Sub

    Private Sub ProcessaImgScanner()
        Dim blnAguardar As Boolean = False
        Dim imgFile As ImageFile
        Dim img As Image

        Try
            Dim deviceManager = New DeviceManager()
            Dim AvailableScanner As DeviceInfo = Nothing
            Dim Path2 As String = ""

            If deviceManager.DeviceInfos.Count = 0 Then
                MsgBox("Nehhum scanner instalado", MsgBoxStyle.Exclamation)
                btnScan.Enabled = True
                Return
            End If


            For i As Integer = 1 To deviceManager.DeviceInfos.Count

                If deviceManager.DeviceInfos(i).Type <> WiaDeviceType.ScannerDeviceType Then
                    Continue For
                End If

                AvailableScanner = deviceManager.DeviceInfos(i)
                Exit For
            Next


            Dim device = AvailableScanner.Connect()
            Dim ScanerItem = device.Items(1)


            clsWia.AdjustScannerSettings(ScanerItem, 200, 0, 0, 1420, 550, 0, 0)

            imgFile = CType(ScanerItem.Transfer(FormatID.wiaFormatTIFF), ImageFile)


            'device.AcquiredImages.AutoClean = True


            Dim fileName As String = DateTime.Now.ToString("yyyyMMddHHmmssfff") & ".tif"

            Dim Path = diLote.FullName & "\ori\" & fileName
            Dim PathReduz = diLote.FullName & "\ori\REDUZ_" & fileName

            imgFile.SaveFile(Path)

            'img = UTL.Imagem.reduzirQualidadeImagem(Image.FromFile(Path), 20)
            'Dim file As New FileInfo(Path)
            'img.Save(PathReduz)

            'Dim ciNetProc As ClearImageNetFnc = New ClearImageNetFnc()
            'Dim ciProc As ClearImageFnc = New ClearImageFnc()
            'Dim tbrCode As UInteger = 0
            'UInteger.TryParse("none", tbrCode)
            'ciNetProc.tbrCode = tbrCode
            'ciProc.tbrCode = tbrCode


            Dim img2 As Bitmap
            img = Image.FromFile(Path)
            img2 = New Bitmap(img)
            'Dim retBarCode As String = ciNetProc.read1DautoType(img2)


            Dim pic1 As New PictureBox
            pic1.Image = Image.FromFile(Path)


            Dim reader = New ZXing.BarcodeReader
            reader.AutoRotate = True
            reader.TryInverted = True

            Dim result As ZXing.Result = reader.Decode(img2)
            'ciNetProc = Nothing
            img.Dispose()

            Dim retBarCode As String = result.Text



            If IsNumeric(retBarCode) AndAlso Val(retBarCode) > 0 AndAlso retBarCode.Length = 10 Then
                Dim bilheteConcursoValido As Boolean = retBarCode.StartsWith(NumeroConcurso.ToString.PadLeft(3, "0"))

                If bilheteConcursoValido Then
                    retBarCode = retBarCode.Replace(vbCrLf, "")
                    retBarCode = retBarCode.Substring(3)


                    Try
                        Dim it As item = VerificaDuplicidade(retBarCode)
                        If Not IsNothing(it) Then
                            Select Case Val(My.Settings.loteAtual)
                                Case 0
                                    MsgBox("Arquivo duplicado!" & "Leitura de lote interrompida", MsgBoxStyle.Information + vbOKOnly)
                                    btnScan.Enabled = True
                                    Return
                                Case 1
                                    If MsgBox("Arquivo duplicado!" & "Deseja repetir a leitura?", MsgBoxStyle.Information + vbYesNo) = vbYes Then
                                        ProcessaImgScanner()
                                    End If
                                Case 3

                                    iCont += 1
                                    Path2 = diLote.FullName & "\" & retBarCode & ".jpg "
                                    Dim fi As New FileInfo(it.PathImg)
                                    fi.Delete()



                                    ReduzirQualidadeImagem(Path).Save(Path2, Imaging.ImageFormat.Jpeg)
                                    fi = Nothing

                                    dic(it.Index) = New item(iCont, retBarCode, Path2, "")
                            End Select

                        Else
                            iCont += 1
                            Path2 = diLote.FullName & "\" & retBarCode.Substring(0, 6) & ".jpg"
                            Try
                                ReduzirQualidadeImagem(Path).Save(Path2, Imaging.ImageFormat.Jpeg)
                            Catch ex As Exception
                                MsgBox("Erro ao reduzir qualidade" & vbCrLf & vbCrLf & vbCrLf & ex.Message & vbCrLf & vbCrLf & vbCrLf & ex.StackTrace)
                            End Try


                            Dim matches() As Control = Me.Controls.Find("P" & iCont.ToString.PadLeft(2, "0"), True)
                            If matches.Length > 0 AndAlso TypeOf matches(0) Is PictureBox Then
                                Dim pic As PictureBox = DirectCast(matches(0), PictureBox)
                                pic.BackgroundImage = Image.FromFile(Path2)
                            End If
                            dic.Add(iCont, New item(iCont, retBarCode, Path2, ""))
                            imgFile = Nothing

                            If dic.Values.Count >= Val(My.Settings.tamanhoLeitura) Then
                                lblStatusLeitura.Text = dic.Values.Count.ToString.PadLeft(3, "0") & " de " & My.Settings.tamanhoLeitura.PadLeft(3, "0")
                                CarregaCodigosProntos()
                                GravaArquivoCSV()

                                ''''''


                                'Try

                                '    Dim diOri As New DirectoryInfo(diLote.FullName & "\ori")
                                '    diOri.Delete(True)

                                'Catch ex As Exception

                                'End Try


                                EnviarArquivosFTP()

                                ''''''

                                MsgBox("Leitura concluída com sucesso!", vbInformation)



                                IncrementaLote()


                                btnScan.Enabled = True
                                btnScan.Focus()
                                dic.Clear()
                                iCont = 0
                                Exit Sub
                            Else
                                lblStatusLeitura.Text = dic.Values.Count.ToString.PadLeft(3, "0") & " de  " & My.Settings.tamanhoLeitura.PadLeft(3, "0")
                            End If

                        End If


                    Catch ex As Exception
                        MsgBox(ex.Message & vbCrLf & Path2)
                    End Try
                    Application.DoEvents()
                    CarregaCodigosProntos()

                Else

                    If MsgBox("Número do concurso do bilhete é inválido. " & vbCrLf & "Deseja tentar novamente?", vbQuestion + vbYesNo) = MsgBoxResult.Yes Then
                        ProcessaImgScanner()
                    Else
                        btnScan.Enabled = True
                    End If
                End If
            Else
                CarregaCodigosProntos()
                If MsgBox("Erro ao buscar codigo de barras." & vbCrLf & vbCrLf & vbCrLf & "Valor Lido:" & retBarCode & vbCrLf & vbCrLf & "Deseja tentar novamente?", vbQuestion + vbYesNo) = MsgBoxResult.Yes Then
                    ProcessaImgScanner()
                Else
                    btnScan.Enabled = True
                End If
                Exit Sub
            End If

            ProcessaImgScanner()
        Catch ex As COMException

            If ex.ErrorCode <> -2145320957 AndAlso ex.ErrorCode <> -2145320958 Then
                If MsgBox("Erro ao realizar a leitura do bilhete. Deseja tentar novamente?" & vbCrLf & vbCrLf & vbCrLf & "Erro: " & ex.Message, vbQuestion + vbYesNo, vbYesNo) = MsgBoxResult.Yes Then
                    ProcessaImgScanner()
                Else
                    If MsgBox("Deseja realizar a gravação do lote?", MsgBoxStyle.Question + MsgBoxStyle.YesNo) = MsgBoxResult.Yes Then
                        GravaArquivoCSV()
                        IncrementaLote()
                        dic.Clear()
                        iCont = 0
                    End If
                End If
                MessageBox.Show(ex.Message)
            Else
                If MsgBox("Nenhum bilhete localizado no scanner. Deseja tentar novamente?", vbQuestion + vbYesNo, vbYesNo) = MsgBoxResult.Yes Then
                    ProcessaImgScanner()
                Else

                    If dic.Count > 0 Then
                        If MsgBox("Deseja realizar a gravação do lote?", MsgBoxStyle.Question + MsgBoxStyle.YesNo) = MsgBoxResult.Yes Then

                            GravaArquivoCSV()
                            IncrementaLote()
                            dic.Clear()
                            iCont = 0
                        End If
                    End If
                    btnScan.Enabled = True
                End If
            End If
        Finally
            imgFile = Nothing
            img = Nothing
            If blnAguardar Then
                ProcessaImgScanner()
            End If
        End Try

    End Sub

    Public Shared Function GetArrayFromImage(image As Image) As Byte()
        If image IsNot Nothing Then
            Dim ic As New ImageConverter()
            Dim buffer As Byte() = DirectCast(ic.ConvertTo(image, GetType(Byte())), Byte())
            Return buffer
        Else
            Return Nothing
        End If
    End Function

    Private Sub IncrementaLote()

        My.Settings.loteAtual = Val(My.Settings.loteAtual) + 1
        lblLote.Text = My.Settings.loteAtual
        My.Settings.Save()

    End Sub

    Private Sub CarregaCodigosProntos()
        If dic.Count > 0 Then
            Dim pnl As Panel = DirectCast(Controls.Find("pnl" & dic.Count.ToString.PadLeft(2, "0"), True)(0), Panel)

            Dim img As Image
            If Not IsNothing(pnl) Then
                Try
                    Dim img2 As Bitmap
                    img = Image.FromFile(My.Settings.localArmazenamento & "\" & dic(dic.Count).PathImgBrowser)
                    img2 = New Bitmap(img)

                    pnl.BackgroundImage = img2


                Catch ex As Exception

                End Try

                img.Dispose()


            End If

        End If
        Application.DoEvents()
    End Sub

    Private Function VerificaDuplicidade(CodBarras As Long) As item
        For Each it As item In dic.Values
            If it.CodBarras = CodBarras Then
                Return it
            End If

        Next
        Return Nothing


    End Function

    Public Sub PerformZoom(ByVal Value As Integer)
        Try
            Dim Res As Object = Nothing
            Dim MyWeb As Object
            'MyWeb = Me.WebBrowser1.ActiveXInstance
            MyWeb.ExecWB(Exec.OLECMDID_OPTICAL_ZOOM, execOpt.OLECMDEXECOPT_PROMPTUSER, CObj(Value), CObj(IntPtr.Zero))
        Catch ex As Exception
            MsgBox(ex.Message)
        End Try
    End Sub

    Private Sub btnLocalArmazenamento_Click(sender As Object, e As EventArgs) Handles btnLocalArmazenamento.Click
        Dim fbd1 As New FolderBrowserDialog

        fbd1.Description = "Selecione um diretório para realizar a gravação dos arquivos"
        fbd1.ShowNewFolderButton = True

        'Exibe a caixa de diálogo
        If fbd1.ShowDialog = Windows.Forms.DialogResult.OK Then
            My.Settings.localArmazenamento = fbd1.SelectedPath
            lblLocalArmazenamento.Text = My.Settings.localArmazenamento

        End If
    End Sub


    Private Sub GravaArquivoCSV()

        Using sw As StreamWriter = New StreamWriter(My.Settings.localArmazenamento & "\" & NumeroConcurso.ToString.PadLeft(3, "0") & "_" & My.Settings.loteAtual.ToString.PadLeft(4, "0") & "_" & RegionalLogada.Codigo & ".csv", False, System.Text.Encoding.ASCII)


            For Each it As item In dic.Values
                Dim conteudo As String = ""
                conteudo = $"{NumeroConcurso.ToString.PadLeft(3, "0")};{My.Settings.loteAtual.ToString.PadLeft(4, "0")};{RegionalLogada.Codigo};{it.Index};{it.CodBarras.Substring(0, 6)};{it.CodBarras.Substring(6, 1)}"
                sw.WriteLine(conteudo)
            Next

            sw.Close()

        End Using
    End Sub

    Private Sub btnConfiguracao_Click(sender As Object, e As EventArgs) Handles btnConfiguracao.Click
        frmConfiguracoes.ShowDialog()

        CarregaForm()
    End Sub

    Private Function ReduzirQualidadeImagem(pathOrignal As String) As Image
        Dim objImageCodecInfo() As System.Drawing.Imaging.ImageCodecInfo

        objImageCodecInfo = System.Drawing.Imaging.ImageCodecInfo.GetImageEncoders

        Dim objEncParams As New System.Drawing.Imaging.EncoderParameters(1)



        Dim objEncParam As New System.Drawing.Imaging.EncoderParameter(System.Drawing.Imaging.Encoder.Quality, 15)

        objEncParams.Param(0) = objEncParam

        Dim img As Image = Image.FromFile(pathOrignal) 'imagem de origem

        objEncParams.Dispose()
        objImageCodecInfo = Nothing

        Return img


    End Function

    Private Sub EnviarArquivosFTP()
        'Try

        '    'Dim oFtp As New FTP("ftp.pontessolucoesdigitais.com.br", "pontessolucoesdigitais.com.br", "h&@45DJy")
        '    Dim oFtp As New FTP(My.Settings.ftpServidor & ",21", My.Settings.ftpUsuario, My.Settings.ftpSenha)

        '    oFtp.Connect()

        '    If Not oFtp.DirectoryExists(My.Settings.loteAtual) Then
        '        oFtp.CreateDirectory(My.Settings.loteAtual, True)
        '    End If



        '    For Each it As item In dic.Values
        '        Dim ex As New Exception
        '        'UploadFTPFiles(it.PathImg, it.PathImgBrowser, True, ex)
        '        Dim wc As New Net.WebClient
        '        Dim fi As New FileInfo(it.PathImg)


        '        UTL.FTP.UploadFTPFiles(My.Settings.ftpServidor, My.Settings.ftpUsuario, My.Settings.ftpSenha, it.PathImg, "/valida/imagens/" & fi.Name, False, ex)

        '    Next
        'Catch ex As Exception
        '    MsgBox(ex.Message)
        'End Try
    End Sub




End Class