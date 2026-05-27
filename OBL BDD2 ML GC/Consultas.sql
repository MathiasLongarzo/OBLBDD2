USe OUTATIME_INC
go
SELECT codCliente,destino_codDestino,COUNT(*)
FROM viajes
GROUP BY codCliente,destino_codDestino
HAVING COUNT(*) > 1