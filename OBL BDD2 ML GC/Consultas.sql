select * from choferes

select * from clientes

select * from destinos

select * from oficinas

select * from pagos

select * from paises

select * from vehiculos

select * from modeloVehiculo

select * from viajes


--Doc quiere premiar a los conductores que más lejos viajaron en el tiempo.
--Para ello, necesita identificar a los tres choferes que hayan acumulado más años viajados que el promedio general, considerando únicamente viajes efectivamente realizados.
--Se deberá calcular la cantidad de años recorridos en cada viaje tomando la diferencia entre la fecha del destino y la fecha de salida.



SELECT TOP 3 c.codChofer, c.nombre, c.apellido,acumulados.totalAniosAcumulados
FROM (SELECT v.codChoferAsignado, SUM(ABS(DATEDIFF(YEAR, v.fechaHora_salida, d.fecha_hora))) AS totalAniosAcumulados
       FROM viajes v
       INNER JOIN destinos d ON d.codDestino = v.destino_codDestino
       WHERE v.estado = 'REALIZADO'
       AND v.codChoferAsignado IS NOT NULL
       GROUP BY v.codChoferAsignado) AS acumulados
       INNER JOIN choferes c ON c.codChofer = acumulados.codChoferAsignado -- aca las junto 
       WHERE acumulados.totalAniosAcumulados > (SELECT AVG(totalAniosAcumulados)
                                                FROM (SELECT v.codChoferAsignado, SUM(ABS(DATEDIFF(YEAR, v.fechaHora_salida, d.fecha_hora))) AS totalAniosAcumulados
                                                      FROM viajes v
                                                      INNER JOIN destinos d ON d.codDestino = v.destino_codDestino
                                                      WHERE v.estado = 'REALIZADO'
                                                      AND v.codChoferAsignado IS NOT NULL
                                                      GROUP BY v.codChoferAsignado) AS acumulados2)
                                                      ORDER BY acumulados.totalAniosAcumulados DESC;




--Marty detectó que algunos vehículos están consumiendo más energía de la esperada y quiere saber cuáles son los más exigidos del parque automotor. 
--Se solicita listar la patente y el total de Gigowatts consumidos acumulados en todos sus viajes realizados, identificando los cuatro vehículos con mayor consumo total.
--Considerar únicamente viajes efectivamente realizados y calcular el consumo total en función de la energía requerida por cada modelo en cada viaje.



SELECT TOP 4 v.patente, SUM(mv.consumoGWViaje) AS totalGWConsumidos
FROM viajes vi
INNER JOIN vehiculos v ON v.patente = vi.patenteVehiculoAsignado
INNER JOIN modeloVehiculo mv ON mv.codModelo = v.codModelo
WHERE vi.estado = 'REALIZADO'
GROUP BY v.patente
ORDER BY totalGWConsumidos DESC;



--El destino más codiciado
---Marty sospecha que hay un momento en la historia que se volvió furor entre los viajeros… especialmente entre quienes pagan en efectivo para no dejar rastros en el tiempo.
--Se solicita identificar cuál es el destino con mayor demanda, considerando únicamente aquellos viajes cuyos pagos fueron realizados en efectivo.


SELECT TOP 1 d.codDestino, d.descripcion, COUNT(DISTINCT vi.codViaje) AS cantidadViajes --Si tienen la misma cantidad de viajes elige  el que primero se repite en las tuplas
FROM viajes vi
INNER JOIN pagos p ON p.codViaje = vi.codViaje
INNER JOIN destinos d ON d.codDestino = vi.destino_codDestino
WHERE p.metodo = 'EFECTIVO'
GROUP BY d.codDestino, d.descripcion
ORDER BY cantidadViajes DESC;



--Doc quiere revisar el comportamiento de cada cliente para medir confiabilidad temporal. Para cada cliente (nombre y apellido), se solicita informar:
--cuántos viajes pagó con tarjeta (crédito o débito), y
--cuántos viajes tuvo que no se realizaron por quedar cancelados o suspendidos.



SELECT c.nombre, c.apellido, COUNT(DISTINCT CASE WHEN p.metodo IN ('CREDITO', 'DEBITO') THEN v.codViaje END) AS viajesPagadosConTarjeta, COUNT(DISTINCT CASE WHEN v.estado IN ('CANCELADO', 'SUSPENDIDO') THEN v.codViaje END) AS viajesNoRealizados
FROM clientes c
LEFT JOIN viajes v ON v.codCliente = c.codCliente
LEFT JOIN pagos p ON p.codViaje = v.codViaje
GROUP BY c.codCliente, c.nombre, c.apellido;



--Doc descubrió una regla crítica de mantenimiento: los vehículos con capacidad de volar deben recambiar el condensador de flujo cada 457 años acumulados de viaje.
--Se solicita listar las patentes de los vehículos que ya superaron ese umbral, considerando tanto los viajes realizados como los que aún están en curso.
--El objetivo es detectar qué máquinas necesitan pasar urgente por el taller antes de que empiecen los problemas.



SELECT v.patente
FROM viajes vi
INNER JOIN vehiculos v ON v.patente = vi.patenteVehiculoAsignado
INNER JOIN modeloVehiculo mv ON mv.codModelo = v.codModelo
INNER JOIN destinos d ON d.codDestino = vi.destino_codDestino
WHERE mv.realizaVuelo = 1
  AND vi.estado IN ('REALIZADO', 'EN VIAJE')
GROUP BY v.patente
HAVING SUM(ABS(DATEDIFF(YEAR, vi.fechaHora_salida, d.fecha_hora))) > 457;



--Marty quiere premiar a las oficinas que operan sin contratiempos: aquellas que nunca tuvieron viajes cancelados o suspendidos.
--Se solicita listar cada oficina y el total de dinero ganado (suma de costos de sus viajes), pero solo para las oficinas con historial impecable.



SELECT o.codOficina, o.descripcion, SUM(v.costo) AS totalDineroGanado
FROM oficinas o
INNER JOIN viajes v ON v.codOficina = o.codOficina
WHERE NOT EXISTS (
                  SELECT 1
                  FROM viajes v2
                  WHERE v2.codOficina = o.codOficina AND v2.estado IN ('CANCELADO', 'SUSPENDIDO')
                  )
GROUP BY o.codOficina, o.descripcion;



--Marty detectó que hay choferes que todavía no han hecho ningún viaje, pero tal vez su oportunidad está por llegar.
--Se solicita listar los choferes que no tengan viajes en estado REALIZADO, siempre que en el país al que pertenecen existan oficinas con viajes actualmente en estado RESERVADO.
--La idea es encontrar conductores “sin historial”, pero en zonas donde el trabajo ya está esperando.



SELECT c.codChofer, c.nombre, c.apellido
FROM choferes c
WHERE NOT EXISTS (SELECT 1
                  FROM viajes v
                  WHERE v.codChoferAsignado = c.codChofer AND v.estado = 'REALIZADO')
      AND EXISTS (
                  SELECT 1
                  FROM oficinas o
                  INNER JOIN viajes v2 ON v2.codOficina = o.codOficina
                  WHERE o.codPais = c.codPais AND v2.estado = 'RESERVADO'
                 );



--Doc detectó una anomalía en el flujo energético del continuo espacio-tiempo.
--Algunos combustibles están consumiendo demasiados Gigawatts… pero no generan suficientes ingresos.
--Necesita que calcules qué tipo de combustible ofrece mejor rendimiento económico por unidad de energía. El futuro financiero de OUTATIME Inc. depende de esa ecuación



SELECT TOP 1 mv.tipoCombustible, SUM(v.costo) AS ingresosTotales, SUM(mv.consumoGWViaje) AS consumoTotalGW, SUM(v.costo) / SUM(mv.consumoGWViaje) AS rendimientoPorGW
FROM viajes v
INNER JOIN vehiculos veh ON veh.patente = v.patenteVehiculoAsignado
INNER JOIN modeloVehiculo mv ON mv.codModelo = veh.codModelo
WHERE v.estado = 'REALIZADO'
GROUP BY mv.tipoCombustible
ORDER BY rendimientoPorGW DESC;

