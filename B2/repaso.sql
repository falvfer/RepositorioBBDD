--funciones

-- crear la función operar a la que se le pasa tres numeros enteros (oper, min y max)
-- y devuelve un numero entero
-- de forma que
-- si oper = 1 devuelve la suma de todos los numeros que van entre min y max
-- si oper = 2 suma los numeros pares y le resto la suma 
--             de los numeros impares entre el min y max. Devuelvo el resultado
-- En cualquier otro caso devuelvuelo el numero de numeros que hay entre max y min 


set term ^;
create or alter function funcionVicent(oper dentero,mini dentero, MAXi dentero)
    RETURNS dentero
as
declare variable cont dentero =0;
declare variable resultado dentero=0;
declare variable pares dentero=0;
declare variable impares dentero=0;
begin

    IF(oper=1)THEN
    begin
        cont=mini;
        WHILE(cont<=maxi)do
            begin
              resultado=resultado+cont;
              cont=cont+1;
            end
    return resultado;
    end 
    else IF(oper=2)THEN
    begin
        cont=mini;
        WHILE(cont<=maxi)do
        begin

              if(MOD(cont,2)=0)THEN
                pares=pares+cont;
              ELSE
                impares=impares+cont;
              CONT=CONT+1;
        end
            
        resultado=pares-impares;
        return resultado;
    end
    else if(oper=3)THEN
        begin
          resultado=maxi-MINi;
          return resultado;
        end
    else
      return 0;

END^
set term ;^


select funcionVicent(33, 4, 8) from  rdb$database;

-- crear la funcion maximo al que se se le pasa un id de habitacion y 
-- nos devuelve el id maximo del alquiler de esa habitacion


set term ^;
CREATE or alter FUNCTION maximo (id_habitacion d_id)
RETURNS d_id
AS
declare id_alquiler d_id;
BEGIN
  
    id_alquiler = (select MAX(id_alquiler) FROM alquileres WHERE id_habitacion = :id_habitacion); 
    
    if (id_alquiler is NULL) then
       id_alquiler = 0;

    RETURN id_alquiler;
END^
set term;^

select id_habitacion, max(id_alquiler) maximo
	from alquileres
    group by id_habitacion;
    

select maximo(1) from rdb$database;



-- crear la funcion mediaimporte al que se le pasa un id de habitacion y devuelve
-- el precio medio de los alquileres de esa habitacion. Debe hacerse recorriendo todos 
-- los alquileres de esa habitacion (no usar avg)

create exception noHayHabitacion 'Esa habitación no existe aún';

set term ^;
create or alter function media_importe(id_habitacion d_id)
returns d_dinero
as
declare variable total_importe d_dinero;
declare variable contador dentero;
declare variable importe_actual d_dinero;
begin
    total_importe = 0.0;
    contador = 0;

    if (not exists (select 1 from habitaciones where id_habitacion = :id_habitacion)) then
        exception noHayHabitacion;

    for select precio from alquileres where id_habitacion = :id_habitacion
        as cursor alquiler_cursor
    do
    begin
        importe_actual = alquiler_cursor.precio;
        if (importe_actual < 0) then 
          continue;
        else
            contador = contador + 1;
        total_importe = total_importe + importe_actual;
       
    end

    if (contador > 0) then 
        return total_importe / contador;
    else
        return null;
end^
set term ;^


select h.*, media_importe(id_habitacion)
	from habitaciones h;
    
-- crear la funcion mediaimportemayores al que se le pasa un id de piso y un importe
-- y devuelve el precio medio de los alquileres del piso que tienen un precio mayor al 
-- importe indicado. El precio se debe comprobar en el cuerpo del cursor

set term ^;
create or alter function mediaImportepiso(id_piso D_ID, importe d_dinero)
    RETURNS d_dinero
as
	declare variable resultado d_dinero;
    declare variable cont dentero;
    declare variable precio d_dinero;
begin
    resultado = 0;
    cont = 0;

    FOR select a.precio 
        from  ALQUILERES a
        	inner join habitaciones h using(id_habitacion)
            where h.id_piso = :id_piso 
        into :precio
    do
    begin
        if (precio > importe) then
        begin
            resultado = resultado + precio;
            cont = cont + 1;
        end
    end
    if (cont > 0) then
      return resultado / cont;
    else
      return 0;

end ^
set term ;^

select p.*, mediaImportePiso(id_piso, :IMP)
	from pisos p;

-- procedimientos almacenado seleccionable
-- crear el procedimiento almacenado datoscortosinquilinos que me devuelve
-- id_inquilino, nif y nombre de todos los inquilinos. Usar un cursor.

set term^;
create or alter procedure datoscortosinquilinos
returns (
	id_inquilino D_ID,
    nif D_NIF,
    nombre D_CADENA60
)
as
	declare cur cursor for (
    	SELECT id_inquilino, nif, nombre
        	FROM inquilinos
    );
begin
	OPEN cur;
    fetch cur into id_inquilino, nif, nombre;
    
    while (row_count = 1) do
      begin
          suspend;
          fetch cur into id_inquilino, nif, nombre;
      end
      
    CLOSE cur;
end^
set term;^

select * from datosCortosInquilinos;
-- crear el procedimiento almacenado datosgeneralesinquilinos al que se le pasa una poblacion
-- y que devuelve n_orden, id_inquilino, nombre, direccion,poblacion de los inquilinos 
-- de la poblacion indicada. n_orden es un autonumerico que deberemos indicar empezando por 1

set term^;
create or alter procedure datosgeneralesinquilinos(poblacion D_CADENA40)
	returns (n_orden dentero, id_inquilino d_id, nombre d_cadena60, 
    direccion d_cadena80, poblacionNueva d_cadena40)
as
	declare variable cursorInq cursor for (select id_inquilino, nombre, direccion, poblacion
    											from inquilinos
                                        		where poblacion=:poblacion);
begin

	n_orden=1;

    open cursorInq;

    	fetch cursorInq into :id_inquilino, :nombre, :direccion, :poblacionNueva;

        while(row_count=1) do
        begin

        	suspend;

            fetch cursorInq into :id_inquilino, :nombre, :direccion, :poblacionNueva;
            n_orden=n_orden+1;

        end

    close cursorInq;

END^
set term;^

select * from datosgeneralesinquilinos('Archidona');


-- crear el procedimiento almacenado datosinquilinoalquiler al que se le pasa dos numeros (id_ini 
-- e id_final) y que devuelve id_inquilino,nombre_inquilino,fecha_inicio_alquiler, precio_alquiler
-- de todos los alquileres de los inquilinos con id entre id_ini e id_final. Se deben usar dos 
-- cursores uno para los inquilinos y otro para los alquileres.

set term ^;
create or alter procedure datosInquilinoAlquiler (id_ini d_id, id_fin d_id)
 returns (id_inquilino d_id, nombre d_cadena60, id_alquiler d_id,
          fecha_inicio d_fecha, precio D_DINERO)
AS
begin
   for select id_inquilino, nombre
       from inquilinos
       where id_inquilino between :id_ini and :id_fin
       into id_inquilino, nombre
   do
   begin
   	 for select id_alquiler, fecha_inicio, precio
    	  from alquileres
          where id_inquilino = :id_inquilino
          into id_alquiler, fecha_inicio, precio
     do
     begin
         suspend;
     end
   end
END^
set term ;^

select * 
   from datosInquilinoAlquiler(1,8);
   
   -- mejora del anterior donde:
   --   se muestra el numero de alquiler dentro de cada inquilino 
   -- se saca un linea extra por cada inquilino tras sus alquileres donde precio
   -- muestre la suma de los precios de todos sus alquilere y en id_alquiler se muestra el numero de alquileres
   -- de ese inquilino
   
set term ^;
create or alter procedure datosInquilinoAlquiler2 (id_ini d_id, id_fin d_id)
 returns (id_inquilino d_id, 
          nombre d_cadena60,
          pos d_entero, 
          id_alquiler d_id,
          fecha_inicio d_fecha, 
          precio D_DINERO)
AS
  declare variable sumaPrecio d_dinero;
begin
   
   for select id_inquilino, nombre
       from inquilinos
       where id_inquilino between :id_ini and :id_fin
       into id_inquilino, nombre
   do
   begin
     pos = 0;
     sumaprecio = 0;
   	 for select id_alquiler, fecha_inicio, precio
    	  from alquileres
          where id_inquilino = :id_inquilino
          into id_alquiler, fecha_inicio, precio
     do
     begin
         pos = pos + 1;
         sumaPrecio = sumaPrecio + coalesce(precio,0);
         suspend;
     end
     id_alquiler = pos;
     pos=0;
     precio = sumaPrecio;
     suspend;
   end
   
END^
set term ;^
   
select * 
   from datosInquilinoAlquiler2(1,8);
   
--- trigger que impida modificar todos los datos de un alquiler excepto el campo activo

set term ^;
create or alter TRIGGER bu_alquileres
for ALQUILERES
 before UPDATE
 position 1
AS
begin
   if(  old.id_alquiler <> new.id_alquiler
        or old.precio<>new.precio 
   		or old.fecha_inicio<>new.fecha_inicio
        or old.fecha_fin<>new.fecha_fin
        or old.id_alquiler<>new.id_alquiler
        or old.id_habitacion<>new.id_habitacion
        or old.id_inquilino<>new.id_inquilino)then
   		EXCEPTION noMod;
END^
set term ;^



-- desactivamos trigger anterior y cada vez que opere con la tabla alquileres se guarde un registro 
-- en logAlq
alter trigger alquileres_bi inactive;

-- dominio tipo de operacion
create domain d_tipooperacion 
	 CHAR(1)
     check (value in ('I','U','D'))
     not null;

--creacion de otro dominio: d_telefono, con 9 cifras numéricas 
-- admite nulos

create domain d_telefono
           char(9)
           default '000000000'
           check (value similar to '[0-9]{9}');

-- dominio fecha_hora

create domain d_fechahora
           timestamp;

--sentencia de creacion de table

create table logAlq (
	id_logAlq d_id generated by default as IDENTITY,
    tipoOperacion d_tipooperacion not null, -- a declarar
    fechaHora d_fechaHora default CURRENT_TIMESTAMP not null , -- a declarar
    id_operacion D_ID not null
);

alter table logalq
    add constraint pk_logalq 
        primary key (id_logalq);


id_operacion guarda una secuencia autonumerica manual por cada una de las tres operaciones que hay
insert, delete, update

tipoOperacion sólo puede valer I, U y D.


--- procedimiento almacenado que inserte un piso con todos los campos de pisos.
--- si el id_piso es nulo se insertará como autonumerico y si no es nulo se inserta 
--- con su valor.

set term ^;

create or alter procedure insertPisoRepaso(id_piso D_ID, id_propietario D_ID,
                        direccion d_cadena80, poblacion d_cadena40)
as
begin
	if (id_piso is not NULL) then
         begin  -- se indica un id_piso
         	insert into pisos  (id_piso, id_propietario, direccion, poblacion)
                  values (:id_piso, :id_propietario, :direccion, :poblacion);
         
         end
        else
         begin  -- id_piso es nulo
         	insert into pisos  ( id_propietario, direccion, poblacion)
                  values ( :id_propietario, :direccion, :poblacion);
         
         end
         
         

end ^                    

set term ;^


select * from pisos;


execute procedure insertPisoRepaso(null, 2, 'carrera madre de dios', 'loja');
commit;

execute procedure insertPisoRepaso(9, 2, 'ejecucion correcta', 'loja');
commit;

execute procedure insertPisoRepaso(null, 20000, 'ejecucion correcta', 'loja');
commit;

--- lanzar las sentencias insert sin comprobaciones devolvera un codigo de error
--- posteriormente tratar las excepciones del sistema primary key duplicada (-1) 
--  y la que no exista el propietario(-2) y (0) si va bien

error primary key 335544665 unique_key_violation
error foreing key 335544466 foreign_key

set term ^;

create or alter procedure insertPisoRepaso(id_piso D_ID, id_propietario D_ID,
                        direccion d_cadena80, poblacion d_cadena40)
		returns (estado D_ENTERO)
as
begin
    estado=0;
    
	if (id_piso is not NULL) then
         begin  -- se indica un id_piso
         	insert into pisos  (id_piso, id_propietario, direccion, poblacion)
                  values (:id_piso, :id_propietario, :direccion, :poblacion);
         
         end
        else
         begin  -- id_piso es nulo
         	insert into pisos  ( id_propietario, direccion, poblacion)
                  values ( :id_propietario, :direccion, :poblacion);
         
         end
         
         
	when GDSCODE unique_key_violation do
        begin
           estado=-1;
           
        end
    when GDSCODE foreign_key do
        begin
           estado=-2;
        end    
        
end ^                    

set term ;^

execute procedure insertPisoRepaso(null, 2, 'ejecucion correcta', 'loja');


--- mejorar el ejercicio anterior haciendolo con la ejecución no de dos insert si no de un
-- único prepared statement

set term ^;

create or alter procedure insertPisoRepasoStatement(id_piso D_ID, id_propietario D_ID,
                        direccion d_cadena80, poblacion d_cadena40)
		returns (estado D_ENTERO)--, sentencia varchar(300))
as
declare variable sentencia varchar(300);
begin
    estado=0;
    
	if (id_piso is not NULL) then
         begin  -- se indica un id_piso
         	sentencia='insert into pisos  (id_piso, id_propietario, direccion, poblacion)'||
                      '  values ('
                      ||id_piso||
                      ', '||id_propietario||
                      ', '''||direccion||''' '||
                      ', '''||poblacion||''' '||
                      ')';
         
         end
        else
         begin  -- id_piso es nulo
         	sentencia='insert into pisos  (id_propietario, direccion, poblacion)'||
                      '  values ('
                      ||id_propietario||
                      ', '''||direccion||''' '||
                      ', '''||poblacion||''' '||
                      ')';
         end
         
   -- ejecuta la sentencia      
   execute statement sentencia;      
         
	when GDSCODE unique_key_violation do
        begin
           estado=-1;
           
        end
    when GDSCODE foreign_key do
        begin
           estado=-2;
        end    
        
end ^                    

set term ;^


execute procedure insertPisoRepasoStatement(null, 2, 'ejecucion correcta', 'loja');

select * from pisos;



--