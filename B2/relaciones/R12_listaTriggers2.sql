/*1. Crear un trigger que no permita indicar a un propietario la población
'Antequera' y la dirección contenga 'carrera'*/
create EXCEPTION p_carreraAntequera 'No se puede indicar la población Antequera y dirección carerra';

set term ^; 
create or alter trigger biu_propietarios01
before insert or update
position 1
on propietarios
as
	
begin

	if (inserting) then begin
    	if (new.poblacion = 'Antequera') then
            if (new.direccion similar to '%carrera%') THEN
            	exception p_carreraAntequera;
    end else begin
    	if (new.poblacion = 'Antequera' or (old.poblacion = 'Antequera' and new.poblacion is NULL)) then
            if (new.direccion similar to '%carrera%' or (old.poblacion similar to '%carrera%' and new.poblacion is NULL)) THEN
            	exception p_carreraAntequera;
	end
    
END^
set term;^

insert into propietarios(nif, nombre, direccion, poblacion)
	values('8885', 'BORRAR_1', 'Calle carrera guapa', 'Antequera');
commit;

insert into propietarios(nif, nombre, direccion, poblacion)
	values('8885', 'BORRAR_1', 'Calle guapa', 'Antequera');
commit;

update propietarios
	set direccion = 'carrera'
    where nif = '8885';
commit;

/*2. En las inserciones de reparaciones hay que hacer tres gestiones:
	1. El importe se tiene que calcular automáticamente a partir de la base y el iva_por
    		(importe = base * (1 + iva_por / 100)
    2. La base y el iva no pueden ser negativos
    3. Se deba actualizar el campo total_reparaciones del reparador correspondiente*/
create exception base_iva_negativo 'La base y el iva no pueden ser negativos';

set term ^;
create trigger bi_reparaciones_01 
	before insert or update
	position 0 
	on reparaciones 
as
begin
	if(new.iva_por < 0 or new.base < 0) then
	    exception base_iva_negativo;
    
    new.importe = new.base * (1.00 + new.iva_por / 100.00);
end^
set term ;^

insert into reparaciones (id_piso, id_reparador, fecha, base, iva_por, importe)
  values (2, 3, current_date , 1000, 16, 1000);
commit;

select * from reparaciones

set term ^;
create trigger au_reparaciones_02
after insert
position 0 on reparaciones as
begin
	update reparadores
    	set total_facturado = total_facturado + new.importe
        where id_reparador = new.id_reparador;
end^
set term ;^

-- mejorar el trigger tratando modificaciones y borrados
set term ^;
create or alter trigger au_reparaciones_02
after insert or delete or update
position 0 on reparaciones as
begin
 if (inserting or updating) then
	update reparadores
    	set total_facturado = total_facturado + new.importe
        where id_reparador = new.id_reparador;
  if (deleting or updating) then
	update reparadores
    	set total_facturado = total_facturado - old.importe
        where id_reparador = old.id_reparador;
end^
set term ;^

select * from reparadores;

/*3. No se puede alquilar una habitación si tiene un alquiler activo*/
create EXCEPTION ex_alquiler_activo 'El alquiler esta activo';

set term ^;
CREATE or alter TRIGGER BI_ALQUILERES_03
BEFORE INSERT 
POSITION 0
on ALQUILERES
AS
	DECLARE VARIABLE alquiler_activo INTEGER;
BEGIN
    SELECT COUNT(*)
    FROM Alquileres
    WHERE id_habitacion = NEW.id_habitacion
    INTO :alquiler_activo;

    IF (alquiler_activo > 0) THEN
    BEGIN
        EXCEPTION ex_alquiler_activo;
    END
END^
set term ;^

set term ^;
CREATE or alter TRIGGER BI_ALQUILERES_03
BEFORE INSERT 
POSITION 0
on ALQUILERES
AS
	
BEGIN
    
    IF (exists (SELECT 1
    				FROM Alquileres
    				WHERE id_habitacion = NEW.id_habitacion
                          and activo)) THEN
        EXCEPTION ex_alquiler_activo;
END^
set term ;^

/*4. Un inquilino no puede alquilar una habitación si no vive en el mismo pueblo*/
CREATE EXCEPTION NO_VIVE_MISMO_PUEBLO 'El inquilino no es del mismo pueblo';

set term^;
create or alter trigger mismoPuebloInquilino
before insert or update
position 1
on alquileres
as
	declare variable poblacionPiso d_cadena40;
    declare variable poblacionInq d_cadena40;
begin
	poblacionPiso = (
    	SELECT poblacion
        	FROM habitaciones
            JOIN pisos USING (id_piso)
            WHERE id_habitacion = new.id_habitacion
    );
    
    poblacionInq = (
    	SELECT poblacion
        	FROM inquilinos
            WHERE id_inquilino = new.id_inquilino
    );
    
    if (upper(poblacionPiso) != upper(poblacionInq)) then
    	EXCEPTION NO_VIVE_MISMO_PUEBLO;
end^
set term;^

/*5. Un alquiler de una habitación no puede hacerse por un importe menor que el de
algún alquiler que ya se haya hecho en la habitación correspondiente*/
create exception importeMenor 'El precio tiene que ser superior a todos los anteriores ';
set term^;
create or alter trigger alquilerHabitacion
before insert or update
position 1
on alquileres
as
begin

	if(new.precio <=  any (select precio
    					from alquileres
                        where id_habitacion=new.id_habitacion)) then
    	exception importeMenor;

END^
set term;


select * from alquileres where id_habitacion = 6;

select * from habitaciones

-- error por precio 550
insert into alquileres (id_habitacion, id_inquilino, fecha_inicio, fecha_fin, precio, activo)
values (1, 2, current_date, current_date + 120, 550, true);
commit;

-- que pasa cuando introduzco el primer alquiler a una habitacion
insert into alquileres (id_habitacion, id_inquilino, fecha_inicio, fecha_fin, precio, activo)
values (6, 2, current_date, current_date + 120, 551, true);
commit;

/*6. Cada vez que en alquileres se cambie el estado de un alquiler se actualizará
el campo ocupado de la habitación correspondiente.*/
set term^;
create or alter trigger aiud_alquileres
after insert or delete or update
position 1
on alquileres
as
begin

	if (DELETING and old.activo)
      update habitaciones
      	set ocupada = false
        where id_habitacion = old.id_habitacion;
        
    if (UPDATING and new.activo != old.activo)
      update habitaciones
      	set ocupada = new.activo
        where id_habitacion = old.id_habitacion;
        
        
           
    if (inserting and new.activo)
      update habitaciones
      	set ocupada = true
        where id_habitacion = old.id_habitacion;
           

END^
set term;