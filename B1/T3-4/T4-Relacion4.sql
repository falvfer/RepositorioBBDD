select;
/*1. Muestra por cada reparador los datos de este el
numero de reparaciones y el base, iva e importe total de estas.*/
with estadistica AS
( select id_reparador,
        COUNT(*) AS num_reparaciones,
        SUM(BASE) AS total_base,
        SUM(IVA_POR * base / 100.00) AS total_iva,
        SUM(IMPORTE) AS total_importe
     from reparaciones
     group by id_reparador)
select r.*, e.*
    from reparadores r
        left outer join estadistica e using(id_reparador);

/*2. Muestra por cada piso el numero de habitaciones y
precio medio de sus habitaciones y el numero de habitaciones
que se encuentran ocupadas (ocupada a true).*/
select  id_piso,
        count(*) num_pis,
        avg(precio) precio_medio,
        sum(iif(ocupada, 1, 0)) numero_ocupadas
    from HABITACIONES
    group by 1;


/*3. Muestra por cada propietario el numero de reparaciones,
el importe de estas y la media del importe.*/
SELECT  p.id_propietario,
		COUNT(*) num_rep,
        sum(r.importe) total_importe,
        avg(r.importe) media_importe
    from PISOS p
        join REPARACIONES r using (id_piso)
    group by 1;

/*4. Muestra los pisos que tienen un numero de reparaciones
por encima de la media de reparaciones por piso.*/
-- con todos los pisos
SELECT p.id_piso,COUNT(*)
from PISOS p
    join REPARACIONES r using (id_piso)
group by 1
HAVING COUNT(*) > ((select count(*) from reparaciones) /  (select count(*) from pisos));
    
-- sólo con los pisos reparados
    SELECT p.id_piso,COUNT(*)
from PISOS p
    join REPARACIONES r using (id_piso)
group by 1
HAVING COUNT(*) > ((select count(*) from reparaciones) /  (select count(distinct id_piso)
 from reparaciones));


/*5. Muestra los pisos que tienen más habitaciones que la
media de habitaciones por piso.*/    
with n_h as
  (select count(*) numero
      from habitaciones
      group by id_piso)
        
select id_piso, count(*)
    from habitaciones
    group by id_piso
    having count(*) >=( select avg(numero* 1.00) 
                        from  n_h);   

/*6. Muestra los datos completos de pisos que tienen menos habitaciones que
el piso con id =3. Los pisos que no tienen habitaciones deben aparecer.*/
with pisos_menos_3 as
(SELECT id_piso
        from pisos p
             join HABITACIONES h using (id_piso)
        group by id_piso
           having count(*)
           <(SELECT count(*)
                        from HABITACIONES h1
                        where id_piso=3) 
)
select p.*
    from pisos p
    where p.id_piso in (select id_piso from pisos_menos_3)
       or p.id_piso not in (select id_piso from habitaciones);

/*7. Muestra las poblaciones de reparadores, junto con el numero de
reparadores que viven en esa población*/
SELECT poblacion,COUNT(id_reparador) as n_reparadores
	from REPARADORES
    group by poblacion;

/*8. Muestra el alquiler más antiguo (usando funciones de agregación).*/
select *
    from alquileres
    where fecha_inicio =
           (select min(fecha_inicio)
                  from alquileres
           );

-- sin usar funciones de agragación          
select *
    from alquileres
    where fecha_inicio =
           (select first 1 fecha_inicio
                  from alquileres
                  order by fecha_inicio asc
           );

/*9. Muestra los datos de los inquilinos que tienen más alquileres.*/
WITH alquileres_por_inquilino AS
	(SELECT id_inquilino, COUNT(*) AS num_alquileres
    	FROM alquileres
    	GROUP BY id_inquilino)
SELECT i.*
	FROM inquilinos i
		JOIN alquileres_por_inquilino e USING (id_inquilino)
	WHERE e.num_alquileres = (SELECT MAX(num_alquileres)
    							FROM alquileres_por_inquilino);

/*10. Muestra los datos de los repartidores que tienen menos importe en su reparaciones. Tiene que tener reparaciones.*/
with imp_reparaciones as
    (select id_reparador
         from reparaciones
         group by id_reparador
         having sum(importe) <=all
             (select SUM(importe)
                  from reparaciones
                  group by id_reparador))
 select *
     from reparadores rep
     	join imp_reparaciones ir using (id_reparador);    

/*11. Importe total y numero de reparaciones por años.*/

/*12. Muestra para cada año el número alquileres.*/

/*13. Muestra el año, mes y numero de alquileres que han comenzado en ese mes.*/

/*14. Muestra el año, mes y numero de reparaciones el año 2024. Mejorar el ejercicio mostrando el nombre del mes.*/

/*15. Muestra el año, mes, dias  y numero de reparaciones por dias.*/


/*UNION*/
/*16. Muestra una lista de todas las poblaciones en las que trabajamos . */
select poblacion
	from reparadores
union
select poblacion
    from inquilinos
union
select poblacion
    from propietarios
union
select poblacion
    from pisos;

-- Para que aparezcan repetidos también se usa union all
select poblacion
	from reparadores
union all
select poblacion
    from inquilinos
union all
select poblacion
    from propietarios
union all
select poblacion
    from pisos;

/*17. Calcula una relación con todas las personas con las que trabajamos
con  nif y población. Eliminamos los repetidos y posteriormente contamos
las personas que hay en cada población.*/
with todos AS
	(select nif, poblacion
    	from reparadores
	union
	select nif, poblacion
    	from propietarios
	union
	select nif, poblacion
    	from inquilinos)
select poblacion, count(*)
	from todos t
    group by 1;

/*18. Muestra los pisos que se han alquilado (fecha de inicio)
o se han reparado durante el presente año.*/
with todos as
	(select distinct h.id_piso, a.fecha_inicio
    	from ALQUILERES a
        	inner join habitaciones h using(id_habitacion)
	union
    select r.id_piso, r.fecha fecha_inicio
    	from reparaciones r)
select distinct id_piso
	from todos
    where extract(year from current_date) = extract(year from FECHA_INICIO);


/*19. Nombres y nif de nuestros propietarios o reparadores antequeranos.*/


/*20. Muestra población, tipo donde tipo es ‘propietarios’ o ‘reparadores’ respectivamente sea de una o de otra, sin repeticiones..*/


/*21. Sacar un lista de todas las personas que están relacionadas con nuestra empresa donde ponga nif, nombre, poblacion y si es tipo que es una constante que puede ser propietario, reparador o inquilino.*/


/*22. Sacar relaciones que tiene nif_propietario, nombre_propietario, nif_relacionado, nombre_relacionado y relación. Donde nombre y nif relacionado es el nombre y nif de un inquilino y un reparador relacionado con el propietario. Y relacionado vale alquiler o reparación según corresponda.*/


/*23. Muestro el id_propietario, nif, nombre y numero de pisos. Al final se mostrará un linea con:*/
/*id_propietario   nif         nombre    numero_de_pisos*/
/*      "           "            "       numero_de_pisos_totales_de_propietarios*/


/*24. Muestra id_reparacion, fecha base, iva e importe más una linas más que saque unos totales de base, iva e importe.*/


/*25. Muestra el año, mes y numero reparaciones e importe de las reparaciones del periodo y al final un total con estos valores.*/


/*26. Año, mes ,  id_repaparación y base de todas las reparaciones. Más unos totales por meses y un total por año y un total total de estas reparaciones. Se recomienda CTE para el resultado final bien ordenado.*/





















/**/