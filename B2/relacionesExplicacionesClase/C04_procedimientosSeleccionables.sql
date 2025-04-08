/*Mostrar por la decada de 2020 al 2030 los alquileres por año*/
set term^;
create or alter procedure contarPisosPropietarios
	returns (anio dentero, total_alquileres dentero)
AS

BEGIN
	anio = 2020;
    while (anio < 2030) DO
    BEGIN
    	-- código
        total_alquileres = (select COUNT(*)
        						from alquileres
                                where extract(year from fecha_inicio) = :anio);
	
        suspend;

        -- incremento del contador
        anio = anio + 1;
	end
END^

set term;^

/*Procedimiento almacenado seleccionable que me liste los datos de los clientes
ordenados por nombre con un autonumerico a la izquierda*/
set term^;
create or alter procedure contarPisosPropietarios
	returns (anio dentero, total_alquileres dentero)
AS

BEGIN
	anio = 2020;
    while (anio < 2030) DO
    BEGIN
    	-- código
        total_alquileres = (select COUNT(*)
        						from alquileres
                                where extract(year from fecha_inicio) = :anio);
	
        suspend;

        -- incremento del contador
        anio = anio + 1;
	end
END^

set term;^

/*Mostrar id_inquilino, nif del inquilino, id_alquiler, id_habitacion, fecha_inicio
del alquiler para todos los inquilinos y alquileres de los mismos. Si un inquilino
no tiene alquiler poner valores por defecto a los datos de alquiler. Usar para ello
dos cursores implicitos, uno para los inquilinos y otro para los alquileres.*/
set term ^;
create or alter procedure listar_alquileres
    returns (id_inquilino d_id, nif d_nif, id_alquiler d_id, id_habitacion d_id,
    fecha_inicio d_fecha)
as
	declare variable tiene d_bolean;
begin

	for select id_inquilino, nif
    	from inquilinos
        order by id_inquilino
        into id_inquilino, nif
    do begin
        tiene = false;
        	
        for select id_alquiler, id_habitacion, fecha_inicio
            from alquileres
            where id_inquilino = :id_inquilino
            order by id_alquiler
            into id_alquiler, id_habitacion, fecha_inicio
        do begin
            tiene = true;
            suspend;
        end
          
        if (not tiene)
        THEN begin
            id_alquiler = 0;
            id_habitacion = 0;
            fecha_inicio = '2020-01-01';
            suspend;
        end
    end
      
end^
set term ;^

select * from listar_alquileres;