/*1. Procedimiento almacenado que se le pasan dos id_propietarios.
Comprueba que el propietario existe, si no existe lanza excepción.
Si el propietario existe, procede a cambiar el propietario por uno nuevo
	exacto al anterior con un nuevo id autonumérico.
(Ayuda cuidado con los pisos del cliente original ).*/
CREATE EXCEPTION PROPIETARIO_NO_EXISTE 'El propietario original no existe';
SET TERM ^;

CREATE OR ALTER PROCEDURE cambiar_propietario (
    old_propietario_id d_id,
    new_propietario_id d_id)
AS
DECLARE VARIABLE v_nif D_NIF;
DECLARE VARIABLE v_nombre VARCHAR(100);
DECLARE VARIABLE v_direccion VARCHAR(200);
DECLARE VARIABLE v_poblacion VARCHAR(100);
BEGIN
  
    IF (NOT EXISTS (SELECT 1 FROM Propietarios WHERE id_propietario = :old_propietario_id)) THEN
    BEGIN
        EXCEPTION PROPIETARIO_NO_EXISTE;
    END

   
    SELECT nif, nombre, direccion, poblacion
    FROM Propietarios
    WHERE id_propietario = :old_propietario_id
    INTO :v_nif, :v_nombre, :v_direccion, :v_poblacion;


    INSERT INTO Propietarios (id_propietario, nif, nombre, direccion, poblacion)
    VALUES (:new_propietario_id, :v_nif, :v_nombre, :v_direccion, :v_poblacion);

	-- se puede cambiar insert por este
    /*
    INSERT INTO Propietarios (id_propietario, nif, nombre, direccion, poblacion)
       select :new_propietario_id, nif, nombre, direccion, poblacion
         from propietarios
         where id_propietario = :old_propietario_id;
    */
    UPDATE Pisos
    SET id_propietario = :new_propietario_id
    WHERE id_propietario = :old_propietario_id;

    DELETE FROM Propietarios WHERE id_propietario = :old_propietario_id;
END^

SET TERM ;^


select * from propietarios;
select * from pisos;

execute procedure cambiar_propietario(3, 11);
commit;

/*2. Procedimiento almacenado que tiene 5 paramatros. El primero es un numero
entre 1 y 3 y el resto los datos de un inquilino nuevo. Este procedimiento
llama a los tres procedimiento insertar_inquilino_SPX que se han hecho el
28 de enero en clase.*/
create or alter exception numero_invalido 'El parámetro num debe ser 1, 2 o 3';

set term ^;
create or alter procedure insertar_inquilino(
    num dentero,
    nif d_nif,
    nombre d_cadena60,
    direccion d_cadena80,
    poblacion d_cadena40
)
as
declare variable cadena varchar(300);
begin
    if (num = 1) then
        execute procedure insertarInquilinoPS1(:nif, :nombre, :direccion, :poblacion) 
          returning_values cadena;
    else if (num = 2) then
        execute procedure insertarInquilinoPS2(:nif, :nombre, :direccion, :poblacion) 
          returning_values cadena;
    else if (num = 3) then
        execute procedure insertarInquilinoPS3(:nif, :nombre, :direccion, :poblacion) 
            returning_values cadena;
    else
        exception numero_invalido;
end^
set term ;^

execute procedure insertar_inquilino(1,'2342454', 'Victor Maqnuel', 'El campo', 'Archidona');


select *
	from inquilinos;
    
/* hecho con Statement */   
    
set term ^;
create or alter procedure insertar_inquilinoE(
    num dentero,
    nif d_nif,
    nombre d_cadena60,
    direccion d_cadena80,
    poblacion d_cadena40
)
 returns(sentencia VARCHAR(250))
as
  declare variable cadena varchar(300);
  
begin
    if (num BETWEEN 1 and 3) then
	begin
    	sentencia = 'execute procedure insertarInquilinoPS' || CAST(num as char(1)) 
             || '(''' || nif || ''',''' 
             || nombre || ''','''
             || direccion || ''','''
             || poblacion || ''')';
         execute statement  sentencia into cadena;
    end	
    else
        exception numero_invalido;
end^
set term ;^


/* hecho con Statement y parametros */   
    
set term ^;
create or alter procedure insertar_inquilinoEPara(
    num dentero,
    nif d_nif,
    nombre d_cadena60,
    direccion d_cadena80,
    poblacion d_cadena40
)
 returns(sentencia VARCHAR(250))
as
  declare variable cadena varchar(300);
  
begin
    if (num BETWEEN 1 and 3) then
	begin
    	sentencia = 'execute procedure insertarInquilinoPS' || CAST(num as char(1)) 
             || '(?,?,?,?)';
         execute statement (sentencia) (nif, nombre, direccion, poblacion) into cadena;
    end	
    else
        exception numero_invalido;
end^
set term ;^

execute procedure insertar_inquilinoEPara(1, '12345', 'Pepito', 'Grande', 'Archidona');

select * from inquilinos;


execute procedure insertar_inquilinoE(1, '12345', 'Miguel', 'Grande', 'Antequera');

select * from inquilinos;

/*3. Procedimeinto alamacenado seleccionable que recorra todas las posibles
parejas de inquilinos y propietarios mostrando nombre y nif de cada uno.
Ordenados por id_propietario y una columna automerica que vaya contando
inquilinos por el propietario. Además se mostrará el numero de alquileres
que tengan esos dos individuos.*/