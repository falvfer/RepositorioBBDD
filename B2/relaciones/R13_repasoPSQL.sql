/*---------------------------------------FUNCIONES-----------------------------------*/

/*Crear la funcion operar a la que se le pasa tres numeros (oper, min y max)
y devuelve un numero entro de forma que
    si oper = 1 --> Devuelve la suma de todos los numeros que van entre min y max
    si oper = 2 --> Suma los numeros pares y le resto la suma de los numeros impares
                    entre el min y max. Devuelvo el resultado.
    si oper = lo que sea --> Devuelvo el numero de numeros que hay entre max y min */
-- Sentencias básicas


/*Crear la funcion maximo al que se le pasa un id de habitacion y nos devuelve
el id maximo del alquiler de esa habitacion*/
-- Cursor simple


/*Crear la funcion media_importe al que se le pasa un id de habitacion y nos devuelve
el precio medio de los alquileres de esa habitacion. Debe hacerse recorriendo todos
los alquileres de esa habitacion (no usar avg)*/
-- Cursor for select


/*Crear la funcion media_importe_mayores al que se le pasa un id de piso y devuelve
el precio medio de los alquileres del piso que tienen un precio mayor al importe
indicado. El precio se debe comprobar en el cuerpo del cursor*/



/*---------------------PROCEDIMIENTOS ALMACENADOS SELECCIONABLES----------------------*/
/*Crear el procedimiento almacenado datoscortosinquilinos que me devuelve
id_inquilino, nif y nombre de todos los inquilinos. Usar un cursor.*/


/*Crear el procedimiento almacenado datosgeneralesinquilinos al que se le pasa
una poblacion y que devuelve n_orden, id_inquilino, nombre, direccion,poblacion
de los inquilinos de la poblacion indicada. n_orden es un autonumerico que
deberemos indicar empezando por 1*/


/*Crear el procedimiento almacenado datos_inquilino_alquiler al que se le pasa
dos numeros (id_ini e id_fin) y que devuelve id_inquilino, nombre_inquilino,
fecha_inicio_alquiler y precio_alquiler de todos los alquileres de los
inquilinos con id entre id_ini e id_final. Se deben usar dos cursores,
uno para los inquilinos y otro para los alquileres*/