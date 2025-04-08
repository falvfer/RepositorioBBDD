/*Crear generadores de numero de alquiler por anio:
 - 2025 Empezamos por 1001*/
create sequence gen_alqui;

alter table ALQUILERES
	add id_alquiler_anio dentero default 0;
    
select * from alquileres;
    
update alquileres set id_alquiler_anio = 0;
commit;

-- Para el año 2025 poner la secuenciapara que comience por 1001
set generator GEN_ALQUI to 1000;

alter sequence GEN_ALQUI
	restart with 1000;

-- Insertar un alquiler con el generador
insert into alquileres(id_habitacion, id_inquilino, fecha_inicio, fecha_fin,
						precio, activo, id_alquiler_anio)
	values (2, 3, current_date, dateadd(6 month to current_date), 354.45,
            true, next value for GEN_ALQUI);
commit;