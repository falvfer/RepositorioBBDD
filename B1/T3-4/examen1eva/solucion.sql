El campo código de la tabla facturas es un código que identifica el tipo de servicio ofertado. Los tres primeras 
letras pueden ser:
AUT de autobus
GUI de guia
COM comida
HAB habitacion
MUS de museo

Resultado de aprendizaje 2.

seguida de un -, y una letra que puede ser A o E: A de agencia y E de exterior
un - 
Y un numero de 9 Cifras que representa un Teléfono. 

1º) Determinar que facturas tiene su campo código construido de forma
 correcta según la descripción anterior. (1)
 
 select *
 	from facturas
    where codigo SIMILAR to '(AUT|GUI|COM|HAB|MUS)\-[AE]\-[0-9]{9}' escape '\';

2º) Sacar un listado de los datos de las facturas, junto con el nombre de la
 agencia y la descripción del viaje y cambiando el código por los valores que
  representa. (1)

Ejemplo: AUT-A- 999234234  quedaría Autobus-Agencia-999234234


select  decode(left(f.codigo, 3), 'AUT', 'AUTOBUS', 'GUI', 'GUIA',
               'COM', 'COMIDA','HAB', 'HABITACIONES', 'MUS', 'MUSEO', 'ERROR')
               || '-' 
               || decode( SUBSTRING  (f.codigo from 5 for 1), 'A', 'AGENCIA',
                                                              'E', 'EXTERIOR',
                                                              'ERROR')
               || '-'                                               
               || SUBSTRING  (f.codigo from 7 for 9)                                               
               codigo_nuevo,
    f.*, a.nombre, v.descripcion
	from facturas f
    	inner join agencias a using(id_agencia)
        inner join viajes v using(id_viaje);

3º) Mostrar los datos de viajes, junto con el total gastado en sus facturas 
 facturas), numero de facturas y la diferencia entre el total_gastado y el total 
 facturado. (Se valorará optimización de la consulta)  (1) 

with calculos as
(select id_viaje, sum(importe_base + importe_iva) importe_total, count(*) numero
	from facturas
    group by id_viaje)
    
select v.*, coalesce(c.importe_total,0) importe_facturas,
            COALESCE(c.numero,0) numero_facturas,
            total_gastado - coalesce(c.importe_total,0)
	from viajes v
     left outer join calculos c using (id_viaje);
    
    

4º) Mostrar los datos completos de la agencia(agencias pueden ser varias) 
que nos han emitido la factura con el importe base más alto. (1)

select a.*
	from agencias a
    where id_agencia in (select id_agencia 
    						from facturas
                            where importe_base = (select max(importe_base) 
                                                      from FACTURAS));
                                                      
  
5º) Datos completos de los socios que no han realizado pagos a viajes que 
haya pagado el socio con id_socio = 2.(1)

-- viajes de socio 2

select distinct id_viaje
	from pagos
    where id_socio = 2;
    
-- socios que han pagado viajes del socio 2

select id_socio
	from pagos
    where id_socio in (select distinct id_viaje
							from pagos
    						where id_socio = 2)
-- Los que no han ido
 
 select *
 	from socios
    where id_socio not in (select id_socio
							from pagos
    						where id_socio in (select distinct id_viaje
												from pagos
    											where id_socio = 2))

/*6º) Socios que
		no tienen (cuotas)
        no tienen (pagos)
        en este año. (1)*/

select *
	from  socios
    where id_socio not in (select id_socio 
                             from cuotas
                             where anio = extract(year from current_date))
      and id_socio not in (select id_socio
        					from pagos
                            where EXTRACT(year from fecha) = extract(year from current_date));                      

7º) Obten un listado con los  pagos y cuotas de todos los socios, con los siguientes elementos:

id_socio 	tipo_de_operación      fecha    importe

El tipo de operación es pago o cuota según sea la operación.
 Además ordenaremos el listado por id_socio ascendente, 
 tipo_de_operación ascendente y fecha descendente. (1)
 with unir as
   (select id_socio, 'pagos' operacion, fecha, importe
      from pagos
   union
   select id_socio, 'cuotas' operacion, fecha_pago, importe 
      from cuotas)
    
 select *
 	from unir   
    order by id_socio asc, operacion asc, fecha desc;
 

8º) Combinaciones de viajes y socio (id_viaje, id_socio) donde ese socio no ha 
hecho un pago a ese viaje. (1)
select s.id_socio, v.id_viaje
	from socios s
    	cross join viajes v
    where not exists (select *
    					from pagos p
                        where p.id_socio = s.id_socio and p.id_viaje = v.id_viaje);
        

select s.id_socio, v.id_viaje
	from socios s
    	cross join viajes v
    where id_socio * 1000000 + id_viaje not in (select id_socio * 1000000 + id_viaje
    												from pagos p);
                        
                        
9º) Datos completos de los Viajes que se han facturado por más de una agencia
 o que aún no se ha facturado por ninguna.  (1)
 
 --los que tienen una 
 select id_viaje
 	from facturas
    group by id_viaje
    having count(DISTINCT id_agencia) > 1;
    
  select * 
  	from viajes
    where id_viaje in (select id_viaje
 						from facturas
					    group by 1
					    having count(DISTINCT id_agencia) > 1)
          or id_viaje not in (select id_viaje
          						from facturas);
 	
    
 select * from facturas where id_viaje = 7

10º) Facturas cuya base esta por debajo de la base de todas las facturas 
de la agencia con id = 2. (1)

select * 
	from  facturas
    where importe_base < all (select importe_base
    						from facturas
                            where id_agencia = 2);
Resultado de aprendizaje 4.

1º) Borrar las facturas que tenga más de 5 años a fecha del 1 de enero del 
presente, posteriormente borrar aquellas agencias que no tengan facturas. (3)


delete
	from facturas
    where extract(year from current_date) - extract (year from fecha) >= 5;
rollback;

delete from agencias
	where id_agencia not in (select id_agencia from  facturas);
rollback;

2º) Se ha detectado que el socio 2, que tiene o puede tener pagos al viaje 1,
 ha hecho exactamente los mismos pagos que el socio 1 al viaje 1. Modificar 
 la base de datos para registrar este hecho. (3.5)
 
 
 delete from pagos
 	where id_socio = 2 and id_viaje = 1;
 ROLLBACK;
 
 insert into pagos (id_socio, id_viaje, fecha, importe)
 	select 2, 1, fecha, importe
    	from pagos
        where id_socio = 1 and id_viaje = 1;
 rollback;

3º) Subir un 15% el total presupuestado de los viajes que aún no se han realizado (por fecha).(1)
 Además fijar el campo total_gastado
  a los viajes que se han realizado en base a sus facturas. (2.5)

UPDATE viajes
	set total_presupuestado = total_presupuestado * 1.15
    where fecha > current_date;
rollback;    
    
select * from viajes;

update viajes v
	set total_gastado = coalesce((select sum(importe_base + importe_iva) 
                           from facturas f
                           where f.id_viaje = v.ID_VIAJE), 0);
commit;

(Subir este mismo odt con cada respuesta en su apartado)
