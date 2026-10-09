# Oficina mecânica — modelagem de banco de dados

Modelagem completa de uma oficina mecânica em MySQL, do cenário de negócio ao schema.
O problema central não é velocidade: é **como guardar um histórico financeiro que não
muda quando a tabela de preços muda.**

[![MySQL 8.4](https://img.shields.io/badge/MySQL-8.4-4479A1?logo=mysql&logoColor=white)](https://dev.mysql.com/)
[![Um comando](https://img.shields.io/badge/subir-docker%20compose%20up-2496ED?logo=docker&logoColor=white)](#subindo-em-um-comando)
[![Licença MIT](https://img.shields.io/badge/licença-MIT-green)](LICENSE)

![Diagrama EER da oficina: cliente, veículo, equipe, mecânico, ordem de serviço e as tabelas associativas de serviço e peça.](img/diagrama_oficina.png)

---

## O problema que o modelo resolve

Uma oficina reajusta a tabela de preços. Três meses depois, alguém abre uma OS fechada em
janeiro — e ela mostra o preço de hoje. O faturamento daquele mês muda sozinho, a nota
emitida não bate com o sistema, e a discussão com o cliente não tem como ser vencida.

O modelo evita isso guardando o **valor praticado no momento da venda** dentro da tabela
associativa, e não apenas a referência ao catálogo:

```sql
CREATE TABLE Item_OS_Servico (
    idOS           INT,
    idServico      INT,
    Quantidade     INT DEFAULT 1,
    Valor_Cobrado  DECIMAL(10,2) NOT NULL,   -- congelado na venda
    PRIMARY KEY (idOS, idServico),
    CONSTRAINT fk_item_servico_os      FOREIGN KEY (idOS)      REFERENCES OS(idOS),
    CONSTRAINT fk_item_servico_servico FOREIGN KEY (idServico) REFERENCES Servico(idServico)
);
```

### A prova, em uma sessão do MySQL

Antes do reajuste, catálogo e OS coincidem:

```
+-----------+----------------+-------------+------+---------------+
| idServico | Descricao      | tabela_hoje | idOS | cobrado_na_OS |
+-----------+----------------+-------------+------+---------------+
|         1 | Troca de Oleo  |       50.00 |    1 |         50.00 |
|         3 | Retifica Motor |     1500.00 |    2 |       1500.00 |
+-----------+----------------+-------------+------+---------------+
```

Aplicando 30% em todo o catálogo:

```sql
UPDATE Servico SET Valor_Mao_Obra = Valor_Mao_Obra * 1.30;
```

```
+-----------+----------------+---------------------------+------+---------------+
| idServico | Descricao      | tabela_depois_do_reajuste | idOS | cobrado_na_OS |
+-----------+----------------+---------------------------+------+---------------+
|         1 | Troca de Oleo  |                     65.00 |    1 |         50.00 |
|         3 | Retifica Motor |                   1950.00 |    2 |       1500.00 |
+-----------+----------------+---------------------------+------+---------------+
```

**O catálogo subiu. As ordens de serviço já fechadas não se mexeram.** É esse
desacoplamento que o modelo existe para garantir.

---

## Subindo em um comando

```bash
docker compose up -d
```

O container do MySQL aplica os três scripts na primeira subida — por isso eles são
numerados. Em cerca de um minuto existe o banco `oficina_mecanica_refinado` criado,
populado e pronto para consulta.

```bash
mysql -h 127.0.0.1 -P 3306 -u root -proot oficina_mecanica_refinado
```

Porta ocupada por outro projeto? Troque sem editar arquivo nenhum:

```bash
MYSQL_PORT=3310 docker compose up -d
```

Já tem um MySQL no ar? `./scripts/bootstrap.sh` aplica os mesmos arquivos, na mesma ordem.

| # | Script | O que faz |
|---|---|---|
| 01 | `01_tabelas.sql` | cria o banco e as 9 tabelas |
| 02 | `02_insert.sql` | popula clientes, veículos, equipes, serviços, peças e 3 OS |
| 03 | `03_perguntas.sql` | as cinco consultas analíticas |

Cada script abre com `SET NAMES utf8mb4` e `USE`, e por isso roda sozinho, fora de ordem,
sem "No database selected" nem acento quebrado.

---

## Decisões de modelagem

| Decisão | Por quê |
|---|---|
| `Valor_Cobrado` nas tabelas associativas | congela o preço da venda; reajuste de catálogo não reescreve histórico |
| `DECIMAL(10,2)` em todo valor monetário | `FLOAT` acumula erro de arredondamento, e em dinheiro isso vira diferença de centavo que ninguém consegue explicar |
| `Equipe` entre `OS` e `Mecanico` | a OS é atribuída a uma equipe, não a uma pessoa; quem executou fica no vínculo mecânico–equipe |
| `Servico` e `Peca` separadas de seus itens | o catálogo é cadastro, o item é transação — ciclos de vida diferentes |
| Chaves estrangeiras sem propagação em cascata | evita o *snowball effect* de carregar a PK do avô em cada neto |
| `Status` da OS como `ENUM` | o fluxo é fechado: em análise, aguardando aprovação, em execução, finalizado, cancelado |

---

## As consultas

As cinco de [`03_perguntas.sql`](sql_implementation/03_perguntas.sql), cada uma exercitando
uma cláusula diferente.

### 1. Relatório geral — quem está fazendo o quê

`INNER JOIN` entre OS, cliente, veículo e equipe.

![Resultado do relatório geral unindo as quatro tabelas principais.](img/query1.png)

### 2. Serviços acima de R$ 60, do mais caro ao mais barato

`WHERE` + `ORDER BY DESC`.

![Lista de serviços filtrados por valor e ordenados.](img/query2.png)

### 3. Subtotal por item — atributo derivado

Quantidade × valor cobrado, calculado na consulta.

![Cálculo de subtotal multiplicando quantidade por valor unitário.](img/query3.png)

### 4. Clientes com mais de um veículo

`GROUP BY` + `HAVING` — o filtro depois da agregação.

![Clientes que possuem múltiplos veículos cadastrados.](img/query4.png)

### 5. Faturamento de uma OS, com nulo tratado

`COALESCE` sobre duas subconsultas: uma OS pode ter serviço sem peça, ou peça sem serviço.
Sem o `COALESCE`, um lado nulo zera a soma inteira.

![Cálculo do faturamento total somando serviços e peças.](img/query5.png)

---

## Projeto irmão

[**Ecommerce-SQL-Database-Specialist**](https://github.com/danilogep/Ecommerce-SQL-Database-Specialist) —
mesmo stack, eixo diferente. Lá o assunto é **performance medida**: índices avaliados com
benchmark de `EXPLAIN` e tempo sobre 100 mil pedidos, stored procedure, triggers de
auditoria e transações. Aqui é **modelagem**.

## Estrutura

```
sql_implementation/
  01_tabelas.sql … 03_perguntas.sql   a modelagem, em ordem de execução
  Oficina.mwb                         modelo do MySQL Workbench
scripts/bootstrap.sh                  aplica os scripts em um MySQL existente
docker-compose.yml                    MySQL 8.4 + inicialização automática
img/                                  diagrama EER e resultados das consultas
```

## Licença

[MIT](LICENSE).

---

<sub>Parte do meu portfólio — mais projetos em **[github.com/danilogep](https://github.com/danilogep)** · [LinkedIn](https://linkedin.com/in/danilogep)</sub>
