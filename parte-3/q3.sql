-- Q3. Consumo do orçamento de horas por projeto, incluindo projetos sem reservas
SELECT p.id_projeto,
       p.titulo,
       o.nome AS orientador,
       p.orcamento_horas,
       COALESCE(SUM(r.duracao), 0) AS horas_usadas,
       p.orcamento_horas - COALESCE(SUM(r.duracao), 0) AS saldo_horas,
       ROUND(100.0 * COALESCE(SUM(r.duracao), 0) / NULLIF(p.orcamento_horas, 0), 1) AS pct_uso
FROM PROJETO p
INNER JOIN ORIENTADOR o ON o.id_orientador = p.id_orientador
LEFT  JOIN RESERVA r ON r.id_projeto = p.id_projeto
                     AND r.status IN ('APROVADA', 'CONCLUIDA')
GROUP BY p.id_projeto, p.titulo, o.nome, p.orcamento_horas
ORDER BY pct_uso DESC, p.titulo ASC;