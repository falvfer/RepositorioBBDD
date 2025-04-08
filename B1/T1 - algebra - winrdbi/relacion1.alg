% listado de pisos
     %pisos;

% listado de pisos con nombre
% da un nombre a una consulta y puede renombrar una tabla
     %pisos_nombre := pisos;

%Introducción _________________________________________________________________________________________
     % 1. Muestra todos los datos de la relación inquilinos
          %inquilinos;

     % 2. Muestra todos los datos de la relación alquileres
          %mis_alquileres := alquileres;

     % 3. Muestra todos los datos de la relación reparaciones con el campo importe llamado importetotal.
          %mis_reparaciones(id_reparacion, nif, id_piso, importetotal) := reparaciones;

     % 4. Muestra todos los datos de la relación alquileres denominándola alquiler y cambiando el nif a nifpropietario.
          %alquiler(id_alquiler, nifpropietario, id_piso, precio) := alquileres;

     % 5. Mostrar los datos de la tabla  alquileres cambiando el nombre de la columna precio por  importe
          %alquiler(id_alquiler, nif, id_piso, importe) := alquileres;

     % 6. Mostrar los datos de la tabla reparadores cambiando añadiendo al nombre de cada columna el sufijo reparador.
          %reparador(nif_reparador, nombre_reparador, direccion_reparador, poblacion_reparador) := reparadores;

% Proyección _________________________________________________________________________________________
     % listado de poblaciones de los reparadores
          %listado_poblaciones_reparadores := project poblacion (reparadores);

     % 7. Muestra las direcciones de los propietarios
          %direcciones_propietarios := project direccion (propietarios);
               % version alternativa
               %direcciones_propietarios_2 := project nombre, direccion (propietarios);

     % 8. Muestra las nombres diferentes de los reparadores
          %ej8 := project nombre (reparadores);

     % 9. Muestra las poblaciones diferentes de los inquilinos.
          %ej9 := project poblacion (inquilinos);

     % 10. Muestra el nif de los propietarios que tienen pisos.
          %ej10 := project nif (pisos);

     % 11. Muestra todos los datos menos el  nif de la tabla reparadores.
          %ej11 := project nombre, direccion, poblacion (reparadores);

     % 12. Muestra el nombre de los propietarios llamando a la columna resultante nombre_propietarios.
          %ej12(nombre_propietarios) := project nombre (propietarios);

     % 13. Muestra la dirección y el precio de los pisos, llamándolas direccion_piso y precio_piso
          %ej13(direccion_piso, precio_piso) := project direccion, precio (pisos);

% Selección _________________________________________________________________________________________
     % 14. Muestra los datos de los reparadores que no son de Malaga.
          %reparadores_noMalaga := select (poblacion<>'Malaga') (reparadores);

     % 15. Muestra los datos de los reparadores cuyo nif están entre el nif3 y nif2889. ¿Qué pasa? Y ¿Por qué?
          %ej15 := select (nif>'nif3') and (nif<'nif2889') (reparadores);
               %no muestra nada ya que el programa para ver si es menor o mayor va mirando por caracter, al buscar que sea mayor que 3
               %como los nif empiezan por 1 entonces los ve como si fueran menor de 'nif30', y por ese motivo no sale nada
               %para arreglar esto habría que modificar los nif para que tengan este formato 'nif0010', y mirar que sea mayor que 'nif0003'.

     % 16. Muestra los datos de las reparadores de Antequera cuyo nif es mayor de nif2
          %ej16 := select (poblacion='Antequera') and (nif>'nif2') (reparadores);
               %pasa como el ejercicio 15, el problema es el formato del nif.

     % 17. Muestra los datos de las alquileres cuyo importe supera de 300€
          %ej17 := select (precio>300) (alquileres);

     % 18. Muestra los datos de las reparaciones cuyo importe es menor o igual a 150€  o el id de la reparación es mayor de 4.
          %ej18 := select (importe<=150) or (id_reparacion>4) (reparaciones);

     % 19. Muestra los datos de las alquileres que se han hecho con un precio superior a 300 o inferior a 200.
          %ej19 := select (precio>300) or (precio<200) (alquileres);

     % 20. Muestra los reparaciones con id_reparación par, cuyo importe suba los 250€. Cambiando el nombre del campo importe por totales.
           %ej20(id_reparacion, nif, id_piso, totales) := select (mod(id_reparacion,2)=0) and (importe>250) (reparaciones);
%No se puede hacer con las herramientas que proporciona esta aplicación.

% Combinación anterior _________________________________________________________________________________________
     % 21. Muestra la dirección de reparadores antequeranos.
          %ej21 := project direccion (select (poblacion='Antequera') (reparadores));

     % 22. Muestra el nombre y población de las propietarios cuyo nombre sea menor que ‘j’.
          %ej22 := project nombre, poblacion (select (nombre<'J') (propietarios));
               %Tecnicamente pide j minuscula pero es incorrecto, ya que todos los nombres empiezan por una letra mayuscula, y en orden ascci las mayusculas van primero que las minusculas, por lo que se van a mostrar todos los nombres
               %ej22b := project nombre, poblacion (select (nombre<'j') (propietarios));

     % 23. Muestra el nombre y población de las inquilinos que no son de Antequera o Loja
          %ej23 := project nombre, poblacion (select (poblacion<>'Antequera') and (poblacion<>'Loja') (inquilinos));
               %Tecnicamente se está pidiendo lo siguiente, ya que pone "Antequera o Loja", por lo que tendría que decir "ni" para que sea correcto, dando el anterior resultado.
               %ej23b := project nombre, poblacion (select (poblacion<>'Antequera') or (poblacion<>'Loja') (inquilinos));

     % 24. Muestra el nombre de las reparadores que son de Malaga o de Loja y su nombre empieza a partir de la ‘L’.
          %ej24 := project nombre (select ((poblacion='Loja') or (poblacion='Malaga')) and (nombre>='L' and nombre<'M') (reparadores));

     % 25. Muestra la población de los reparadores (cambia el nombre del campo a nombre_reparador) viven en Archidona y su nombre empieza por V.  
          %ej25(nombre_reparador) := project poblacion (select (poblacion='Archidona') and (nombre>='V') and (nombre<'W') (reparadores));
               %Tecnicamente esta consulta tiene un funcionamiento escaso, solo sirve para confirmar si hay un reparador con los requisitos dados (vive en archidona y su nombre empieza por v), y nada más,
               %da igual si hay más de 1, no cambia el resultado, solo cambia si hay o no hay, dando una tabla vacia o una tabla solamente con una celda llamada 'Archidona'

% Producto cartesiano. _________________________________________________________________________________________
%Ejercicio de tamaño
%Tabla A = 1000 registros y 1k con 5 campos = 1000*1024=1000000=1M (aprox)
%Tabla B = 2000 registros y 2k con 10 campos = 2000*2048=4000000=4M (aprox)
%Producto Cartesiano = (2000*1000) registros * 15 campos(3072)=2000000*3072=6144000000 = 6G (aprox)

% Definir la relaciones propietariosn, inquilinosn, reparadoresn y pisosn a partir de sus homólogos añadiendo en sufijo p, i,r y p respectivamente al final de cada uno de sus campos.
     %propietariosn(p_nif, p_nombre, p_direccion, p_poblacion) := propietarios;
     %inquilinosn(i_nif, i_nombre, i_direccion, i_poblacion) := inquilinos;
     %reparadoresn(r_nif, r_nombre, r_direccion, r_poblacion) := reparadores;
     %pisosn(pi_id_piso, pi_nif, pi_direccion, pi_precio) := pisos;

     % 26. Mostrar todas las posibles combinaciones entre  inquilinosn y pisosn.
          %ej26 := (inquilinosn) product (pisosn);

     % 27. Mostrar parejas de nombres de propietarios y reparadores.
          %ej27 := (project p_nombre (propietariosn)) product (project r_nombre (reparadoresn));

     % 28. Mostrar propietario_nombre, inquilino_poblacion, inquilino_nombre y propietario_población de las relaciones correspondientes.
          %ej28 := (project p_nombre, p_poblacion (propietariosn)) product (project i_poblacion, i_nombre (inquilinosn));

     % 29. Mostrar los nombre y los nif de los propietarios y reparadores que sean de la misma población.
          %ej29 := project p_nif, p_nombre, r_nif, r_nombre (select (p_poblacion=r_poblacion) ((propietariosn) product (reparadoresn)));

     % 30. Mostrar los pisos con los datos de sus propietarios.
          %ej30 := select (pi_nif=p_nif) ((pisosn) product (propietariosn));
               %Forma adicional de hacerlo
               %ej30b := project pi_id_piso, p_nif, p_nombre, p_direccion, p_poblacion (select (pi_nif=p_nif) ((pisosn) product (propietariosn)));
          

% Natural join _________________________________________________________________________________________
% A partir de las tablas originales (renombra columnas cuando veas que es necesario) 
     % 31. Muestra los datos de la reparaciones, piso y reparador.
          %Renombrar todas las columnas para evitar problemas y que quede claro en la relación final de donde viene cada columna
               %reparador(nif_reparador, nombre_reparador, direccion_reparador, poblacion_reparador):= (reparadores);
               %piso(id_piso, nif_propietario, direccion_piso, precio_piso):=(pisos);
               %reparacion(id_reparacion,nif_reparador,id_piso,importe_reparacion):=(reparaciones);
          %njoin
               %ej31:=piso njoin (reparador njoin reparacion);

     % 32. Muestra los datos del piso y su propietario.
          %prop1(nif, nombre, pr_direccion, poblacion) := propietarios;
          %ej32 := pisos njoin prop1;
               %Parte 2: Mostrar solo los propietarios que tienen pisos.
               %ej32b := project nombre (ej32);

     % 33. Muestra los datos de los propietarios antequeranos junto a sus pisos.
          %Renombrar para que no de problemas y sea legible a posteriori en la relacion final.
               %propietario(nif, nombre, direccion_propietario, poblacion) := select (poblacion='Antequera') (propietarios);
               %piso(id_piso, nif, direccion_piso, precio) := (pisos);
          %njoin
               %ej33 := propietario njoin piso;


     % 34. Muestra los datos de los alquileres con precio superior a 200 euros junto con los datos de su inquilino.
          %ej34 := select (precio>200) (alquileres njoin inquilinos);
          %ej34b := (select (precio>200) (alquileres)) njoin inquilinos;

     % 35. Muestra los datos de las reparaciones junto a los datos del piso de los reparadores de Loja.
          %Renombrar para que no de errores y sea entendible en la relacion final
               %reparador(nif_reparador, nombre_reparador, direccion_reparador, poblacion_reparador):=  select (poblacion='Loja') (reparadores);
               %piso(id_piso, nif_propietario, direccion_piso, precio_piso):=(pisos);
               %reparacion(id_reparacion,nif_reparador,id_piso,importe_reparacion):=(reparaciones);
          %njoin
               %ej35:=piso njoin (reparador njoin reparacion);

     % 36. Muestra los pisos de propietarios que no viven en Málaga capital.
          %Renombrar para que no de errores y sea entendible en la relacion final
               %piso(id_piso, nif, direccion_piso, precio) := (pisos);
               %propietario(nif, nombre, direccion_propietario, poblacion) := select (poblacion<>'Malaga') (propietarios);
          %njoin
               %ej35 := piso njoin propietario;