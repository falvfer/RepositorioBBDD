/*1. Crear dos funciones booleanas que compruebe si existe una habitacion por
id y otra si existe un inquilino por id.*/
-- Funcion 1
set term ^;
create or alter function existeHabitacion(id D_ID)
	returns d_bolean
as
begin

	return exists
    	(select *
    		from habitaciones
            where :id = id_habitacion);

END^
set term ;^

select  existeHabitacion(3),
		existeHabitacion(300)
	from rdb$database;

-- Funcion 2
set term ^;
create or alter function existeInquilino(id D_ID)
	returns d_bolean
as
begin

	return exists
    	(select *
    		from inquilinos
            where :id = id_inquilino);

END^
set term ;^

select  existeInquilino(3),
		existeInquilino(300)
	from rdb$database;

/*2. Crear un procedimiento almacenado que se le pasan como parámetros todos
los campos de alquileres menos el id_alquiler. El procedimiento inserta un
alquiler si existe el inquilino y la habitación en base a los parámetros aportados
y devuelve la siguiente cadena:
 • ‘no existe la habitación’: si la habitación no existe
 • ‘no existe el inquilino’: si el inquilino no existe
 • ‘no existe ni la habitación ni el inquilino’: si la habitación no existe ni el inquilino tampoco
 • ‘registro insertado correctamente’*/
set term ^;
create or alter procedure insertarAlquiler(
			 id_habitacion d_id, id_inquilino D_ID, fecha_inicio d_fecha,
             fecha_fin d_fecha, precio d_dinero, activo d_bolean)
	returns (resultado D_CADENA60)
as
	
begin

	if (existeHabitacion(id_habitacion) and existeInquilino(id_inquilino)) then begin
        insert into alquileres (id_habitacion, id_inquilino, fecha_inicio, fecha_fin, precio, activo)
            values (:id_habitacion, :id_inquilino, :fecha_inicio, :fecha_fin, :precio, :activo);
            resultado = 'Se ha insertado el registro';
    end else if (not existeHabitacion(id_habitacion) and not existeInquilino(id_inquilino)) then begin
        resultado = 'No existe habitacion y no existe inquilino';
    end else if (not existeHabitacion(id_habitacion)) then begin
        resultado = 'No existe habitacion';
    end else
    	resultado = 'No existe inquilino';

END^
set term ;^

execute procedure insertarAlquiler(2, 4, '2025-01-10', '2025-05-23', 500, true);
execute procedure insertarAlquiler(100, 4, '2025-01-10', '2025-05-23', 500, true);
execute procedure insertarAlquiler(2, 100, '2025-01-10', '2025-05-23', 500, true);
-- drop procedure insertarAlquiler;

/*3. Crear un procedimiento almacenado que se le pasa el id_alquiler de un
alquiler y suba el precio de este en el tanto por ciento que se pasa como
segundo parámetro. Devuelve el número de registros modificados, 0 o 1.*/
set term ^;
create or alter procedure cambiarPrecioAlquiler(id_alquiler D_ID, porcentaje d_porcentaje)
	returns (resultado dentero)
as
	
begin

	update alquileres set precio = precio + precio * :porcentaje / 100
    	where id_alquiler = :id_alquiler;
	resultado = row_count; -- Devuelve el numero de registros que
    					   -- ha afectado la ultima sentencia
END^
set term ;^

execute procedure cambiarPrecioAlquiler(246, 2);
commit;

/*4. Procedimiento almacenado al que se le pasa el id de un reparador y
borre este sin que se produzcan errores, eliminándolo completamente de la
base de datos con todos sus datos relacionados.*/
set term ^;
create or alter procedure borrarReparador(id_reparador D_ID)
	returns (resultado dentero)
as
	
begin

	delete from reparaciones
    	where id_reparador = :id_reparador;
        
	resultado = row_count;

	delete from reparadores
    	where id_reparador = :id_reparador;

END^
set term ;^

execute procedure borrarReparador(1);
execute procedure borrarReparador(1);