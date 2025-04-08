/*1. Realizar un listado de alquileres ordenados por fecha, junto con un campo
más que se llama total alquileres que es una suma acumulada de todos los
precios de los alquileres.*/
SET TERM ^;
CREATE OR ALTER PROCEDURE ListarAlquileresConTotal
RETURNS (id_alquiler D_ID,id_habitacion D_ID, id_inquilino D_ID,
    fecha_inicio D_FECHA, fecha_fin D_FECHA, precio D_DINERO, activo BOOLEAN,
    total_alquileres D_DINERO)
AS

DECLARE VARIABLE acumulado DENTERO;
BEGIN

    total_alquileres = 0;

    FOR SELECT id_alquiler, id_habitacion, id_inquilino,
			fecha_inicio, fecha_fin, precio, activo
        FROM Alquileres
        ORDER BY fecha_inicio
        INTO :id_alquiler, :id_habitacion, :id_inquilino,
            :fecha_inicio, :fecha_fin, :precio, :activo
    DO
    BEGIN
        total_alquileres = total_alquileres+coalesce(precio,0);
        SUSPEND; 
    END
    
END^
SET TERM ;^

SELECT * FROM ListarAlquileresConTotal;

/*2. Listar las reparaciones ordenadas por fecha mostrando únicamente la que
aparezcan en posiciones pares.*/
set term^;   
    CREATE OR ALTER PROCEDURE ListarRepPosPares
RETURNS (
    id_reparacion D_ID,id_piso D_ID,id_reparador D_ID,
    fecha D_FECHA,base D_DINERO,iva_por D_PORCENTAJE,
    importe D_DINERO
)
AS
DECLARE VARIABLE contador INTEGER;
BEGIN
    contador = 0;

    FOR SELECT id_reparacion, id_piso, id_reparador,fecha,base, 
        		iva_por, importe
        FROM Reparaciones
        ORDER BY fecha
        INTO 
            :id_reparacion,:id_piso,:id_reparador,:fecha,:base, 
            :iva_por,:importe
      DO
      BEGIN
          
 		  contador = contador + 1;
          IF (MOD(contador , 2 )= 0) THEN 
            BEGIN
                SUSPEND;
            END
          
         
      END
END^
set term;^

SELECT * FROM reparaciones order by fecha;
select * from ListarRepPosPares;

/*3. Sacar un listado de los nombres  de los propietarios ordenados por
población y nombre, pero al cambiar de población en lugar del nombre
aparecerá la cadena propietarios de población, algo parecido a:
  propietarios de Archidona
  Enrique 
  Vicente
  propietarios de Loja
  Jesús
  Manuel
  propieatarios de ...
  ...*/
set term ^;
create or alter procedure listar_propietarios
    returns (
        resultado d_cadena60
    )
as
	declare variable poblacion_actual d_cadena60;
    declare variable poblacion_anterior d_cadena60;
	declare variable nombre d_cadena60;
begin
    poblacion_anterior = '';
    resultado='';

    for select poblacion, nombre
        from propietarios
        order by poblacion, nombre
        into :poblacion_actual, :nombre
    do
    begin
        if (:poblacion_actual <> poblacion_anterior) then
        begin
             
            resultado = 'propietarios de ' || poblacion_actual;
            poblacion_anterior=poblacion_actual;
            suspend;
        end

        resultado = nombre;
        suspend;
    end
end^
set term ;^


execute procedure listar_propietarios;

/*4. Procedimiento almacenado seleccionable que nos devuelva una lista con
los inquilinos que tengan alquileres ordenados por nif y con un autunumerico
a la izquierda.*/
SET TERM ^ ;

CREATE OR ALTER PROCEDURE ListadoInquilinosConAlquileres
RETURNS (
    autonumerico DENTERO,
    id_inquilino D_ID,
    nif D_CADENA60,
    nombre D_CADENA60,
    direccion D_CADENA80,
    poblacion D_CADENA40
)
AS
BEGIN
    autonumerico = 0;

    FOR SELECT
            i.id_inquilino,
            i.nif,
            i.nombre,
            i.direccion,
            i.poblacion
        FROM inquilinos i
        WHERE i.id_inquilino IN (
                SELECT a.id_inquilino
                	FROM alquileres a
            )
        ORDER BY
            i.nif
        INTO
            :id_inquilino, :nif, :nombre, :direccion, :poblacion
    DO
    BEGIN
        autonumerico = autonumerico + 1; -- Incremento del autonumérico
        SUSPEND; 
    END
END^

SET TERM ; ^


select * from ListadoInquilinosConAlquileres;