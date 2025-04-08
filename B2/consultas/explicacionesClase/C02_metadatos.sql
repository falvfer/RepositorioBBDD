/*Ejemplos con metadatos*/
select *
	from rdb$relations;

/*Creacion de la consulta.
Vista con los pisos y el nombre y nif del propietario*/
select pi.*, pi.nombre, pr.nif
	from pisos pi
    	inner join propietarios pr USING(id_propietario);

/*Creacion de la vista*/
create or alter view pisos_propietarios
as
select PI.*, pr.nombre, pr.NIF
    from pisos pi
    	inner join propietarios pr USING(id_propietario);

/*Prueba de la vista*/
select *
	from pisos_propietarios;

/*Ver las vistas de los usuarios*/
select RDB$RELATION_NAME
	from RDB$relations
    where rdb$relation_type = 1;
    
/*Ver todos los campos declarados*/
select *
	from RDB$RELATION_FIELDS;

/* Campos que son creados por usuarios, no son del sistema */
select *
	from RDB$RELATION_FIELDS
    where RDB$SYSTEM_FLAG = 0;
    
/* Campos que son creados por usuarios, no son del sistema, pero que sean
solo de vistas */
select rf.rdb$relation_name, rf.RDB$FIELD_NAME
	from RDB$RELATION_FIELDS rf
		inner join rdb$relations r using(rdb$relation_name)
	where r.RDB$RELATION_TYPE = 1;

/*Número de campos de cada una de las tablas del usuario, no quiero vistas,
solo tablas*/
select RDB$RELATION_NAME, count(*) num_campos
	from RDB$RELATION_FIELDS rf
		inner join rdb$relations r using(rdb$relation_name)
    where r.RDB$SYSTEM_FLAG = 0 and r.RDB$RELATION_TYPE = 0
    group by 1;
    
/*Dominios que ha creado el usuario*/
select *
	from rdb$fields
    where RDB$SYSTEM_FLAG = 0;
    
/*Utilizando :nombre_tabla en la sentencia select:
sacar todos los campos de la tabla junto con el nombre de su dominio
y su tipo base*/
select rf.RDB$FIELD_NAME, f.RDB$FIELD_NAME, f.RDB$FIELD_TYPE, f.RDB$FIELD_LENGTH
	from RDB$RELATION_FIELDS rf
    	inner join rdb$fields f on rf.RDB$FIELD_SOURCE = f.RDB$FIELD_NAME
    where rf.RDB$RELATION_NAME = upper(:nombre_tabla);

/*Indices de la tabla alquileres*/
select *
	from RDB$INDICES
    where rdb$relation_name = 'ALQUILERES';

create index i_alquileres on alquileres (fecha_inicio, fecha_fin);