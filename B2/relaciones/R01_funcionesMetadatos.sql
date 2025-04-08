/*1. Función que devuelva el numero total de tablas del sistema*/
set term ^;
create or alter function tablasSistema()
	returns DENTERO
as
	declare totalTablas DENTERO;
BEGIN

select COUNT(*)
    from rdb$relations
    where RDB$RELATION_TYPE = 0
      and RDB$SYSTEM_FLAG = 1
    into totalTablas;

return totalTablas;

END^
set term ;^

select tablasSistema() from rdb$database;

/*2. Función que devuelva las tablas creadas por usuario.*/

set term ^;
create or alter function tablasUsuario()
	returns DENTERO
as
	declare totalTablas DENTERO;
BEGIN

select COUNT(*)
    from rdb$relations
    where RDB$RELATION_TYPE = 0
      and RDB$SYSTEM_FLAG = 0
    into totalTablas;

return totalTablas;

END^
set term ;^

select tablasUsuario() from rdb$database;

/*3. Función que devuelva el numero de campos de una tabla que
se pasa como parámetro.*/
set term ^;
create or alter function numCampos(tabla D_CADENA20)
	returns DENTERO
as
	declare totalCampos DENTERO;
BEGIN

select count(*)
	from rdb$relation_fields
    where RDB$RELATION_NAME = upper(:tabla)
    into totalCampos;

return totalCampos;

END^
set term ;^

select numCampos('alquileres') from rdb$database;

/*4. Función que se le pasa el nombre de un campo y devuelve el
numero de tablas en que aparece.*/
set term ^;
create or alter function numTablasConCampo(campo D_CADENA20)
	returns DENTERO
as
BEGIN

return (select count(*)
            from rdb$relation_fields
            where RDB$FIELD_NAME = upper(:campo));

END^
set term ;^

select numTablasConCampo('rdb$system_flag') from rdb$database;

/*5. Función que devuelve verdadero o falso en base a que el
parámetro que se le pasa es una tabla del sistema.*/
set term ^;
create or alter function esTablaDelSistema(tabla D_CADENA20)
	returns boolean
as
BEGIN

return exists
	(select *
        from rdb$relations
        where RDB$relation_name = upper(:tabla)
          and RDB$SYSTEM_FLAG = 1);

END^
set term ;^

select esTablaDelSistema('rdb$relations') from RDB$DATABASE;

/*6. Función que se le pasa como parámetros una  tabla y un
campo y devuelve ‘no existe’ si la tabla o el campo no existen
o una cadena en castellano en base al tipo numérico de dicho campo.*/
set term ^;
create or alter function tipoDeDominio(tabla D_CADENA20, campo D_CADENA20)
	returns d_cadena20
as
	declare tipo dentero;
BEGIN

	tipo = (select f.RDB$FIELD_TYPE
            from rdb$relation_fields rf
                inner join rdb$fields f on rf.RDB$FIELD_SOURCE = f.RDB$FIELD_NAME
            where rf.RDB$relation_name = upper(:tabla)
              and rf.RDB$FIELD_NAME = upper(:campo));
    
    return decode(tipo,
        261, 'Blob', 14, 'Cadena', 27, 'Doble', 10, 'Flotante', 16, 'Entero grande',
        8, 'Entero', 7, 'Entero pequenno', 12, 'Fecha', 13, 'Hora',
        35, 'Fecha y Hora', 37, 'Cadena variable', 23, 'Booleano', 'Desconocido');

END^
set term ;^

select  tipoDeDominio('alquileres', 'fecha_inicio') fechaIni_alquileres,
		tipoDeDominio('alquileres', 'precio') precio_alquileres,
        tipoDeDominio('rdb$relations', 'rdb$relation_name') relName_rdb$relations,
        tipoDeDominio('rdb$relations', 'rdb$field_name') fieldName_rdb$relations
	from RDB$DATABASE;

/*7. Función que devuelva el nombre de la primary de una tabla
que se pasa como parametro. En caso de no existir la tabla o la
primary key devolverá ‘no existe primary key para parametro_de_entrada’*/
set term ^;
create or alter function pkDeTabla(tabla D_CADENA40)
	returns d_cadena40
as
BEGIN

	return COALESCE(
    	(select RDB$CONSTRAINT_NAME
            from RDB$RELATION_CONSTRAINTS
            where RDB$RELATION_NAME = upper(:tabla)
              and RDB$CONSTRAINT_TYPE = 'PRIMARY KEY'), 'no existe');

END^
set term ;^

select pkDeTabla('alquileres') from rdb$database;

/*8. Función que cuente el numero de claves foráneas que tiene
una tabla que se pasa como parámetro.*/
set term ^;
create or alter function fkDeTabla(tabla d_cadena40)
	returns DENTERO
as
BEGIN

	return (select count(*)
            from RDB$RELATION_CONSTRAINTS
            where RDB$RELATION_NAME = upper(:tabla)
              and RDB$CONSTRAINT_TYPE = 'FOREIGN KEY');

END^
set term ;^

select fkDeTabla('alquileres') from rdb$database;

/*9. Función que se le pasa como parámetro una tabla y nos
devuelve el numero de triggers de dicha tabla.*/
set term ^;
create or alter function fkDeTabla(tabla d_cadena40)
	returns DENTERO
as
BEGIN

	select count(*)
    	from rdb$triggers;
        

END^
set term ;^

/*10. Función que comprueba si un dominio que se pasa como
parámetro existe o no.*/


/*PROCEDIMIENTOS ALMACENADOS*/

/*Procedimiento almacenado que devuelva dirección y población de un propietario indicado*/

set term ^;
create or alter procedure devolverDatos(id_propietario D_ID)
	returns (direccion d_cadena80, poblacion d_cadena40)
as
begin

	select direccion, poblacion
    	from propietarios
        where id_propietario = :id_propietario
        into direccion, poblacion;

END^
set term ;^

execute procedure devolverDatos(3);