Public Class Form2

    ' Lista simulando o banco de dados
    Private produtos As New List(Of Produto)

    Private Sub Form2_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        ConfigurarTabela()

        ' Produtos de exemplo
        produtos.Add(New Produto("Arroz 5kg", "Lote-001", "Alimento", "Corredor A", 25.99, 10))
        produtos.Add(New Produto("Feijão 1kg", "Lote-002", "Alimento", "Corredor A", 8.5, 20))
        produtos.Add(New Produto("Detergente", "Lote-015", "Limpeza", "Corredor C", 3.75, 50))
        produtos.Add(New Produto("Leite 1L", "Lote-023", "Bebida", "Geladeira", 6.0, 12))

        AtualizarTabela()
    End Sub

    ' Configuração das colunas da tabela
    Private Sub ConfigurarTabela()
        dgvProdutos.ColumnCount = 6
        dgvProdutos.Columns(0).Name = "Produto"
        dgvProdutos.Columns(1).Name = "Lote"
        dgvProdutos.Columns(2).Name = "Tipo"
        dgvProdutos.Columns(3).Name = "Localização"
        dgvProdutos.Columns(4).Name = "Preço (R$)"
        dgvProdutos.Columns(5).Name = "Quantidade"

        dgvProdutos.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill
    End Sub

    ' Atualiza os dados na tabela e calcula o total
    Private Sub AtualizarTabela()
        dgvProdutos.Rows.Clear()

        Dim totalEstoque As Double = 0

        For Each p As Produto In produtos
            dgvProdutos.Rows.Add(p.Nome, p.Lote, p.Tipo, p.Localizacao, p.Preco.ToString("F2"), p.Quantidade)
            totalEstoque += p.Preco * p.Quantidade
        Next

        lblTotal.Text = $"Valor total em estoque: R$ {totalEstoque:F2}"
    End Sub

    ' Botão: Adicionar novo produto
    Private Sub btnAdicionar_Click(sender As Object, e As EventArgs) Handles btnAdicionar.Click
        Dim nome As String = InputBox("Digite o nome do produto:")
        Dim lote As String = InputBox("Digite o número do lote:")
        Dim tipo As String = InputBox("Digite o tipo do produto (Ex: Alimento, Limpeza, Bebida):")
        Dim local As String = InputBox("Digite a localização (Ex: Corredor A, Geladeira, Estoque):")
        Dim precoStr As String = InputBox("Digite o preço do produto:")
        Dim qtdStr As String = InputBox("Digite a quantidade em estoque:")

        If nome <> "" AndAlso lote <> "" AndAlso tipo <> "" AndAlso local <> "" AndAlso IsNumeric(precoStr) AndAlso IsNumeric(qtdStr) Then
            produtos.Add(New Produto(nome, lote, tipo, local, CDbl(precoStr), CInt(qtdStr)))
            AtualizarTabela()
        Else
            MessageBox.Show("Dados inválidos! Verifique e tente novamente.")
        End If
    End Sub

    ' Botão: Remover produto selecionado
    Private Sub btnRemover_Click(sender As Object, e As EventArgs) Handles btnRemover.Click
        If dgvProdutos.SelectedRows.Count > 0 Then
            Dim nomeSelecionado As String = dgvProdutos.SelectedRows(0).Cells(0).Value.ToString()
            produtos.RemoveAll(Function(p) p.Nome = nomeSelecionado)
            AtualizarTabela()
        Else
            MessageBox.Show("Selecione um produto para remover.")
        End If
    End Sub

    ' Botão: Atualizar tabela
    Private Sub btnAtualizar_Click(sender As Object, e As EventArgs) Handles btnAtualizar.Click
        AtualizarTabela()
    End Sub

    ' Botão: Sair
    Private Sub btnSair_Click(sender As Object, e As EventArgs) Handles btnSair.Click
        Dim resposta = MessageBox.Show("Deseja sair do sistema?", "Confirmação", MessageBoxButtons.YesNo)
        If resposta = DialogResult.Yes Then
            Application.Exit()
        End If
    End Sub
End Class


' Classe Produto
Public Class Produto
    Public Property Nome As String
    Public Property Lote As String
    Public Property Tipo As String
    Public Property Localizacao As String
    Public Property Preco As Double
    Public Property Quantidade As Integer

    Public Sub New(nome As String, lote As String, tipo As String, local As String, preco As Double, qtd As Integer)
        Me.Nome = nome
        Me.Lote = lote
        Me.Tipo = tipo
        Me.Localizacao = local
        Me.Preco = preco
        Me.Quantidade = qtd
    End Sub
End Class
