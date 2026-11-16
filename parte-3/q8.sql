-- Q8. Reagentes abaixo do estoque mínimo
WITH saldo_reagente AS (
    SELECT rg.id_reagente,
           rg.nome,
           rg.estoque_min,
           COALESCE(SUM(l.quantidade), 0) AS qtd_disponivel
    FROM REAGENTE rg
    LEFT JOIN POSSUI po ON po.id_reagente = rg.id_reagente
    LEFT JOIN LOTE l ON l.id_lote = po.id_lote
                      AND l.status  = 'DISPONIVEL'
    GROUP BY rg.id_reagente, rg.nome, rg.estoque_min
)
SELECT nome,
       estoque_min,
       qtd_disponivel,
       estoque_min - qtd_disponivel AS deficit
FROM saldo_reagente
WHERE qtd_disponivel < estoque_min
ORDER BY deficit DESC;