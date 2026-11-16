-- Q6. Pesquisadores que tiveram reserva cancelada por manutenção
SELECT pe.id_pesquisador, pe.nome, pe.email
FROM PESQUISADOR pe
WHERE EXISTS (SELECT id_pesquisador
              FROM RESERVA r
              WHERE r.id_pesquisador = pe.id_pesquisador
                AND r.id_manutencao_cancela IS NOT NULL)
ORDER BY pe.nome;