-- Q7. Lotes com retirada na última semana que vencem em até 60 dias
SELECT l.id_lote,
       rg.nome AS reagente,
       l.validade,
       l.quantidade,
       l.localizacao,
       l.fornecedor
FROM LOTE l
INNER JOIN POSSUI po   ON po.id_lote    = l.id_lote
INNER JOIN REAGENTE rg ON rg.id_reagente = po.id_reagente
WHERE l.id_lote IN (SELECT rd.id_lote
                    FROM RETIRA_DE rd
                    WHERE rd.data_hora >= '2026-11-09')
  AND l.validade BETWEEN '2026-11-15' AND '2027-01-14'
ORDER BY l.validade ASC;