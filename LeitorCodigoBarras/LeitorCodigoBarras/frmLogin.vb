Public Class frmLogin
    Private Sub frmLogin_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        CancelButton = btnCancelar
        AcceptButton = btnOk

        LerArquivoRegionais()

#If DEBUG Then
        MsgBox("Versão Debug!" & vbCrLf & vbCrLf & "Fixado Número do concurso 011", MsgBoxStyle.Exclamation)
        NumeroConcurso = 11
#End If


        txtNumeroConcurso.Text = NumeroConcurso.ToString.PadLeft(3, "0")
    End Sub

    Private Sub btnCancelar_Click(sender As Object, e As EventArgs) Handles btnCancelar.Click

        If MsgBox("Deseja realmente sair do sistema?", MsgBoxStyle.Question + MsgBoxStyle.YesNo) = MsgBoxResult.Yes Then
            Application.Exit()
        End If

    End Sub

    Private Sub btnOk_Click(sender As Object, e As EventArgs) Handles btnOk.Click
        If Regionais.ContainsKey(txtUsuario.Text.ToLower) Then
            RegionalLogada = Regionais(txtUsuario.Text.ToLower)
            frmPrincipal.Show()
            Me.Close()
            Me.Dispose()
        Else

            MsgBox("Usuário inválido", MsgBoxStyle.Exclamation + MsgBoxStyle.OkOnly)

        End If
    End Sub
End Class