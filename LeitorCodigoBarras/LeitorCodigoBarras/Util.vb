Imports System.IO
Imports System.Net

Module Util

    Public NumeroConcurso As Integer
    Public Regionais As New Dictionary(Of String, Regional)
    Public RegionalLogada As Regional



    Public Class Regional
        Private mCodigo As Integer
        Public Property Codigo() As Integer
            Get
                Return mCodigo
            End Get
            Set(ByVal value As Integer)
                mCodigo = value
            End Set
        End Property

        Private mNome As String
        Public Property Nome() As String
            Get
                Return mNome
            End Get
            Set(ByVal value As String)
                mNome = value
            End Set
        End Property


        Private mUsuario As String
        Public Property Usuario() As String
            Get
                Return mUsuario
            End Get
            Set(ByVal value As String)
                mUsuario = value
            End Set
        End Property

        Public Sub New(codigo As Integer, nome As String, usuario As String)
            mCodigo = codigo
            mNome = nome
            mUsuario = usuario
        End Sub
    End Class



    Public Sub LerArquivoRegionais()

        Dim arquivo As String = Application.StartupPath & "\bemdagente.csv"
        Regionais.Clear()

        If (New FileInfo(arquivo)).Exists Then

            Dim linhas As String() = File.ReadAllLines(arquivo, System.Text.Encoding.Default)


            For Each linha As String In linhas

                Dim arrLinha As String() = linha.Replace("""", "").Split(";")

                If NumeroConcurso = 0 Then
                    NumeroConcurso = arrLinha(0)
                End If

                Regionais.Add(arrLinha(3).ToLower,
                              New Regional(arrLinha(1),
                                           arrLinha(2),
                                           arrLinha(3)))
            Next

        Else
            MsgBox("Arquivo de configuração não encontrado", MsgBoxStyle.Critical)
            Application.Exit()
        End If
    End Sub


    'Public Function UploadFTPFiles(fileToUpload As String, targetFileName As String, deleteAfterUpload As Boolean, ByRef ExceptionInfo As Exception) As Boolean

    '    Dim credential As NetworkCredential

    '    Try
    '        credential = New NetworkCredential(My.Settings.ftpUsuario, My.Settings.ftpSenha)

    '        Dim sFtpFile As String = My.Settings.ftpServidor & "\" & My.Settings.ftpDiretorio & "\" & targetFileName

    '        Dim request As FtpWebRequest = DirectCast(WebRequest.Create(sFtpFile), FtpWebRequest)

    '        request.KeepAlive = False
    '        request.Method = WebRequestMethods.Ftp.UploadFile
    '        request.Credentials = credential
    '        request.UsePassive = False
    '        request.Timeout = (60 * 1000) * 3 '3 mins

    '        Using reader As New FileStream(fileToUpload, FileMode.Open)

    '            Dim buffer(Convert.ToInt32(reader.Length - 1)) As Byte
    '            reader.Read(buffer, 0, buffer.Length)
    '            reader.Close()

    '            request.ContentLength = buffer.Length
    '            Dim stream As Stream = request.GetRequestStream
    '            stream.Write(buffer, 0, buffer.Length)
    '            stream.Close()

    '            Using response As FtpWebResponse = DirectCast(request.GetResponse, FtpWebResponse)

    '                If deleteAfterUpload Then
    '                    My.Computer.FileSystem.DeleteFile(fileToUpload)
    '                End If

    '                response.Close()
    '            End Using

    '        End Using

    '        Return True

    '    Catch ex As Exception
    '        ExceptionInfo = ex
    '        Return False
    '    Finally
    '    End Try
    'End Function



End Module