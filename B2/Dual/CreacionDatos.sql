/*Departamentos
- nombre varchar(40)
- ubicacion varchar(100)*/
insert into departamentos(nombre, ubicacion)
	values('Educacion','Piso 2, Sala 5');

insert into departamentos(nombre, ubicacion)
	values('Deporte','Piso 1, Sala 2');


/*Empleados
- id_departamento integer NOT NULL,
- nombre varchar(40)
- apellidos varchar(60)
- dni varchar(9)
- puesto varchar(100)*/
insert into empleados(id_departamento, nombre, apellidos, dni, puesto)
    values(1, 'Juan', 'Pérez López', '12345678A', 'Profesor');

insert into empleados(id_departamento, nombre, apellidos, dni, puesto)
    values(2, 'María', 'Gómez Fernández', '87654321B', 'Entrenador');

/*Ciudadanos
- nombre varchar(40)
- apellidos varchar(60)
- dni varchar(9)
- direccion varchar(100)
- telefono varchar(9)
- email varchar(80)*/
insert into ciudadanos(nombre, apellidos, dni, direccion, telefono, email)
    values('Carlos', 'Rodríguez Torres', '11223344C', 'Calle Mayor 10', '600123456', 'carlos@email.com');

insert into ciudadanos(nombre, apellidos, dni, direccion, telefono, email)
    values('Laura', 'Fernández Ruiz', '55667788D', 'Avenida Central 5', '610987654', 'laura@email.com');

/*Permisos
- id_ciudadano integer
- tipo varchar(60)
- fecha_emision date
- fecha_expiracion date*/
insert into permisos(id_ciudadano, tipo, fecha_emision, fecha_expiracion)
    values(1, 'Permiso de conducir', '2024-01-15', '2034-01-15');

insert into permisos(id_ciudadano, tipo, fecha_emision, fecha_expiracion)
    values(2, 'Permiso de residencia', '2023-06-10', '2028-06-10');

/*Impuestos
- nombre varchar(40)
- descripcion varchar(150)
- monto decimal(10,2)
- fecha_vencimiento date*/
insert into impuestos(nombre, descripcion, monto, fecha_vencimiento)
    values('Impuesto de bienes', 'Impuesto anual sobre propiedades inmobiliarias', 250.75, '2024-12-31');

insert into impuestos(nombre, descripcion, monto, fecha_vencimiento)
    values('Impuesto de circulación', 'Impuesto anual sobre vehículos', 120.50, '2024-11-30');

/*Servicios
- nombre varchar(40)
- descripcion varchar(150)
- precio decimal(10,2)*/
insert into servicios(nombre, descripcion, precio)
    values('Agua potable', 'Suministro de agua potable mensual', 30.00);

insert into servicios(nombre, descripcion, precio)
    values('Electricidad', 'Suministro eléctrico mensual', 50.00);

/*Pagos
- id_ciudadano integer
- id_servicio integer
- id_impuesto integer
- monto decimal(10,2)
- fecha_pago date*/
insert into pagos(id_ciudadano, id_servicio, id_impuesto, monto, fecha_pago)
    values(1, 1, 1, 280.75, '2024-02-15');

insert into pagos(id_ciudadano, id_servicio, id_impuesto, monto, fecha_pago)
    values(2, 2, 2, 170.50, '2024-03-20');

commit;


/* Pruebas */
select * from departamentos;
select * from empleados;
select * from ciudadanos;
select * from permisos;
select * from impuestos;
select * from servicios;
select * from pagos;
