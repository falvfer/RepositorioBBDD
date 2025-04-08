-- procedimiento almacenado ejecutable al que se pasa el nombre de una tabla y me 
-- devuelva el numero de registros que tiene la tabla. Se debe usar excute statement

--sin usar statement


-- no nos funciona porque el nombre de la tabla en el from
-- no puede ser una variable
set term ^;

create or alter procedure registrosTabla(tabla D_CADENA40)
		returns (numero D_ENTERO)
as
begin
   select COUNT(*) from :tabla
         into numero;

END^

set term ;^

-- para solucionarlo se define una sentencia y ejecuto la misma


set term ^;

create or alter procedure registrosTabla(tabla D_CADENA40)
		returns (numero D_ENTERO, resultado varchar(200))
as
declare sentencia varchar(200)='';
begin
   numero=-1;
   if (exists (select * from rdb$relations where rdb$relation_name=UPPER(:tabla))) then
       begin 
   		sentencia='select COUNT(*) from '||tabla ;
        execute statement sentencia into numero;
       end
	
   resultado=sentencia;
END^

set term ;^


execute procedure registrosTabla('camioneros');
execute procedure registrosTabla('inQUIlinos');


-- procedimiento almacenado seleccionable que nos devuelva los propietarios ordenados 
-- por un campo que se pasa como parametro

set term ^;

create or alter procedure listarPropietariosStatement(orden D_ENTERO)
       returns (id_propietario D_ID, nif d_nif, nombre d_cadena60,
                  direccion d_cadena80, poblacion D_CADENA40) --,
                 -- resultado varchar(500))
as
declare sentencia varchar(500);
begin
	sentencia=' select id_propietario, nif, nombre d_cadena,'||
              '         direccion, poblacion ' ||
              '      from propietarios '||
              '      order by '||orden ;
	--resultado=sentencia;
	for execute statement sentencia
         into id_propietario, nif, nombre,
                  direccion, poblacion 
       do
          suspend;           
END^

set term ;^     

select * from listarPropietariosStatement(3);
    
-- Insertar un inquilino con estatement
-- en Java se inserta igual

set term ^;
create or alter procedure insertarInquilinoPS1 (nif d_nif, nombre D_CADENA60,
                                                direccion D_CADENA80, poblacion D_CADENA40)
  returns(sentencia VARCHAR(250))                                                
as

begin
 sentencia = 'insert into inquilinos (nif, nombre, direccion, poblacion) values (''' ||
                                             nif  || ''',''' || 
                                             nombre || ''',''' || 
                                             direccion || ''',''' || 
                                             poblacion || ''');';
end^                                                
set term ;^

execute procedure insertarInquilinoPS1 ('1111', 'Julian', 'Calle Julian', 'Lugo');
    

select 'hola '' jjj'
	from RDB$DATABASE;