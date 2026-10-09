SET NAMES utf8mb4;

-- Criação do Banco de Dados
-- DROP antes do CREATE: com `IF NOT EXISTS` sozinho, rodar o script duas vezes
-- para em "Table 'Cliente' already exists" na segunda. A sequência inteira
-- precisa ser repetível do zero.
DROP DATABASE IF EXISTS oficina_mecanica_refinado;
CREATE DATABASE oficina_mecanica_refinado;
USE oficina_mecanica_refinado;

-- 1. Tabela Cliente
CREATE TABLE Cliente (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(45) NOT NULL,
    CPF CHAR(11) NOT NULL UNIQUE,
    Endereco VARCHAR(150),
    Telefone VARCHAR(20)
);

-- 2. Tabela Equipe
CREATE TABLE Equipe (
    idEquipe INT AUTO_INCREMENT PRIMARY KEY,
    Nome_Equipe VARCHAR(45) NOT NULL,
    Descricao VARCHAR(100)
);

-- 3. Tabela Mecânico
CREATE TABLE Mecanico (
    idMecanico INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(45) NOT NULL,
    Endereco VARCHAR(150),
    Especialidade VARCHAR(45),
    idEquipe INT,
    CONSTRAINT fk_mecanico_equipe FOREIGN KEY (idEquipe) REFERENCES Equipe(idEquipe)
);

-- 4. Tabela Veículo
CREATE TABLE Veiculo (
    idVeiculo INT AUTO_INCREMENT PRIMARY KEY,
    Placa CHAR(7) NOT NULL UNIQUE,
    Modelo VARCHAR(45) NOT NULL,
    Marca VARCHAR(45),
    Ano YEAR,
    idCliente INT,
    CONSTRAINT fk_veiculo_cliente FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
);

-- 5. Tabelas de Referência (Serviço e Peça)
CREATE TABLE Servico (
    idServico INT AUTO_INCREMENT PRIMARY KEY,
    Descricao VARCHAR(45) NOT NULL,
    Valor_Mao_Obra DECIMAL(10,2) NOT NULL
);

CREATE TABLE Peca (
    idPeca INT AUTO_INCREMENT PRIMARY KEY,
    Descricao VARCHAR(45) NOT NULL,
    Valor_Unitario DECIMAL(10,2) NOT NULL,
    Estoque_Atual INT DEFAULT 0
);

-- 6. Tabela Ordem de Serviço (OS) - Tabela Fato Central
CREATE TABLE OS (
    idOS INT AUTO_INCREMENT PRIMARY KEY,
    Numero_OS VARCHAR(20) NOT NULL UNIQUE,
    Data_Emissao DATE NOT NULL,
    Data_Conclusao DATE,
    Status ENUM('Em Analise', 'Aguardando Aprovacao', 'Em Execucao', 'Finalizado', 'Cancelado') DEFAULT 'Em Analise',
    Valor_Total DECIMAL(10,2), -- Pode ser calculado via procedure ou app, mas mantido aqui para histórico
    idVeiculo INT,
    idEquipe INT,
    CONSTRAINT fk_os_veiculo FOREIGN KEY (idVeiculo) REFERENCES Veiculo(idVeiculo),
    CONSTRAINT fk_os_equipe FOREIGN KEY (idEquipe) REFERENCES Equipe(idEquipe)
);

-- 7. Tabelas Associativas (Detalhes)
CREATE TABLE Item_OS_Servico (
    idOS INT,
    idServico INT,
    Quantidade INT DEFAULT 1,
    Valor_Cobrado DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (idOS, idServico),
    CONSTRAINT fk_item_servico_os FOREIGN KEY (idOS) REFERENCES OS(idOS),
    CONSTRAINT fk_item_servico_servico FOREIGN KEY (idServico) REFERENCES Servico(idServico)
);

CREATE TABLE Item_OS_Peca (
    idOS INT,
    idPeca INT,
    Quantidade INT DEFAULT 1,
    Valor_Cobrado DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (idOS, idPeca),
    CONSTRAINT fk_item_peca_os FOREIGN KEY (idOS) REFERENCES OS(idOS),
    CONSTRAINT fk_item_peca_peca FOREIGN KEY (idPeca) REFERENCES Peca(idPeca)
);