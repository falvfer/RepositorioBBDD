/*El acceso a un campo por su tabla*/
select p.nif
	from propietarios p;

/*Los tres primeros propietarios*/
select first 3 *
	from propietarios;
    
select first 3 skip 3 *
	from propietarios;
    
select *
	from propietarios
    rows 1 to 3;

/*Extraer de la fila 4 a la 7*/
select *
	from PROPIETARIOS
    rows 4 to 7;
    

/*Ordenar propietarios por poblacion en orden descendente y por nombre*/
select *
	from propietarios
    order by poblacion desc nulls first,
    		 nombre asc nulls last;

/*Mostrar alquileres de menor a mayor precio, nulos al principio*/
select *
	from alquileres
	order by precio;

/*Mostrar alquileres de menor a mayor precio nulos al final*/
select *
	from alquileres
    order by precio nulls last;

/*Alquileres: Ordenar mostrando los nulos a 0 y ordenando por precio*/
select  a.id_alquiler, a.ID_HABITACION, a.ID_INQUILINO, a.FECHA_INICIO, a.FECHA_FIN,
		coalesce(precio, 0) precio, a.ACTIVO
	from alquileres a
    order by precio nulls last;
    
select  a.id_alquiler, a.ID_HABITACION, a.ID_INQUILINO, a.FECHA_INICIO, a.FECHA_FIN,
		coalesce(precio, 0) precio, a.ACTIVO
	from alquileres a
    order by 6 asc nulls last;
    
/*Ordenar la tabla alquileres por fecha de inicio en orden ascendente*/
select *
    from ALQUILERES
    order by fecha_inicio asc;
    
/*Mostrar las reparaciones donde las últimas realizadas aparezcan al principio*/
select *
    from reparaciones 
    order by fecha desc;
    
/*Mostrar las 3 primeras filas de reparaciones donde las últimas realizadas
aparezcan al principio */
select *
    from REPARACIONES
    order by fecha desc
    rows 3;
    
/* lo anterior + donde las reparaciones sean de los dos ultimos años*/
select *
    from REPARACIONES
    where fecha >= dateadd(YEAR, -2, current_date)
    order by fecha desc,id_reparacion asc
    rows 3;

/*  WHERE 		primero
	ORDER BY 	segundo
    */