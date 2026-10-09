-- Charset explicito na conexao: o entrypoint do container mysql executa os
-- scripts com o cliente nos padroes dele, e sem isto um arquivo UTF-8 e
-- lido como latin1 ('Joao' entra como 'JoA£o').
SET NAMES utf8mb4;
USE oficina_mecanica_refinado;

SELECT Descricao, Valor_Mao_Obra 
FROM Servico
WHERE Valor_Mao_Obra > 60.00
ORDER BY Valor_Mao_Obra DESC;

SELECT 
    p.Descricao AS Peca,
    i.Quantidade,
    i.Valor_Cobrado AS Valor_Unitario,
    (i.Quantidade * i.Valor_Cobrado) AS Subtotal -- Atributo Derivado
FROM Peca p
INNER JOIN Item_OS_Peca i ON p.idPeca = i.idPeca
INNER JOIN OS o ON i.idOS = o.idOS
WHERE o.Numero_OS = 'OS-001';

SELECT 
    c.Nome,
    COUNT(v.idVeiculo) AS Qtd_Veiculos
FROM Cliente c
INNER JOIN Veiculo v ON c.idCliente = v.idCliente
GROUP BY c.idCliente
HAVING Qtd_Veiculos > 1;

SELECT 
    o.Numero_OS,
    c.Nome AS Cliente,
    v.Modelo AS Veiculo,
    e.Nome_Equipe AS Equipe_Responsavel,
    o.Status
FROM OS o
INNER JOIN Veiculo v ON o.idVeiculo = v.idVeiculo
INNER JOIN Cliente c ON v.idCliente = c.idCliente
INNER JOIN Equipe e ON o.idEquipe = e.idEquipe
ORDER BY o.Data_Emissao;

SELECT 
    o.Numero_OS,
    o.Status,
    -- Soma (Total Serviços) + (Total Peças)
    (COALESCE((SELECT SUM(s.Valor_Cobrado * s.Quantidade) FROM Item_OS_Servico s WHERE s.idOS = o.idOS), 0) +
     COALESCE((SELECT SUM(p.Valor_Cobrado * p.Quantidade) FROM Item_OS_Peca p WHERE p.idOS = o.idOS), 0)) AS Valor_Final_Calculado
FROM OS o
WHERE o.Status = 'Finalizado';