-- Q1. Volume de reservas por laboratório e status
SELECT e.laboratorio,
       r.status,
       COUNT(*) AS qtd_reservas,
       SUM(r.duracao) AS horas_total,
       ROUND(AVG(r.duracao), 2) AS duracao_media_h
FROM RESERVA r
INNER JOIN EQUIPAMENTO e ON e.patrimonio = r.patrimonio
GROUP BY e.laboratorio, r.status
ORDER BY e.laboratorio ASC, horas_total DESC;