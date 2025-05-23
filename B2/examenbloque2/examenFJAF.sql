/*1º)  En determinados casos un Bonsai se puede partir en dos. Crear el procedimiento
almacenado ejecutable partirBonsai que permita partir un Bonsai en dos,
este procedimiento almacenado tiene cuatro parámetros el id_bonsai del bonsai a partir,
precio_final_original (precio con el que queda el bonsai original tras la partición),
precio_nuevo (precio del bonsai nuevo) y el id_maestro que realiza la inscripción
del nuevo Bonsai.

El nuevo bonsai tiene los mismos datos que el original excepto
el precio que se pasa como parámetro, la fecha de inscripción del bonsai nuevo
que es la fecha del sistema y el id_maestro que se pasa como parámetro
(claro esta que tiene un nuevo id_bonsai).

El bonsai original coge un nuevo precio que se pasa como parámetro, precio_final_original (1.25).

Además se insertarán al nuevo Bonsai los mismos tratamientos que el original
pero con su precio a 0, utilizando un cursor para recorrer los tratamientos (1 puntos).
Si se usa un cursor explicito (0.5).*/

set term ^;
create or alter procedure partirBonsai(
	id_bonsai d_id,
    precio_final_original D_DINERO,
    precio_nuevo d_dinero,
    id_maestro d_id
)
	returns (respuesta D_CADENA60)
as
	declare id_maestro_t d_id;
    declare fecha_t d_fecha;
    declare id_bonsai_nuevo D_ID;
begin

	if (:id_bonsai = any (select id_bonsai from BONSAIS) and
    	:id_maestro = any (select id_maestro from maestros))
    	then begin
    		
    		insert into bonsais(id_aficionado, id_maestro, especie,	descripcion,
            					fecha_plantacion, fecha_inscripcion, precio)
            	select id_aficionado, :id_maestro, especie, descripcion, fecha_plantacion, CURRENT_DATE, :precio_nuevo
                	from bonsais
                    where id_bonsai = :id_bonsai
				returning id_bonsai into :id_bonsai_nuevo;
                    
			update bonsais
            	set precio = :precio_final_original
                where id_bonsai = :id_bonsai;
				
                for select id_maestro, fecha
                		from tratamientos
                        where id_bonsai = :id_bonsai
                        into :id_maestro_t, :fecha_t
				do begin
                	
                	insert into tratamientos(id_bonsai, id_maestro, fecha, importe)
                    	values (:id_bonsai_nuevo, :id_maestro_t, :fecha_t, 0);
                	
                end
                
				respuesta = 'Se ha ejecutado correctamente';
    		
    	end else begin
        	respuesta = 'Datos no válidos';
        end

end^
set term ;^

select b.*, t.ID_TRATAMIENTO, t.FECHA, t.IMPORTE
	from BONSAIS b
    	join tratamientos t using(id_bonsai);

execute procedure partirBonsai(5, 5, 5, 1);


/*2º) Procedimiento almacenado seleccionable listarOpercionesMaestro(sin parámetros)
realizado con tres cursores, que muestre los siguientes datos de las operaciones
realizadas por cada maestro existente: (3 puntos)
 - id_maestro
 - nif (se extrae de aficionados)
 - nombre (se extrae de aficionados)
 - id_bonsai (con el que el maestro ha realizado una operación)
 - operación (que puede ser un tratamiento (en Tratamientos) o una inscripción(en bonsai)
 - fecha (es la fecha del tratamiento o la fecha de inscripción del Bonsai)*/
 
SET TERM ^;
CREATE OR ALTER PROCEDURE listarOpercionesMaestro
RETURNS (id_maestro d_id,
		 nif d_nif,
         nombre d_cadena40,
         id_bonsai d_id,
         operacion d_cadena20,
         fecha d_fecha)
AS
BEGIN
    FOR SELECT  m.id_maestro, a.nif, a.nombre, b.id_bonsai,
    			'inscripcion' as operacion, b.FECHA_INSCRIPCION
    		from maestros m
            	join aficionados a using(id_aficionado)
                join bonsais b using(id_maestro)
            into :id_maestro, :nif, :nombre, :id_bonsai,
    			:operacion, :fecha
    DO
    BEGIN
         suspend;
    END
    
    FOR SELECT  m.id_maestro, a.nif, a.nombre, t.id_bonsai,
    			'tratamiento' as operacion, t.fecha
    		from maestros m
            	join aficionados a using(id_aficionado)
                join tratamientos t using(id_maestro)
            into :id_maestro, :nif, :nombre, :id_bonsai,
    			:operacion, :fecha
    DO
    BEGIN
         suspend;
    END
    
    
END^
SET TERM ;^

SELECT * FROM listarOpercionesMaestro;

/*3º) Función llamada actividadMaestro a la que se le pasa el id_maestro y devuelve 0
si el maestro no existe. Si el maestro existe devuelve el numero total de
tratamientos que ha realizado en Bonsais más el numero de bonsais que ha inscrito. (0.75)*/

set term ^;
create or alter function actividadMaestro(id D_ID)
	returns d_entero
as
begin

	if (:id = any (select id_maestro from maestros)) then
    begin
    
    	return (select count(*)
        			from listarOpercionesMaestro
        			where id_maestro = :id);
    
    end else begin
    	return 0;
    end

END^
set term ;^

select actividadMaestro(200)
	from rdb$database;
    
/*4º) Se quiere gestionar mediante triggers el campo total_importe de aficionados
cuando se van insertando o actualizando sus cuotas, teniendo en cuenta:

a) Si fecha_cuota tiene un valor null en la inserción se le asigna la fecha del sistema. (0.5)
b) Fecha_pago tiene que ser nula o mayor o igual que fecha_cuota.(0.5)
c) No se puede modificar fecha_cuota.(0.5)
d) Sólo se puede modificar fecha_pago si se pasa del valor null a su valor definitivo (0.5)
e) Si se inserta una cuota y tiene el campo fecha_pago diferente de null se carga
	el importe de la cuota al aficionado correspondiente en el campo total_importe. (0.5)
f) Cuando se realiza una modificación de fecha_pago con un valor  null a la
	fecha de pago es cuando se pasa el importe al total_importe del aficionado correspondiente.(0.5)

(se valorará el uso con dos trigger para su correcta realización y el lanzamiento
de las correspondientes excepciones (0.5))*/

create EXCEPTION i_excepcionCuotas 'Error al insertar la cuota';
create EXCEPTION u_excepcionCuotas 'Error al actualizar la cuota';

set term ^; 
create or alter trigger biu_cuotas01
before insert or update
position 1
on cuotas
as
	
begin

	if (inserting) then
    begin
    
    	if (new.fecha_cuota is null) then
        	new.fecha_cuota = current_date;
            
        if (new.fecha_pago is not null) then
        	update aficionados
            	set total_importe = total_importe + new.importe;
    		
    end else begin
    
    	if (new.fecha_cuota is not NULL) then
        	EXCEPTION u_excepcionCuotas 'Error: No se puede modificar la fecha de cuota';
            
        if (old.fecha_pago is not NULL and new.fecha_pago is not NULL)
        	EXCEPTION u_excepcionCuotas 'Error: Ya se ha pagado esta cuota';
            
        if (old.fecha_pago is null and new.fecha_pago is not null)
        	set total_importe = total_importe + new.importe;
    
    end
    
    if (not (new.fecha_pago is null or new.fecha_pago >= new.fecha_cuota))
        EXCEPTION i_excepcionCuotas 'Error: La fecha de pago tiene que ser nula, o mayor o igual a la de cuotas';
    
END^
set term;^