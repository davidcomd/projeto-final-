-- Q5. Equipamentos com sessões acima da média geral de duração
SELECT e.nome AS equipamento,
       COUNT(*) AS sessoes_acima_da_media,
       ROUND((SELECT AVG(duracao) FROM RESERVA WHERE status <> 'CANCELADA'), 2) AS media_geral_h
FROM RESERVA r
INNER JOIN EQUIPAMENTO e ON e.patrimonio = r.patrimonio
WHERE r.status <> 'CANCELADA'
    AND r.duracao > (SELECT AVG(duracao) FROM RESERVA WHERE status <> 'CANCELADA')
GROUP BY e.patrimonio, e.nome
ORDER BY sessoes_acima_da_media DESC, equipamento ASC;