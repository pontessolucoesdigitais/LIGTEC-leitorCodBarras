Imports System.Environment
Imports System.IO

Public Class Service1

    Dim diLog As New DirectoryInfo(My.Settings.localLog & "\Log")

    Private arquivoWS As StreamWriter

    Protected Overrides Sub OnStart(ByVal args() As String)

        Dim t As Task = Task.Run(Sub()
                                     EnvioFtp()
                                 End Sub)

    End Sub

    Protected Overrides Sub OnStop()
        GravaLog("Serviço Parado")
    End Sub




    Private Sub EnvioFtp()

        Dim diAux As New DirectoryInfo(diLog.FullName & "\..\")

        If Not diAux.Exists Then
            diAux.Create()
        End If

        diAux = New DirectoryInfo(diLog.FullName)
        If Not diAux.Exists Then
            diAux.Create()
        End If

        GravaLog("Serviço iniciado")
        Dim msg As String = "Verfica Internet: " & UTL.Geral.VerificaConexaoInternet & vbCrLf &
                            "Diertório Local:  " & My.Settings.localArmazenamento & vbCrLf &
                            "Servidor FTP:     " & My.Settings.ftpServidor & vbCrLf &
                            "Usuario FTP:      " & My.Settings.ftpUsuario & vbCrLf &
                            "Senha FTP:        " & My.Settings.ftpSenha & vbCrLf &
                            "Diretorio FTP:    " & My.Settings.ftpDiretorio

        GravaLog(msg)
        Do

            Try

                If UTL.Geral.VerificaConexaoInternet Then

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

                        If strNomeDiretorio <> fi.FullName.Replace(My.Settings.localArmazenamento, My.Settings.ftpDiretorio).Replace("\", "/").Replace(fi.Name, "") Then
                            strNomeDiretorio = fi.FullName.Replace(My.Settings.localArmazenamento, My.Settings.ftpDiretorio).Replace("\", "/").Replace(fi.Name, "")

                            GravaLog("Criação diretório: " & My.Settings.ftpServidor & "/" & strNomeDiretorio)
                            Dim retCriacaoDir = UTL.FTP.CreateFTPDirectory(My.Settings.ftpServidor & "/" & strNomeDiretorio,
                                                                           My.Settings.ftpUsuario,
                                                                           My.Settings.ftpSenha)

                            GravaLog("Criação diretório: " & My.Settings.ftpServidor & "/" & strNomeDiretorio & " - " & retCriacaoDir)
                        End If

                        'Dim t As Task = Task.Run(Sub()
                        Dim msgArq As String = "Envio arquivo: " & My.Settings.ftpServidor & "/" & strNomeDiretorio & fi.Name

                        Dim retEnvioArq As Boolean = UTL.FTP.UploadFTPFiles(My.Settings.ftpServidor,
                                                                            My.Settings.ftpUsuario,
                                                                            My.Settings.ftpSenha,
                                                                            fi.FullName,
                                                                            strNomeDiretorio & fi.Name,
                                                                            True,
                                                                            ex)


                        If Not retEnvioArq Then
                            msgArq &= vbCrLf & "Erro:" & ex.Message
                        End If

                        GravaLog(msgArq)

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
                    Threading.Thread.Sleep(1000)

                Else
                    Threading.Thread.Sleep(10000)
                End If
            Catch ex As Exception
                GravaLog(ex.Message)

                Threading.Thread.Sleep(10000)
            End Try

        Loop While True

    End Sub



    Private Sub GravaLog(msg As String)
        Dim arquivoWS As New StreamWriter(diLog.FullName & "\" & Now.ToString("yyyy-MM-dd") & ".txt", True, Text.Encoding.Default)
        arquivoWS.WriteLine("--------------------------------------")
        arquivoWS.WriteLine(DateTime.Now.ToString("HH:mm:ss"))
        arquivoWS.WriteLine(msg)
        arquivoWS.WriteLine("--------------------------------------")
        arquivoWS.WriteLine("")
        arquivoWS.Close()

    End Sub
End Class
