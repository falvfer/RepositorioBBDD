/*63. Muestra los años en los que se ha dado de alta más de un cliente*/
select extract(year from fecha_alta)
	from CLIENTES
    group by 1
    having count(*) > 1;

/*64. Muestra nombre de cliente, fecha de factura, marca del móvil, donde el
cliente no es de Antequera,  la factura se hizo por más de 100€ y el móvil
tiene entre 2 y 8 de RAM y contiene en su marca una H, Y o S.*/
select c.nombre, f.cod_factura, m.marca
	from CLIENTES c
    	inner join facturas f using(cod_cliente)
    	inner join lineas_factura l using(cod_factura)
    	inner join moviles m using(cod_movil)
    where lower(c.POBLACION) <> 'antequera'
      and f.importe > 100
      and m.ram BETWEEN 2 and 8
      and m.marca similar to '%[HYS]%';

/*65. Supón que los clientes con código menor de 4, compran 2 unidades de los
móviles con mas 4 de RAM al precio del móvil. Muestra el código del cliente,
el nombre del cliente, el código del móvil, la marca y el modelo del móvil,
el número de unidades compradas y el importe por unidad de esas posibles compras.*/
select c.cod_cliente, c.nombre, m.COD_MOVIL, 2 unidades, 2 * m.PRECIO precio
	from clientes c
    	cross join moviles m
    where cod_cliente < 8
      and m.ram > 8;

/*74. Muestra el nombre de los clientes en los que su código coincide con un
código de factura y el cliente se dio de alta el año 2017.*/


/*75. Muestra nombre de cliente, fecha de factura y marca de móvil, donde
la factura es de ese cliente y el móvil podría ser de ese cliente*/


/*81. Muestra el nombre del cliente, la población del cliente y la fecha de
la factura de compras realizadas en este año (2018) y donde el cliente es de
Antequera y la factura es de ese cliente. Además, se mostrarán los clientes de
Antequera que no han comprado nada*/