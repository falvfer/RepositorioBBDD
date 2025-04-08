/* Procedimiento almacenado seleccionable que use un cursor forward only que liste los pisos
 ordenados por id, precedidos por un numero de orden. */


set term ^;
create or alter procedure listarPisoCFO()
	returns (orden d_entero, id_piso d_id, id_propietario d_id,
             direccion d_cadena80, poblacion d_cadena40 )
as
	declare variable cursorPisos cursor for  (select id_piso, id_propietario,
                                                      direccion, poblacion
                                                from pisos
                                                order by id_piso);
begin
    orden = 1;
    -- apertura
    open cursorPisos;
    -- lectura pre-adelantada
    FETCH cursorPisos into id_piso, id_propietario,direccion, poblacion;
    while (row_count = 1) do
    begin
    -- procesar registro
       suspend;
       
       
    -- preparar registro siguiente
       orden = orden + 1;
       FETCH cursorPisos into id_piso, id_propietario,direccion, poblacion;   
    end
    suspend;
    
    
    close cursorPisos;
END^
set term ;^


select * 
	from listarPisoCFO;
    
    /* Procedimiento almacenado seleccionable que utiliza un curso explicito y
    nos liste los alquileres de un piso que se pasa como parametro. Mostrando los 
    datos del alquiler más un campo donde se van acumulando los precios de los
    alquileres */
    
 
set term ^;
create or alter procedure listarAlquileres(id_piso d_id)
	returns (id_alquiler d_id, id_habitacion d_id, id_inquilino d_id,
             fecha_inicio d_fecha, fecha_fin d_fecha,
             precio d_dinero, activo d_bolean, acumulado d_dinero )
as
    
	declare variable cursorAlquileres cursor for 
     (select a.id_alquiler, a.id_habitacion , a.id_inquilino,
             a.fecha_inicio, a.fecha_fin,
             a.precio, a.activo
        from alquileres a
        	inner join habitaciones h using (id_habitacion)
        where h.id_piso = :id_piso);
begin
    acumulado = 0;
    -- apertura
    open cursorAlquileres;
    
    -- lectura pre-adelantada
    FETCH cursorAlquileres into id_alquiler, id_habitacion , id_inquilino,
             fecha_inicio, fecha_fin, precio, activo;
             
    while (row_count = 1) do
    begin
    -- procesar registro
       acumulado = acumulado + precio;
       suspend;
       
       
    -- preparar registro siguiente
       
       FETCH cursorAlquileres into id_alquiler, id_habitacion , id_inquilino,
             fecha_inicio, fecha_fin, precio, activo; 
    end
    suspend;
    
    -- cierre
    close cursorAlquileres;
END^
set term ;^

select * from listarAlquileres(1);


/* Listar los tres pasitos para adelante y un pasito para atras */

set term ^;
create or alter procedure listarPisoSPasodoble()
	returns (id_piso d_id, id_propietario d_id,
             direccion d_cadena80, poblacion d_cadena40 )
as
    declare VARIABLE pasitos d_entero;
	declare variable cursorPisos scroll cursor for  (select id_piso, id_propietario,
                                                      direccion, poblacion
                                                from pisos
                                                order by id_piso);
begin
    pasitos = 1;
    -- apertura
    open cursorPisos;
    -- lectura pre-adelantada
    FETCH next from cursorPisos into id_piso, id_propietario,direccion, poblacion;
    while (row_count = 1) do
    begin
    -- procesar registro
       
       suspend;
       
       
    -- preparar registro siguiente
       if (pasitos = 3) then
       begin
         pasitos = 1;
         FETCH prior from cursorPisos into id_piso, id_propietario,direccion, poblacion;
       END
       else
       begin
         pasitos = pasitos + 1;
         FETCH next from cursorPisos into id_piso, id_propietario,direccion, poblacion;
       end  
    end
  
    
    
    close cursorPisos;
END^
set term ;^

select id_piso, id_propietario,
                                                      direccion, poblacion
                                                from pisos
                                                order by id_piso


select * from listarPisosPasodoble;