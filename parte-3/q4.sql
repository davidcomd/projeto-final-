-- Q4. Pesquisadores com 10 h ou mais de uso realizado, por projeto
SELECT pe.nome AS pesquisador,
       pr.titulo AS projeto,
       COUNT(r.id_reserva) AS sessoes,
       SUM(r.duracao) AS horas,
       COUNT(DISTINCT e.patrimonio) AS equipamentos_distintos
FROM PESQUISADOR pe
INNER JOIN RESERVA r ON r.id_pesquisador = pe.id_pesquisador
INNER JOIN PROJETO pr ON pr.id_projeto = r.id_projeto
INNER JOIN EQUIPAMENTO e ON e.patrimonio = r.patrimonio
WHERE r.status = 'CONCLUIDA'
GROUP BY pe.id_pesquisador, pe.nome, pr.titulo
HAVING SUM(r.duracao) >= 10
ORDER BY horas DESC, pesquisador ASC;