/* procedimiento almacenado que inserta una habitacion.
si el piso no existe nos debe devolver una excepcion personalizada 
que diga 'el piso no existe'
suponemos que ocupado esta siempre a false.
se devuelve el id de la habitacion insertada*/

set term ^;

create or alter procedure insertar_habitacion(id_piso D_ID, descripcion d_cadena40,
          precio d_dinero)  
     returns (id d_id)
as
begin
	insert into habitaciones (id_piso, descripcion, precio, ocupada)
    		values (:id_piso, :descripcion, :precio, false)
           returning id_habitacion into id;


END^

set term ;^

execute procedure insertar_habitacion(2,'habitacion nueva',123);

select * from habitaciones;

-- insertar habitacion con error
execute procedure insertar_habitacion(20000,'habitacion nueva',123);

/* procedimiento almacenado con excepciones que inserte un piso, si
el propietario no existe lanzará una excepción propia */

create or alter exception noExistePropietario 'El id de propietario no se encuentra en la base de datos';

SET TERM ^ ;

CREATE PROCEDURE InsertarPiso2(
  ID_PROPIETARIO D_ID,
  direccion D_CADENA80,
  poblacion d_cadena40)
RETURNS( id_piso D_ID)
AS

begin
    -- Verificar que existe  el propietario
    if (not exists(select 1 from PROPIETARIOS where id_propietario = :id_propietario)) then
    begin
        exception noExistePropietario 'cambio mensaje';
    end

    

    insert into PISOS ( id_propietario, direccion, poblacion)
       values(:id_propietario, :direccion, :poblacion)
      RETURNING id_piso into :id_piso;

end^

SET TERM ; ^
-- correcto
execute procedure insertarPiso (3, 'Calle Antequera 22', 'Archidona');

--incorrecto
execute procedure insertarPiso2 (300, 'Calle Archidona 22', 'Antequera');


/* tratar la excepción en isertar piso 
Tratamos la Excepción Manual */

SET TERM ^ ;

CREATE PROCEDURE InsertarPisoTEM(
  ID_PROPIETARIO D_ID,
  direccion D_CADENA80,
  poblacion d_cadena40)
RETURNS( id_piso D_ID)
AS

begin
    -- Verificar que existe  el propietario
    if (not exists(select 1 from PROPIETARIOS where id_propietario = :id_propietario)) then
    begin
        exception noExistePropietario;
    end

    

    insert into PISOS ( id_propietario, direccion, poblacion)
       values(:id_propietario, :direccion, :poblacion)
      RETURNING id_piso into :id_piso;
      
    when exception noExistePropietario
    do
    begin
    	id_piso = 0;
    end

end^

SET TERM ; ^

--incorrecto
execute procedure insertarPisoTEM (300, 'Calle Archidona 22', 'Antequera');


/* tratar la excepción en insertar piso 
Tratamos Todas las Excepciones que se produzcan */

SET TERM ^ ;

CREATE PROCEDURE InsertarPisoTTE(
  ID_PROPIETARIO D_ID,
  direccion D_CADENA80,
  poblacion d_cadena40)
RETURNS( id_piso D_ID)
AS

begin
    -- Verificar que existe  el propietario
    if (not exists(select 1 from PROPIETARIOS where id_propietario = :id_propietario)) then
    begin
        exception noExistePropietario;
    end

    

    insert into PISOS ( id_propietario, direccion, poblacion)
       values(:id_propietario, :direccion, :poblacion)
      RETURNING id_piso into :id_piso;
      
    when Any
    do
    begin
    	id_piso = 0;
    end

end^

SET TERM ; ^

--incorrecto
execute procedure insertarPisoTTE (300, 'Calle Archidona 22', 'Antequera');

/* tratar la excepción en isertar piso 
Tratamos la Excepción Manual y todas las excepciones */

SET TERM ^ ;

CREATE PROCEDURE InsertarPisoTEMTE2(
  ID_PROPIETARIO D_ID,
  direccion D_CADENA80,
  poblacion d_cadena40)
RETURNS( id_piso D_ID)
AS

begin
    -- Verificar que existe  el propietario
    if (not exists(select 1 from PROPIETARIOS where id_propietario = :id_propietario)) then
    begin
        exception noExistePropietario;
    end

    

    insert into PISOS ( id_propietario, direccion, poblacion)
       values(:id_propietario, :direccion, :poblacion)
      RETURNING id_piso into :id_piso;
      
    when any
    do
    begin
    	id_piso = -2;
    end
    when exception noExistePropietario
    do
    begin
    	id_piso = -1;
    end
    
    

end^

SET TERM ; ^

--incorrecto
execute procedure insertarPisoTEMTE2 (300, 'Calle Archidona 22', 'Antequera');


/* tratar la excepción en isertar piso 
Tratamos la capturar la del 
Sistema GsCode  */

SET TERM ^ ;

CREATE PROCEDURE InsertarPisoSG2(
  ID_PROPIETARIO D_ID,
  direccion D_CADENA80,
  poblacion d_cadena40)
RETURNS( id_piso D_ID)
AS

begin
    -- Verificar que existe  el propietario
      
    insert into PISOS ( id_propietario, direccion, poblacion)
       values(:id_propietario, :direccion, :poblacion)
      RETURNING id_piso into :id_piso;
      
    when gdscode foreign_key
    DO
    begin
    	id_piso = -1;
    end

end^

SET TERM ; ^

--incorrecto
execute procedure insertarPisoSG2 (300, 'Calle Archidona 22', 'Antequera');

/* Insertar un propietario y dar un error si el id_propietaroio existe
con GDSCOE */

select * from  propietarios;

insert into propietarios
 values (1, '1111', 'Perico', 'Calle Percio', 'Archidona', 0);

set term ^;
create or alter procedure insertarPropietario (id_propietario d_id, nif d_nif,
                                               nombre d_cadena60, direccion d_cadena80,
                                               poblacion d_cadena40, total_reparaciones d_dinero)
  returns (id_propietariod d_id)
  as
  begin
  insert into propietarios
	 values (:id_propietario, :nif, :nombre, :direccion, :poblacion, :total_reparaciones);
     
  id_propietariod = id_propietario;
  
  when gdscode unique_key_violation
    DO
    begin
    	id_propietariod = -1;
    end
  
  END^
set term ;^

execute procedure insertarPropietario (100, '1111','Perico', 'C Perico', 'Archidona',0);

/* Insertar un propietario y dar un error si el id_propietaroio existe
con SQLCODE -803 */

set term ^;
create or alter procedure insertarPropietarioSQ (id_propietario d_id, nif d_nif,
                                               nombre d_cadena60, direccion d_cadena80,
                                               poblacion d_cadena40, total_reparaciones d_dinero)
  returns (id_propietariod d_id)
  as
  begin
  insert into propietarios
	 values (:id_propietario, :nif, :nombre, :direccion, :poblacion, :total_reparaciones);
     
  id_propietariod = id_propietario;
  
  when  sqlcode -803
    DO
    begin
    	id_propietariod = -1;
    end
  
  END^
set term ;^

execute procedure insertarPropietarioSQ (101, '1111','Perico', 'C Perico', 'Archidona',0);