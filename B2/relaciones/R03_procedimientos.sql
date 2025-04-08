/*1. Procedimiento almacenado que se le pasa una el id_reparacion, id_piso e
id_reparador y haga una copia de esa reparación a ese reparador y a ese piso.
Comprobar la existencia previa de reparación, piso y reparador y devolverá un
mensaje en base a lo que haya podido hacer.*/
set term ^;
create or alter procedure copiarReparacion(id_reparacion D_ID, id_piso d_id, id_reparador d_id)
	returns (respuesta D_CADENA60)
as

begin

	if (exists (select * from reparaciones where :id_reparacion = id_reparacion))
      then begin
        if (exists (select * from pisos where :id_piso = id_piso))
          then begin
            if (exists (select * from reparadores where :id_reparador = id_reparador))
              then begin
                insert into REPARACIONES (id_piso, id_reparador, fecha, base, iva_por, importe)
                    select :id_piso, :id_reparador, fecha, base, iva_por, importe
                        from reparaciones
                        where :id_reparacion = id_reparacion;
                      	
                respuesta = 'Se ha copiado correctamente la reparacion';
                          
              end
              else begin -- No existe el reparador
                  respuesta = 'No existe el reparador';
              end
          end
        else begin -- No existe el piso
            respuesta = 'No existe el piso';
        end
      end
    else begin -- No existe la reparacion
    	respuesta = 'No existe la reparacion';
    end

end^
set term ;^

execute procedure COPIARREPARACION(1, 2, 3);


/*2. Procedimiento almacenado que cree un piso en base a un id_propietario y
el id_piso que existe. Se le cargarán todas las habitaciones del piso
original al piso nuevo.*/
set term ^;
create or alter procedure crearPiso(id_propietario D_ID, id_piso_orig D_ID)
    returns (respuesta D_CADENA80)
as
	declare variable id_piso_nuevo d_id;
begin
    -- Verificar que existe tanto el propietario como el piso a insertar en el propietario
    if (not exists(select 1 from PROPIETARIOS where id_propietario = :id_propietario)) then
    begin
        respuesta = 'El propietario ' || :id_propietario || ' no existe.';
        exit;
    end

    if (not exists(select 1 from PISOS where id_piso = :id_piso_orig)) then
    begin
        respuesta = 'El piso ' || :id_piso_orig || ' no existe.';
        exit;
    end

    insert into PISOS ( id_propietario, direccion, poblacion)
       select :id_propietario, direccion, poblacion
          from PISOS 
          where id_piso = :id_piso_orig
      RETURNING id_piso into :id_piso_nuevo;

    insert into HABITACIONES (id_piso, descripcion, precio, ocupada)
    	select :id_piso_nuevo, descripcion, precio, ocupada
        	from habitaciones
            where id_piso = :id_piso_orig;
    
    
    respuesta = 'correcto';
end^
set term ;^


select * from habitaciones;

execute procedure crearPiso(3,2);

select * from pisos;

/*3. Procedimiento almacenado que mediante un cursor lea los alquileres
ordenados por id_alquiler y nos devuelve tres valores:
  numero de alquileres cuyo precio es igual al precio del alquiler anterior
  numero de alquileres cuyo precio es menor al precio del alquiler anterior
  numero de alquileres cuyo precio es mayor al precio del alquiler anterior*/
set term ^;
create or alter procedure comprobarprecio()
    returns (n_igual dentero, 
             n_menor dentero,
             n_mayor dentero )
as
	declare variable precio d_dinero;
    declare variable precio_anterior d_dinero;
    declare variable primero d_bolean = true;
    
begin
n_igual = 0;
n_menor = 0;
n_mayor = 0;
FOR SELECT coalesce(precio,0)
		FROM alquileres
        order by id_alquiler
INTO precio

DO
BEGIN
   

	-- comparar precio actual con precio anterior
  if (NOT(primero)) then
  begin
	if (precio > precio_anterior) then
       n_mayor = n_mayor + 1;
    else if (precio < precio_anterior) then
       n_menor = n_menor + 1;
    else 
    	n_igual = n_igual + 1;
  end
  else
     primero = false;  
     
       
    -- preparar precio anterior    
    precio_anterior = precio;
END

END^
set term ;^

-- ponemos en precio_anterior como valor inicial un valor muy bajo 
-- y empezamo n_mayor con -1
set term ^;
create or alter procedure comprobarprecio2()
    returns (n_igual dentero, 
             n_menor dentero,
             n_mayor dentero )
as
	declare variable precio d_dinero;
    declare variable precio_anterior d_dinero;
    declare variable primero d_bolean = true;
    
begin
n_igual = 0;
n_menor = 0;
n_mayor = -1;
precio_anterior = -99999;

FOR SELECT coalesce(precio,0)
		FROM alquileres
        order by id_alquiler
INTO precio

DO
BEGIN
   

	-- comprar
	if (precio > precio_anterior) then
       n_mayor = n_mayor + 1;
    else if (precio < precio_anterior) then
       n_menor = n_menor + 1;
    else 
    	n_igual = n_igual + 1;
     
       
    -- preparar precio anterior    
    precio_anterior = precio;
END

END^
set term ;^



select * from alquileres order by id_alquiler;

execute procedure comprobarPrecio;

execute procedure comprobarPrecio2;

SELECT coalesce(precio,0)
		FROM alquileres
        order by id_alquiler
        rows 2 to 1000
        
        
--saltado la primera fila
set term ^;
create or alter procedure comprobarprecio3()
    returns (n_igual dentero, 
             n_menor dentero,
             n_mayor dentero )
as
	declare variable precio d_dinero;
    declare variable precio_anterior d_dinero;
    declare variable primero d_bolean = true;
    
begin
n_igual = 0;
n_menor = 0;
n_mayor = 0;

select coalesce(precio,0)
	from alquileres
    order by id_alquiler
    rows 1
    into precio_anterior;



FOR SELECT coalesce(precio,0)
		FROM alquileres
        order by id_alquiler
        rows 2 to 10000000
INTO precio

DO
BEGIN
   

	-- comprar
	if (precio > precio_anterior) then
       n_mayor = n_mayor + 1;
    else if (precio < precio_anterior) then
       n_menor = n_menor + 1;
    else 
    	n_igual = n_igual + 1;
     
       
    -- preparar precio anterior    
    precio_anterior = precio;
END

END^
set term ;^

execute procedure comprobarPrecio3;

/*4. Procedimiento almacenado ejecutable que recorra la tabla alquileres y
por cada alquiler que encuentre subirá en 1€ el precio de alquiler de su
habitación correspondiente y si el inquilino de esa habitación es de
Antequera le suba otro más de propina.*/
select * from inquilinos;

select * from alquileres;

update inquilinos
  set poblacion = 'Antequera'
  where id_inquilino <= 2;
commit;



set term^;
create or alter procedure subir_precio_alquileres 
as
declare variable id_habitacion dentero;
declare variable id_inquilino dentero;
declare variable poblacion d_cadena40;
begin
    for select a.id_habitacion, a.id_inquilino, i.poblacion 
           from alquileres a
              inner join inquilinos i using(id_inquilino)
    into :id_habitacion, :id_inquilino, poblacion
    do
    begin
        update habitaciones
        set precio = precio + IIF (:poblacion = 'Antequera', 2, 1)
        where id_habitacion = :id_habitacion;
        
    end
end^
set term;^


select * from habitaciones;

execute PROCEDURE subir_precio_alquileres;
commit;

/*5. Procedimiento almacenado ejecutable que utilice un cursor implícito
que nos recorra la tabla de propietarios y por cada propietario calcule el
numero de pisos que tiene. El cursor devolverá el numero de propietarios
que tienen pisos y el total de pisos disponibles.*/
set term^;
CREATE OR ALTER PROCEDURE contarPisosPropietarios RETURNS (
    propietarios_con_pisos DENTERO,
    total_pisos DENTERO
) AS
  DECLARE pisos_por_propietario DENTERO;
BEGIN
    propietarios_con_pisos = 0;
    total_pisos = 0;

    FOR SELECT COUNT(*)
        FROM pisos
        GROUP BY id_propietario
        INTO :pisos_por_propietario
    DO
    BEGIN
        propietarios_con_pisos = propietarios_con_pisos + 1;
        total_pisos = total_pisos + :pisos_por_propietario;
    END
END ^
set term;^