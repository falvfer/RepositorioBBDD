/*SUBCONSULTA DE LISTA Y SUBCONSULTA ESCALAR*/
/*1. Muestra las habitaciones que cuestan más que la habitacion
con id igual a 4.*/
select *
	from habitaciones
    where precio > (select precio
    					from habitaciones
                        where id_habitacion = 4);

/*2. Muestra los propietarios que son de la misma poblacion que el
reparador de la reparación con id = a 5.*/
select *
	from propietarios
	where poblacion =
    	(select poblacion
			from reparadores
    		where id_reparador =
            	(select id_reparador
					from reparaciones
    				where id_reparacion = 5));

/*3. Muestra para la tabla RDB$DATABASE, el nombre del propietarios con id 1,
el nombre  del repartidos con id = 1 y la fecha de la primera reparación.*/
select (select nombre from propietarios where id_propietario = 1) NOMBRE_pro,
	   (select nombre from reparadores where id_reparador = 1) NOMBRE_rep,
       (select fecha from reparaciones where id_reparacion = 1) FECHA_re
	from rdb$database;

/*4. Muestra en nombre del tercer propietario con id = 3 y el nombre
del tercer propietario ordenado por nombre.*/
select nombre
	from PROPIETARIOS
    where id_propietario = 3
       OR nombre = (select first 1 skip 2 nombre 
						from propietarios
						order by nombre asc);

/*5. Muestra las reparaciones de reparadores de la primera población
ordenada alfabeticamente.*/
select *
	from reparaciones
    where id_reparador =
    	(select first 1 id_reparador
        	from reparadores
            order by poblacion asc);
            

/*PREDICADOS EXISTENCIALES*/
/*6. Datos de las reparaciones de propietarios archidoneses.
Hacedlo con in, exists, join, =any*/
select r.*
	from reparaciones r
    	inner join pisos p using(id_piso)
        inner join propietarios pr USING(id_propietario)
    where pr.poblacion = 'Archidona';

select r.*
	from reparaciones r
    where id_piso in
    	(select id_piso
        	from pisos
           	where id_propietario in
            	(select id_propietario
                	from PROPIETARIOS
                    where poblacion = 'Archidona'));
                    
select r.*
	from reparaciones r
    where id_piso = any
    	(select id_piso
        	from pisos
           	where id_propietario = any
            	(select id_propietario
                	from PROPIETARIOS
                    where poblacion = 'Archidona'));
            
SELECT *
	FROM reparaciones r
	WHERE EXISTS
        (SELECT *
            FROM pisos p
            where p.id_piso = r.id_piso
              and exists
              	(select *
                	from propietarios pr
            		WHERE pr.poblacion = 'Archidona'
                      AND p.id_propietario = pr.id_propietario));

    

/*7. Nif y nombre de los reparadores que son inquilinos (por nif).
Hacedlo con in, exists, join, =any*/
select nif, nombre
	from reparadores
    where nif in (select nif from inquilinos);
    
select nif, nombre
	from reparadores r
    where exists (select *
    				from inquilinos i
                    where r.nif = i.nif);
    
select distinct r.nif, r.nombre
	from pisos p
    	join habitaciones h using(id_piso)
        join alquileres a using(id_habitacion)
        join reparaciones re using(id_piso)
		join reparadores r using(id_reparador)
		join inquilinos i using(id_inquilino)
    where r.nif = i.nif;
    
select nif, nombre
	from reparadores
    where nif = any(select nif from inquilinos);

/*8. Mostrar el nombre de los inquilinos archidoneses con sus alquileres.
Hacedlo con in, exists,  join, =any*/
select nombre, a.*
	from inquilinos i
    	inner join alquileres a using(id_inquilino)
        where i.POBLACION in('Archidona');
        
select nombre, a.*
	from inquilinos i
    	inner join alquileres a using(id_inquilino)
        where exists
        	(select *
            	from RDB$DATABASE
                where 'Archidona' = i.poblacion);
        
select i.nombre, a.*
	from inquilinos i
    	inner join alquileres a using(id_inquilino)
        where i.POBLACION = 'Archidona';
        
select i.nombre, a.*
	from inquilinos i
    	inner join alquileres a using(id_inquilino)
        where i.POBLACION = any(select 'Archidona' from rdb$database);

/*9. Mostrar los pisos de propietarios archidoneses que no tienen
reparaciones en los último 2 años. Hacedlo con in, exists y join*/
select distinct *
	from pisos
    where id_piso IN
    	(select id_piso
            from pisos
            where id_propietario in
                (select id_propietario
                    from propietarios
                    where poblacion = 'Archidona'))
	  and id_piso in
      		(select id_piso
                from reparaciones
                where DATEADD(-2 year to CURRENT_DATE) <= fecha);
                
select distinct *
	from pisos pi1
    where exists
    	(select *
            from pisos pi2
            where pi1.ID_PISO = pi2.ID_PISO
              and exists
                (select id_propietario
                    from propietarios pr
                    where poblacion = 'Archidona'
                      and PI2.ID_PROPIETARIO = pr.ID_PROPIETARIO))
	  and exists
      		(select id_piso
                from reparaciones re
                where DATEADD(-2 year to CURRENT_DATE) <= fecha
                  and re.ID_PISO = pi1.ID_PISO);

select distinct p.*
	from reparaciones r
    	inner join pisos p using(id_piso)
        inner join propietarios pr using(id_propietario)
    where pr.poblacion = 'Archidona'
      and DATEADD(-2 year to CURRENT_DATE) <= r.fecha;

/*10. Mostrar los datos de los pisos que se han alquilado este
año y son de una población donde no hay reparador. Hacedlo con in,
exists y join*/
select *
	from pisos
    where id_piso IN
    	(select id_piso
            from habitaciones
            where id_habitacion in
                (select distinct id_habitacion
                    from alquileres
                    where extract(year from CURRENT_DATE)
                        = extract(year from fecha_inicio)))
      and poblacion not in
      	(select distinct poblacion
			from reparadores);

select distinct *
	from pisos p
    where exists
    	(select *
            from habitaciones h
            where h.id_piso = p.id_piso
              and exists
                (select *
                    from alquileres a
                    where extract(year from CURRENT_DATE)
                        = extract(year from fecha_inicio)
                      and h.ID_HABITACION = a.ID_HABITACION))
      and not exists
      	(select *
			from reparadores r
            where p.poblacion = r.poblacion);

select distinct p.*
	from pisos p
    	inner join habitaciones h using(id_piso)
    	inner join alquileres a using(id_habitacion)
    	inner join reparaciones r using(id_piso)
    	inner join reparadores re using(id_reparador)
    where extract(year from CURRENT_DATE) = extract(year from a.fecha_inicio)
      and p.poblacion <> re.poblacion; -- No funciona

/*11. Mostrar los dos primeros nombre de los reparadores ordenados
por id que no son de Antequera y que no han reparado en el presente año.
Hacedlo con in, exists y join*/


/*12. Muestra los datos de los propieatarios a los que no se le ha
reparado nada en sus pisos.*/
SELECT distinct p.*
    from PROPIETARIOS p
        join pisos ps using(id_propietario)
    WHERE ps.ID_PISO not in (select r.ID_PISO
                                from REPARACIONES r);

/*13. Muestra los datos de los clientes que han comprado alguna pieza
por la que han pagado más de 25€. (haced las dos condiciones con in,
exists y con join).*/


/*14. Muestra los datos de los inquilinos que tiene un alquileres
superior a 200 o/y inferiores a 100. de los dos tipos.*/
select i.*
    from INQUILINOS i
         join ALQUILERES a using (id_inquilino)
    where a.PRECIO>200 or a.PRECIO<100);
    
select i.*
	from inquilinos i
    	where i.id_inquilino in
        	(select id_inquilino
            	from alquileres a
               	where a.precio < 100)
          and i.id_inquilino in
        	(select id_inquilino
            	from alquileres a
               	where a.precio > 200);
    
select i.*
	from inquilinos i
    	where i.id_inquilino = any
        	(select id_inquilino
            	from alquileres a
               	where a.precio < 100)
          and i.id_inquilino = any
        	(select id_inquilino
            	from alquileres a
               	where a.precio > 200);
    
select i.*
	from inquilinos i
    	where exists
        	(select *
            	from alquileres a
               	where a.precio < 100
                  and i.ID_INQUILINO = a.ID_INQUILINO)
          and exists
        	(select *
            	from alquileres a
               	where a.precio > 200
                  and i.ID_INQUILINO = a.ID_INQUILINO);

/*15.Muestra las parejas nombre del propietario que no tiene piso
junto al nombre del reparador que no ha reparado.*/
SELECT p.NOMBRE
    from PROPIETARIOS p
    where p.ID_PROPIETARIO not in
        (select ps.ID_PROPIETARIO
             from pisos PS
                 join REPARACIONES rc using (id_piso)
                 join REPARADORES rd using (id_reparador)
             where rc.ID_REPARADOR<>rd.ID_REPARADOR);

/*16.Muestra el nombres de propietario y reparador donde ambos son
de la misma población y no existen reparaciones entre ellos.*/
select p.NOMBRE,rd.NOMBRE
    from PROPIETARIOS p
        join PISOS ps using (id_propietario)
        join REPARACIONES rc using (id_piso)
        join REPARADORES rd using (id_reparador)
    where p.POBLACION in(select rd1.POBLACION
                            from REPARADORES rd1
                            where rd1.ID_REPARADOR<>rc.ID_REPARADOR);

/*17.Muestra los datos de nuestro propietario más antiguo por la
fecha de inicio de sus alquileres. (puede haber varios)*/
select p.*
    from PROPIETARIOS p
        join pisos ps using (id_propietario)
        join HABITACIONES h using (id_piso)
        join ALQUILERES a using(id_habitacion)
    WHERE a.FECHA_INICIO in (SELECT min(a1.fecha_inicio)
                                from alquileres a1);

/*18.Muestra los datos de nuestro último propietario por fecha de
inicio de alquiler. (puede haber varios)*/
select p.*
    from PROPIETARIOS p
        join pisos ps using (id_propietario)
        join habitaciones h using(id_piso)
        join ALQUILERES a using (id_habitacion)
    WHERE a.FECHA_INICIO in (select max(a1.FECHA_INICIO)
                                from ALQUILERES a1);


/*DIFERENCIA*/
/*19.	Habitaciones que no se han alquilado.*/
select *
	from habitaciones
   	where id_habitacion not in
    	(select id_habitacion
        	from alquileres);

/*20.	Pisos con habitaciones alquiladas en el 2024 y no en el 2023
(por fecha de inicio)*/
select distinct p.*
	from pisos p
    	inner join habitaciones h using(id_piso)
    	inner join alquileres a using(id_habitacion)
    where extract(year from a.FECHA_INICIO) = 2024
      and id_piso not in
      	(select h.id_piso
            from habitaciones h
                inner join alquileres a using(id_habitacion)
            where extract(year from a.FECHA_INICIO) = 2023);
            
/*21.	Inquilinos sin alquileres con ficha final posterior a la actual.*/
select i.*
	from inquilinos i
    where i.ID_INQUILINO not in
            (select a.id_inquilino
                from alquileres a
                where a.FECHA_FIN > CURRENT_DATE
                  and a.activo = true);

/*22.	Datos completos de pisos con reparaciones y sin alquileres*/
select *
	from pisos p
    where p.id_piso in
    		(select id_piso
            	from reparaciones)
	  and p.id_piso not in
      		(select h.ID_PISO
            	from habitaciones h
                join alquileres a using(id_habitacion));

/*23.	Pisos que se alquilado y aún no se han reparado.*/


/*24.	Propietarios sin pisos (y sin reparaciones).*/





/*Ejeplos agregados simples*/
/*Muestro cuantos alquileres hay*/
select count(*) numero
	from alquileres;

/*Cuantos alquileres tienen precio. Es decir, cuyo precio es not null.*/
select COUNT(*) numero
	from alquileres
    where precio is not null;

-- Sacarlo con una variante count
select count(precio) numero_No_Null, count(*) numero
	from alquileres;

/*La media de los precios*/
select avg(precio) media, SUM(precio) / count(precio) media2
	from alquileres;






















/**/