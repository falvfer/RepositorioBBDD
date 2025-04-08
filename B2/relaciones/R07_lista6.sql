/* Procedimiento almacenado que se se pasan el id de dos inquilinos y usando 
un sólo cursor explicito liste los pisos del primer inquilino y los pisos del 
segundo inquilino. */

set term^;
create or alter procedure pisosDeDosInquilinos(id_inquilino1 d_id, id_inquilino2 d_id)
	returns(id_piso d_id, id_propietario d_id, direccion d_cadena80, poblacion d_cadena40,
     id_inquilino d_id)
as
	declare variable cursorPisos cursor for (select p.id_piso, p.id_propietario,
    												p.direccion, p.poblacion, a.id_inquilino
    											from pisos p
                                                	join habitaciones h using (id_piso)
                                                    join alquileres a using (id_habitacion)
                                                where a.id_inquilino = :id_inquilino1
                                                or a.id_inquilino = :id_inquilino2
                                                	order by a.id_inquilino);
begin

    open cursorPisos;

    	fetch cursorPisos into id_piso, id_propietario,
    						direccion, poblacion,id_inquilino;

        while(ROW_COUNT=1) do
        begin
        	suspend;
            fetch cursorPisos into id_piso, id_propietario,
    											direccion, poblacion, id_inquilino;
                                                
         end

    close cursorPisos;

END^
set term;^

select * from alquileres




select p.id_piso, p.id_propietario,
    												p.direccion, p.poblacion, a.id_inquilino
    											from pisos p
                                                	join habitaciones h using (id_piso)
                                                    join alquileres a using (id_habitacion)
                                                where a.id_inquilino = :id_inquilino1
                                                or a.id_inquilino = :id_inquilino2
                                                	order by a.id_inquilino
                                                    
                                                   
/* procedimiento almacenao que separa los inquilinos */

set term^;
create or alter procedure pisosDeDosInquilinos2(id_inquilino1 d_id, id_inquilino2 d_id)
	returns(id_piso d_id, id_propietario d_id, direccion d_cadena80, poblacion d_cadena40,
     id_inquilino d_id)
as
    declare variable valor d_id;
	declare variable cursorPisos cursor for (select p.id_piso, p.id_propietario,
    												p.direccion, p.poblacion, a.id_inquilino
    											from pisos p
                                                	join habitaciones h using (id_piso)
                                                    join alquileres a using (id_habitacion)
                                                where a.id_inquilino = :valor);
begin

    valor = id_inquilino1;
    open cursorPisos;

    	fetch cursorPisos into id_piso, id_propietario,
    						direccion, poblacion,id_inquilino;

        while(ROW_COUNT=1) do
        begin
        	suspend;
            fetch cursorPisos into id_piso, id_propietario,
    											direccion, poblacion, id_inquilino;
                                                
         end

    close cursorPisos;
    
    valor = id_inquilino2;
    open cursorPisos;

    	fetch cursorPisos into id_piso, id_propietario,
    						direccion, poblacion,id_inquilino;

        while(ROW_COUNT=1) do
        begin
        	suspend;
            fetch cursorPisos into id_piso, id_propietario,
    											direccion, poblacion, id_inquilino;
                                                
         end

    close cursorPisos;

END^
set term;^


select * from pisosdedosinquilinos2(3,1);


/*Procedimiento almacenado que liste  los alquileres mostrando uno sí y otro no. */
set term ^;
create or alter procedure listar_alquileres_alternados
returns (
    id_alquiler integer,
    id_inquilino integer,
    id_habitacion integer,
    fecha_inicio date,
    fecha_fin date,
    activo d_bolean,
    precio numeric(10, 2)
)
as
declare variable i integer;
begin
    i = 1;
    for select id_alquiler, id_inquilino, id_habitacion, fecha_inicio, fecha_fin, activo, precio
        from alquileres
        into :id_alquiler, :id_inquilino, :id_habitacion, :fecha_inicio, :fecha_fin, :activo, :precio 
        do
    begin
        if (mod(i, 2) = 1) then
        begin
            suspend;
        end
        i = i + 1;
    end
end^
set term ;^

select * from LISTAR_ALQUILERES_alternados;



set term ^;
create or alter procedure listar_alquileres_alternados2
returns (
    id_alquiler integer,
    id_inquilino integer,
    id_habitacion integer,
    fecha_inicio date,
    fecha_fin date,
    activo d_bolean,
    precio numeric(10, 2)
)
as
 DECLARE VARIABLE cursorAlquileres
     SCROLL CURSOR FOR (select id_alquiler, id_inquilino, id_habitacion,
                               fecha_inicio, fecha_fin, activo, precio
                        from alquileres);
begin
    open cursorAlquileres;
    -- cambiar este que da problemas
    /*    fetch relative 1 from cursorAlquileres into id_alquiler, id_inquilino, id_habitacion,
    
                           fecha_inicio, fecha_fin, activo, precio; */
    -- por absolute
    fetch absolute 2 from cursorAlquileres into id_alquiler, id_inquilino, id_habitacion,
    
                           fecha_inicio, fecha_fin, activo, precio; 
    while (row_count = 1) do
    begin
    	suspend;
        fetch  relative 2 from cursorAlquileres into id_alquiler, id_inquilino, id_habitacion,
                               fecha_inicio, fecha_fin, activo, precio;
    end
        close cursorAlquileres;
end^
set term ;^


select * from alquileres;

select * from LISTAR_ALQUILERES_alternados2;

/* Procedimiento almacenado que se le pasa cuatro posiciones 
y nos liste los datos de los propietarios ordenados por id que ocupen esas posiciones. */



set term ^;
create or alter procedure listar_propietarios_salteados (pos1 int, pos2 int, pos3 int, pos4 int)
returns (id_propietario d_id, nif d_nif, nombre d_cadena60, direccion d_cadena80, poblacion d_cadena40,
         total_reparaciones d_dinero)
    

as
 DECLARE VARIABLE cursorPropietarios
     SCROLL CURSOR FOR (select id_propietario, nif, nombre, 
                               direccion, poblacion, total_reparaciones
                        from propietarios
                        order by id_propietario);
begin
 open cursorPropietarios;
	fetch absolute pos1 from cursorPropietarios into id_propietario, nif, nombre, 
                               direccion, poblacion, total_reparaciones;
    if (row_count = 1) then
	    suspend;
        
    fetch absolute pos2 from cursorPropietarios into id_propietario, nif, nombre, 
                               direccion, poblacion, total_reparaciones;
    if (row_count = 1) then
	    suspend;
        
    fetch absolute pos3 from cursorPropietarios into id_propietario, nif, nombre, 
                               direccion, poblacion, total_reparaciones;
    if (row_count = 1) then
	    suspend;
        
    fetch absolute pos4 from cursorPropietarios into id_propietario, nif, nombre, 
                               direccion, poblacion, total_reparaciones;
    if (row_count = 1) then
	    suspend;
	close cursorPropietarios;
end^
set term ;^

select * from listar_propietarios_Salteados (2,4,5, 300);