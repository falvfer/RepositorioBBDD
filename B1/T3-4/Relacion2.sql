select;
/*Lista Expresiones regulares, predicados y funciones.*/
/* suponemos que tenemos una nota numerica entera :
menor que uno y mayor que 10 error
    1 MD
    2 MD
    3 INS
    4 INS
    5 SUF
    6 SUF
    7 BIEN
    8 NOT
    9 SOB
    10 MH */

SELECT case mod(extract (day from current_date), 11)
		when 1 then 'Muy Deficiente'
        when 2 then 'Muy Deficiente'
        when 3 then 'Insuficiente'
        when 4 then 'Insuficiente'
        when 5 then 'Suficiente'
        when 6 then 'Suficiente'
        when 7 then 'Bien'
        when 8 then 'Notable'
        when 9 then 'Sobresaliente'
        when 10 then 'Matricula de Honor'
        else  'Nota erronea'
       end nota_por_valor,
       case 
		when mod(extract (day from current_date), 11) < 3
         and mod(extract (day from current_date), 11) >=0
             then 'Muy Deficiente'
        when mod(extract (day from current_date), 11) >= 3
         and mod(extract (day from current_date), 11) < 5
             then 'Insuficiente'
        when mod(extract (day from current_date), 11) >= 5
         and mod(extract (day from current_date), 11) < 7
             then 'Suficiente'
        when mod(extract (day from current_date), 11) = 7 then 'Bien'
        when mod(extract (day from current_date), 11) = 8 then 'Notable'
        when mod(extract (day from current_date), 11) = 9 then 'Sobresaliente'
        when mod(extract (day from current_date), 11) = 10 then 'Matricula de Honor'
        else  'Nota erronea'
       end nota_por_posicion
  from rdb$database; 

/*En alquileres quiero que la fecha de inicio aparezca como
"Viernes 18 de octubre del 2024"*/
select fecha_inicio,
		case extract(WEEKDAY from fecha_inicio)
            when 1 then 'Lunes '      when 2 then 'Martes ' 
            when 3 then 'Miércoles '  when 4 then 'Jueves ' 
            when 5 then 'Viernes '    when 6 then 'Sábado ' 
            when 0 then 'Domingo ' 
            else '(ERROR, DIA INCORRECTO) '
        end ||
        extract(day from fecha_inicio) ||
        ' de ' ||
        case extract(month from fecha_inicio)
            when 1 then 'enero'       when 2 then 'febrero'
            when 3 then 'marzo'       when 4 then 'abril'
            when 5 then 'mayo'        when 6 then 'junio'
            when 7 then 'julio'       when 8 then 'agosto'
            when 9 then 'septiembre'  when 10 then 'octubre'
            when 11 then 'noviembre'  when 12 then 'diciembre'
            else '(ERROR, MES INCORRECTO)'
        end ||
        ' del ' ||
        extract(year from fecha_inicio) formato_fecha 
	from alquileres;

/*Prueba de coalesce: Los alquileres nulos se consideran que valen -100
sacar todos los campos*/
select  id_alquiler, id_habitacion, id_inquilino, fecha_inicio, fecha_fin,
		COALESCE(precio * 1.21, -100) precio_A,
		COALESCE(precio, -100) * 1.21 precio_B,
        activo
	from alquileres;

/*Prueba nullif: En el proceso de gestión pasado he supuesto que el precio de los alquileres
nulos o desconocidos lo he puesto como 0 y ahora quiero recuperarlos,
recuperar ese nulo*/
select id_alquiler, id_habitacion, id_inquilino, fecha_inicio, fecha_fin,
		precio, NULLIF(precio, 0) precio_nullif, activo
    from alquileres;

/*Prueba iif: Todos los precios de alquileres a 0 o negativos son realmente nulos.
Mostrar todos los datos de alquileres*/
select  id_alquiler, id_habitacion, id_inquilino, fecha_inicio, fecha_fin,
		precio, IIF(precio <= 0, NULL, precio)precio_iif, activo
    from alquileres;
    
/*Prueba decode: En alquileres quiero que la fecha de inicio aparezca como
"Viernes 18 de octubre del 2024"*/
select fecha_inicio,
		DECODE(extract(WEEKDAY from fecha_inicio),
        	1,'Lunes',   2,'Martes',   3,'Miércoles',
            4,'Jueves',  5,'Viernes',  6,'Sábado', 
            0,'Domingo',
            'ERROR') ||
        ' ' ||
        extract(day from fecha_inicio) ||
        ' de ' ||
		decode (extract(month from fecha_inicio),
            1,'enero',     2,'febrero',     3,'marzo',
            4,'abril',     5,'mayo',        6,'junio',
            7,'julio',     8,'agosto',      9,'septiembre',
            10,'octubre',  11,'noviembre',  12,'diciembre',
            'ERROR') ||
        ' del ' ||
        extract(year from fecha_inicio) formato_fecha 
	from alquileres;

/*Prueba predicado between: Alquileres que se iniciaron en
el año 2021 o el 2022*/
select *
	from alquileres
    where fecha_inicio between '2021-01-01' and '2022-12-31';

/*Prueba predicado in: Propietarios que viven en
Loja , Archidona, Granada o Teba*/
select *
	from PROPIETARIOS
    where lower(poblacion) in('loja','archidona','granada','teba');
    
	/*Propietarios que viven en poblaciones de reparadores*/
    select *
        from PROPIETARIOS
        where poblacion in(select distinct poblacion
                               from reparadores);
                               
/*Prueba predicado containing: Datos de los propietarios cuyas poblaciones
contengan 'que'*/
select *
	from propietarios
    where lower(poblacion) CONTAINING 'que';
    
/*Prueba predicado like: Ejemplo anterior*/
select *
	from propietarios
    where lower(poblacion) like '%que__';


/*1. Listar los datos del alquileres y junto al precio los siguientes valores:
       error si es negativo
       gratis si es cero
       barato si vale menos de 200€
       normal entre 200 y 300€
       caro en el resto de los casos.*/
select  id_alquiler, id_habitacion, id_inquilino, fecha_inicio, fecha_fin,
		precio,
        case 
          when precio<0 then 'Error'		when precio=0 then 'Gratis'
          when precio<200 then 'Barato'	when precio<=300 then 'Normal'
          else 'Caro'
        end precio_B, activo
	from alquileres;
    
/*2. En las Reparaciones los porcentajes IVA negativos o 0 se consideran
nulos. Mostrar reparaciones de venta con su iva positivo y nulo.*/   
select  id_reparacion, id_piso, id_reparador, fecha, base,
		iif(iva_por<=0, null, iva_por) iva_null, importe
	from reparaciones;

/*3. Comprobar que propietarios tienen un nif con el formato:
       a) 9 números y una letra mayúscula. 
       b) 9 números y una letra (de dos formas)
       c) Los que tienen menos de 5 caracteres.*/
select  id_propietario, nif,
		case
          when nif similar to '[1-9]{9}[A-Z]' then 'Cadena de 10'
          when nif similar to '[1-9]{8}[A-Z]' then 'Cadena de 9'
          when nif similar to '[1-9]{0,5}[A-Z]' then 'Cadena de 5 o menos'
          else 'DNI NO VALIDO'
        end nif_B, nombre, direccion, poblacion
	from propietarios;
     
/*4. Hay reparaciones con id_'reparacion' (no hay id_ventas) a null,
mostrar todas las lineas de venta cambiando este null por un 0.*/
select  coalesce(id_reparacion, 0) id_reparacion,
		id_piso, id_reparador, fecha, base, iva_por, importe
    from reparaciones;

/*5. Generar una expresión regular que filtre números de teléfono
con el formato: "999-999-999"*/
select  '683-235-341' similar to '[1-9]{3}\-[1-9]{3}\-[1-9]{3}' escape '\',
		'ds-235-341' similar to '[1-9]{3}\-[1-9]{3}\-[1-9]{3}' escape '\'
	from rdb$database;

/*6. Generar una expresión regular que filtre números de teléfono
con el formato: "999\999\999"*/
select  '683\235\341' similar to '[1-9]{3}\\[1-9]{3}\\[1-9]{3}' escape '\',
		'sd\235\341' similar to '[1-9]{3}\\[1-9]{3}\\[1-9]{3}' escape '\'
	from rdb$database;

/*7. Inquilinos cuya población comience por G, de distintas formas.*/
select *
	from inquilinos
    where poblacion starting with 'G';
select *
	from inquilinos
    where poblacion like 'G%';
select *
	from inquilinos
    where left(poblacion, 1) = 'G'; 
select *
	from inquilinos
    where poblacion similar to 'G%';

/*8. Propietarios cuya población no empiece por A sin usar not.*/    
select *
	from PROPIETARIOS
    where poblacion similar to '[^Aa]%';
select *
	from PROPIETARIOS
    where poblacion similar to '[B-Zb-z]%';


/*9. Reparadores cuya población contenga la palabra "de" de varias formas*/
select *
	from reparadores
    where poblacion containing ' de ';
/*Con like*/
select *
	from reparadores
    where lower(poblacion) like '% de %';
/*Con similar to*/
select *
	from reparadores
    where lower(poblacion) similar to '% de %';

/*10. Expresión regular para un correo electrónico como entre 1..30 (letras
números), una arroba 1..15 (letras números) un punto y 1..3 (letras)*/
select 'correo123@gmai23.coe' similar to '[A-Za-z0-9.\-\_]{1,30}@[A-Za-z0-9.\-\_]{1,15}.[A-Za-z]{2,5}' escape '\'
	from rdb$database;



/*Poblaciones que empiezan por A y por L en reparadores*/
select distinct poblacion
	from REPARADORES
    where poblacion similar to '[ALal]%';
    
/*Poblaciones que empiezan por una letra entre A y L en reparadores*/
select distinct poblacion
	from REPARADORES
    where poblacion similar to '[^A-L]%';

/*Prueba "similar to": Haz la expresion regular que cumpla con el formato de
matriculas de coches: 4 numeros, un guión y 3 letras mayusculas sin vocales*/
select  '2341-DSW' similar to '[[:DIGIT:]]{4}\-[A-Z^AEIOU]{3}' escape '\',
		'2341-AEW' similar to '[[:DIGIT:]]{4}\-[A-Z^AEIOU]{3}' escape '\',
        '23A1-DSW' similar to '[[:DIGIT:]]{4}\-[A-Z^AEIOU]{3}' escape '\',
        '2341-1SW' similar to '[[:DIGIT:]]{4}\-[A-Z^AEIOU]{3}' escape '\',
        '234-DSW' similar to '[[:DIGIT:]]{4}\-[A-Z^AEIOU]{3}' escape '\',
        '2341DSW' similar to '[[:DIGIT:]]{4}\-[A-Z^AEIOU]{3}' escape '\',
        '2341-SW' similar to '[[:DIGIT:]]{4}\-[A-Z^AEIOU]{3}' escape '\'
	from RDB$DATABASE;
    
/*Prueba "similar to": Haz la expresion regular que cumpla con el formato
de matriculas AA-9999-A[A]*/
select  'SD-2345-WF' similar to '[A-Z^AEIOU]{1,2}\-[[:DIGIT:]]{4}\-[A-Z^AEIOU]{1,2}' escape '\',
		'FW-2341-A' similar to '[A-Z^AEIOU]{1,2}\-[[:DIGIT:]]{4}\-[A-Z^AEIOU]{1,2}' escape '\',
        'A-2323-SW' similar to '[A-Z^AEIOU]{1,2}\-[[:DIGIT:]]{4}\-[A-Z^AEIOU]{1,2}' escape '\',
        '1D-2341-W' similar to '[A-Z^AEIOU]{1,2}\-[[:DIGIT:]]{4}\-[A-Z^AEIOU]{1,2}' escape '\'
	from RDB$DATABASE;
    
/*Prueba "similar to": Mezcla los dos anteriores*/
select  /**/ 'SD-2345-WF' similar to '([[:DIGIT:]]{4}\-[A-Z^AEIOU]{3})|([A-Z^AEIOU]{1,2}\-[[:DIGIT:]]{4}\-[A-Z^AEIOU]{1,2})' escape '\',
		/**/ '2341-DDS' similar to '([[:DIGIT:]]{4}\-[A-Z^AEIOU]{3})|([A-Z^AEIOU]{1,2}\-[[:DIGIT:]]{4}\-[A-Z^AEIOU]{1,2})' escape '\',
        	 '2323-W' similar to '([[:DIGIT:]]{4}\-[A-Z^AEIOU]{3})|([A-Z^AEIOU]{1,2}\-[[:DIGIT:]]{4}\-[A-Z^AEIOU]{1,2})' escape '\',
             'SA-2341-W' similar to '([[:DIGIT:]]{4}\-[A-Z^AEIOU]{3})|([A-Z^AEIOU]{1,2}\-[[:DIGIT:]]{4}\-[A-Z^AEIOU]{1,2})' escape '\',
        /**/ 'S-2341-WD' similar to '([[:DIGIT:]]{4}\-[A-Z^AEIOU]{3})|([A-Z^AEIOU]{1,2}\-[[:DIGIT:]]{4}\-[A-Z^AEIOU]{1,2})' escape '\',
        	 'SD-2D41-WD' similar to '([[:DIGIT:]]{4}\-[A-Z^AEIOU]{3})|([A-Z^AEIOU]{1,2}\-[[:DIGIT:]]{4}\-[A-Z^AEIOU]{1,2})' escape '\',
        	 '2341-A1W' similar to '([[:DIGIT:]]{4}\-[A-Z^AEIOU]{3})|([A-Z^AEIOU]{1,2}\-[[:DIGIT:]]{4}\-[A-Z^AEIOU]{1,2})' escape '\',
        	 '2341-' similar to '([[:DIGIT:]]{4}\-[A-Z^AEIOU]{3})|([A-Z^AEIOU]{1,2}\-[[:DIGIT:]]{4}\-[A-Z^AEIOU]{1,2})' escape '\',
        /**/ 'SD-2341-W' similar to '([[:DIGIT:]]{4}\-[A-Z^AEIOU]{3})|([A-Z^AEIOU]{1,2}\-[[:DIGIT:]]{4}\-[A-Z^AEIOU]{1,2})' escape '\'
	from RDB$DATABASE;
    
/*La matriculo de AA-9999-AA para las provincias andaluzas (AL, CA, CO, H, GR, J, MA, SE*/
select  'AL-2345-WF' similar to '(AL|CA|CO|H|GR|J|MA|SE)\-[[:DIGIT:]]{4}\-[A-Z^AEIOU]{1,2}' escape '\',
		'H-2341-S' similar to '(AL|CA|CO|H|GR|J|MA|SE)\-[[:DIGIT:]]{4}\-[A-Z^AEIOU]{1,2}' escape '\',
        'IO-2323-SW' similar to '(AL|CA|CO|H|GR|J|MA|SE)\-[[:DIGIT:]]{4}\-[A-Z^AEIOU]{1,2}' escape '\',
        'SE-2341-W' similar to '(AL|CA|CO|H|GR|J|MA|SE)\-[[:DIGIT:]]{4}\-[A-Z^AEIOU]{1,2}' escape '\'
	from RDB$DATABASE;
    
/* Más pruebas de "similar to"
'A|L%' no funciona: "A" o "L%"
'(A|L)%' si funciona: "A%" o "L%" 
'[A-Za-z]*' se repite 0 o más veces
'[A-Za-z]?' puede estar o no (0 o 1)
'[A-Za-z]+' tiene que estar una o más veces
'[A-Za-z]{5}' estar exactamente 5 veces
'[A-Za-z]{3,}' estar 3 veces o más
'[A-Za-z]{2,5}' estar entre 2 y 5 veces
(similar to '3\+4' escape '\') tiene que coincidir que sea "3+4"

*/

/*Filtrar los propietarios con NIF antiguo 8 números y una letra*/
select *
	from propietarios
    where nif similar to '[[:digit:]]{8}[[:alpha:]]';