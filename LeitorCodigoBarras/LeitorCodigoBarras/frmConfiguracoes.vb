Imports System.ComponentModel

Public Class frmConfiguracoes
    Private Sub frmConfiguracoes_Load(sender As Object, e As EventArgs) Handles MyBase.Load


        txtLoteAtual.Text = My.Settings.loteAtual.ToString.PadLeft(4, "0")
        txtLoteAtual.Tag = Val(My.Settings.loteAtual)

        txtTamanhoLeitura.Text = My.Settings.tamanhoLeitura
        txtTamanhoLeitura.Tag = My.Settings.tamanhoLeitura
    End Sub

    Private Sub btnCancelar_Click(sender As Object, e As EventArgs) Handles btnCancelar.Click

        If txtLoteAtual.Tag <> Val(txtLoteAtual.Text) OrElse txtTamanhoLeitura.Tag <> txtTamanhoLeitura.Text Then

            If MsgBox("Existem dados modificados. Deseja sair sem salvá-los?", MsgBoxStyle.Question + MsgBoxStyle.YesNo + MsgBoxStyle.DefaultButton2) = MsgBoxResult.No Then
                Return
            End If

        End If
        Me.Close()
        Me.Dispose()
    End Sub

    Private Sub btnOk_Click(sender As Object, e As EventArgs) Handles btnOk.Click

        If Not IsNumeric(txtLoteAtual.Text) Then
            MsgBox("Lote inválido!", MsgBoxStyle.Exclamation)
            txtLoteAtual.Focus()
            Return
        End If

        If Not IsNumeric(txtTamanhoLeitura.Text) Then
            MsgBox("Tamanho da leitura inválido!", MsgBoxStyle.Exclamation)
            txtTamanhoLeitura.Focus()
            Return
        End If

        If MsgBox("Deseja realmente salvar os dados?", MsgBoxStyle.Question + MsgBoxStyle.YesNo) = MsgBoxResult.Yes Then


            My.Settings.loteAtual = Val(txtLoteAtual.Text)
            My.Settings.tamanhoLeitura = Val(txtTamanhoLeitura.Text)

            My.Settings.Save()
            Me.Close()
            Me.Dispose()
        End If

    End Sub

End Class