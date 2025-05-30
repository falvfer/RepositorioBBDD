/* EJERCICIO 1 */
set term^;

create or alter procedure partirBonsai(
	id_bonsai D_ID,
    precio_final_original D_DINERO,
    precio_nuevo D_DINERO,
    id_maestro D_ID
)
returns (
	resultado D_CADENA80
)
as
	declare id_aficionado D_ID;
	declare especie D_CADENA40;
    declare descripcion D_CADENA40;
    declare fecha_plantacion D_FECHA;
    declare new_id_bonsai D_ID;
    declare fecha_tratamiento D_FECHA;
begin
	SELECT 
    	id_aficionado, especie, descripcion, fecha_plantacion
        FROM bonsais WHERE id_bonsai = :id_bonsai
        INTO id_aficionado, especie, descripcion, fecha_plantacion;
        
    if (id_aficionado is null) then
    	BEGIN
    		resultado = 'El bonsai no existe';
        	suspend;
        END
        
    UPDATE bonsais
    	SET precio = :precio_final_original
        WHERE id_bonsai = :id_bonsai;
        
    INSERT INTO bonsais
    	(
        	id_aficionado,
            id_maestro,
            especie, 
            descripcion,
            fecha_plantacion,
            fecha_inscripcion,
            precio
        ) VALUES (
        	:id_aficionado,
            :id_maestro,
            :especie,
            :descripcion,
            :fecha_plantacion,
            current_date,
            :precio_nuevo
        )
        RETURNING id_bonsai INTO :new_id_bonsai;
        
    FOR SELECT
          fecha
        FROM tratamientos WHERE id_bonsai = :id_bonsai
        INTO :fecha_tratamiento
    DO
    	BEGIN
        	INSERT INTO tratamientos
            	(id_bonsai, id_maestro, fecha, importe)
                VALUES
                (:new_id_bonsai, :id_maestro, :fecha_tratamiento, 0);
    	END
        
    resultado = 'Bonsai partido correctamente';
end^

set term;^

execute procedure partirBonsai(20, 100, 50, 4);
commit;

/* EJERCICIO 2 */
set term^;

create or alter procedure listarOperacionesMaestro
returns (
	id_maestro D_ID,
    nif D_NIF,
    nombre D_CADENA40,
    id_bonsai D_ID,
    operacion D_CADENA40,
    fecha D_FECHA
)
as
    declare cur_maestros cursor for (
    	SELECT id_maestro, nif, nombre
        	FROM maestros
            JOIN aficionados USING (id_aficionado)
    );
    
    declare cur_tratamientos cursor for (
    	SELECT id_bonsai, fecha
        	FROM tratamientos
            WHERE id_maestro = :id_maestro
    );
    
    declare cur_inscripciones cursor for (
    	SELECT id_bonsai, fecha_inscripcion
        	FROM bonsais
            WHERE id_maestro = :id_maestro
    );
begin
	OPEN cur_maestros;
    fetch cur_maestros into id_maestro, nif, nombre;
    
    while (row_count = 1) do
    	begin
        	OPEN cur_tratamientos;
            fetch cur_tratamientos into id_bonsai, fecha;
            
            while (row_count = 1) do
            	begin
                	operacion = 'Tratamiento';
                	suspend;
                    fetch cur_tratamientos into id_bonsai, fecha;
                end
                
            CLOSE cur_tratamientos;
            
            OPEN cur_inscripciones;
            fetch cur_inscripciones into id_bonsai, fecha;
            
         
            while (row_count = 1) do
            	begin
                	operacion = 'Inscripcion';
                	suspend;
                    fetch cur_inscripciones into id_bonsai, fecha;
                end
                
            CLOSE cur_inscripciones;
            
            fetch cur_maestros into id_maestro, nif, nombre;
        end
        
    CLOSE cur_maestros;
end^

set term;^

select * from listarOperacionesMaestro;

/* EJERCICIO 3 */
set term^;

create or alter function actividadMaestro(id_maestro D_ID)
returns D_ENTERO
as
	declare existe boolean;
    declare tratamientos D_ENTERO;
    declare bonsais D_ENTERO;
begin
	existe = false;
    
    existe = EXISTS (SELECT 1 FROM maestros WHERE id_maestro = :id_maestro);
    
    if (not existe) then
    	return 0;
        
    tratamientos = (
    	SELECT COUNT(*) FROM tratamientos WHERE id_maestro = :id_maestro
    );
    
    bonsais = (
    	SELECT COUNT(*) FROM bonsais WHERE id_maestro = :id_maestro
    );
    
    return tratamientos + bonsais;
end^

set term;^

select actividadMaestro(20) from rdb$database;

/* EJERCICIO 4 */
CREATE OR ALTER EXCEPTION FECHA_INCORRECTA
	'La fecha_pago debe ser nula o mayor o igual que fecha_cuota';
    
CREATE OR ALTER EXCEPTION NO_MODIFICAR_FECHA_CUOTA
	'No se puede modificar fecha_cuota';
    
CREATE OR ALTER EXCEPTION NO_MODIFICAR_FECHA_PAGO
	'No se puede modificar fecha_pago';

set term^;

create or alter trigger importesAficionados
before insert or update
position 0
ON cuotas
as
	declare nuevo_importe D_DINERO;
begin
	if (INSERTING and new.fecha_cuota is null) then
    	new.fecha_cuota = current_date;
        
    if (new.fecha_pago is not null and new.fecha_pago < new.fecha_cuota) then
    	EXCEPTION FECHA_INCORRECTA;
        
    if (UPDATING and old.fecha_cuota <> new.fecha_cuota) then
    	EXCEPTION NO_MODIFICAR_FECHA_CUOTA;
        
    if (UPDATING and old.fecha_pago is not null and new.fecha_pago <> old.fecha_pago) then
        EXCEPTION NO_MODIFICAR_FECHA_PAGO;
        
    if (INSERTING and new.fecha_pago is not null) then
    	begin
        	UPDATE aficionados
            	SET total_importe = total_importe + new.importe
            	WHERE id_aficionado = new.id_aficionado;
        end
        
    if (UPDATING and new.fecha_pago is not null and old.fecha_pago is null) then
    	begin
            UPDATE aficionados
            	SET total_importe = total_importe + new.importe
            	WHERE id_aficionado = new.id_aficionado;
        end
end^

set term;^