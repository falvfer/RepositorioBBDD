/*Sintaxis básica de select*/
select /*Modificadores*/ /*Columna/Expresiones*/,
		/*Columna/Expresiones*/
    from /*tabla*/;

/*Probar tamaño en los tipos enteros*/

/*INT*/
/*funciona*/
select CAST(2134 as smallint)
	from RDB$DATABASE;
select CAST(-2134 as smallint)
	from RDB$DATABASE;
/*no funciona*/
select CAST(42134 as smallint)
	from RDB$DATABASE;
select CAST(-42134 as smallint)
	from RDB$DATABASE;

/*INT*/
/*funciona*/
select CAST(42134 as int)
	from RDB$DATABASE;
select CAST(-42134 as int)
	from RDB$DATABASE;
/*no funciona*/
select CAST(3100200300 as int)
	from RDB$DATABASE;
select CAST(-3100200300 as int)
	from RDB$DATABASE;

/*BIGINT*/
/*funciona*/
select CAST(3100200300 as bigint)
	from RDB$DATABASE;
select CAST(-3100200300 as bigint)
	from RDB$DATABASE;

/*Prueba de variables de entorno*/
select current_date fecha,
	CURRENT_TIME as hora,
	CURRENT_TIMESTAMP fecha_hora
  from RDB$DATABASE;
  
/*Prueba cadenas predefinidas*/
select current_date fecha,
	CAST('NOW' as DATE) fecha_now,
    CURRENT_TIMESTAMP fecha_hora,
    CAST('NOW' as TIMESTAMP) fecha_hora_now
  from rdb$database;

/*Prueba propagación de null*/
select 3 + NULL,
		0 + NULL,
    from RDB$DATABASE;
    
select null is null null_is_null,
	(3 + null) is null algoMasNullEsNull,
	(3 + null) is not null AlgoMasNullNoEsNull,
    (3 > null)
  from RDB$DATABASE;

/*Numeric y Decimal*/
select cast(alquileres.PRECIO as DECIMAL(5,2))
	from RDB$DATABASE;

select cast((3.241 * 4.241) as DECIMAL(5,2)), --Dos decimales
		cast(3.241 as decimal (6,2)) * cast(4.241 as decimal (6,2)), --Cuatro decimales
        cast(3.241 as decimal (6,3)) * cast(4.241 as decimal (6,3)) --Seis decimales
	from RDB$DATABASE;

/*Diferencia entre decimales y numeric*/
select cast (23.24 as DECIMAL(4,2)),
		cast (123.24 as DECIMAL(4,2)),
		cast (1123.24 as DECIMAL(4,2)),
		cast (19123.24 as DECIMAL(4,2)),
		cast (199123.24 as DECIMAL(4,2)),
		cast (1999123.24 as DECIMAL(4,2)),
		cast (19999123.24 as DECIMAL(4,2)) --Decimal es más permisivo
	from RDB$DATABASE;
select cast (23.24 as NUMERIC(4,2)),
		cast (123.24 as NUMERIC(4,2)) --Numeric es estricto
    from rdb$database;
    
/*Prueba de flotantes*/
select cast(2.234 as float),
		cast (51231.2232356 as float) --Tiene cierto margen de error
	from RDB$DATABASE;					--por como funciona variable float.
    
/*División entera*/
select 8/14,
		8/14.0,
		8/14.00*14, --No es exacto por falta de decimales
		8/14.000, --Hace la division truncando al número de decimales especificado
        cast(8 as DECIMAL(4,2))/14 --Hace la división con dos decimales
	from RDB$DATABASE;
    
/*Resto división entera*/
select mod(14,5), --Devuelve 4
		mod(14.32,6.54) --Trabaja con números enteros redondeando -> 14%7=0
	from rdb$database;
    
/*Error en casting automático*/
select '34.56' + 8 --No se pueden mezclar cadenas con números
	from RDB$DATABASE;
select cast('34.56' as DECIMAL(4,2)) + 8 --Conversión manual
	from RDB$DATABASE;
    
/*34 en Hexadecimal*/
select 0x22,
		0x3c
    from RDB$DATABASE;

/*Calcular la fecha del dia 0*/
select CAST('0001-01-01' as date)
	from rdb$database;
    
/*Operaciones bases con fecha*/
select cast('2024-10-08' as DATE),
		cast('2024-10-08' as DATE)+3, --Suma 3
		cast('2024-10-08' as DATE)-3, --Resta 3
		cast('2024-10-08' as DATE)+3.55 --Redondea a 4 y suma 4
	from RDB$DATABASE;
    
/*Me dice los días entre dos fechas restando*/
/*Calcular los días que tengo vividos*/
select current_date - cast('2006-12-26' as DATE)
	from RDB$DATABASE;

/*Calcular los años de una persona*/
select TRUNC((current_date - cast('2006-12-26' as DATE))/365.2500)
	from RDB$DATABASE;
    
/*Poner una constante a las 4 de la tarde*/
select CAST('16:00:00' as time)
	from RDB$DATABASE;
    
/*Compruebo lo anterior sumando 3600 segundos que es una hora*/
select CAST('16:00:00' as time) + 3600
	from RDB$DATABASE;

/*Intentamos cargar diezmilesimas*/
select CAST('16:00:00.5' as time)
	from RDB$DATABASE;
    
/*Ahora comprobamos que tiene diezmilesimas*/
select CAST('16:00:00' as time) + 0.6,
		CAST('16:00:00.5' as time) + 0.6
	from RDB$DATABASE;

/*Tipo timestamp, mezcla de fecha y hora 64 bits*/
select CAST('1992-10-13 16:05:13' as TIMESTAMP),
		CAST('1992-10-13 16:05:13' as TIMESTAMP)+3, --Sumar 3 días
		CAST('1992-10-13 16:05:13' as TIMESTAMP)-3.5, --Restar 3 días y medio
		CAST('1992-10-13 16:05:13' as TIMESTAMP)+(2+15/60.000+23/3600.00000)/24 --Sumar 2:15:23 aproximadamente
	from RDB$DATABASE;
    
/*Extract*/
/*Sacar el mes actual*/
select EXTRACT(month from current_timestamp)
	from RDB$DATABASE;
    
/*Sacar los años de la tabla alquileres de la base de datos alquileres*/
select distinct extract(year from FECHA_INICIO) as fecha_inicio
	from alquileres; --Distinct es para evitar duplicados
    
/*Poblaciones distintas de los propietarios*/
select distinct poblacion
	from propietarios;
    
/*Mostrar los distintos años, meses y días
de las fechas de inicio de los alquileres*/
select distinct extract(day from FECHA_INICIO) dia,
		extract(month from FECHA_INICIO) mes,
		extract(year from FECHA_INICIO) anno
	from alquileres;

/*Mostrar la fecha de inicio de los alquileres como "dia de mes de año"*/
select fecha_inicio
		distinct extract(day from FECHA_INICIO)||' de '||
			extract(month from FECHA_INICIO)||' de '||
			extract(year from FECHA_INICIO) fecha,
    from ALQUILERES;

/*Ejemplos de clase*/
select CURRENT_DATE, t.*
	from propietarios t;
    
select * --Esta tabla se usa porque tiene una sola tupla, dando un resultado
	from rdb$database; --para cada columna, no más de una fila por columna.
		
select fechaaa --"fechaaa" no es un campo existente de la tabla alquileres
	from alquileres;

/*Sacar el nombre de los inquilinos con un "Don " delante*/
select distinct 'Don: '||nombre DON_NOMBRE
	from inquilinos;
    
select '-'||cast('hola' as char(10))||'-' char_col, --Cadena de longitud fija,
			--añade espacios si no llega a la longitud especificada
		'-'||cast('hola' as varchar(10))||'-' varchar_col --Cadena de longitud variable
	from RDB$DATABASE;

/*Muestra para todos los alquileres la fecha de alquiler y si
es un alquiler de este año o no*/

select distinct fecha_inicio fecha,
		extract(year from fecha_inicio) = extract(year from current_date) este_anno
	from alquileres;
    
/*La fecha se pueden comparar como números.
Se puede sumar días a una fecha.
Mostrar las fechas de inicio de los alquileres más 90 días*/
select fecha_inicio fecha,
		fecha_inicio+90 fecha_mas_90
	from alquileres;
    
/*Ver los alquileres activos*/
select activo estado,
		activo = true activados, --"is" se puede escribir como "="
        not activo is true inactivos --"not" como "!", "is not" como "!=" o "<>"
	from alquileres;