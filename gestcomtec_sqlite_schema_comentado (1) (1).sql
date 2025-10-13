-- GestComTec - Banco de Dados SQLite (Versão Comentada)
-- Este arquivo define toda a estrutura do banco de dados do sistema GestComTec.
-- O objetivo é permitir a criação de um banco local em SQLite, usado no DB Browser for SQLite.
-- Cada seção está explicada em detalhes para facilitar o entendimento técnico e educativo.

PRAGMA foreign_keys = ON;  -- Ativa o suporte a chaves estrangeiras no SQLite (por padrão vem desativado)

-- ============================================
-- TABELA: Fornecedores
-- Armazena os dados dos fornecedores do armazém, incluindo contato e observações.
-- ============================================
CREATE TABLE Fornecedores (
  fornecedor_id INTEGER PRIMARY KEY AUTOINCREMENT,  -- Identificador único do fornecedor
  nome TEXT NOT NULL,                              -- Nome do fornecedor (campo obrigatório)
  contato TEXT,                                    -- Nome do responsável ou contato principal
  telefone TEXT,                                   -- Telefone do fornecedor
  observacoes TEXT                                 -- Campo livre para anotações ou observações adicionais
);

-- ============================================
-- TABELA: Categorias
-- Agrupa produtos por categoria (ex.: Alimentos, Limpeza, Bebidas, etc.)
-- ============================================
CREATE TABLE Categorias (
  categoria_id INTEGER PRIMARY KEY AUTOINCREMENT,  -- Identificador único da categoria
  nome TEXT NOT NULL                               -- Nome da categoria
);

-- ============================================
-- TABELA: Locais
-- Define os locais físicos onde os produtos são armazenados.
-- Exemplo: "Prateleira A", "Freezer 1", "Depósito".
-- ============================================
CREATE TABLE Locais (
  local_id INTEGER PRIMARY KEY AUTOINCREMENT,  -- Identificador único do local
  nome TEXT NOT NULL,                         -- Nome do local
  tipo TEXT                                   -- Tipo do local (prateleira, freezer, geladeira, depósito)
);

-- ============================================
-- TABELA: Produtos
-- Contém os produtos cadastrados no sistema, com vínculo ao fornecedor e à categoria.
-- ============================================
CREATE TABLE Produtos (
  produto_id INTEGER PRIMARY KEY AUTOINCREMENT,  -- Identificador único do produto
  nome TEXT NOT NULL,                            -- Nome do produto
  codigo_barras TEXT UNIQUE,                     -- Código de barras (único)
  categoria_id INTEGER,                          -- Relacionamento com a tabela Categorias
  fornecedor_id INTEGER,                         -- Relacionamento com a tabela Fornecedores
  descricao TEXT,                                -- Descrição do produto
  unidade_medida TEXT,                           -- Unidade de medida (ex.: fardo, unidade, caixa)
  FOREIGN KEY (categoria_id) REFERENCES Categorias(categoria_id) ON DELETE SET NULL,  -- Se a categoria for excluída, este campo vira NULL
  FOREIGN KEY (fornecedor_id) REFERENCES Fornecedores(fornecedor_id) ON DELETE SET NULL  -- Mesmo comportamento para fornecedor
);

-- ============================================
-- TABELA: Lotes
-- Cada produto pode ter vários lotes, com diferentes quantidades e datas de validade.
-- Essa tabela é essencial para o controle de estoque e validade.
-- ============================================
CREATE TABLE Lotes (
  lote_id INTEGER PRIMARY KEY AUTOINCREMENT,      -- Identificador único do lote
  produto_id INTEGER NOT NULL,                    -- Produto ao qual o lote pertence
  codigo_lote TEXT,                               -- Código de identificação do lote
  quantidade INTEGER NOT NULL,                    -- Quantidade total de itens neste lote
  data_entrada TEXT,                              -- Data em que o lote entrou no estoque
  data_validade TEXT,                             -- Data de validade do lote
  local_id INTEGER,                               -- Local onde o lote está armazenado
  status INTEGER DEFAULT 0,                       -- Status de validade (0=verde, 1=amarelo, 2=laranja, 3=vermelho)
  ativo INTEGER DEFAULT 1,                        -- Indica se o lote está ativo (1) ou inativo (0)
  FOREIGN KEY (produto_id) REFERENCES Produtos(produto_id) ON DELETE CASCADE,  -- Se o produto for excluído, o lote também é removido
  FOREIGN KEY (local_id) REFERENCES Locais(local_id) ON DELETE SET NULL         -- Se o local for removido, este campo vira NULL
);

-- ============================================
-- TABELA: Movimentacoes
-- Registra todas as entradas e saídas de produtos (controle de estoque).
-- ============================================
CREATE TABLE Movimentacoes (
  movimentacao_id INTEGER PRIMARY KEY AUTOINCREMENT,  -- Identificador único da movimentação
  lote_id INTEGER,                                   -- Lote envolvido na movimentação
  tipo TEXT CHECK(tipo IN ('entrada','saida')),      -- Define se é uma entrada ou saída
  quantidade INTEGER,                                -- Quantidade movimentada
  data_movimentacao TEXT DEFAULT CURRENT_TIMESTAMP,  -- Data e hora da movimentação
  usuario TEXT,                                      -- Usuário responsável pela ação
  observacao TEXT,                                   -- Campo livre para observações
  FOREIGN KEY (lote_id) REFERENCES Lotes(lote_id) ON DELETE CASCADE  -- Se o lote for excluído, as movimentações também são
);

-- ============================================
-- TABELA: Usuarios
-- Armazena as credenciais e níveis de acesso dos usuários do sistema.
-- ============================================
CREATE TABLE Usuarios (
  usuario_id INTEGER PRIMARY KEY AUTOINCREMENT,   -- Identificador único do usuário
  username TEXT UNIQUE NOT NULL,                  -- Nome de login (deve ser único)
  senha_hash TEXT NOT NULL,                       -- Hash da senha para garantir segurança
  nivel_acesso TEXT CHECK(nivel_acesso IN ('admin','user')) NOT NULL  -- Define o nível de permissão do usuário
);

-- ============================================
-- TABELA: Auditoria
-- Guarda um histórico de todas as alterações feitas no banco (create, update, delete).
-- ============================================
CREATE TABLE Auditoria (
  auditoria_id INTEGER PRIMARY KEY AUTOINCREMENT,  -- Identificador único do registro de auditoria
  entidade TEXT NOT NULL,                          -- Nome da tabela afetada
  entidade_id INTEGER,                             -- ID do registro afetado
  acao TEXT CHECK(acao IN ('CREATE','UPDATE','DELETE')),  -- Tipo de ação executada
  usuario TEXT,                                    -- Usuário que executou a ação
  data_hora TEXT DEFAULT CURRENT_TIMESTAMP,        -- Data e hora da operação
  detalhes TEXT                                    -- Descrição detalhada da modificação
);

-- ============================================
-- TABELA: Configuracoes
-- Guarda pares de chave/valor para ajustes do sistema (ex.: dias de alerta, idioma, etc.)
-- ============================================
CREATE TABLE Configuracoes (
  chave TEXT PRIMARY KEY,  -- Nome da configuração
  valor TEXT               -- Valor associado
);

-- ============================================
-- ÍNDICES
-- Criam otimizações para consultas frequentes em campos importantes.
-- ============================================
CREATE INDEX idx_produtos_codigo ON Produtos(codigo_barras);      -- Acelera buscas por código de barras
CREATE INDEX idx_lotes_validade ON Lotes(data_validade);          -- Melhora consultas por data de validade
CREATE INDEX idx_lotes_fornecedor ON Produtos(fornecedor_id);     -- Acelera filtros por fornecedor
CREATE INDEX idx_movimentacoes_data ON Movimentacoes(data_movimentacao);  -- Melhora consultas por data de movimentação

-- ============================================
-- VIEW: vw_produtos_proximos_vencer
-- Cria uma visão automática de produtos com vencimento próximo (<= 15 dias).
-- Serve para gerar relatórios e alertas visuais no dashboard do sistema.
-- ============================================
CREATE VIEW vw_produtos_proximos_vencer AS
SELECT 
  p.nome AS produto,  -- Nome do produto
  l.codigo_lote,      -- Código do lote
  l.data_validade,    -- Data de validade do lote
  (julianday(l.data_validade) - julianday('now')) AS dias_restantes,  -- Calcula dias até o vencimento
  CASE
    WHEN (julianday(l.data_validade) - julianday('now')) < 0 THEN 'Vermelho'  -- Vencido
    WHEN (julianday(l.data_validade) - julianday('now')) <= 7 THEN 'Laranja'  -- Até 7 dias
    WHEN (julianday(l.data_validade) - julianday('now')) <= 15 THEN 'Amarelo' -- Até 15 dias
    ELSE 'Verde'                                                              -- Mais de 15 dias
  END AS status
FROM Lotes l
JOIN Produtos p ON p.produto_id = l.produto_id
WHERE l.ativo = 1;  -- Considera apenas lotes ativos
