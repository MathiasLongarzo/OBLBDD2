
CREATE DATABASE OUTATIME_INC
GO
USE OUTATIME_INC
GO

CREATE TABLE paises(
codPais int  primary key,
descripcion varchar(100))
GO

CREATE TABLE oficinas(
codOficina INT primary key,
descripcion varchar(50),
codPais int references paises(codPais),
dirección varchar(100))


GO
CREATE TABLE modeloVehiculo(
codModelo int PRIMARY KEY,
descripcion varchar(50),
consumoGWViaje decimal(8,2) check (consumoGWViaje % 1.21 = 0),
realizaVuelo bit,
tipoCombustible varchar(50) check(tipoCombustible in ('Plutonio','Residuos Orgánicos','Rocas Volcánicas','H2O'))
)
GO

CREATE TABLE vehiculos(
patente varchar(10) primary key,
codPais int REFERENCES paises(codPais),
codModelo int REFERENCES modeloVehiculo(codModelo),
oficinaAsignado int REFERENCES oficinas(codOficina))


GO
--Cambiar datetime a datetime2?
CREATE TABLE destinos(
codDestino int primary key,
descripcion varchar(100),
fecha_hora datetime2)
GO

CREATE TABLE choferes(
codChofer int primary key,
apellido varchar(50),
nombre varchar(50),
codPais int REFERENCES paises(codPais),
fnacimiento date,
oficinaAsignado int REFERENCES oficinas(codOficina))


GO

CREATE TABLE clientes(
codCliente int primary key ,
apellido varchar(50),
nombre varchar(50),
codPais int REFERENCES paises(codPais),
LimiteCreditoMax decimal(8,2))



GO



CREATE TABLE viajes(
codViaje int  primary key,
codCliente int references clientes(codCliente),
codOficina int references oficinas(codOficina),
fechaHoraContratacion datetime2,
fechaHora_salida datetime2,
destino_codDestino int references destinos(codDestino),
fechaHora_vuelta datetime2,
costo money  check (costo > 0),
estado varchar(10) check (estado in ('RESERVADO','REALIZADO','CANCELADO','SUSPENDIDO','EN VIAJE')),
codChoferAsignado int references choferes(codChofer),
patenteVehiculoAsignado varchar(10) references vehiculos(patente),
CONSTRAINT UK_DESTINO UNIQUE(codCliente,destino_codDestino),
CONSTRAINT CH_FECHAS_VIAJE CHECK(fechaHora_salida < fechaHora_vuelta),
CONSTRAINT CH_FECHAS_CONTRATO CHECK(fechaHoraContratacion < fechaHora_vuelta AND fechaHoraContratacion < fechaHora_salida)

)


GO

CREATE TABLE pagos(
codPago int  primary key,
codViaje int references viajes (codViaje),
metodo varchar(30) CHECK (metodo in ('CREDITO','DEBITO','EFECTIVO','TRANSFERENCIA')),
cuotas int check (cuotas > 0),
montoTotal money check (montoTotal > 0))



GO


CREATE TABLE devoluciones(
codDevolucion int primary key identity,
codPago int references pagos(codPago),
fechaDevolucion datetime2, 
montoDevuelto money check (montoDevuelto > 0),
motivo varchar(100))


/*Indices de FK*/

/*Devoluciones*/

CREATE NONCLUSTERED INDEX FKCodPagoInDevoluciones ON devoluciones(codPago)

/*Pagos*/

CREATE NONCLUSTERED INDEX FKCodViajeInPagos ON pagos(codViaje)

/*Viajes*/

CREATE NONCLUSTERED INDEX FKCodCLientesInViajes ON viajes(codCLiente)
CREATE NONCLUSTERED INDEX FKCodOficinaInViajes ON viajes(codOficina)
CREATE NONCLUSTERED INDEX FKCodDestinoInViajes ON viajes(destino_codDestino)
CREATE NONCLUSTERED INDEX FKCodChoferInViajes ON viajes(codChoferAsignado)
CREATE NONCLUSTERED INDEX FKPatenteInVIajes ON viajes(patenteVehiculoAsignado)

/*Clientes*/

CREATE NONCLUSTERED INDEX FKCodPaisInClientes ON clientes (codPais)

/*Choferes*/

CREATE NONCLUSTERED INDEX FKCodPaisInChoferes ON choferes (codPais)
CREATE NONCLUSTERED INDEX FKCodOficinaInChoferes ON choferes(oficinaAsignado)

/*Vehiculos*/

CREATE NONClustered Index FKCodPaisInVehiculos ON vehiculos (codPais)
Create NONClustered Index FKCodModeloInVehiculos ON vehiculos(codModelo)
CREATE NONCLUSTERED INDEX FKCodOficinaInVehiculos ON vehiculos(oficinaAsignado)

/*Oficinas*/

CREATE NONClustered Index FKCodPaisInOficina ON oficinas (codPais);

/*Indices para consultas*/

/*Choferes que mas desafiaron el tiempo (1)*/
Create NONCLUSTERED INDEX DatosMejoresChoferes ON viajes (codChoferAsignado,estado,fechaHora_salida,fechaHora_vuelta)

/*Devoradores de energia (2)*/
Create NonClustered Index DatosMayorConsumo ON modeloVehiculo (codModelo,consumoGWViaje,realizaVuelo,tipoCombustible)
Create NonClustered Index DatosMayorConsumo2 ON vehiculos (patente)

/*Destino mas codiciado (3)*/
Create NonClustered Index DestinoMasCodiciado ON viajes (destino_codDestino)
Create NonClustered Index DestinoMasCodiciado2 ON pagos (metodo)

/*Clientes con historial movido (4)*/
Create NonClustered Index ClientesMovidos ON Clientes (Nombre, Apellido)
Create NonClustered Index ClientesMovidos2 ON pagos (metodo)
Create NonClustered Index ClientesMovidos3 ON viajes (estado)

/*Recambio de flujo (5)*/
Create NonClustered Index TallerUrgente2 ON Viajes (patenteVehiculoAsignado,estado)

/*Oficinas con historial perfecto*/
Create NonClustered Index OficinasPerfectas ON Viajes (codOficina,estado,costo)

/*Choferes con futuro*/
Create NonClustered Index ChoferesConReserva ON Choferes (codChofer,codPais)
Create NonClustered Index ChoferesConReserva ON Viajes (codChoferAsignado,estado)

/*Gigawatts que pagan mejor*/
Create NonClustered Index CombustiblesResntables ON modeloVehiculo (consumoGWViaje,tipoCombustible)


DELETE FROM devoluciones

DELETE FROM PAGOS

DELETE FROM VIAJES




-- =========================================
-- PAISES
-- =========================================

INSERT INTO paises VALUES (1,'Uruguay')
INSERT INTO paises VALUES (2,'Estados Unidos')
INSERT INTO paises VALUES (3,'Japón')
INSERT INTO paises VALUES (4,'Italia')
INSERT INTO paises VALUES (5,'Alemania')
INSERT INTO paises VALUES (6,'Reino Unido')
INSERT INTO paises VALUES (7,'Brasil')
INSERT INTO paises VALUES (8,'Francia')
GO

-- =========================================
-- OFICINAS
-- =========================================

INSERT INTO oficinas VALUES (1,'Montevideo Central',1,'18 de Julio 1234')
INSERT INTO oficinas VALUES (2,'Punta del Este TimePort',1,'Gorlero 445')
INSERT INTO oficinas VALUES (3,'Hill Valley HQ',2,'9303 Lyon Drive')
INSERT INTO oficinas VALUES (4,'New York Temporal Station',2,'5th Avenue 777')
INSERT INTO oficinas VALUES (5,'Tokyo Quantum Gate',3,'Shibuya 404')
INSERT INTO oficinas VALUES (6,'Roma Antica Tours',4,'Via del Corso 88')
INSERT INTO oficinas VALUES (7,'Berlin Chronos',5,'Alexanderplatz 12')
INSERT INTO oficinas VALUES (8,'London Time Agency',6,'Baker Street 221B')
INSERT INTO oficinas VALUES (9,'Rio Flux Center',7,'Copacabana 500')
INSERT INTO oficinas VALUES (10,'Paris Continuum',8,'Rue Rivoli 45')
INSERT INTO oficinas VALUES (11,'Chicago TimeLab',2,'Lake Shore Drive 99')
INSERT INTO oficinas VALUES (12,'Kyoto Legacy Trips',3,'Gion District 77')
GO

-- =========================================
-- MODELOS DE VEHICULO
-- =========================================

INSERT INTO modeloVehiculo VALUES (1,'DeLorean DMC-12',121.00,1,'Plutonio')
INSERT INTO modeloVehiculo VALUES (2,'Time Train X',242.00,0,'Rocas Volcánicas')
INSERT INTO modeloVehiculo VALUES (3,'Hover Van 88',363.00,1,'H2O')
INSERT INTO modeloVehiculo VALUES (4,'Quantum Bike',484.00,0,'Residuos Orgánicos')
INSERT INTO modeloVehiculo VALUES (5,'Flux Bus',605.00,1,'H2O')
INSERT INTO modeloVehiculo VALUES (6,'Chrono Cab',726.00,0,'Plutonio')
GO

-- =========================================
-- VEHICULOS
-- =========================================

INSERT INTO vehiculos VALUES ('OUT-001',2,1,3)
INSERT INTO vehiculos VALUES ('OUT-002',1,1,1)
INSERT INTO vehiculos VALUES ('OUT-003',6,3,8)
INSERT INTO vehiculos VALUES ('OUT-004',3,5,5)
INSERT INTO vehiculos VALUES ('OUT-005',4,2,6)
INSERT INTO vehiculos VALUES ('OUT-006',5,4,7)
INSERT INTO vehiculos VALUES ('OUT-007',2,6,4)
INSERT INTO vehiculos VALUES ('OUT-008',1,3,2)
INSERT INTO vehiculos VALUES ('OUT-009',7,5,9)
INSERT INTO vehiculos VALUES ('OUT-010',8,2,10)
INSERT INTO vehiculos VALUES ('OUT-011',2,1,11)
INSERT INTO vehiculos VALUES ('OUT-012',3,3,12)
INSERT INTO vehiculos VALUES ('OUT-013',2,5,3)
INSERT INTO vehiculos VALUES ('OUT-014',6,1,8)
INSERT INTO vehiculos VALUES ('OUT-015',1,4,1)
INSERT INTO vehiculos VALUES ('OUT-016',5,2,7)
INSERT INTO vehiculos VALUES ('OUT-017',4,3,6)
INSERT INTO vehiculos VALUES ('OUT-018',3,5,5)
GO

-- =========================================
-- DESTINOS HISTORICOS
-- =========================================
--Destinos no cargados :1,2,11,,14,22.

INSERT INTO destinos VALUES (1,'Descubrimiento de América - 1492','1492-10-12 10:00')
INSERT INTO destinos VALUES (2,'Caída del Imperio Romano - 476','0476-09-04 12:00')
INSERT INTO destinos VALUES (3,'Revolución Francesa - 1789','1789-07-14 08:00')
INSERT INTO destinos VALUES (4,'Firma de la Independencia USA - 1776','1776-07-04 09:00')
INSERT INTO destinos VALUES (5,'Hundimiento del Titanic - 1912','1912-04-15 02:20')
INSERT INTO destinos VALUES (6,'Llegada a la Luna - 1969','1969-07-20 20:17')
INSERT INTO destinos VALUES (7,'Muro de Berlín cae - 1989','1989-11-09 18:00')
INSERT INTO destinos VALUES (8,'Final Copa del Mundo Uruguay 1930','1930-07-30 15:00')
INSERT INTO destinos VALUES (9,'Woodstock - 1969','1969-08-15 18:00')
INSERT INTO destinos VALUES (10,'Primer vuelo de los Wright - 1903','1903-12-17 10:35')
INSERT INTO destinos VALUES (11,'Incendio de Roma - 64','0064-07-19 22:00')
INSERT INTO destinos VALUES (12,'Coronación de Napoleón - 1804','1804-12-02 11:00')
INSERT INTO destinos VALUES (13,'Apertura Torre Eiffel - 1889','1889-03-31 09:00')
INSERT INTO destinos VALUES (14,'Jurassic Period Expedition','0065-06-10 10:00')
INSERT INTO destinos VALUES (15,'Tokyo Futuro Cyberpunk - 2150','2150-05-20 21:00')
INSERT INTO destinos VALUES (16,'Colonización de Marte - 2145','2145-01-01 00:00')
INSERT INTO destinos VALUES (17,'Nueva Roma Espacial - 2500','2500-08-01 12:00')
INSERT INTO destinos VALUES (18,'Primera IA Mundial - 2088','2088-04-11 13:00')
INSERT INTO destinos VALUES (19,'Pandemia Global - 2020','2020-03-11 09:00')
INSERT INTO destinos VALUES (20,'Hill Valley 1955','1955-11-12 22:04')
INSERT INTO destinos VALUES (21,'Concierto Queen Wembley 1986','1986-07-12 20:00')
INSERT INTO destinos VALUES (22,'Descubrimiento de fuego controlado','0020-01-01 12:00')
INSERT INTO destinos VALUES (23,'Batalla de Waterloo - 1815','1815-06-18 14:00')
INSERT INTO destinos VALUES (24,'Mundial Qatar 2022','2022-12-18 18:00')
INSERT INTO destinos VALUES (25,'Crisis Energética Mundial 2099','2099-10-10 08:00')
GO

-- =========================================
-- CHOFERES
-- =========================================

INSERT INTO choferes VALUES (1,'McFly','Marty',2,'1998-06-12',3)
INSERT INTO choferes VALUES (2,'Brown','Emmett',2,'1960-03-01',3)
INSERT INTO choferes VALUES (3,'Rodriguez','Lucia',1,'1985-01-10',1)
INSERT INTO choferes VALUES (4,'Tanaka','Kenji',3,'1990-08-11',5)
INSERT INTO choferes VALUES (5,'Rossi','Marco',4,'1978-02-20',6)
INSERT INTO choferes VALUES (6,'Schmidt','Anna',5,'1982-12-01',7)
INSERT INTO choferes VALUES (7,'Smith','John',2,'1975-09-14',4)
INSERT INTO choferes VALUES (8,'Taylor','Rose',6,'1992-04-05',8)
INSERT INTO choferes VALUES (9,'Silva','Joao',7,'1988-05-17',9)
INSERT INTO choferes VALUES (10,'Dubois','Claire',8,'1991-07-07',10)
INSERT INTO choferes VALUES (11,'Perez','Martin',1,'1994-03-02',2)
INSERT INTO choferes VALUES (12,'Sato','Aiko',3,'1987-10-10',12)
INSERT INTO choferes VALUES (13,'Johnson','Rick',2,'1980-11-11',11)
INSERT INTO choferes VALUES (14,'Bianchi','Luca',4,'1979-06-22',6)
INSERT INTO choferes VALUES (15,'Meyer','Karl',5,'1986-09-09',7)
INSERT INTO choferes VALUES (16,'Wilson','Kate',6,'1993-01-30',8)
INSERT INTO choferes VALUES (17,'Costa','Felipe',7,'1995-05-25',9)
INSERT INTO choferes VALUES (18,'Moreau','Jean',8,'1981-08-18',10)
INSERT INTO choferes VALUES (19,'Lopez','Camila',1,'1997-02-13',1)
INSERT INTO choferes VALUES (20,'Nakamura','Yuki',3,'1996-12-24',5)
GO

-- =========================================
-- CLIENTES
-- =========================================

INSERT INTO clientes VALUES (1,'Gomez','Laura',1,50000)
INSERT INTO clientes VALUES (2,'Fernandez','Diego',1,70000)
INSERT INTO clientes VALUES (3,'Parker','Peter',2,90000)
INSERT INTO clientes VALUES (4,'Wayne','Bruce',2,150000)
INSERT INTO clientes VALUES (5,'Yamada','Hiro',3,80000)
INSERT INTO clientes VALUES (6,'Ricci','Paolo',4,60000)
INSERT INTO clientes VALUES (7,'Muller','Hans',5,120000)
INSERT INTO clientes VALUES (8,'Johnson','Emily',6,95000)
INSERT INTO clientes VALUES (9,'Souza','Carlos',7,40000)
INSERT INTO clientes VALUES (10,'Martin','Sophie',8,110000)
INSERT INTO clientes VALUES (11,'Perez','Luciana',1,55000)
INSERT INTO clientes VALUES (12,'Kent','Clark',2,130000)
INSERT INTO clientes VALUES (13,'Suzuki','Mei',3,72000)
INSERT INTO clientes VALUES (14,'Romano','Giulia',4,61000)
INSERT INTO clientes VALUES (15,'Fischer','Greta',5,83000)
INSERT INTO clientes VALUES (16,'Taylor','William',6,47000)
INSERT INTO clientes VALUES (17,'Oliveira','Marina',7,67000)
INSERT INTO clientes VALUES (18,'Bernard','Louis',8,99000)
INSERT INTO clientes VALUES (19,'Acosta','Nicolas',1,54000)
INSERT INTO clientes VALUES (20,'Lee','Haru',3,75000)
GO

-- =========================================
-- VIAJES
-- =========================================
--Viajes no cargados:6,11,15,

INSERT INTO viajes VALUES (1,1,1,'2025-01-01','2026-01-01',8,'2026-01-03',12000,'REALIZADO',3,'OUT-002')
INSERT INTO viajes VALUES (2,2,3,'2025-01-05','2026-02-01',20,'2026-02-03',18000,'REALIZADO',1,'OUT-001')
INSERT INTO viajes VALUES (3,3,4,'2025-01-10','2026-03-01',5,'2026-03-06',25000,'REALIZADO',7,'OUT-007')
INSERT INTO viajes VALUES (4,4,5,'2025-01-15','2026-03-10',15,'2026-03-15',35000,'REALIZADO',4,'OUT-004')
INSERT INTO viajes VALUES (5,5,5,'2025-01-20','2026-04-01',16,'2026-04-05',32000,'REALIZADO',20,'OUT-018')
INSERT INTO viajes VALUES (6,6,6,'2025-02-01','2026-04-10',2,'2026-04-15',29000,'REALIZADO',5,'OUT-005')
INSERT INTO viajes VALUES (7,7,7,'2025-02-05','2026-05-01',7,'2026-05-02',15000,'REALIZADO',6,'OUT-006')
INSERT INTO viajes VALUES (8,8,8,'2025-02-10','2026-05-10',3,'2026-05-15',17000,'REALIZADO',8,'OUT-003')
INSERT INTO viajes VALUES (9,9,9,'2025-02-15','2026-05-20',6,'2026-05-25',21000,'REALIZADO',9,'OUT-009')
INSERT INTO viajes VALUES (10,10,10,'2025-02-20','2026-06-01',13,'2026-06-05',16000,'REALIZADO',10,'OUT-010')
INSERT INTO viajes VALUES (11,11,2,'2025-03-01','2026-06-10',1,'2026-06-14',40000,'REALIZADO',11,'OUT-008')
INSERT INTO viajes VALUES (12,12,11,'2025-03-05','2026-06-20',17,'2026-06-30',45000,'REALIZADO',13,'OUT-011')
INSERT INTO viajes VALUES (13,13,12,'2025-03-10','2026-07-01',18,'2026-07-05',26000,'REALIZADO',12,'OUT-012')
INSERT INTO viajes VALUES (14,14,6,'2025-03-15','2026-07-10',23,'2026-07-14',15000,'REALIZADO',14,'OUT-017')
INSERT INTO viajes VALUES (15,15,7,'2025-03-20','2026-07-20',11,'2026-07-24',50000,'REALIZADO',15,'OUT-016')
INSERT INTO viajes VALUES (16,16,8,'2025-03-25','2026-08-01',9,'2026-08-03',19000,'REALIZADO',16,'OUT-014')
INSERT INTO viajes VALUES (17,17,9,'2025-04-01','2026-08-10',24,'2026-08-15',9000,'REALIZADO',17,'OUT-009')
INSERT INTO viajes VALUES (18,18,10,'2025-04-05','2026-08-20',12,'2026-08-25',22000,'REALIZADO',18,'OUT-010')
INSERT INTO viajes VALUES (19,19,1,'2025-04-10','2026-09-01',21,'2026-09-05',17000,'REALIZADO',3,'OUT-015')
INSERT INTO viajes VALUES (20,20,5,'2025-04-15','2026-09-10',25,'2026-09-14',28000,'REALIZADO',4,'OUT-004')

-- viajes extra para choferes dominantes
INSERT INTO viajes VALUES (21,1,3,'2025-05-01','2026-10-01',2,'2026-10-10',55000,'REALIZADO',1,'OUT-013')
INSERT INTO viajes VALUES (22,2,3,'2025-05-05','2026-10-15',11,'2026-10-20',53000,'REALIZADO',1,'OUT-001')
INSERT INTO viajes VALUES (23,3,4,'2025-05-10','2026-11-01',22,'2026-11-04',60000,'REALIZADO',7,'OUT-007')
INSERT INTO viajes VALUES (24,4,4,'2025-05-15','2026-11-10',14,'2026-11-14',65000,'REALIZADO',7,'OUT-007')
INSERT INTO viajes VALUES (25,5,1,'2025-05-20','2026-11-20',1,'2026-11-30',42000,'REALIZADO',3,'OUT-002')
INSERT INTO viajes VALUES (26,6,1,'2025-05-25','2026-12-01',2,'2026-12-05',58000,'REALIZADO',3,'OUT-002')
INSERT INTO viajes VALUES (27,7,12,'2025-06-01','2027-01-01',17,'2027-01-05',47000,'REALIZADO',12,'OUT-012')
INSERT INTO viajes VALUES (28,8,12,'2025-06-05','2027-01-10',15,'2027-01-15',33000,'REALIZADO',12,'OUT-018')

-- reservados / suspendidos / cancelados
INSERT INTO viajes VALUES (29,9,1,'2025-06-10','2027-02-01',19,'2027-02-05',10000,'RESERVADO',19,'OUT-015')
INSERT INTO viajes VALUES (30,10,1,'2025-06-15','2027-02-10',6,'2027-02-15',15000,'RESERVADO',19,'OUT-002')
INSERT INTO viajes VALUES (31,11,5,'2025-06-20','2027-03-01',16,'2027-03-06',38000,'EN VIAJE',20,'OUT-004')
INSERT INTO viajes VALUES (32,12,8,'2025-06-25','2027-03-10',15,'2027-03-15',34000,'EN VIAJE',16,'OUT-003')
INSERT INTO viajes VALUES (33,13,7,'2025-07-01','2027-04-01',5,'2027-04-05',23000,'CANCELADO',15,'OUT-016')
INSERT INTO viajes VALUES (34,14,6,'2025-07-05','2027-04-10',3,'2027-04-15',18000,'SUSPENDIDO',14,'OUT-017')
INSERT INTO viajes VALUES (35,15,10,'2025-07-10','2027-05-01',20,'2027-05-03',15000,'CANCELADO',18,'OUT-010')
INSERT INTO viajes VALUES (36,16,9,'2025-07-15','2027-05-10',7,'2027-05-15',12000,'SUSPENDIDO',17,'OUT-009')

-- oficina perfecta (11 y 12)
INSERT INTO viajes VALUES (37,17,11,'2025-08-01','2027-06-01',24,'2027-06-02',9000,'REALIZADO',13,'OUT-011')
INSERT INTO viajes VALUES (38,18,11,'2025-08-05','2027-06-10',6,'2027-06-11',21000,'RESERVADO',13,'OUT-011')
INSERT INTO viajes VALUES (39,19,12,'2025-08-10','2027-07-01',18,'2027-07-03',27000,'REALIZADO',12,'OUT-012')
INSERT INTO viajes VALUES (40,20,12,'2025-08-15','2027-07-10',15,'2027-07-14',31000,'EN VIAJE',12,'OUT-018')
GO

-- =========================================
-- PAGOS
-- =========================================

INSERT INTO pagos VALUES (1,1,'CREDITO',6,12000)
INSERT INTO pagos VALUES (2,2,'EFECTIVO',1,18000)
INSERT INTO pagos VALUES (3,3,'DEBITO',1,25000)
INSERT INTO pagos VALUES (4,4,'TRANSFERENCIA',1,35000)
INSERT INTO pagos VALUES (5,5,'EFECTIVO',1,32000)
INSERT INTO pagos VALUES (6,6,'CREDITO',12,29000)
INSERT INTO pagos VALUES (7,7,'DEBITO',1,15000)
INSERT INTO pagos VALUES (8,8,'EFECTIVO',1,17000)
INSERT INTO pagos VALUES (9,9,'EFECTIVO',1,21000)
INSERT INTO pagos VALUES (10,10,'TRANSFERENCIA',1,16000)
INSERT INTO pagos VALUES (11,11,'CREDITO',9,40000)
INSERT INTO pagos VALUES (12,12,'TRANSFERENCIA',1,45000)
INSERT INTO pagos VALUES (13,13,'DEBITO',1,26000)
INSERT INTO pagos VALUES (14,14,'EFECTIVO',1,15000)
INSERT INTO pagos VALUES (15,15,'CREDITO',10,50000)
INSERT INTO pagos VALUES (16,16,'DEBITO',1,19000)
INSERT INTO pagos VALUES (17,17,'EFECTIVO',1,9000)
INSERT INTO pagos VALUES (18,18,'TRANSFERENCIA',1,22000)
INSERT INTO pagos VALUES (19,19,'CREDITO',3,17000)
INSERT INTO pagos VALUES (20,20,'EFECTIVO',1,28000)
INSERT INTO pagos VALUES (21,21,'EFECTIVO',1,55000)
INSERT INTO pagos VALUES (22,22,'EFECTIVO',1,53000)
INSERT INTO pagos VALUES (23,23,'DEBITO',1,60000)
INSERT INTO pagos VALUES (24,24,'CREDITO',12,65000)
INSERT INTO pagos VALUES (25,25,'EFECTIVO',1,42000)
INSERT INTO pagos VALUES (26,26,'TRANSFERENCIA',1,58000)
INSERT INTO pagos VALUES (27,27,'DEBITO',1,47000)
INSERT INTO pagos VALUES (28,28,'CREDITO',6,33000)
INSERT INTO pagos VALUES (29,29,'EFECTIVO',1,10000)
INSERT INTO pagos VALUES (30,30,'DEBITO',1,15000)
INSERT INTO pagos VALUES (31,31,'TRANSFERENCIA',1,38000)
INSERT INTO pagos VALUES (32,32,'CREDITO',6,34000)
INSERT INTO pagos VALUES (33,33,'EFECTIVO',1,23000)
INSERT INTO pagos VALUES (34,34,'DEBITO',1,18000)
INSERT INTO pagos VALUES (35,35,'EFECTIVO',1,15000)
INSERT INTO pagos VALUES (36,36,'TRANSFERENCIA',1,12000)
INSERT INTO pagos VALUES (37,37,'EFECTIVO',1,9000)
INSERT INTO pagos VALUES (38,38,'CREDITO',3,21000)
INSERT INTO pagos VALUES (39,39,'DEBITO',1,27000)
INSERT INTO pagos VALUES (40,40,'EFECTIVO',1,31000)
GO

-- =========================================
-- DEVOLUCIONES
-- =========================================

INSERT INTO devoluciones(codPago,fechaDevolucion,montoDevuelto,motivo)
VALUES (33,'2027-04-10',23000,'Paradoja temporal detectada')

INSERT INTO devoluciones(codPago,fechaDevolucion,montoDevuelto,motivo)
VALUES (34,'2027-04-20',18000,'Falla del condensador de flujo')

INSERT INTO devoluciones(codPago,fechaDevolucion,montoDevuelto,motivo)
VALUES (35,'2027-05-05',15000,'Interferencia espacio-temporal')

INSERT INTO devoluciones(codPago,fechaDevolucion,montoDevuelto,motivo)
VALUES (36,'2027-05-20',12000,'Distorsión cuántica')
GO

-- =========================================
-- NOTAS IMPORTANTES DEL DATASET
-- =========================================

/*
1) Los choferes 1, 3 y 7 son los que más años acumulan.

2) OUT-004, OUT-007, OUT-002 y OUT-012
son los vehículos con más consumo acumulado.

3) Hill Valley 1955 es el destino más solicitado
pagado en efectivo.

4) Existen oficinas perfectas:
- Oficina 11
- Oficina 12
Nunca tuvieron viajes cancelados ni suspendidos.

5) Vehículos voladores que superan los 457 años:
- OUT-001
- OUT-002
- OUT-004
- OUT-012
- OUT-013
- OUT-018

6) Hay choferes sin REALIZADOS pero con oficinas
en su país que poseen RESERVADOS.

7) H2O debería terminar siendo el combustible
más rentable.

8) Casos para función:
- Cliente 1 ? TENIENTE
- Cliente 4 ? COMANDANTE
- Cliente 7 ? CORONEL
- Cliente 10 ? A REVISAR
- Algunos clientes con solo reservados ? EXPLORADOR
*/

