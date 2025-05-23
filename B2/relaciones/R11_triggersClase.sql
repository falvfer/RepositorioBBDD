/*1. Cada vez que se hace una venta se restan las unidades a artículos, se suman
a unidades vendidas y se aumenta las ventas totales*/
create exception sinUnidadesArticulos 'No quedan articulos suficientes';

set term ^;
create or alter trigger ai_ventas_01
before insert
position 1 on ventas as
	declare variable unidadesOriginales DENTERO;
begin

	unidadesOriginales = (select unidades
    						from articulos
            				where id_articulo = new.id_articulo);

	if (unidadesOriginales >= new.unidades)
    then begin
        update articulos
            set unidades = unidades - new.unidades,
            	unidades_vendidas = unidades_vendidas + new.unidades,
                ventas_totales = ventas_totales + (new.precio * new.unidades)
            where id_articulo = new.id_articulo;
	end else
    	exception sinUnidadesArticulos;
    	
    	
end^
set term ;^

select * from articulos; -- id=1, ud=3, ud-v=0, vent-t=0

insert into VENTAS(id_articulo, precio, unidades)
	values(1, 20, 2);
commit;

select * from articulos; -- id=1, ud=1, ud-v=2, vent-t=40

/*2. Vamos a impedir que se borren y se modifiquen las ventas*/
-- Crear las excepciones que se van a usar
create exception ventas_ND 'No se puede borrar ninguna venta';
create exception ventas_NU 'No se puede modificar ninguna venta';

-- Crear el trigger para controlar que no se borre o modifique ninguna venta
set term ^;
create or alter trigger bud_ventas_01
before update or delete
position 1 on ventas as
begin

    if (updating) then
        exception ventas_NU;
    else
        exception ventas_ND;
        
end^
set term ;^

-- Quitar el trigger anterior
drop trigger bud_ventas_01;

/*3. Vamos a desactivar los triggers del ejercicio anterior, y si se borra o modifica
una venta, se anula lo que se hace en la inserción. (Aconsejable en dos triggers)*/

-- Crear el trigger para update
set term ^;
create or alter trigger bu_ventas_01
before update
position 1 on ventas as
	declare variable unidadesOriginales DENTERO;
begin
    
	-- Guardar las unidades originales del articulo nuevo
    unidadesOriginales = (select unidades
                            from articulos
                            where id_articulo = new.id_articulo);
    
    -- Comprobar que hayan suficientes unidades del articulo nuevo
    if (old.id_articulo <> new.id_articulo) then begin
        if (unidadesOriginales < new.unidades) then
        	exception sinUnidadesArticulos;
    end else begin
        if (unidadesOriginales < (new.unidades - old.unidades)) then
        	exception sinUnidadesArticulos;
    end
        
    -- Actualizar los datos
    update articulos
        set unidades = unidades + old.unidades,
            unidades_vendidas = unidades_vendidas - old.unidades,
            ventas_totales = ventas_totales - (old.precio * old.unidades)
        where id_articulo = old.id_articulo;
            
    update articulos
        set unidades = unidades - new.unidades,
            unidades_vendidas = unidades_vendidas + new.unidades,
            ventas_totales = ventas_totales + (new.precio * new.unidades)
        where id_articulo = new.id_articulo;
    	
end^
set term ;^

-- Crear el trigger para delete
set term ^;
create or alter trigger ad_ventas_01
after delete
position 1 on ventas as
begin

        update articulos
            set unidades = unidades + old.unidades,
                unidades_vendidas = unidades_vendidas - old.unidades,
                ventas_totales = ventas_totales - (old.precio * old.unidades)
            where id_articulo = old.id_articulo;
    	
end^
set term ;^





-- Añadir los 2 articulos para las pruebas y la venta correspondiente
insert into articulos(id_articulo, descripcion, precio, unidades)
	values(101, 'a101', 20, 5);

insert into articulos(id_articulo, descripcion, precio, unidades)
	values(102, 'a102', 30, 10);

insert into VENTAS(id_venta, id_articulo, precio, unidades)
	select 100, id_articulo, precio, 2
    	from articulos
        where id_articulo = 101;
commit;

-- Información de la venta con id "100" junto a su artículo correspondiente 
select a.*, v.*
	from articulos a
		join ventas v using(id_articulo)
    where v.id_venta = 100;

-- Probamos a modificar el precio a "30" de la venta con id "100",
-- lo cual tiene que hacer que las "ventas_totales" cambien a "60"
update VENTAS
	set precio = 30
    where id_venta = 100;
commit;

-- Esta vez vamos a modificar las unidades de la venta a "3", teniendo
-- que modificar prácticamente todo
update VENTAS
	set unidades = 3
    where id_venta = 100;
commit;

-- Por último, vamos a cambiar el id_articulo de la venta a "102",
-- esto mueve lo de un articulo a otro
update VENTAS
	set id_articulo = 102
    where id_venta = 100;
commit;

-- Ahora si borramos la única venta que ha habido, todo debería de estar como al
-- principio, "a101" tiene 5 articulos, "a102" tiene 10 articulos, lo demás a "0"
delete from ventas
	where id_venta = 100;
commit;

select *
	from articulos
	where id_articulo > 100;
    
-- Borrar los dos articulos
delete from articulos
	where id_articulo > 100;
commit;

