/*Consulta de clientes*/
select * from clientes;

/*Consulta de frutas*/
select * from frutas;

/*Ejemplo de primera salida*/
select 'Mi primera salida'
	from RDB$DATABASE;
    
/*Ejemplo de formula matemática*/
select 7*8, mod(24,9)
	from RDB$DATABASE;

/*Mostrar fecha del sistema, hora y el conjunto de ambas*/
select current_date fecha,
	CURRENT_TIME hora,
    CURRENT_TIMESTAMP FECHA_HORA
  from RDB$DATABASE;

/*Vamos a comprobar que la fecha es un número y como se incrementa con 1*/
select current_date + 2 fecha,
	CURRENT_TIME + 3 hora,
    CURRENT_TIMESTAMP + 2.5 FECHA_HORA
  from RDB$DATABASE;
  
/*Fecha del 3/enero/1424 y le vamos a sumar 7 días*/
select cast ('1424-01-03' as date) fecha1,
	    cast ('1424-01-03' as date) + 7 fecha2
    from RDB$DATABASE;