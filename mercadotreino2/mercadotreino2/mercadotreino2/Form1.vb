' Form1 - Tela de Login
Public Class Form1
    ' Evento do botão de login
    Private Sub btnLogin_Click(sender As Object, e As EventArgs) Handles btnLogin.Click
        ' Defina aqui seu nome de usuário e senha para validação
        Dim username As String = txtUsername.Text
        Dim password As String = txtPassword.Text

        ' Validação simples de login (substitua isso por um banco de dados ou outra lógica mais segura)
        If username = "alves" And password = "mercado" Then
            ' Se o login for válido, abre o Form2 (Dashboard)
            Dim dashboardForm As New Form2
            dashboardForm.Show()   ' Abre o Form2
            Me.Hide()  ' Esconde o Form1 (Login)
        Else
            ' Se as credenciais estiverem erradas, exibe uma mensagem de erro
            MessageBox.Show("Credenciais inválidas! Tente novamente.")
        End If
    End Sub
End Class