CREATE DATABASE NEXUS;
USE NEXUS;

CREATE TABLE Endereco (
  idEndereco INT AUTO_INCREMENT PRIMARY KEY,
  cep CHAR(8) NULL,
  logradouro VARCHAR(45) NOT NULL,
  bairro VARCHAR(45) NOT NULL,
  localidade VARCHAR(45) NOT NULL,
  uf CHAR(2) NOT NULL,
  complemento VARCHAR(45) NULL
);
-- Inserindo dados na tabela Endereco
INSERT INTO Endereco (cep, logradouro, bairro, localidade, uf, complemento)
VALUES
  ('12345678', 'Rua Padrao', 'Padrao', 'Padrao', 'SP', 'Padrao');


CREATE TABLE Empresa (
  idEmpresa INT AUTO_INCREMENT PRIMARY KEY,
  nomeEmpresa VARCHAR(45) NOT NULL,
  CNPJ VARCHAR(14) NOT NULL UNIQUE,
  digito CHAR(3) NOT NULL,
  descricao VARCHAR(45) NULL,
  ispb CHAR(8) NOT NULL,
  situacao TINYINT NULL
);
-- Inserindo dados na tabela Empresa
INSERT INTO Empresa (nomeEmpresa, CNPJ, digito, descricao, ispb, situacao)
VALUES
  ('Bradesco', '60746948000112', '237', 'Bradesco S.A.', '60746948', 1),
  ('Banco do Brasil', '00000000000191', '001', 'Banco do Brasil', '00000000', 1),
  ('Itau', '60701190000104', '341', 'Itau', '60701190', 1);

CREATE TABLE Agencia (
  idAgencia INT AUTO_INCREMENT PRIMARY KEY,
  numero CHAR(4) NULL,
  digitoAgencia CHAR(1) NULL,
  ddd CHAR(2) NULL,
  telefone VARCHAR(9) NULL,
  email VARCHAR(45) NULL UNIQUE,
  fkEmpresa INT NOT NULL,
  fkEndereco INT NOT NULL,
  CONSTRAINT fkEndereco
    FOREIGN KEY (fkEndereco)
    REFERENCES Endereco (idEndereco),
  CONSTRAINT fkEmpresaAgencia
    FOREIGN KEY (fkEmpresa)
    REFERENCES Empresa (idEmpresa)
);

-- Inserindo dados na tabela Agencia
INSERT INTO Agencia (numero, digitoAgencia, ddd, telefone, email, fkEmpresa, fkEndereco)
VALUES
  ('1111', '1', '11', '111111111', 'padrao@padrao.com', 1, 1),
  ('0897', '2', '22', '222222222', 'agencia2@bradesco.com', 1, 1),
  ('0327', '3', '33', '333333333', 'agencia3@bradesco.com', 1, 1),
  ('0438', '4', '44', '444444444', 'agencia4@bradesco.com', 1, 1),
  ('0283', '5', '55', '555555555', 'agencia5@bradesco.com', 1, 1);


CREATE TABLE Funcionario (
  idFuncionario INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(45) NULL,
  sobrenome VARCHAR(45) NULL,
  emailCorporativo VARCHAR(45) NULL UNIQUE,
  token VARCHAR(50) NULL,
  ddd CHAR(2) NULL,
  telefone VARCHAR(9) NULL UNIQUE,
  cargo VARCHAR(45) NULL,
  situacao VARCHAR(10) NULL,
  fkAgencia INT NOT NULL,
  fkEmpresa INT NOT NULL,
  fkFuncionario INT NULL,
  CONSTRAINT fkAgencia
    FOREIGN KEY (fkAgencia)
    REFERENCES Agencia (idAgencia),
  CONSTRAINT fkEmpresa
    FOREIGN KEY (fkEmpresa)
    REFERENCES Empresa (idEmpresa),
  CONSTRAINT fkFuncionario
    FOREIGN KEY (fkFuncionario)
    REFERENCES Funcionario (idFuncionario)
);
INSERT INTO Funcionario (nome, sobrenome, emailCorporativo, ddd, telefone, cargo, situacao, token, fkAgencia, fkEmpresa)
VALUES
    ('Michael', 'Teixeira', 'michael.h.silva@bradesco.com.br', '11', '999999999', 'NOC', 'Ativo', 'O1O1', 2, 1),
    ('Marcos', 'Trajano', 'marcos.vt.souza@bradesco.com.br', '11', '111111111', 'Gerente de Sistemas', 'Ativo', 'O1O2', 2, 1),
    ('Lisandra', 'Cunha', 'lisandra.cunha@bradesco.com.br', '11', '222222222', 'Gerente de Contas', 'Ativo', 'O1O3', 2, 1),
    ('Jeremias', 'Barcellos', 'jeremias.barcellos@simpress.com.br', '11', '333333333', 'NOC', 'Ativo', 'O1O4', 2, 1),
    ('Lucas', 'Arantes', 'lfsarantes@simpress.com.br', '11', '444444444', 'Funcionario', 'Ativo', 'O1O5', 2, 1),
    ('Guilherme', 'Santos', 'guilherme.dsantos@bradesco.com.br', '11', '555555555', 'Funcionario', 'Ativo', 'O1O6', 2, 1);

CREATE TABLE Maquina (
  idMaquina INT AUTO_INCREMENT PRIMARY KEY,
  marca VARCHAR(45) NULL,
  modelo VARCHAR(45) NULL,
  situacao VARCHAR(10) NULL,
  sistemaOperacional VARCHAR(15) NULL,
  fkFuncionario INT NOT NULL,
  fkAgencia INT NOT NULL,
  fkEmpresa INT NOT NULL,
  CONSTRAINT fkFuncionarioMaq
    FOREIGN KEY (fkFuncionario)
    REFERENCES Funcionario (idFuncionario),
  CONSTRAINT fkAgenciaMaq
    FOREIGN KEY (fkAgencia)
    REFERENCES Agencia (idAgencia),
  CONSTRAINT fkEmpresaMaq
    FOREIGN KEY (fkEmpresa)
    REFERENCES Empresa (idEmpresa)
);

INSERT INTO Maquina (marca, modelo, situacao, sistemaOperacional, fkFuncionario, fkAgencia, fkEmpresa)
VALUES 
('Apple', 'MacBook Air', 'Ativa', 'macOS', 1, 2, 1),
('Dell', 'Latitude 7400', 'Ativa', 'Linux Ubuntu', 2, 2, 1),
('HP', 'ProBook 450 G6', 'Ativa', 'Windows 10', 3, 2, 1),
('Lenovo', 'ThinkPad T480', 'Inativa', 'Windows 11', 4, 2, 1),
('HP', 'EliteBook 840 G5', 'Ativa', 'Linux Mint', 5, 2, 1),
('Asus', 'AlienWare', 'Inativa', 'Windows 11', 6, 2, 1);

UPDATE maquina SET situacao = 'Manutenção' WHERE idMaquina = 2;

CREATE TABLE Componente (
  idComponente INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(45) NULL UNIQUE
);

INSERT INTO Componente (nome) VALUES
  ('Processador'),
  ('Memória RAM'),
  ('Disco rígido'),
  ('Placa de vídeo'),
  ('Disco de estado sólido (SSD)'),
  ('Placa de rede (Ethernet)'),
  ('Placa de rede sem fio (Wi-Fi)'),
  ('Disco rígido externo');

CREATE TABLE Processo (
  idProcesso INT AUTO_INCREMENT PRIMARY KEY,
  PID INT NOT NULL,
  nome VARCHAR(45) NULL,
  usoAtualRAM DOUBLE NULL,
  usoAtualDisco DOUBLE NULL,
  usoAtualCPU DOUBLE NULL,
  dataHora DATETIME NOT NULL,
  fkMaquina INT NOT NULL,
   CONSTRAINT fkMaquinaProcesso
    FOREIGN KEY (fkMaquina)
    REFERENCES Maquina (idMaquina)
);

INSERT INTO Processo (PID, nome, usoAtualRAM, usoAtualDisco, usoAtualCPU, dataHora, fkMaquina)
VALUES
  (56789, 'chrome', 4.2, 2.5, 8.0, NOW(), 1),
  (98765, 'firefox', 3.0, 3.8, 6.5, NOW(), 1),
  (11122, 'vscode', 6.5, 5.2, 7.2, NOW(), 1),
  (33344, 'spotify', 2.0, 1.5, 4.8, NOW(), 1),
  (55566, 'explorer', 1.8, 2.0, 3.2, NOW(), 1);


CREATE TABLE Alerta (
  idAlerta INT AUTO_INCREMENT PRIMARY KEY,
  causa VARCHAR(60) NOT NULL,
  gravidade VARCHAR(45) NOT NULL
);

INSERT INTO Alerta (causa, gravidade)
VALUES
  ('Sobrecarga de CPU', 'Baixa'),
  ('Sobrecarga de CPU', 'Media'),
  ('Sobrecarga de CPU', 'Alta'),
  ('Memória insuficiente', 'Baixa'),
  ('Memória insuficiente', 'Média'),
  ('Memória insuficiente', 'Alta'),
  ('Erro de disco rígido', 'Baixa'),
  ('Erro de disco rígido', 'Media'),
  ('Erro de disco rígido', 'Alta'),
  ('Sem Alerta', 'Nenhuma');


CREATE TABLE Registro (
  idRegistro INT AUTO_INCREMENT PRIMARY KEY,
  modelo VARCHAR(50) NULL,
  capacidadeMax DOUBLE NULL,
  usoAtual DOUBLE NULL,
  montagem VARCHAR(20) NULL,  
  enderecoIPV4 VARCHAR(500) NOT NULL,
  dataHora DATETIME NOT NULL,  
  fkAlerta INT NOT NULL,
  fkComponente INT NOT NULL,
  fkMaquina INT NOT NULL,
  CONSTRAINT fkAlertaRegistro
    FOREIGN KEY (fkAlerta)
    REFERENCES Alerta (idAlerta),
  CONSTRAINT fkComponenteRegistro
    FOREIGN KEY (fkComponente)
    REFERENCES Componente (idComponente),
  CONSTRAINT fkMaquinaRegistro
    FOREIGN KEY (fkMaquina)
    REFERENCES Maquina (idMaquina)
);

INSERT INTO Registro (modelo, capacidadeMax, usoAtual, montagem, enderecoIPV4, dataHora, fkAlerta, fkComponente, fkMaquina)
VALUES
  ('Apple M3 Max', 6.0, 2.0, NULL, '192.168.1.101', NOW(), 1, 1, 1),
  ('RAM Apple 32GB', 32.0, 8.0, NULL, '192.168.1.101', NOW(), 4, 2, 1),
  ('SSD Apple 2TB', 2000.0, 300.0, NULL, '192.168.1.101', NOW(), 7, 3, 1),

  ('Intel I9-1430', 3.0, 2.1, NULL, '192.168.1.102', NOW(), 2, 1, 2),
  ('Cosair 8GB', 8.0, 5.0, NULL, '192.168.1.102', NOW(), 4, 2, 2),
  ('Cosair 512GB', 512.0, 98.0, NULL, '192.168.1.102', NOW(), 7, 5, 2),

  ('AMD Ryzen 7', 3.5, 2.9, NULL, '192.168.1.103', NOW(), 2, 1, 3),
  ('Samsung 16GB', 16.0, 8.0, NULL, '192.168.1.103', NOW(), 4, 2, 3),
  ('Samsung 1TB', 1000.0, 300.0, NULL, '192.168.1.103', NOW(), 7, 5, 3),

  ('Intel I5-1220', 3.2, 1.9, NULL, '192.168.1.104', NOW(), 1, 1, 4),
  ('Kingston 8GB', 8.0, 7.5, NULL, '192.168.1.104', NOW(), 6, 2, 4),
  ('Seagate 256GB', 256.0, 100.0, NULL, '192.168.1.104', NOW(), 8, 3, 4),

  ('Intel Core 2', 2.0, 1.9, NULL, '192.168.1.105', NOW(), 3, 1, 5),
  ('Asgard 4GB', 4.0, 3.9, NULL, '192.168.1.105', NOW(), 6, 2, 5),
  ('Barracuda 64GB', 64.0, 55.0, NULL, '192.168.1.105', NOW(), 9, 3, 5),

  ('Intel I3-4730', 6.0, 2.0, NULL, '192.168.1.106', NOW(), 3, 1, 6),
  ('XPG 12GB', 12.0, 8.0, NULL, '192.168.1.106', NOW(), 5, 2, 6),
  ('XPG 512GB', 512.0, 176.64, NULL, '192.168.1.106', NOW(), 7, 3, 6);

SELECT
  Registro.idRegistro,
  Registro.modelo,
  Registro.capacidadeMax,
  Registro.usoAtual,
  Registro.montagem,
  Registro.enderecoIPV4,
  Registro.dataHora,
  Alerta.causa AS causa_alerta,
  Alerta.gravidade AS gravidade_alerta,
  Componente.nome AS nome_componente,
  Maquina.marca AS marca_maquina,
  Maquina.modelo AS modelo_maquina,
  Maquina.situacao AS situacao_maquina,
  Maquina.sistemaOperacional AS sistemaOperacional_maquina,
  Funcionario.nome AS nome_funcionario,
  Funcionario.sobrenome AS sobrenome_funcionario,
  Funcionario.emailCorporativo AS email_corporativo_funcionario
FROM Registro
JOIN Alerta ON Registro.fkAlerta = Alerta.idAlerta
JOIN Componente ON Registro.fkComponente = Componente.idComponente
JOIN Maquina ON Registro.fkMaquina = Maquina.idMaquina
JOIN Funcionario ON Maquina.fkFuncionario = Funcionario.idFuncionario;

SELECT Agencia.numero AS "CodigoAgencia",
       Maquina.idMaquina AS "NumeroMaquina",
       Registro.capacidadeMax AS "TotalCapacidade",
       Registro.usoAtual AS "ConsumoAtual"
FROM Registro
JOIN Maquina ON Registro.fkMaquina = Maquina.idMaquina
JOIN Agencia ON Maquina.fkAgencia = Agencia.idAgencia
WHERE Registro.fkAlerta = (SELECT idAlerta FROM Alerta WHERE causa = 'Sobrecarga de CPU' AND gravidade = 'Alta')
  AND Agencia.fkEmpresa = (SELECT idEmpresa FROM Empresa WHERE nomeEmpresa = 'Bradesco')
ORDER BY (Registro.usoAtual - Registro.capacidadeMax) DESC
LIMIT 1;

SELECT DISTINCT
  Maquina.idMaquina AS "ID Maquina",
  Componente.nome AS "Nome Componente",
  Registro.capacidadeMax AS "CapacidadeMaxima",
  Registro.usoAtual AS "Uso Atual",
  Maquina.situacao AS "Status"
FROM (
  SELECT
      fkComponente,
      MAX(Registro.dataHora) AS max_dataHora
  FROM Registro
  GROUP BY fkComponente	
) AS ultimos_registros
INNER JOIN Componente ON ultimos_registros.fkComponente = Componente.idComponente
INNER JOIN Registro ON ultimos_registros.fkComponente = Registro.fkComponente AND ultimos_registros.max_dataHora = Registro.dataHora
INNER JOIN Maquina ON Registro.fkMaquina = Maquina.idMaquina
INNER JOIN Agencia ON Maquina.fkAgencia = Agencia.idAgencia
INNER JOIN Alerta ON Registro.fkAlerta = Alerta.idAlerta
WHERE Maquina.fkAgencia = 1
AND Agencia.fkEmpresa = (SELECT idEmpresa FROM Empresa WHERE nomeEmpresa = 'Bradesco');

SELECT distinct
    Maquina.idMaquina AS "ID Maquina",
    Componente.nome AS "Nome da Tarefa",
    Registro.usoAtual AS "Uso Atual", 
    Registro.dataHora AS "Data / Hora"
FROM (
    SELECT
        fkComponente,
        MAX(usoAtual) AS max_usoAtual
    FROM Registro
    GROUP BY fkComponente
) AS ultimos_registros
INNER JOIN Componente ON ultimos_registros.fkComponente = Componente.idComponente
INNER JOIN Registro ON ultimos_registros.fkComponente = Registro.fkComponente AND ultimos_registros.max_usoAtual = Registro.usoAtual
INNER JOIN Maquina ON Registro.fkMaquina = Maquina.idMaquina
INNER JOIN Agencia ON Maquina.fkAgencia = Agencia.idAgencia
INNER JOIN Alerta ON Registro.fkAlerta = Alerta.idAlerta
WHERE Maquina.fkAgencia = 1
AND Agencia.fkEmpresa = (SELECT idEmpresa FROM Empresa WHERE nomeEmpresa = 'Bradesco')
order by Registro.usoAtual desc; 

SELECT
    Maquina.idMaquina AS "ID Maquina",
    Componente.nome AS "Nome Componente",
    Registro.capacidadeMax AS "Capacidade Máxima",
    Registro.usoAtual AS "Uso Atual",
    Maquina.situacao AS "Status",
    MAX(Registro.dataHora) AS "Data / Hora"
FROM Registro
INNER JOIN Componente ON Registro.fkComponente = Componente.idComponente
INNER JOIN Maquina ON Registro.fkMaquina = Maquina.idMaquina
INNER JOIN Agencia ON Maquina.fkAgencia = Agencia.idAgencia
WHERE Maquina.fkAgencia = (SELECT idAgencia FROM Agencia WHERE email = 'padrao@padrao.com')
AND Agencia.fkEmpresa = (SELECT idEmpresa FROM Empresa WHERE nomeEmpresa = 'Bradesco')
AND Maquina.idMaquina = 1
GROUP BY Maquina.idMaquina, Componente.nome, Registro.capacidadeMax, Registro.usoAtual, Maquina.situacao
ORDER BY MAX(Registro.dataHora) DESC
LIMIT 5;

SELECT 
       Maquina.idMaquina AS "NumeroMaquina",
       Registro.capacidadeMax AS "TotalCapacidade",
       Registro.usoAtual AS "ConsumoAtual"
  FROM Registro
    JOIN Maquina ON Registro.fkMaquina = Maquina.idMaquina
    JOIN Agencia ON Maquina.fkAgencia = Agencia.idAgencia
  WHERE Registro.fkAlerta = (SELECT idAlerta FROM Alerta WHERE causa = 'Memória insuficiente' AND gravidade = 'Alta')
    AND Agencia.fkEmpresa = (SELECT idEmpresa FROM Empresa WHERE nomeEmpresa = 'Bradesco')
  ORDER BY (Registro.usoAtual - Registro.capacidadeMax) DESC
  LIMIT 1;

SELECT 
       Maquina.idMaquina AS "NumeroMaquina",
       Registro.capacidadeMax AS "TotalCapacidade",
       Registro.usoAtual AS "ConsumoAtual"
  FROM Registro
    JOIN Maquina ON Registro.fkMaquina = Maquina.idMaquina
    JOIN Agencia ON Maquina.fkAgencia = Agencia.idAgencia
  WHERE Registro.fkAlerta = (SELECT idAlerta FROM Alerta WHERE causa = 'Sobrecarga de CPU' AND gravidade = 'Alta')
    AND Agencia.fkEmpresa = (SELECT idEmpresa FROM Empresa WHERE nomeEmpresa = 'Bradesco')
  ORDER BY (Registro.usoAtual - Registro.capacidadeMax) DESC
  LIMIT 1;
  
  SELECT DISTINCT
  Componente.nome AS "NomeComponente",
  Registro.capacidadeMax AS "CapacidadeMaxima",
  Registro.usoAtual AS "UsoAtual",
  Maquina.situacao AS "Status",
  Maquina.idMaquina AS "IdMaquina"
FROM (
  SELECT
      fkComponente,
      MAX(Registro.dataHora) AS max_dataHora
  FROM Registro
  GROUP BY fkComponente
) AS ultimos_registros
INNER JOIN Componente ON ultimos_registros.fkComponente = Componente.idComponente
INNER JOIN Registro ON ultimos_registros.fkComponente = Registro.fkComponente AND ultimos_registros.max_dataHora = Registro.dataHora
INNER JOIN Maquina ON Registro.fkMaquina = Maquina.idMaquina
INNER JOIN Agencia ON Maquina.fkAgencia = Agencia.idAgencia
INNER JOIN Alerta ON Registro.fkAlerta = Alerta.idAlerta
WHERE Maquina.idMaquina = 1
AND Maquina.fkAgencia = 1
AND Agencia.fkEmpresa = (SELECT idEmpresa FROM Empresa WHERE nomeEmpresa = 'Bradesco');