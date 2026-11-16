-- Projeto Físico - Gestão de Equipamentos e Reagentes
-- Convenções:
--    -Datas  : TEXT no formato ISO-8601 ('YYYY-MM-DD' ou 'YYYY-MM-DD HH:MM:SS')
--    -Booleano: INTEGER (0 = falso, 1 = verdadeiro)
--    -Durações/horas: REAL (em horas)

PRAGMA foreign_keys = ON;

-- 1. USUÁRIOS
CREATE TABLE if not EXISTS ORIENTADOR (
    id_orientador INTEGER PRIMARY KEY AUTOINCREMENT,
    nome          TEXT    NOT NULL CHECK (length(trim(nome)) > 0),
    email         TEXT    NOT NULL UNIQUE CHECK (email LIKE '%_@_%._%'),
    ativo         INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0, 1))
);

CREATE TABLE if not EXISTS PESQUISADOR (
    id_pesquisador INTEGER PRIMARY KEY AUTOINCREMENT,
    nome           TEXT    NOT NULL CHECK (length(trim(nome)) > 0),
    email          TEXT    NOT NULL UNIQUE CHECK (email LIKE '%_@_%._%'),
    ativo          INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0, 1))
);

CREATE TABLE if not EXISTS COORDENADOR (
    id_coordenador INTEGER PRIMARY KEY AUTOINCREMENT,
    nome           TEXT    NOT NULL CHECK (length(trim(nome)) > 0),
    email          TEXT    NOT NULL UNIQUE CHECK (email LIKE '%_@_%._%'),
    ativo          INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0, 1))
);

CREATE TABLE if not EXISTS ALMOXARIFADO (
    id_colaborador INTEGER PRIMARY KEY AUTOINCREMENT,
    nome           TEXT    NOT NULL CHECK (length(trim(nome)) > 0),
    email          TEXT    NOT NULL UNIQUE CHECK (email LIKE '%_@_%._%'),
    ativo          INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0, 1))
);

CREATE TABLE if not EXISTS TECNICO (
    id_tecnico INTEGER PRIMARY KEY AUTOINCREMENT,
    nome       TEXT    NOT NULL CHECK (length(trim(nome)) > 0),
    email      TEXT    NOT NULL UNIQUE CHECK (email LIKE '%_@_%._%'),
    ativo      INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0, 1))
);

-- 2. PROJETO
CREATE TABLE if not EXISTS PROJETO (
    id_projeto       INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo           TEXT    NOT NULL CHECK (length(trim(titulo)) > 0),
    vigencia_inicio  TEXT    NOT NULL CHECK (date(vigencia_inicio) IS NOT NULL),
    vigencia_final   TEXT    NOT NULL CHECK (date(vigencia_final)  IS NOT NULL),
    orcamento_horas  REAL    NOT NULL DEFAULT 0 CHECK (orcamento_horas >= 0),
    id_orientador    INTEGER NOT NULL,
    CHECK (vigencia_final >= vigencia_inicio),
    FOREIGN KEY (id_orientador) REFERENCES ORIENTADOR (id_orientador)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX if not EXISTS idx_projeto_orientador ON PROJETO (id_orientador);

-- 3. EQUIPAMENTO E MANUTENÇÃO
CREATE TABLE if not EXISTS EQUIPAMENTO (
    patrimonio          TEXT    PRIMARY KEY CHECK (length(trim(patrimonio)) > 0),
    nome                TEXT    NOT NULL CHECK (length(trim(nome)) > 0),
    laboratorio         TEXT    NOT NULL,
    duracao_max_sessao  REAL    NOT NULL CHECK (duracao_max_sessao > 0),   -- horas
    periodicidade_manu  INTEGER NOT NULL CHECK (periodicidade_manu > 0),   -- dias
    data_calibracao     TEXT    CHECK (data_calibracao IS NULL OR date(data_calibracao) IS NOT NULL),
    status              TEXT    NOT NULL DEFAULT 'DISPONIVEL'
        CHECK (status IN ('DISPONIVEL', 'EM_MANUTENCAO', 'INATIVO'))
);

CREATE TABLE if not EXISTS MANUTENCAO (
    id_manutencao  INTEGER PRIMARY KEY AUTOINCREMENT,
    tipo           TEXT NOT NULL
        CHECK (tipo IN ('PREVENTIVA', 'CORRETIVA', 'CALIBRACAO')),
    data_abertura  TEXT NOT NULL DEFAULT (date('now'))
        CHECK (date(data_abertura) IS NOT NULL),
    data_conclusao TEXT
        CHECK (data_conclusao IS NULL OR date(data_conclusao) IS NOT NULL),
    descricao      TEXT,
    CHECK (data_conclusao IS NULL OR data_conclusao >= data_abertura)
);

-- 4. REAGENTE E LOTE
CREATE TABLE if not EXISTS REAGENTE (
    id_reagente INTEGER PRIMARY KEY AUTOINCREMENT,
    nome        TEXT    NOT NULL UNIQUE CHECK (length(trim(nome)) > 0),
    estoque_min REAL    NOT NULL DEFAULT 0 CHECK (estoque_min >= 0)
);

CREATE TABLE if not EXISTS LOTE (
    id_lote     INTEGER PRIMARY KEY AUTOINCREMENT,
    validade    TEXT    NOT NULL CHECK (date(validade) IS NOT NULL),
    quantidade  REAL    NOT NULL DEFAULT 0 CHECK (quantidade >= 0),
    localizacao TEXT    NOT NULL,
    status      TEXT    NOT NULL DEFAULT 'DISPONIVEL'
        CHECK (status IN ('DISPONIVEL', 'ESGOTADO', 'VENCIDO')),
    fornecedor  TEXT    NOT NULL
);

-- 5. CERTIFICAÇÃO
CREATE TABLE if not EXISTS CERTIFICACAO (
    id_certificacao INTEGER PRIMARY KEY AUTOINCREMENT,
    data_emissao    TEXT    NOT NULL DEFAULT (date('now'))
        CHECK (date(data_emissao) IS NOT NULL),
    instrutor       TEXT    NOT NULL,
    id_pesquisador  INTEGER NOT NULL,
    FOREIGN KEY (id_pesquisador) REFERENCES PESQUISADOR (id_pesquisador)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX if not EXISTS idx_certificacao_pesq ON CERTIFICACAO (id_pesquisador);

-- 6. RESERVA
CREATE TABLE if not EXISTS RESERVA (
    id_reserva             INTEGER PRIMARY KEY AUTOINCREMENT,
    data_inicio            TEXT    NOT NULL CHECK (datetime(data_inicio) IS NOT NULL),
    data_fim               TEXT    NOT NULL CHECK (datetime(data_fim)    IS NOT NULL),
    duracao                REAL    NOT NULL CHECK (duracao > 0),            -- horas
    status                 TEXT    NOT NULL DEFAULT 'PENDENTE'
        CHECK (status IN ('PENDENTE', 'APROVADA', 'CANCELADA', 'CONCLUIDA')),
    motivo_cancelamento    TEXT,
    flag_prioridade        INTEGER NOT NULL DEFAULT 0 CHECK (flag_prioridade IN (0, 1)),
    id_projeto             INTEGER NOT NULL,
    id_pesquisador         INTEGER NOT NULL,
    patrimonio             TEXT    NOT NULL,
    id_orientador_aprova   INTEGER,          -- aprova (0,1)
    id_manutencao_cancela  INTEGER,          -- cancela (0,1)
    CHECK (data_fim > data_inicio),
    CHECK (status <> 'CANCELADA' OR motivo_cancelamento IS NOT NULL),
    CHECK (status <> 'APROVADA'  OR id_orientador_aprova IS NOT NULL),
    FOREIGN KEY (id_projeto)            REFERENCES PROJETO (id_projeto)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_pesquisador)        REFERENCES PESQUISADOR (id_pesquisador)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (patrimonio)            REFERENCES EQUIPAMENTO (patrimonio)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_orientador_aprova)  REFERENCES ORIENTADOR (id_orientador)
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id_manutencao_cancela) REFERENCES MANUTENCAO (id_manutencao)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE INDEX if not EXISTS idx_reserva_projeto     ON RESERVA (id_projeto);
CREATE INDEX if not EXISTS idx_reserva_pesquisador ON RESERVA (id_pesquisador);
CREATE INDEX if not EXISTS idx_reserva_equip_data  ON RESERVA (patrimonio, data_inicio, data_fim);

-- RN02: Reservas não podem se sobrepor no mesmo equipamento;
CREATE TRIGGER if not EXISTS trg_reserva_sem_conflito_ins
BEFORE INSERT ON RESERVA
WHEN NEW.status IN ('PENDENTE', 'APROVADA')
BEGIN
    SELECT RAISE(ABORT, 'Conflito: equipamento já reservado neste período')
    WHERE EXISTS (
        SELECT 1 FROM RESERVA r
        WHERE r.patrimonio = NEW.patrimonio
          AND r.status IN ('PENDENTE', 'APROVADA')
          AND r.data_inicio < NEW.data_fim
          AND r.data_fim    > NEW.data_inicio
    );
END;

CREATE TRIGGER IF NOT EXISTS trg_reserva_sem_conflito_upd
BEFORE UPDATE OF data_inicio, data_fim, patrimonio, status ON RESERVA
WHEN NEW.status IN ('PENDENTE', 'APROVADA')
BEGIN
    SELECT RAISE(ABORT, 'Conflito: equipamento já reservado neste período')
    WHERE EXISTS (
        SELECT 1 FROM RESERVA r
        WHERE r.patrimonio = NEW.patrimonio
          AND r.id_reserva <> NEW.id_reserva
          AND r.status IN ('PENDENTE', 'APROVADA')
          AND r.data_inicio < NEW.data_fim
          AND r.data_fim    > NEW.data_inicio
    );
END;

-- 7. RELATÓRIO DE USO
CREATE TABLE IF NOT EXISTS RELATORIO_USO (
    id_relatorio   INTEGER PRIMARY KEY AUTOINCREMENT,
    data_entrega   TEXT    CHECK (data_entrega IS NULL OR date(data_entrega) IS NOT NULL),
    duracao_real   REAL    NOT NULL CHECK (duracao_real >= 0),              -- horas
    anomalias      TEXT,
    observacoes    TEXT,
    id_pesquisador INTEGER NOT NULL,
    id_reserva     INTEGER,
    FOREIGN KEY (id_pesquisador) REFERENCES PESQUISADOR (id_pesquisador)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_reserva)     REFERENCES RESERVA (id_reserva)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_relatorio_pesq    ON RELATORIO_USO (id_pesquisador);
CREATE INDEX IF NOT EXISTS idx_relatorio_reserva ON RELATORIO_USO (id_reserva);

-- 8. TABELAS ASSOCIATIVAS
CREATE TABLE IF NOT EXISTS PARTICIPA (
    id_projeto     INTEGER NOT NULL,
    id_pesquisador INTEGER NOT NULL,
    data_entrada   TEXT    NOT NULL DEFAULT (date('now'))
        CHECK (date(data_entrada) IS NOT NULL),
    data_saida     TEXT
        CHECK (data_saida IS NULL OR date(data_saida) IS NOT NULL),
    PRIMARY KEY (id_projeto, id_pesquisador, data_entrada),
    CHECK (data_saida IS NULL OR data_saida >= data_entrada),
    FOREIGN KEY (id_projeto)     REFERENCES PROJETO (id_projeto)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_pesquisador) REFERENCES PESQUISADOR (id_pesquisador)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS PREVE (
    id_reserva    INTEGER NOT NULL,
    id_reagente   INTEGER NOT NULL,
    qtd_prevista  REAL    NOT NULL CHECK (qtd_prevista > 0),
    PRIMARY KEY (id_reserva, id_reagente),
    FOREIGN KEY (id_reserva)  REFERENCES RESERVA (id_reserva)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_reagente) REFERENCES REAGENTE (id_reagente)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS RETIRA_DE (
    id_tecnico INTEGER NOT NULL,
    id_lote    INTEGER NOT NULL,
    data_hora  TEXT    NOT NULL DEFAULT (datetime('now')),
    quantidade REAL    NOT NULL CHECK (quantidade > 0),
    PRIMARY KEY (id_tecnico, id_lote, data_hora),
    CHECK (datetime(data_hora) IS NOT NULL),
    FOREIGN KEY (id_tecnico) REFERENCES TECNICO (id_tecnico)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_lote)    REFERENCES LOTE (id_lote)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS EXECUTA (
    id_manutencao INTEGER NOT NULL,
    id_tecnico    INTEGER NOT NULL,
    PRIMARY KEY (id_manutencao, id_tecnico),
    FOREIGN KEY (id_manutencao) REFERENCES MANUTENCAO (id_manutencao)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_tecnico)    REFERENCES TECNICO (id_tecnico)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS SOFRE (
    patrimonio    TEXT    NOT NULL,
    id_manutencao INTEGER NOT NULL,
    PRIMARY KEY (patrimonio, id_manutencao),
    FOREIGN KEY (patrimonio)    REFERENCES EQUIPAMENTO (patrimonio)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_manutencao) REFERENCES MANUTENCAO (id_manutencao)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS POSSUI (
    id_reagente INTEGER NOT NULL,
    id_lote     INTEGER NOT NULL,
    PRIMARY KEY (id_reagente, id_lote),
    FOREIGN KEY (id_reagente) REFERENCES REAGENTE (id_reagente)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_lote)     REFERENCES LOTE (id_lote)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS COORD_VE_RESERVA (
    id_coordenador INTEGER NOT NULL,
    id_reserva     INTEGER NOT NULL,
    PRIMARY KEY (id_coordenador, id_reserva),
    FOREIGN KEY (id_coordenador) REFERENCES COORDENADOR (id_coordenador)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_reserva)     REFERENCES RESERVA (id_reserva)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS COORD_VE_LOTE (
    id_coordenador INTEGER NOT NULL,
    id_lote        INTEGER NOT NULL,
    PRIMARY KEY (id_coordenador, id_lote),
    FOREIGN KEY (id_coordenador) REFERENCES COORDENADOR (id_coordenador)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_lote)        REFERENCES LOTE (id_lote)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS ALMOX_VISUALIZA (
    id_colaborador INTEGER NOT NULL,
    id_lote        INTEGER NOT NULL,
    PRIMARY KEY (id_colaborador, id_lote),
    FOREIGN KEY (id_colaborador) REFERENCES ALMOXARIFADO (id_colaborador)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_lote)        REFERENCES LOTE (id_lote)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Indices para FK's das associativas 
CREATE INDEX IF NOT EXISTS idx_participa_pesq   ON PARTICIPA (id_pesquisador);
CREATE INDEX IF NOT EXISTS idx_preve_reagente   ON PREVE (id_reagente);
CREATE INDEX IF NOT EXISTS idx_retira_lote      ON RETIRA_DE (id_lote);
CREATE INDEX IF NOT EXISTS idx_executa_tecnico  ON EXECUTA (id_tecnico);
CREATE INDEX IF NOT EXISTS idx_sofre_manut      ON SOFRE (id_manutencao);
CREATE INDEX IF NOT EXISTS idx_possui_lote      ON POSSUI (id_lote);
CREATE INDEX IF NOT EXISTS idx_cvr_reserva      ON COORD_VE_RESERVA (id_reserva);
CREATE INDEX IF NOT EXISTS idx_cve_lote         ON COORD_VE_LOTE (id_lote);
CREATE INDEX IF NOT EXISTS idx_almox_lote       ON ALMOX_VISUALIZA (id_lote);

-- 9. ATRIBUTOS DERIVADOS (views)
CREATE VIEW IF NOT EXISTS vw_projeto_saldo_horas AS
SELECT p.id_projeto,
       p.titulo,
       p.orcamento_horas,
       p.orcamento_horas - COALESCE(SUM(r.duracao), 0) AS saldo_horas
FROM PROJETO p
LEFT JOIN RESERVA r
       ON r.id_projeto = p.id_projeto
      AND r.status IN ('APROVADA', 'CONCLUIDA')
GROUP BY p.id_projeto;

CREATE VIEW IF NOT EXISTS vw_relatorio_prazo_limite AS
SELECT ru.id_relatorio,
       ru.id_reserva,
       date(r.data_fim, '+2 days') AS prazo_limite
FROM RELATORIO_USO ru
LEFT JOIN RESERVA r ON r.id_reserva = ru.id_reserva;

CREATE VIEW IF NOT EXISTS vw_certificacao_status AS
SELECT c.id_certificacao,
       c.id_pesquisador,
       c.data_emissao,
       CASE WHEN date('now') <= date(c.data_emissao, '+2 year')
            THEN 'VIGENTE' ELSE 'EXPIRADA' END AS status
FROM CERTIFICACAO c;
