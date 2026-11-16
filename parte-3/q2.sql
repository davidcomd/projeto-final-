-- Q2. Equipamentos com 20 ou mais reservas realizadas: menor e maior sessão
SELECT e.patrimonio,
       e.nome,
       COUNT(*) AS reservas_realizadas,
       MIN(r.duracao) AS menor_sessao_h,
       MAX(r.duracao) AS maior_sessao_h,
       SUM(r.duracao) AS horas_uso
FROM EQUIPAMENTO e
INNER JOIN RESERVA r ON r.patrimonio = e.patrimonio
WHERE r.status = 'CONCLUIDA'
GROUP BY e.patrimonio, e.nome
HAVING COUNT(*) >= 20
ORDER BY reservas_realizadas DESC, e.nome ASC;