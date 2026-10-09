-- Charset explicito na conexao: o entrypoint do container mysql executa os
-- scripts com o cliente nos padroes dele, e sem isto um arquivo UTF-8 e
-- lido como latin1 ('Joao' entra como 'JoA£o').
SET NAMES utf8mb4;
USE oficina_mecanica_refinado;

-- Inserindo Clientes
INSERT INTO Cliente (Nome, CPF, Endereco, Telefone) VALUES
('João Silva', '12345678901', 'Rua das Flores, 123', '(11) 99999-1111'),
('Maria Oliveira', '98765432100', 'Av. Paulista, 500', '(11) 98888-2222'),
('Carlos Souza', '45678912300', 'Rua do Porto, 45', '(21) 97777-3333');

-- Inserindo Equipes
INSERT INTO Equipe (Nome_Equipe, Descricao) VALUES
('Alpha', 'Especialistas em Motor e Câmbio'),
('Beta', 'Especialistas em Lataria e Pintura');

-- Inserindo Mecânicos
INSERT INTO Mecanico (Nome, Endereco, Especialidade, idEquipe) VALUES
('Roberto Justos', 'Rua A, 10', 'Motor', 1),
('Ana Clara', 'Rua B, 20', 'Eletrônica', 1),
('Pedro Paulo', 'Rua C, 30', 'Pintura', 2);

-- Inserindo Veículos
INSERT INTO Veiculo (Placa, Modelo, Marca, Ano, idCliente) VALUES
('ABC1234', 'Civic', 'Honda', 2018, 1),
('DEF5678', 'Gol', 'VW', 2015, 1), -- João tem 2 carros
('GHI9012', 'Corolla', 'Toyota', 2022, 2);

-- Inserindo Serviços e Peças
INSERT INTO Servico (Descricao, Valor_Mao_Obra) VALUES
('Troca de Oleo', 50.00),
('Alinhamento', 80.00),
('Retifica Motor', 1500.00);

INSERT INTO Peca (Descricao, Valor_Unitario, Estoque_Atual) VALUES
('Oleo Sintetico 5W30', 45.00, 100),
('Filtro de Oleo', 25.00, 50),
('Pistão', 200.00, 20);

-- Inserindo Ordens de Serviço (OS)
-- OS 1: Troca de óleo simples (João)
INSERT INTO OS (Numero_OS, Data_Emissao, Status, idVeiculo, idEquipe) VALUES
('OS-001', '2023-10-01', 'Finalizado', 1, 1);

-- OS 2: Serviço pesado de motor (Maria)
INSERT INTO OS (Numero_OS, Data_Emissao, Status, idVeiculo, idEquipe) VALUES
('OS-002', '2023-10-05', 'Em Execucao', 3, 1);

-- OS 3: Serviço cancelado (João - outro carro)
INSERT INTO OS (Numero_OS, Data_Emissao, Status, idVeiculo, idEquipe) VALUES
('OS-003', '2023-10-06', 'Cancelado', 2, 2);

-- Inserindo Itens das OS (Vinculando serviços e peças)
-- OS 1 Itens: 1 Troca de oleo + 4 Litros de Oleo + 1 Filtro
INSERT INTO Item_OS_Servico (idOS, idServico, Quantidade, Valor_Cobrado) VALUES (1, 1, 1, 50.00);
INSERT INTO Item_OS_Peca (idOS, idPeca, Quantidade, Valor_Cobrado) VALUES 
(1, 1, 4, 45.00), -- 4 Oleos a 45 cada
(1, 2, 1, 25.00); -- 1 Filtro

-- OS 2 Itens: Retifica
INSERT INTO Item_OS_Servico (idOS, idServico, Quantidade, Valor_Cobrado) VALUES (2, 3, 1, 1500.00);
INSERT INTO Item_OS_Peca (idOS, idPeca, Quantidade, Valor_Cobrado) VALUES (2, 3, 4, 200.00); -- 4 Pistões