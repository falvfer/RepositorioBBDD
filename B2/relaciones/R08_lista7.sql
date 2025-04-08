/* Procedimiento almacenado seleccionable que nos devuelva los datos de los 
inquilinos, propietarios y reparadores con tres cursores y cada individuo 
con un campo que indica su tipo. No se puede hacer con una Unión y un único cursor. */

set term ^;
create or alter procedure listarPersonas()
    returns(ids D_ID,nif D_NIF,nombre D_CADENA60,direccion D_CADENA80,
    poblacion D_CADENA40,tipo D_CADENA40)
as
declare variable cursorInqui CURSOR for
  (select id_inquilino,nif,nombre,direccion,poblacion from INQUILINOS);
declare variable cursorProp CURSOR for
  (select id_propietario,nif,nombre,direccion,poblacion from PROPIETARIOS);
declare variable cursorRep CURSOR for
   (select id_reparador,nif,nombre,direccion,poblacion from REPARADORES);
BEGIN

open cursorInqui;
  :tipo='Tipo inquilino';
FETCH cursorInqui into :ids,:nif,:nombre,:direccion,:poblacion;
  WHILE(ROW_COUNT=1) do
      begin
        suspend;
        FETCH cursorInqui into :ids,:nif,:nombre,:direccion,:poblacion;
      end

close cursorInqui;

open cursorProp;
  :tipo='Tipo propietario';
FETCH cursorProp into :ids,:nif,:nombre,:direccion,:poblacion;
  WHILE(ROW_COUNT=1) do
      begin
        suspend;
        FETCH cursorProp into :ids,:nif,:nombre,:direccion,:poblacion;
      end

close cursorProp;

open cursorRep;
  :tipo='Tipo reparador';
FETCH cursorRep into :ids,:nif,:nombre,:direccion,:poblacion;
  WHILE(ROW_COUNT=1) do
      begin
        suspend;
        FETCH cursorRep into :ids,:nif,:nombre,:direccion,:poblacion;
      end

close cursorRep;

end^
set term ;^

select * from listarPersonas;

/* Procedimiento almacenado que liste  los alquileres mostrando uno sí y otro no 
utilizando un cursor scrollable. */


set term ^ ;
create or alter procedure listaralquileresalternos 
returns (id_alquiler d_id, id_habitacion d_id, id_inquilino d_id,
    		fecha_inicio d_fecha, fecha_fin d_fecha, precio d_dinero)
as
declare cur_alquileres scroll cursor for (select id_alquiler, id_habitacion, id_inquilino,
                                                 fecha_inicio, fecha_fin, precio 
                                              from alquileres);
begin
 
    open cur_alquileres;
    fetch next from cur_alquileres into id_alquiler, id_habitacion, id_inquilino,
                                    fecha_inicio, fecha_fin, precio;
    while (row_count = 1) do
    begin
        suspend;
        fetch relative 2 from cur_alquileres into id_alquiler, id_habitacion, id_inquilino,
                                    fecha_inicio, fecha_fin, precio;
 
    end
    close cur_alquileres;
end^
set term ; ^

select *
	from alquileres;
    
select *
	from listarAlquileresAlternos;
    
    
    


/* Procedimiento almacenado seleccionable que devuelve autonumerico, nombre, nif 
y tipo de persona. Que se haga con dos cursores explicitos, que liste los 
propietarios con tipo propietario y por cada propietario sus inquilinos con tipo 
inquilino. En autonómico se debe contar propietarios e inquilinos  */

set term ^;
create or alter procedure sp_lista_personas
returns (
    id_autonumerico dentero,
    nombre d_cadena40,
    nif d_nif,
    tipo_persona d_cadena40
)
as
	declare variable cont_propietarios dentero;
	declare variable cont_inquilinos dentero;

	declare variable id_propietario d_id;

	declare cur_propietarios  cursor for (
    select id_propietario, nombre, nif
    from propietarios);

	declare cur_inquilinos  cursor for (
    select DISTINCT inq.nombre, inq.nif
    from pisos p
    join habitaciones h on h.id_piso = p.id_piso
    join alquileres a on a.id_habitacion = h.id_habitacion
    join inquilinos inq on inq.id_inquilino = a.id_inquilino
    where p.id_propietario = :id_propietario
);
begin
    cont_propietarios = 0;
    cont_inquilinos = 0;
    
    open cur_propietarios;

    fetch cur_propietarios into id_propietario, nombre, nif;

    while (row_count = 1) do
    begin
        -- preparación del suspend
        cont_propietarios = cont_propietarios + 1;
        id_autonumerico = cont_propietarios;
        tipo_persona = 'propietario';
        suspend;
        

        -- tratamiento de inquilinos de un propietario
        cont_inquilinos = 0;
        open cur_inquilinos;
        fetch cur_inquilinos into nombre, nif;
        while (row_count = 1) do
        begin
            cont_inquilinos = cont_inquilinos + 1;
            id_autonumerico = cont_inquilinos;
            tipo_persona = 'inquilino';
            suspend;
        end
        close cur_inquilinos;
        
        fetch cur_propietarios into id_propietario, nombre, nif; 
    end
    close cur_propietarios;  
end^

set term ;^


select  inq.nombre, inq.nif, p.id_propietario
    from pisos p
    join habitaciones h on h.id_piso = p.id_piso
    join alquileres a on a.id_habitacion = h.id_habitacion
    join inquilinos inq on inq.id_inquilino = a.id_inquilino
    
select *
	from sp_lista_personas;