/*9. Muestra como obtienes el número de días que van
desde hoy a la fecha ‘16/3/2018’.*/
select current_date - cast('2018-03-16' as date)
	from rdb$database;

select *
	from rdb$database;


/*10. Muestra cuantos meses, años, días, horas y minutos
van entre ahora y ‘16/3/2020 07:04:34’*/
select datediff(year, cast('2020-03-16 07:04:34' as timestamp), CURRENT_TIMESTAMP) annos,
    	datediff(month, cast('2020-03-16 07:04:34' as timestamp), CURRENT_TIMESTAMP) meses,
		datediff(day, cast('2020-03-16 07:04:34' as timestamp), CURRENT_TIMESTAMP) dias,
		datediff(hour, cast('2020-03-16 07:04:34' as timestamp), CURRENT_TIMESTAMP) horas,
		datediff(minute, cast('2020-03-16 07:04:34' as timestamp), CURRENT_TIMESTAMP) minutos
	from rdb$database;

/*Datediff no es util en la práctica porque redondea*/
select datediff(year, -- No es mayor de edad aún
				cast('2006-12-26' as DATE),
              	cast('2024-10-11' as DATE)
              	) mayor_edad
	from rdb$database; 


/*11. Muestra la fecha, el día y el mes correspondientes a:
sumar al día de hoy 25 días, sumar al día de hoy 34 meses,
restar a la fecha ‘12/03/2021’ 17 años.*/
select DATEADD(25 day to current_date) dia_25,
		dateadd(34 month to current_date) meses_34,
		dateadd(-17 year to cast('12/03/2021' as date)) annos_17
	from rdb$database;
 
/*Ejemplo Datediff anterior pero funcionando bien*/
select DATEADD(18 year to cast('2006-12-26' as DATE)) <= cast('2024-10-11' as DATE), mayor_edad_a,
		DATEADD(-18 year to cast('2024-10-11' as DATE)) >= cast('2006-12-26' as DATE) mayor_edad_b
	from rdb$database;

/*12. Muestra el valor de PI, el redondeo a entero del número 123,6345
(hacia arriba, hacia abajo y el más cercano), trunca el numero 123,6345
a dos cifras decimales y a entero, redondea a 3 cifras decimales
el numero 123,6345*/
select pi() pi,
	   CEILING(123.6345) ceil_,
	   floor(123.6345) floor_,
	   trunc(123.6345,2) trunc_2,
	   trunc(123.6345) trunc_0,
	   round(123.6345) redondeo_0,
	   round(123.6345,3) redondeo_3
	from rdb$database;

/*Pruebas ceiling, floor y round*/
select CEILING(3.6) pA_ceiling_,
       CEILING(3.2) pB_ceiling_,
	   floor(3.6) pA_floor_,
	   floor(3.2) pB_floor_,
       round(3.6) pA_round_,
       round(3.2) pB_round_,
       CEILING(-3.6) nA_ceiling_,
       CEILING(-3.2) nB_ceiling_,
	   floor(-3.6) nA_floor_,
	   floor(-3.2) nB_floor_,
       round(-3.6) nA_round_,
       round(-3.2) nB_round_
	from rdb$database;
    
/*Ceil de dos decimales*/
select 2.799 + 0.75,
	   CEILING((2.799 + 0.75) * 100) / 100.00 redondeo_alza -- Se suman los decimales, 100.0 no valdría.
	from rdb$database;

/*13. Muestra el seno, coseno y tangente de 47 grados,
la raíz cuadrada de 325, el logaritmo en base 10 de 1000,
2 elevado a 5, el menor valor de 2,65,23,56, el signo del
número -234, el resto entero de dividir 123.233 entre 23.34.*/ 
select  SIN(47), cos(47), TAN(47),
		SQRT(325), LOG10(1000),
        POWER(2,5), minvalue(2,65,23,56),
        SIGN(-234), mod(123.233, 23.34)
    from rdb$database;

/*14. Muestra un número aleatorio, un número aleatorio entre 0 y 10,
un número aleatorio entre 12 y 24.*/


/*15. Muestra la cadena –cadena-, donde cadena tiene 15 caracteres
como cadena de longitud fija y como cadena de longitud variable.*/


/*16. Muestra el número de caracteres y el número de bytes de la cadena
‘Esta es la cadena’ si se usa el conjunto de caracteres
ISO8859-1 y el UTF-8. */


/*17. Muestra una cadena de 5 caracteres. Los caracteres deben ser
aleatorios entre el código 65 (A) y el 90 (Z).*/


/*18. Muestra para la cadena ‘Esta es la cadena’,
los primeros 4 caracteres, los últimos 3 caracteres,
el resultado de añadir el carácter ‘-‘ al final
para que la cadena sea de 30 caracteres, la posición de ‘ca’,
la cadena resultante de sustituir ‘es’ por ‘ssss’,
la cadena en mayúscula, la cadena en minúscula,
las caracteres que van desde la posición 7 a la 12. */


/*19. Muestra los valores correspondientes a la tabla de verdad de las
operaciones and y or, si 2 es mayor de 20, si dos es menor o igual a 20.*/


/*max y min de campos*/
select max(precio),
	   min(precio)
    from alquileres;

/*ASCII_CHAR y ASCII_VAL*/
select  ASCII_CHAR(65),
		ASCII_VAL('A')
	from rdb$database;
    
/*Prueba de Hash*/
select  hash('hola'),
		hash('Hola')
    from RDB$database;
    
/*Mostramos DNI y hash del DNI de los propietarios*/
select  NIF,
		hash(ASCII_CHAR(trunc(RAND()*25+97))||
        	 ASCII_CHAR(trunc(RAND()*25+97))||
             ASCII_CHAR(trunc(RAND()*25+97))||
             NIF)
	from propietarios;

/*Sacar la letra que está en la novena posición*/
select  NIF,
		right(left(NIF,9),1)
    from propietarios;
    
/*Muestra una cadena de 5 caracteres, ascii entre codigo 65 y 90*/

select  ASCII_CHAR(trunc(65 + rand() * (90-65))) ||
		ASCII_CHAR(trunc(65 + rand() * (90-65))) ||
		ASCII_CHAR(trunc(65 + rand() * (90-65))) ||
		ASCII_CHAR(trunc(65 + rand() * (90-65))) ||
		ASCII_CHAR(trunc(65 + rand() * (90-65))) cinto_letras
    from RDB$DATABASE;
    
/*Nombre de los reparadores en mayuscula*/
select  UPPER(nombre) nombre_mayuscula,
		lower(nombre) nombre_minuscula
	from reparadores;
    
/*Mayusculas y minusculas se usan para no tener problemas cuando uso 
las letras de forma mayuscula/minuscula de forma indiscriminada.*/
select *
	from REPARADORES
    where upper(nombre) = 'FELIPE';
    
/*Quiero que la base en reparaciones aparezca como Base:bbb99999.99*/

select 'Base:' || LPAD(cast(base as varchar(10)),11,' ')
	from reparaciones;
    
/*Prueba de overlay: Como seguridad en los nif de los inquilinos se
cambia los numeros de la posicion 5 a la 8 por '*' */
select overlay(nif placing '****' from 5)
	from propietarios;
    
/*Prueba de position: Poblacion en reparadores que tengan 'de'*/
select distinct poblacion
	from reparadores
    where position(' DE ' in upper(poblacion)) > 0;
    
/*Prueba de replace: En poblaciones cambiar las 'a' por 'e'*/
select replace(REPLACE(poblacion, 'a', 'e'),'A','E')
	from reparadores;

/*Reverse le da la vuelta a la cadena
detecta si una cadena es un palíndromo*/
select poblacion, REVERSE(poblacion)
	from reparadores;
    
select *
	from alquileres
    where precio=reverse(precio);

/*Prueba de substring: Queremos sacar la letra del nif de los propietarios,
suponiendo que está en la novena posicion*/
select nif, substring(nif from 9 for 1)
	from propietarios;
    
/*En base de las reparaciones sacar la parte decimal*/
select  base,
		right(base, 2) decimales,
        reverse(SUBSTRING(reverse(base) from 1 for 2)) decimales_2,
        SUBSTRING(base from POSITION('.' in base)+1 for 2)
	from reparaciones;
    
/*Prueba de TRIM*/
select  trim(trailing ' ' from CAST('Hola' as CHAR(20))) || ' buenas'
	from rdb$database;
    
/*prueba de TRIM(both)*/
select  'inicio ' || '     texto a limpiar     ' || ' fin' texto_sin_limpiar,
		'inicio ' ||
			trim(both ' ' from '     texto a limpiar     ') ||
        	' fin' texto_limpio
    from rdb$database;