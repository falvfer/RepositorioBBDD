/* Crear un procedimiento almacenado que inserte un alquiler y devuelva el id_alquiler.
 Y lance excepciones si no existe la habitación, el inquilino o el precio es superior a 500€. 
 Tratar dichas excepciones y que devuelva -1, -2, -3 respectivamente. */
 
 
create exception no_existe_habitacion 'La habitacion no existe';
create exception no_existe_inquilino 'El inquilino no existe';
create exception precio_excesivo 'El precio es superior a 500€';

set term^;
create or alter procedure insertarAlquiler
	( id_habitacion d_id, id_inquilino d_id, 
    fecha_inicio d_fecha, fecha_fin d_fecha,
    precio d_dinero, activo d_bolean
    )
	returns (id_alquiler d_id)
as
	begin
    	-- verificar si la habitación existe
    	if (not exists(select 1
        				from habitaciones
                        where id_habitacion = :id_habitacion)) then
            exception no_existe_habitacion;
            
    	-- verificar si el inquilino existe
    	if (not exists(select 1
            				from inquilinos
                        where id_inquilino = :id_inquilino)) then
            exception no_existe_inquilino;
    
    	-- verificar si el precio es mayor a 500€
        if (precio > 500) then
        	exception precio_excesivo;
    
    	insert into alquileres(id_habitacion, id_inquilino, 
    	                     fecha_inicio, fecha_fin, activo, precio)
        	   values(:id_habitacion, :id_inquilino, 
    	                     :fecha_inicio, :fecha_fin, :activo, :precio)
            returning id_alquiler into :id_alquiler;
        
        when exception no_existe_habitacion do
        begin
            	id_alquiler = -1;
        end
        when exception no_existe_inquilino do
        begin
            	id_alquiler = -2;
        end
        when exception precio_excesivo do
        begin
            	id_alquiler = -3;
        end
     END^
            	
set term ;^

--correcto
execute procedure insertarAlquiler(1, 1, current_date, current_date + 365, 200, true);
commit;

--fallo en habitacion
execute procedure insertarAlquiler(100, 1, current_date, current_date + 365, 200, true);

--fallo en inquilino
execute procedure insertarAlquiler(1, 1, current_date, current_date + 365, 600, true);

/* Procedimiento almacenado modifique el id_alquiler a un id_alquiler nuevo y 
devuelva un el mensaje correcto si ha hecho la operación e 
incorecto si se ha producido un error. 
Hacerlo tratando las excepciones del sistema. */



set term ^;
create or alter procedure modificar_alquier(id_alquiler d_id, 
											id_alquiler_nuevo d_id)
	returns (mensaje d_cadena60)
as
	begin
    	
		mensaje = 'Operación correcta';    
    	update alquileres
        set id_alquiler = :id_alquiler_nuevo
        where id_alquiler = :id_alquiler;
        
        
        when gdscode unique_key_violation do
        begin
    		mensaje = 'Error: el id_alquiler nuevo esta duplicado. GDS';
        end		
        when sqlcode -603 do
        begin
    		mensaje = 'Error: el id_alquiler nuevo esta duplicado. sql';
        end

    end^
set term ;^

select * 
	from alquileres;
    
    update alquileres
        set id_alquiler = :id_alquiler_nuevo
        where id_alquiler = :id_alquiler;
    commit;
    
   
execute procedure modificar_Alquier(80, 2);

/* Procedimiento almacenado que intente borrar un piso y devuelva correcto
 si se ha borrado e incorrecto ni no ha podido borrarlo o no existe el piso. 
 Capturar las excepciones del sistema y mostrarlas por pantalla. */
 
 set term ^;
create or alter procedure borrarPiso(id_piso d_id)
	returns (mensaje d_cadena60)
as
	begin
    	
		delete from pisos 
        	where id_piso = :id_piso;
            
        if (row_count = 1) then
           mensaje = 'Se ha borrado el piso';
        else  if (row_count = 0) then
    	   mensaje = 'No existe dicho picho';
        else 
        	mensaje = 'Se han borrado ' || row_count || ' registro imposible';
            
            
        when gdscode foreign_key do
        begin
    		mensaje = 'Error existen reparaciones o habitaciones GDS';
        end		
        when sqlcode -530 do
        begin
    		mensaje = 'Error: existen reparaciones o habitaciones. sql';
        end

    end^
set term ;^

delete from pisos 
        	where id_piso = :id_piso;
            
            
-- un piso que no existe
execute procedure borrarPiso(300);

-- un piso correcto
insert into pisos (id_propietario, direccion, poblacion)
   values (1, 'dd', 'dd');
commit;

select *
	from pisos;
    
execute procedure borrarPiso(54);