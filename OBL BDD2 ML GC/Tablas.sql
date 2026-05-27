Use OUTATIME_INC
Go

--Tablas
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
