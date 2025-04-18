select;
/*Insertar el propietario Agustín que es de Antequera y con NIF: 66667777J*/
insert into propietarios (nif, nombre, direccion, poblacion)
	values ('66667777J', 'Agustin', 'Calle de Agustin', 'Antequera');
commit; -- Importante, no poner tildes en las cadenas de texto

select * from propietarios;

/*Insertar a Leocadia, con nif 55667788V y es de Archidona
y nos arrepentimos después de crearla*/
insert into propietarios (nif, nombre, direccion, poblacion)
	values ('55667788V', 'Leocadia', 'Calle de Leocadia', 'Archidona');
rollback;

/*Inserto Leocadia, esta vez estando seguros.*/
insert into propietarios (nif, nombre, direccion, poblacion)
	values ('55667788V', 'Leocadia', 'Calle de Leocadia', 'Archidona');
commit;

-- Raulillo
insert into inquilinos (nif, nombre, direccion, poblacion)
	values ('234222G', 'Raulillo', 'Calle Ejido 99', 'Archidona');
commit;

/*Insertar sin el campo dirección*/
insert into inquilinos (nif, nombre, poblacion)
	values ('234222G', 'Raulillo', 'Archidona')
commit;

/*Insertar sin el campo población*/
insert into inquilinos (nif, nombre, direccion)
	values ('234222G', 'Raulillo', 'Calle Ejido 99')
commit;

/*Insertar con población nula*/
insert into inquilinos (nif, nombre, direccion, poblacion)
	values ('234222G', 'Raulillo', 'Calle Ejido 99', null);
commit;

/*Insertar un inquilino indicando el id directamente (sin autoincremento)*/
insert into inquilinos (id_inquilino, nif, nombre, direccion, poblacion)
	values (14, '333333G', 'Federico', 'Dios sabe', 'Malaga');
commit;

/*Hacemos inserciones. Cuando el autonumérico llegue al id que hemos insertado
manualmente nos fallará porque la clave principal solo puede ser única, no
se permite 2 veces el mismo número*/
insert into inquilinos (id_inquilino, nif, nombre, direccion, poblacion)
	values ('333333G', 'Manuel', 'Dios sabe', 'Malaga');
commit;

/*Inserción múltiple: Resulta que el propietario con id 5 pasa también a ser inquilino*/
-- Obtengo los datos que voy a insertar
insert into inquilinos (nif, nombre, direccion, poblacion)
	select nif, nombre, direccion, poblacion
    	from propietarios
        where id_propietario = 5;
commit;

/*Los propietarios con id 1 a 3 son también inquilinos pero con población en loja*/
insert into inquilinos (nif, nombre, direccion, poblacion)
	select nif, nombre, direccion, 'loja'
		from propietarios
    	where id_propietario between 1 and 3;
commit;

/*CREAR DOMINIOS*/
create domain DENTERO integer;

/*CREAR TABLAS*/

/*Creamos la tabla estadisticas
Almacena las estadisticas de reparaciones por meses*/
create table estadisticas (
	id_estadistica d_id generated by default as identity not NULL,
    anno DENTERO default 2024 not null,
    mes DENTERO default 1 not NULL,
    n_reparaciones DENTERO default 0 not null,
    importe_base d_dinero default 0.0 not null,
    importe_iva d_dinero default 0.0 not null);
    
select * from estadisticas;

/*Insertar las estadísticas de las reparaciones de enero del 24*/
select  2024, 1, count(*),
        coalesce(sum(base), 0.0),
        coalesce(sum(base * iva_por / 100), 0.0)
    from reparaciones
    where extract(year from fecha) = 2024
      and extract(month from fecha) = 1;
          
insert into estadisticas (anno, mes, n_reparaciones, importe_base, importe_iva)
    select 2024, 1, count(*),
    		coalesce(sum(base), 0.0),
    		coalesce(sum(base * iva_por / 100), 0.0)
        from reparaciones
        where extract(year from fecha) = 2024
          and extract(month from fecha) = 1;
commit;

/*BORRAR ESTADÍSTICAS, SENTENCIA DELETE: Funciona igual que una sentencia select
pero sin elegir las columnas*/

/*queremos borrar todas las estadísticas*/
delete from estadisticas;
commit;

/*Vamos a añadir las estadísticas de todos los años y meses donde haya reparaciones*/
select  extract(year from fecha), extract(month from fecha), count(*),
        coalesce(sum(base), 0.0),
        coalesce(sum(base * iva_por / 100), 0.0)
    from reparaciones
	group by 1, 2;

insert into estadisticas (anno, mes, n_reparaciones, importe_base, importe_iva)
    select  extract(year from fecha), extract(month from fecha), count(*),
            coalesce(sum(base), 0.0),
            coalesce(sum(base * iva_por / 100), 0.0)
        from reparaciones
        group by 1, 2;
commit;

/*ACTUALIZAR CELDAS, SENTENCIA UPDATE: Funciona igual que una sentencia select
pero con "set" para modificar*/

/*Por ejemplo: Tenemos errores y los iva_por en reparaciones negativos hay que
ponerlos en positivo*/
select r.iva_por
	from reparaciones r
    where iva_por < 0;

update reparaciones r
	set r.iva_por = abs(r.iva_por)
    where iva_por < 0;
commit;

/*Fijar el precio de habitaciones al máximo del precio de los alquileres
de esa habitación, las que no tienen alquiler se pone 200*/
select id_habitacion, precio,
		(select coalesce(max(a.precio), 200)
        	from alquileres a
        	where a.ID_HABITACION = h.ID_HABITACION)
	from habitaciones h;
    
update habitaciones h
	set precio = coalesce((select max(a.precio)
        	from alquileres a
        	where a.ID_HABITACION = h.ID_HABITACION), 200);
commit;
    
-- quiero poner a 0 todos los precios que están a 200
select id_habitacion, precio, 0
	from habitaciones h
    where precio = 200;
    
update habitaciones h
	set precio = 0
    where precio = 200;
commit;

-- en vez de 200 se queda con el precio original de la habitacion
select id_habitacion, precio, coalesce(
		(select max(a.precio)
        	from alquileres a
        	where a.ID_HABITACION = h.ID_HABITACION), precio)
	from habitaciones h;

/*Resulta que tengo un nuevo piso en la calle 'C/ Puerta 23', de 'Antequera'
que es del mismo propietario del piso con id = 3
Insertar este nuevo piso*/

select id_propietario
	from pisos
	where id_piso = 3;

insert into pisos (id_propietario, direccion, poblacion)
	select id_propietario, 'C/ Puerta 23-B', 'Antequera'
				from pisos
				where id_piso = 3;
commit;



/*INSERT*/

/*1. Inserta un alquiler que esta activo a 250€ a fecha de hoy y duración tres meses a la habitación 4 y del inquilino 3.*/

       
/*2. Insertar un reparador que es la mujer del reparador 1 vive en el mismo sitio y tiene como nif 12312345N y nombre Juliana.*/

       
/*3. Inserta un reparación al primer piso que no tenga inquilino a fecha de hoy realizada por el repartidor 1 con base 100 y porcentaje de iva 21% y su importe correcto.*/

       
/*4. Hacer lo mismo para todos los pisos que no tengan inquilinos.*/


/*5. Inserta un reparador con nif = 222222, nombre David y que vive en la misma dirección y población que el propietario con id = 3.*/

       
/*6. Insertar un piso del propietario 3 con dirección ‘c/ Ejido 23-A’ de Archidona en esta dirección sólo esta este piso. Además este piso tiene las mismas habitaciones que el piso con id_piso = 4.*/

       
/*7. Insertar un nuevo alquiler que es igual que el alqluiler 4 pero cambiando las fechas 2024-12-01 a 2025-02-28*/

       

/*UPDATE*/

/*8. Subir el precio de todos los alquileres activos un 4%. */
UPDATE alquileres
	SET precio = precio * 1.04
	WHERE activo = TRUE;
commit;

/*9. Subir en 20€ el precio de todas las habitaciones.*/
select id_habitacion, precio, precio+20
	from habitaciones;

UPDATE habitaciones
	SET precio = precio + 20;
commit;

/*10.  Todos los propietarios de Archidona viven ahora en la
‘La Gran Villa de Archidona’*/
UPDATE propietarios
	SET poblacion = 'La Gran Villa de Archidona'
	WHERE poblacion = 'Archidona';
commit;

select * from propietarios;

/*11. El Rey nombra a Antequera con ‘Real Ciudad de Antequera’,
subsanar el problema en toda la base de datos.*/
UPDATE propietarios
	SET poblacion = 'Real Ciudad de Antequera'
	WHERE poblacion = 'Antequera';
UPDATE reparadores
	SET poblacion = 'Real Ciudad de Antequera'
	WHERE poblacion = 'Antequera';
UPDATE inquilinos
	SET poblacion = 'Real Ciudad de Antequera'
	WHERE poblacion = 'Antequera';
UPDATE pisos
	SET poblacion = 'Real Ciudad de Antequera'
	WHERE poblacion = 'Antequera';
commit;

/*12. Fijar el numero el importe en reparaciones en base a su base y
a su porcentaje de IVA*/
UPDATE reparaciones
	SET importe = base + (base * iva_por / 100.00);
commit;

/*13. Insertar en reparadores un campo total facturado de tipo dinero.
Fijar dicho campo al valor real de lo que no ha facturado el reparador
en base a sus reparaciones. (se incluye el iva)*/
-- Agregar el campo
ALTER TABLE reparadores
ADD total_facturado d_dinero;

-- Actualizar el campo con el total facturado, incluyendo IVA
UPDATE reparadores r
	SET total_facturado = coalesce(
        (SELECT SUM(base+base*iva_por/100.00)
    		FROM reparaciones re
    		WHERE re.id_reparador = r.id_reparador
            group by id_reparador),0);
commit;

-- Cosas adicionales: Borrar la columna creada
alter table reparadores
	drop total_facturado;

/*14. El precio de cada habitación se iguala al precio del alquiler más alto
de dicha habitación o 200 si no se dispone de ningún alquiler.*/
UPDATE habitaciones h
	SET precio = COALESCE(
    	(SELECT MAX(a.precio)
     		FROM alquileres a
    		WHERE a.id_habitacion = h.id_habitacion), 200);
commit;

/*15. Añadir el campo total_reparaciones a propietarios. Fijar dicho campo a cero.
Calcularlo de nuevo en todos los registros en base a las reparaciones de sus pisos.*/
-- Agregar el campo
ALTER TABLE propietarios
ADD total_reparaciones d_dinero DEFAULT 0;

-- Fijar a 0
UPDATE propietarios
	set total_reparaciones = 0;

-- Calcular el total de reparaciones por propietario
UPDATE propietarios pr
	SET total_reparaciones = coalesce(
        (SELECT sum(re.base + re.base * re.iva_por / 100.00)
            FROM reparaciones re
                INNER JOIN pisos p using(id_piso)
            WHERE p.id_propietario = pr.id_propietario),0);
commit;

select * from propietarios;

/*DELETE*/

/*16. Borra propietario con id = 1 (se puede hacer)*/
DELETE FROM propietarios
	WHERE id_propietario = 1;
commit;

/*17. Borra propietario con id = 1 y todas sus relaciones. */
-- Borrar reparaciones asociadas a los pisos del propietario
DELETE FROM reparaciones
    WHERE id_piso IN
    	(SELECT id_piso
        	FROM pisos
        	WHERE id_propietario = 1);
commit;

-- Borrar alquileres asociados a las habitaciones de los pisos del propietario
DELETE FROM alquileres
	WHERE id_habitacion IN
    	(SELECT id_habitacion
        	FROM habitaciones
            	INNER JOIN pisos using(id_piso)
    		WHERE id_propietario = 1);

-- Borrar habitaciones asociadas a los pisos del propietario
DELETE FROM habitaciones
	WHERE id_piso IN
    	(SELECT id_piso
            FROM pisos
            WHERE id_propietario = 1);

-- Borrar pisos del propietario
DELETE FROM pisos
	WHERE id_propietario = 1;

-- Borrar al propietario
DELETE FROM propietarios
	WHERE id_propietario = 1;

/*18. Borra los inquilinos que no tienen alquileres (se puede hacer)*/
DELETE FROM inquilinos
    WHERE id_inquilino NOT IN
    	(SELECT DISTINCT id_inquilino
        	FROM alquileres);
commit;

/*19. Borra los alquileres que tienen más de 3 años. (se puede hacer)*/
DELETE FROM alquileres
	WHERE fecha_inicio < DATEADD(-3 YEAR TO CURRENT_DATE);
commit;

/*20. Borra los pìsos que no tienen dueño (se puede hacer)*/
DELETE FROM pisos
	WHERE id_propietario IS NULL;
commit;

/*21. Borra los pisos que no tienen dueño, eliminando todas sus relaciones.*/
-- Borrar reparaciones asociadas a los pisos sin dueño
DELETE FROM reparaciones
    WHERE id_piso IN
    	(SELECT id_piso
        	FROM pisos
        	WHERE id_propietario IS NULL);

-- Borrar alquileres asociados a las habitaciones de los pisos sin dueño
DELETE FROM alquileres
	WHERE id_habitacion IN
    	(SELECT id_habitacion
            FROM habitaciones
            	inner join pisos using(id_piso)
            WHERE id_propietario IS NULL);

-- Borrar habitaciones asociadas a los pisos sin dueño
DELETE FROM habitaciones
	WHERE id_piso IN
    	(SELECT id_piso
    		FROM pisos
    		WHERE id_propietario IS NULL);

-- Finalmente, borrar los pisos sin dueño
DELETE FROM pisos
	WHERE id_propietario IS NULL;

/*Ejercicios DML Varios:*/

/*22. Insertar un nuevo propietario que vive en el mismo sitio que el
propietario 1. Copiar los pisos de el propietario 1 a el nuevo propietario
que se llama 'Miguel Hernandez' con nif '12344456J' que actua como clave.*/
INSERT INTO propietarios (NIF, NOMBRE, DIRECCION, POBLACION)
	SELECT '12344456J', 'Miguel Hernandez', DIRECCION, POBLACION
    	from propietarios
        where id_propietario = 1;
INSERT INTO pisos (ID_PROPIETARIO, DIRECCION, POBLACION)
	SELECT (select id_propietario
    			from PROPIETARIOS
                where nif = '12344456J'),
           DIRECCION, POBLACION
    	from pisos
        where id_propietario = 1;
commit;

select * from propietarios;
select * from pisos;

/*23. Convertir el inquilino 3 en propietario y cambiar la propiedad de todos
los pisos que ha alquilado a él (NIF actua como clave).*/


/*24. Bajar los alquileres activos de pisos en Granada un 10%*/


/*25. Borrar los alquileres que no estén activos y la fecha de fin sea
anterior a la fecha actual.*/
DELETE from alquileres
	where not activos and fecha_fin < current_date;
commit;

/*26. Fijar en total_reparaciones de propietarios el valor de los importes
de todas sus reparaciones más 10€ de gastos de gestión por cada reparación.*/
update propietarios p
	set total_reparaciones = coalesce(
    	(select sum(importe) + (COUNT(*) * 10)
        	from reparaciones r
            	inner join pisos p2 using(id_piso)
            where p2.id_propietario = p.ID_PROPIETARIO), 0);
commit;

select * from propietarios;

/*27. Pasar la población de cada inquilino a la del último alquiler que tenga
por fecha de inicio. Si un inquilino no tiene alquileres se queda con la
población que tiene*/
UPDATE inquilinos i
	set poblacion =
    	(select first 1 p.POBLACION
        	from alquileres a
            	join habitaciones h using(id_habitacion)
                join pisos p using(id_piso)
            where a.id_inquilino = i.ID_INQUILINO
            order by a.FECHA_INICIO DESC)
	where ID_INQUILINO in (select id_inquilino from alquileres);
commit;



/*Ejemplo de cociente: Reparadores que han reparado todos los años que
hemos trabajado*/

select distinct extract(year from fecha) anno
	from reparaciones;














/**/