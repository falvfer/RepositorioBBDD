/*Crear un procedimiento almacenado que se le pasan como parámetros todos
los campos de alquileres menos el id_alquiler. El procedimiento inserta un
alquiler si existe el inquilino y la habitación en base a los parámetros aportados
y devuelve el id_alquiler*/
set term ^;
create or alter procedure insertarAlquiler2(
			 id_habitacion d_id, id_inquilino D_ID, fecha_inicio d_fecha,
             fecha_fin d_fecha, precio d_dinero, activo d_bolean)
	returns (resultado dentero)
as
	
begin

	if (existeHabitacion(id_habitacion) and existeInquilino(id_inquilino)) then begin
        insert into alquileres (id_habitacion, id_inquilino, fecha_inicio, fecha_fin, precio, activo)
            values (:id_habitacion, :id_inquilino, :fecha_inicio, :fecha_fin, :precio, :activo)
            returning id_alquiler into resultado;
    end else begin
    	resultado = 0;
    end

END^
set term ;^

execute procedure insertarAlquiler2(2, 5, '2024-12-10', '2025-02-23', 200, true);

/*Funcion a la que se le pasa un id de propietario y devuelve una cadena compuesta
por la direccion y población, separados por un guión*/

set term ^;
create or alter function direccionPoblacion(id d_id)
	returns varchar(103)
as
	
begin
	
	if (exists (select * from propietarios where :id = id_propietario)) then begin
    	
    END else BEGIN
    	return 'no existe';
    end

end^
set term ;^

/*PA. que me devuelva el numero de alquileres, el total de importes y la media
del importe del alquiler sin usar funciones de agregación (se usará for select).*/

set term ^;
create or alter procedure totalesAlquileres()
	returns (numero_alquileres dentero, importe_total D_DINERO, importe_medio D_DINERO)
as
	declare importe d_dinero;
begin

	numero_alquileres = 0;
    importe_total=0;
    importe_medio=0;

	for select precio
    		from ALQUILERES
        	into importe
        do begin
        	numero_alquileres = numero_alquileres + 1;
            importe_total = importe_total + coalesce(importe, 0);
        end

	if (numero_alquileres > 0) then
    	importe_medio = importe_total / numero_alquileres;

end^
set term ;^

execute procedure totalesAlquileres;