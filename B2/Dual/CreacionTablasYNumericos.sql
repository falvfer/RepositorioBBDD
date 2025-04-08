/* Crear las tablas */

CREATE TABLE Ciudadanos(
	id_ciudadano integer NOT NULL,
	nombre varchar(40) NOT NULL,
	apellidos varchar(60) NOT NULL,
	dni varchar(9) NOT NULL UNIQUE,
	direccion varchar(100) NOT NULL,
	telefono varchar(9) NOT NULL,
	email varchar(80) NOT NULL,
	PRIMARY KEY (id_ciudadano)
);

CREATE TABLE Departamentos(
	id_departamento integer NOT NULL,
	nombre varchar(40) NOT NULL,
	ubicacion varchar(100) NOT NULL,
	PRIMARY KEY (id_departamento)
);

CREATE TABLE Empleados(
	id_empleado integer NOT NULL,
	id_departamento integer NOT NULL,
	nombre varchar(40) NOT NULL,
	apellidos varchar(60) NOT NULL,
	dni varchar(9) NOT NULL UNIQUE,
	puesto varchar(100) NOT NULL,
	PRIMARY KEY (id_empleado)
);

CREATE TABLE Impuestos(
	id_impuesto integer NOT NULL,
	nombre varchar(40) NOT NULL,
	descripcion varchar(150),
	monto decimal(10,2) NOT NULL,
	fecha_vencimiento date NOT NULL,
	PRIMARY KEY (id_impuesto)
);

CREATE TABLE Servicios(
	id_servicio integer NOT NULL,
	nombre varchar(40) NOT NULL,
	descripcion varchar(150),
	precio decimal(10,2) NOT NULL,
	PRIMARY KEY (id_servicio)
);

CREATE TABLE Pagos(
	id_pago integer NOT NULL,
	id_ciudadano integer NOT NULL,
	id_servicio integer, -- Un pago puede tener servicio e impuesto, o uno de los dos solamente.
	id_impuesto integer,
	monto decimal(10,2) NOT NULL,
	fecha_pago date NOT NULL,
	PRIMARY KEY (id_pago)
);

CREATE TABLE Permisos(
	id_permiso integer NOT NULL,
	id_ciudadano integer NOT NULL,
	tipo varchar(60) NOT NULL,
	fecha_emision date NOT NULL,
	fecha_expiracion date NOT NULL,
	PRIMARY KEY (id_permiso)
);


/* Crear las Foreign Keys */
ALTER TABLE Pagos
	ADD FOREIGN KEY (id_ciudadano)
	REFERENCES Ciudadanos (id_ciudadano)
;

ALTER TABLE Permisos
	ADD FOREIGN KEY (id_ciudadano)
	REFERENCES Ciudadanos (id_ciudadano)
;

ALTER TABLE Empleados
	ADD FOREIGN KEY (id_departamento)
	REFERENCES Departamentos (id_departamento)
;

ALTER TABLE Pagos
	ADD FOREIGN KEY (id_impuesto)
	REFERENCES Impuestos (id_impuesto)
;

ALTER TABLE Pagos
	ADD FOREIGN KEY (id_servicio)
	REFERENCES Servicios (id_servicio)
;


/* Crear las secuencias para los ID */
CREATE SEQUENCE ciudadanos_num;
CREATE SEQUENCE departamentos_num;
CREATE SEQUENCE empleados_num;
CREATE SEQUENCE impuestos_num;
CREATE SEQUENCE servicios_num;
CREATE SEQUENCE pagos_num;
CREATE SEQUENCE permisos_num;


/* Aplicar los auto numéricos */
SET TERM ^ ;
  CREATE TRIGGER bi_ciudadanos FOR ciudadanos
  ACTIVE BEFORE INSERT POSITION 0
  AS
  BEGIN
      IF (NEW.id_ciudadano IS NULL) THEN
          NEW.id_ciudadano = NEXT VALUE FOR ciudadanos_num;
  END^

  CREATE TRIGGER bi_departamentos FOR departamentos
  ACTIVE BEFORE INSERT POSITION 0
  AS
  BEGIN
      IF (NEW.id_departamento IS NULL) THEN
          NEW.id_departamento = NEXT VALUE FOR departamentos_num;
  END^

  CREATE TRIGGER bi_empleados FOR empleados
  ACTIVE BEFORE INSERT POSITION 0
  AS
  BEGIN
      IF (NEW.id_empleado IS NULL) THEN
          NEW.id_empleado = NEXT VALUE FOR empleados_num;
  END^

  CREATE TRIGGER bi_impuestos FOR impuestos
  ACTIVE BEFORE INSERT POSITION 0
  AS
  BEGIN
      IF (NEW.id_impuesto IS NULL) THEN
          NEW.id_impuesto = NEXT VALUE FOR impuestos_num;
  END^

  CREATE TRIGGER bi_servicios FOR servicios
  ACTIVE BEFORE INSERT POSITION 0
  AS
  BEGIN
      IF (NEW.id_servicio IS NULL) THEN
          NEW.id_servicio = NEXT VALUE FOR servicios_num;
  END^

  CREATE TRIGGER bi_pagos FOR pagos
  ACTIVE BEFORE INSERT POSITION 0
  AS
  BEGIN
      IF (NEW.id_pago IS NULL) THEN
          NEW.id_pago = NEXT VALUE FOR pagos_num;
  END^

  CREATE TRIGGER bi_permisos FOR permisos
  ACTIVE BEFORE INSERT POSITION 0
  AS
  BEGIN
      IF (NEW.id_permiso IS NULL) THEN
          NEW.id_permiso = NEXT VALUE FOR permisos_num;
  END^
SET TERM ; ^