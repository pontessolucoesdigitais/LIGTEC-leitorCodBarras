Imports System.Environment
Imports System.IO
Imports System.Threading

Public Class ServicoEnvioFTP


    Protected Overrides Sub OnStart(ByVal args() As String)



        Dim t As Task = Task.Run(Sub()
                                     EnvioFtp()
                                 End Sub)
    End Sub


    Private Sub EnvioFtp()
        Dim diAux As New DirectoryInfo(Environment.GetFolderPath(SpecialFolder.ApplicationData) & "\EnvioFTP")

        If Not diAux.Exists Then
            diAux.Create()
        End If

        diAux = New DirectoryInfo(Environment.GetFolderPath(SpecialFolder.ApplicationData) & "\EnvioFTP\Log")
        If Not diAux.Exists Then
            diAux.Create()
        End If

        GravaLog("Serviço iniciado")
        Dim msg As String = "Verfica Internet: " & UTL.Geral.VerificaConexaoInternet & vbCrLf &
                            "Diertório Local:" & My.Settings.localArmazenamento & vbCrLf &
                            "Servidor FTP:" & My.Settings.ftpServidor & vbCrLf &
                            "Usuario FTP:" & My.Settings.ftpUsuario & vbCrLf &
                            "Senha FTP:" & My.Settings.ftpSenha & vbCrLf &
                            "Diretorio FTP:" & My.Settings.ftpDiretorio

        GravaLog(msg)
        Do While 1 = 1
            Try

                If Not UTL.Geral.VerificaConexaoInternet Then

                    Dim oDir As DirectoryInfo() = New DirectoryInfo(My.Settings.localArmazenamento & "\imagens").GetDirectories("*", SearchOption.AllDirectories)
                    For Each di As DirectoryInfo In oDir
                        If di.GetDirectories().Count = 0 AndAlso di.GetFiles().Count = 0 AndAlso di.CreationTime.Date < Date.Now.Date.AddDays(-1) Then
                            Try
                                di.Delete()
                            Catch ex As Exception

                            End Try
                        End If
                    Next

                    Dim oFiles As FileInfo() = New DirectoryInfo(My.Settings.localArmazenamento).GetFiles("*.csv", SearchOption.AllDirectories)

                    For Each fi As FileInfo In oFiles
                        UTL.FTP.UploadFTPFiles(My.Settings.ftpServidor, My.Settings.ftpUsuario, My.Settings.ftpSenha, fi.FullName, "valida/" & fi.Name, True, Nothing)
                    Next



                    oFiles = New DirectoryInfo(My.Settings.localArmazenamento & "\imagens\").GetFiles("*.jpg", SearchOption.AllDirectories)

                    Dim strNomeDiretorio As String = ""

                    For Each fi As FileInfo In oFiles
                        Dim ex As New Exception
                        Dim wc As New Net.WebClient


                        'If fi.CreationTime.ToString("yyyyMMddHHmm") < Now.ToString("yyyyMMddHHmm") - 5 Then


                        If strNomeDiretorio <> fi.FullName.Replace(My.Settings.localArmazenamento, My.Settings.ftpDiretorio).Replace("\", "/").Replace(fi.Name, "") Then
                            strNomeDiretorio = fi.FullName.Replace(My.Settings.localArmazenamento, My.Settings.ftpDiretorio).Replace("\", "/").Replace(fi.Name, "")

                            GravaLog("Criação diretório: " & My.Settings.ftpServidor & "/" & strNomeDiretorio)
                            Dim retCriacaoDir = UTL.FTP.CreateFTPDirectory(My.Settings.ftpServidor & "/" & strNomeDiretorio,
                                                                           My.Settings.ftpUsuario,
                                                                           My.Settings.ftpSenha)

                            GravaLog("Criação diretório: " & My.Settings.ftpServidor & "/" & strNomeDiretorio & " - " & retCriacaoDir)
                        End If
                        '   
                        '   
                        'End If


                        Dim t As Task = Task.Run(Sub()
                                                     GravaLog("Envio arquivo: " & My.Settings.ftpServidor & "/" & strNomeDiretorio & fi.Name)

                                                     Dim retEnvioArq As Boolean = UTL.FTP.UploadFTPFiles(My.Settings.ftpServidor,
                                                                                                         My.Settings.ftpUsuario,
                                                                                                         My.Settings.ftpSenha,
                                                                                                         fi.FullName,
                                                                                                         strNomeDiretorio & fi.Name,
                                                                                                         True,
                                                                                                         ex)

                                                     GravaLog("Envio arquivo: " & My.Settings.ftpServidor & "/" & strNomeDiretorio & fi.Name & " -" & retEnvioArq & "-" & ex.Message)
                                                 End Sub)


                    Next


                    oFiles = New DirectoryInfo(My.Settings.localArmazenamento & "\imagens\").GetFiles("*.tif", SearchOption.AllDirectories)

                    For Each fi As FileInfo In oFiles
                        Try
                            If fi.CreationTime.Date < Date.Now.Date.AddDays(-1) Then
                                fi.Delete()
                                If fi.Directory.GetFiles().Count = 0 Then
                                    fi.Directory.Delete()
                                    fi.Directory.Parent.Delete()
                                End If
                            End If

                        Catch ex As Exception
                            GravaLog("Erro ao excluir TIFF: " & ex.Message)
                        End Try


                    Next

                End If


                Threading.Thread.Sleep(1000)
            Catch ex As Exception
                Threading.Thread.Sleep(10000)
            End Try

        Loop

    End Sub

    Protected Overrides Sub OnStop()
        GravaLog("Serviço parado")
    End Sub


    Private Sub GravaLog(msg As String)
        Dim arquivoWS As New StreamWriter(Environment.GetFolderPath(SpecialFolder.ApplicationData) & "\EnvioFTP\Log\" & Now.ToString("yyyyMMdd") & ".txt", True, Text.Encoding.Default)
        arquivoWS.WriteLine("--------------------------------------")
        arquivoWS.WriteLine(DateTime.Now.ToString("HH:mm:ss"))
        arquivoWS.WriteLine(msg)
        arquivoWS.WriteLine("--------------------------------------")
        arquivoWS.WriteLine("")
        arquivoWS.Close()

    End Sub

End Class
