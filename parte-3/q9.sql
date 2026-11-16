-- Q9. Retirada de reagente com baixa no lote (1 lançamento errado)
SAVEPOINT retirada_1;
INSERT INTO RETIRA_DE (id_tecnico, id_lote, quantidade)
VALUES (1, 5, 50);
UPDATE LOTE SET quantidade = quantidade - 50 WHERE id_lote = 5;

SAVEPOINT retirada_2;
INSERT INTO RETIRA_DE (id_tecnico, id_lote, quantidade)
VALUES (1, 4, 100);
UPDATE LOTE SET quantidade = quantidade - 100 WHERE id_lote = 4;

ROLLBACK TO SAVEPOINT retirada_2;
RELEASE SAVEPOINT retirada_2;
RELEASE SAVEPOINT retirada_1;

COMMIT;