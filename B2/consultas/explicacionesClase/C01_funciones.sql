/*Crear una función (método) para calcular el factorial*/
set term ^;
create or alter function factorial (numero dentero) 
 	returns dentero
as
	declare resultado dentero =  1;
    declare contador dentero = 2;
begin
	while (contador <= numero) do
    begin
    	resultado = resultado * contador;
        contador = contador + 1;
 	end
	return resultado;
END^
set term ;^

/*Prueba factorial de 5*/
select factorial(5)
	from rdb$database;
    
/*Calcular el factorial de un numero que se piede por teclado*/
select factorial(:numero)
	from rdb$database;

/*Función que devuelve TRUE o FALSE en base a que el número que se le pasa
como parametro sea par o no*/
set term ^;
create or alter function par(numero DENTERO)
	returns d_bolean
as
BEGIN
	return MOD(numero,2) = 0;
/*  if (MOD(numero,2) = 0) then
    -- Sentencia única
    	return true;
    else
    -- Bloque de codigo {}
    begin
    	return false;
    end*/
END^
set term ;^
    
/*Función que devuelve el sumatorio de un número que se pasa como parámetro*/
set term ^;
create or alter function sumatorio(numero dentero)
	returns dentero
as
	declare cont dentero = 1;
    declare resultado dentero = 0;
BEGIN

	while (cont <= numero) do
    begin
    	resultado = resultado + cont;
        cont = cont + 1;
    end
	return resultado;
    
END^
set term ;^

-- Pruebas de sumatorio
select sumatorio(5)
	from RDB$DATABASE;

/*Función que devuelve el valor de Fibonacci de un número que se pasa como parámetro*/
set term ^;
create or alter function fibonacci(numero dentero)
	returns dentero
as
	declare cont dentero = 1;
    declare num1 dentero = 1;
    declare num2 dentero = 1;
BEGIN

	while (cont < numero) do
    begin
    
    	num1 = num1 + num2;
    	num2 = num2 + num1;
    
    	cont = cont + 2;
    end

	if (par(numero))
    then
    	return num1;
    else
    	return num2;

END^
set term ;^

-- Pruebas de fibonnaci
select id_alquiler, fibonacci(id_alquiler)
	from alquileres;

/*Función que dada una fecha devuelve una cadena, por ejemplo, para "2024-12-18"
devuelve 'miércoles, 18 de diciembre de 2024'*/
set term ^;
create or alter function fechaLarga(fecha d_fecha)
	returns d_cadena40
as
BEGIN
    
    return DECODE(extract(weekday from fecha),
                1, 'lunes', 2, 'martes', 3, 'miercoles', 4, 'jueves',
                5, 'viernes', 6, 'sabado', 0, 'domingo') || ', ' ||
           EXTRACT(day from fecha) || ' de ' ||
           DECODE(extract(month from fecha),
                1, 'enero', 2, 'febrero', 3, 'marzo', 4, 'abril', 5, 'mayo',
                6, 'junio', 7, 'julio', 8, 'agosto', 9, 'septiembre',
                10, 'octubre', 11, 'noviembre', 12, 'diciembre') || ' de ' ||
           EXTRACT(year from fecha);

END^
set term ;^

select fechaLarga(current_date)
	from RDB$DATABASE;

/*Funcion que calcula la potencia. Tiene dos parámetros
y hace que el primer parámetro se eleve al segundo.*/

set term ^;

create or alter function potencia(base dentero, exponente dentero)
	returns dentero
as
declare resultado dentero = 1;
declare cont dentero = 1;

begin
	if (exponente < 0) then
    	return 0;
    
    while (cont <= exponente) do
        BEGIN
        	resultado = resultado * base;
            
            cont = cont + 1;
        end
        
    return resultado;

end^
set term;^

select  potencia(3, 3),
		potencia(3, -2),
        potencia(23, 4),
        potencia(5, 1),
        potencia(20, 0)
	from rdb$database;

/*Funciones que acceden a campos de la base de datos*/

/*Función totalReparaciones: se le pasa id_reparador y el año,
lo cual nos devuelve el importe total de las reparaciones hechas por
el reparador en el año indicado. Devolver 0 en caso de que no se haya
hecho ninguna reparación*/

-- Usar ":id" y ":anno" para hacer referencia a la variable en la sentencia select