/*Resultado de aprendizaje 3.*/
/*1º) Determinar que facturas tiene su campo código construido de forma correcta
según la descripción anterior. (1)*/
select *
	from facturas
    where codigo similar to '(AUT|GUI|COM|HAB|MUS)\-[AE]\-[0-9]{9}' escape '\';

/*2º) Sacar un listado de los datos de las facturas, junto con el nombre de
la agencia y la descripción del viaje y cambiando el código por los valores
que representa. (1)*/
/*Ejemplo: AUT-A-999234234  quedaría Autobus-Agencia-999234234*/
select f.*, a.nombre, v.descripcion,
		DECODE(LEFT(f.codigo, 3),
        	'AUT', 'Autobus', 'GUI', 'Guia', 'COM', 'Comida',
            'HAB', 'Habitacion', 'MUS', 'Museo') || '-' ||
		DECODE(RIGHT(LEFT(f.codigo, 5),1),
        	'A', 'Agencia', 'E', 'Exterior') || '-' ||
        RIGHT(f.CODIGO, 9) codigo_completo
	from facturas f
    	join viajes v using(id_viaje)
        join agencias a using(id_agencia)
    where f.CODIGO similar to '(AUT|GUI|COM|HAB|MUS)\-[AE]\-[0-9]{9}' escape '\';
    -- Pongo el similar to para evitar errores y que los decode funcionen correctamente

/*3º) Mostrar los datos de viaje, junto con el total gastado en sus facturas
(de facturas), numero de facturas y la diferencia entre el total_gastado y
el total facturado. (Se valorará optimización de la consulta)  (1) */
with facturado as
	(select v.id_viaje, sum(importe_base) + sum(importe_iva) total_facturado,
            count(*) num_facturas
        from viajes v
            join facturas f using(id_viaje)
        group by 1)
        
select v.*, f.total_facturado, f.num_facturas,
		v.TOTAL_GASTADO - f.total_facturado diferencia_totales
	from viajes v
    	join facturado f using(id_viaje);

/*4º) Mostrar los datos completos de la agencia(agencias pueden ser varias)
que nos han emitido la factura con el importe base más alto. (1)*/
select *
	from agencias
    where id_agencia =
    	(select a.ID_AGENCIA
            from facturas f
                join agencias a using(id_agencia)
            group by 1
            order by max(f.importe_base) desc
            rows 1);

/*5º) Datos completos de los socios que no han realizado pagos a viajes que
haya pagado el socio con id_socio = 2.(1)*/
select *
	from socios
    where id_socio in
    	(select s.id_socio
        	from socios s
            	join pagos p USING(id_socio)
            where id_viaje not in
            	(select distinct id_viaje
                    from socios s
                        join pagos p using(id_socio)
                    where id_socio = 2));

/*6º) Socios que no tienen ni cuotas ni pagos en este año. (1)*/
select *
	from socios
    where id_socio not IN
    	(select id_socio
			from socios
                join pagos using(id_socio)
                join cuotas using(id_socio));

/*7º) Obten un listado con los  pagos y cuotas de todos los socios, con los
siguientes elementos:*/
/*id_socio, tipo_de_operación, fecha, importe*/
/*El tipo de operación es pago o cuota según sea la operación.
Además ordenaremos el listado por id_socio ascendente, tipo_de_operación
ascendente y fecha descendente. (1)*/
select id_socio, 'pago' tipo_de_operacion, p.fecha, p.IMPORTE
    from socios s
        join pagos p using(id_socio)
union
select id_socio, 'cuota' tipo_de_operacion,
		cast(c.ANIO || '-' || iif(c.MES<10,'0' || c.mes, c.MES) || '-01' as date),
        c.IMPORTE
	from socios s
    	join cuotas c using(id_socio);
-- He hecho un casting usando año y mes ya que he visto que hay fechas nulas

/*8º) Combinaciones de viajes y socio (id_viaje, id_socio) donde ese socio
no ha hecho un pago a ese viaje. (1)*/
select distinct s.ID_SOCIO, v.ID_VIAJE
	from pagos
    	inner join socios s using(id_socio)
        cross join viajes v
	where not exists
    	(select distinct v2.id_viaje, s2.id_socio
            from pagos
                join socios s2 using(id_socio)
                join viajes v2 using(id_viaje)
            where v2.id_viaje = v.ID_VIAJE
              and s2.ID_SOCIO = s.ID_SOCIO);

/*9º) Datos completos de los Viajes que se han facturado por más de una agencia
o que aún no se ha facturado por ninguna.  (1)*/
select *
	from VIAJES
    where id_viaje in
    	(select id_viaje
            from facturas
                join viajes using(id_viaje)
            group by 1
            having count(*) > 1)
	   or id_viaje in
        (select id_viaje
            from facturas
                right join viajes using(id_viaje)
            where id_factura is null);

/*10º) Facturas cuya base esta por debajo de la base de todas las facturas de
la agencia con id = 2. (1)*/
select *
	from facturas
    where importe_base < all
    	(select distinct importe_base
        	from facturas
            where id_agencia = 2);

/*Resultado de aprendizaje 4.*/
/*1º) Borrar las facturas que tenga más de 5 años a fecha del 1 de enero del
presente, posteriormente borrar aquellas agencias que no tengan facturas. (3)*/
delete from facturas
	where fecha < dateadd(year, -5, cast(extract(year from current_date)
    						|| '-01-01' as date));
commit;

delete from agencias
	where id_agencia not in (select distinct id_agencia from facturas);
commit;

/*2º) Se ha detectado que el socio 2, que tiene o puede tener pagos al viaje
1, ha hecho exactamente los mismos pagos que el socio 1 al viaje 1. Modificar
la base de datos para registrar este hecho. (3.5)*/
update pagos
	set importe = (select avg(importe)
    				from pagos
                    where id_socio = 1 and id_viaje = 1)
	where id_socio = 2 and id_viaje = 1;
commit;

/*3º) Subir un 15% el total presupuestado de los viajes que aún no se han
realizado (por fecha).(1) Además fijar el campo total_gastado a los viajes
que se han realizado en base a sus facturas. (2.5)*/
update viajes
	set total_presupuestado = (total_presupuestado * 1.15)
    where fecha > current_date;
commit;
    
update viajes v
	set v.total_gastado =
    	(select sum(importe_base) + sum(importe_iva)
        	from facturas f
            where f.id_viaje = v.ID_VIAJE);
commit;



/**/