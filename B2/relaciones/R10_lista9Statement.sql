/*1. Realizar el ejerecicio 3 de la lista anterior utilizando dos cursores.*/
set term^;
create or alter procedure parejasInqProp3()
	returns(inqPorProp dentero, 
            nombreP d_cadena60, 
            nifP d_nif, 
            nombreI d_cadena60, 
            nifI d_nif, 
            numAlq dentero)
as
    declare id_inquilino d_id;
    declare id_propietario d_id;
	declare cursorProp cursor for (select id_propietario,nombre, nif
    									from propietarios
                                        order by id_propietario);
    declare cursorInq cursor for (select i.id_inquilino, i.nombre, i.nif
    									from inquilinos i
                                        order by id_inquilino);
    
begin
	    
   	    open cursorProp;
    
    	fetch cursorProp into id_propietario, nombreP, nifP;
        
        while(row_count=1) do
        begin
        		inqPorProp=0;
				open cursorInq; 
                fetch cursorInq into id_inquilino, nombreI, nifI;     
               	WHILE(row_count=1)do
                begin
            		
    				inqPorProp=inqPorProp+1;
                    numalq = (select count(*)
                                from alquileres a 
                                  inner join habitaciones h using (id_habitacion)
                                  inner join pisos p using (id_piso)
                                  where p.id_propietario = :id_propietario and 
                                        a.id_inquilino = :id_inquilino);
        			suspend;
                    fetch cursorInq into id_inquilino, nombreI, nifI;
        
            	end
            	close cursorInq;
         
        
            	fetch cursorProp into id_propietario, nombreP, nifP;
        end
        
	close cursorProp;

END^
set term;^    


select *
	from parejasInqProp3;        


/* con cursores implicitos */

set term^;
create or alter procedure parejasInqProp4()
	returns(inqPorProp dentero, 
            nombreP d_cadena60, 
            nifP d_nif, 
            nombreI d_cadena60, 
            nifI d_nif, 
            numAlq dentero)
as
    declare id_inquilino d_id;
    declare id_propietario d_id;
    declare total_alquileres d_entero;
	/*declare cursorProp cursor for (select id_propietario,nombre, nif
    									from propietarios
                                        order by id_propietario);
    declare cursorInq cursor for (select i.id_inquilino, i.nombre, i.nif
    									from inquilinos i
                                        order by id_inquilino);
    */
begin

		for select id_propietario, nombre, nif
                from propietarios
                order by id_propietario
                into id_propietario, nombreP, nifP
   	    do
        begin
        		inqPorProp=0;
                total_alquileres = 0;
				for select i.id_inquilino, i.nombre, i.nif
                        from inquilinos i
                        order by id_inquilino
                        into id_inquilino, nombreI, nifI
                do
                begin
    				inqPorProp=inqPorProp+1;
                    numalq = (select count(*)
                                from alquileres a 
                                  inner join habitaciones h using (id_habitacion)
                                  inner join pisos p using (id_piso)
                                  where p.id_propietario = :id_propietario and 
                                        a.id_inquilino = :id_inquilino);
					total_alquileres = total_alquileres + numalq;
        			suspend;
        
            	end
                
                -- Vamos a sacar una estadistica o linea por propietario
                nifi = '--------';
                nombrei = 'Total Alquileres:';
                numalq = total_alquileres;
                suspend;
        end

END^
set term;^    

select * from parejasInqProp4;

/*2. Procedimiento almacenado seleccionable que usando dos cursores explícitos
nos muestre id, nif, nombre, direccion, población y tipo(tipo de registros) de
los inquilinos y reparadores. Se ordenadarán ambos cursores por nif y se hara
una fusión o mezcla de ambos manteniendo el orden por NIF.*/
SET TERM ^;
CREATE PROCEDURE fusion_inquilinos_reparadores
RETURNS (
    id d_id,
    nif d_nif,
    nombre d_cadena60,
    direccion d_cadena80,
    poblacion d_cadena40,
    tipo d_cadena20
)
AS
    DECLARE c_inq CURSOR FOR (
    	SELECT id_inquilino id, nif, nombre, direccion, poblacion, 'Inquilino' tipo
        	FROM Inquilinos
            ORDER BY nif
    );
    DECLARE c_rep CURSOR FOR(
    	SELECT id_reparador id, nif, nombre, direccion, poblacion, 'Reparador' tipo
        	FROM Reparadores
            ORDER BY nif
    );
    DECLARE VARIABLE id_aux d_id;
    DECLARE VARIABLE nif_aux d_nif;
    DECLARE VARIABLE nombre_aux d_cadena60;
    DECLARE VARIABLE direccion_aux d_cadena80;
    DECLARE VARIABLE poblacion_aux d_cadena40;
    DECLARE VARIABLE tipo_aux d_cadena20;
    declare variable hay_inquilino D_BOLEAN;
    declare variable hay_propietario D_BOLEAN;
BEGIN
    OPEN c_inq;
    OPEN c_rep;
    FETCH c_inq INTO :id_aux, :nif_aux, :nombre_aux, :direccion_aux, :poblacion_aux, :tipo_aux;
    FETCH c_rep INTO :id_aux, :nif_aux, :nombre_aux, :direccion_aux, :poblacion_aux, :tipo_aux;
    WHILE (NOT EOF(c_inq) OR NOT EOF(c_rep)) DO
    BEGIN
        SUSPEND;
        IF (NOT EOF(c_inq)) THEN FETCH c_inq INTO :id_aux, :nif_aux, :nombre_aux, :direccion_aux, :poblacion_aux, :tipo_aux;
        IF (NOT EOF(c_rep)) THEN FETCH c_rep INTO :id_aux, :nif_aux, :nombre_aux, :direccion_aux, :poblacion_aux, :tipo_aux;
    END
    CLOSE c_inq;
    CLOSE c_rep;
END^
SET TERM ;^

/*3. En esta tabla se guarda el nombre de una tabla y el nombre de un campo, 
y esta relleno previamente con combinaciones posibles. Construir un procedimiento
almacenado seleccionable ejecutarTarea al que se le pasa el id_tarea y devuelve
los registros del select: 'select campo from tabla order by campo' en una cadena
varchar(300).

Se lanzarán excepciones:
 - si no existe la tarea
 - si no existe la tabla
 - si no existe el campo dentro de la tabla.*/

create table tareas (
	id_tarea d_id generated by default as identity,
	tabla d_cadena40 not null,
    campo d_cadena40 not null
);

alter table tareas
	add constraint pk_tareas primary key (id_tarea);

insert into tareas (tabla, campo)
	values ('propietarios', 'nif');
insert into tareas (tabla, campo)
	values ('habitaciones', 'precio');
insert into tareas (tabla, campo)
	values ('propietarios', 'provincia');
insert into tareas (tabla, campo)
	values ('viajeros', 'provincia');
commit;

select * from tareas;

-- no campo -> SQL: -206
-- no tabla -> SQL: -204

create exception no_existe_tarea 'No existe tarea';  
create exception no_existe_campo 'No existe campo';
create exception no_existe_tabla 'No existe tabla';

set term^;
create or alter procedure ejecutarTarea(id_tarea d_id)
returns (
	result VARCHAR(300)
)
as
	declare variable existe_tabla boolean;
    declare variable existe_campo boolean;
    declare variable sentencia varchar(200);
    declare variable tabla varchar(40);
    declare variable campo varchar(40);
begin
	select tabla, campo from tareas
    	where id_tarea = :id_tarea
        into tabla, campo;
        
    if (tabla is null) then
    	EXCEPTION NO_EXISTE_TAREA;
        
    existe_tabla = exists (
    					select 1 from rdb$relations
                        	where rdb$relation_name = upper(:tabla)
    );
    
    if (not existe_tabla) then
    	EXCEPTION NO_EXISTE_TABLA 'no existe la tabla: ' || tabla;
        
    existe_campo = exists (
    					select 1 from rdb$relation_fields
                        	where RDB$RELATION_NAME = upper(:tabla)
                            AND RDB$FIELD_NAME = upper(:campo)
	);
    
    if (not existe_campo) then
    	EXCEPTION NO_EXISTE_CAMPO 'No existe el campo: ' || 'campo';
        
        
  sentencia = 'select ' || 'cast('  || campo || ' as varchar(300))' 
              || ' from ' || tabla ||  
              ' order by ' || campo;
              
  for execute statement sentencia into :result 
  do
  begin
    suspend;
  end  				
end^
set term;^


