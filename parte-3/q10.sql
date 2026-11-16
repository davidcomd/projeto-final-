-- Q10. Simulação descartada: apaga relatórios de uso e desfaz tudo
SAVEPOINT simulacao;
DELETE FROM RELATORIO_USO WHERE data_entrega < '2026-11-06';
SELECT COUNT(*) AS relatorios_apos_delete FROM RELATORIO_USO;

ROLLBACK;