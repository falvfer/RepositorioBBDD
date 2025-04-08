% Unión __ También se puede tomar como una expresion lógica "O" para distintas tablas _________________________________________________________________________________________
     % 1. Muestra todas las personas de nuestra organización
          %ej01 := propietarios union (inquilinos union reparadores);

     % 2. Muestra todas las poblaciones con las que trabaja nuestro sistema.
          %ej02 := project poblacion (propietarios union (inquilinos union reparadores));

     % 3. Obtén una relación con columnas con la direcciones de propietarios, de pisos y de inquilinos.
          %ej03 :=(project direccion (propietarios)) union ((project direccion (inquilinos)) union (project direccion (pisos)));

     % 4. Obtén una relación con columnas nif y nombre donde aparecerán filas de inquilinos y reparadores donde los primeros son de Archidona y los segundos no.
          %ej04 := project nif, nombre ((select (poblacion='Archidona') (inquilinos)) union (select (poblacion<>'Archidona') (reparadores)));

     % 5. Muestra la lista de (id_alquileres y precio) seguidos de los (id_reparaciones e importe) denominando a estos (id_operaciones y valor).
          %prAlq(id_operacion, valor):=project id_alquiler, precio (alquileres);
          %prRep(id_operacion, valor):=project id_reparacion, importe (reparaciones);
          %ej05:=prAlq union prRep;
               %ej05_completo_mal(id_alquiler, precio, id_operacion, valor):=project id_alquiler, precio, id_reparacion, importe ((project id_piso, id_alquiler, precio (alquileres)) njoin (project id_piso, id_reparacion, importe (reparaciones)));

     % 6. Muestra el nif de los reparadores que son de Antequera o han reparado pisos con precio superior a 400. (ventas).
          %slAnt:=project nif (select (poblacion='Antequera') (reparadores));
          %sl400:= project nif (select (precio>400) (pisos));
          %ej06 := (slAnt) union (sl400);
               %ej06_completo_Y_en_vez_de_O:= (select (poblacion='Antequera') (reparadores)) njoin (project nif ((project id_piso (select (precio>400) (pisos))) njoin (reparaciones)));

% Diferencia __ También se puede tomar como una expresion lógica "XOR" para distintas tablas, pero si esta en la segunda y no en la primera no se muestra ___________________________________
     % 7. Muestra las poblaciones que están en propietarios y no en reparadores
          %ej07 := (project poblacion (propietarios)) difference (project poblacion (reparadores));

     % 8. Reparadores que no han reparado pisos con id_piso menor que 4.
          %idMenos4:=project nif (select (id_piso<4) (reparaciones));
          %ej08 := (project nif (reparadores)) difference idMenos4;
               %ej08_completo := (project nif (reparadores)) difference (project nif (select (id_piso<4) (reparaciones)));
               % Mostrar todos los datos de estos reparadores
                    %ej08b:= ej08_completo njoin reparadores;

     % 9. Muestras los datos inquilinos que no tienen pisos alquilados.
          %nif_alq := project nif (alquileres);
          %nif_inq := project nif (inquilinos);
          %nif_final := nif_inq difference nif_alq;
          %ej09 := nif_final njoin inquilinos;
               %ej09_completo := ((project nif (inquilinos)) difference (project nif (alquileres))) njoin (inquilinos);

     % 10. Muestra el nif de los reparadores que nunca han cobrado más de 100 € en alguna de sus reparaciones.
          %nifReparador := project nif (reparadores);
          %nifReparacion := project nif (select (importe>100) (reparaciones));
          %ej10 := nifReparador difference nifReparacion;
               %ej10_completo :=(project nif (reparadores)) difference (project nif (select (importe>100) (reparaciones)));
                    % Se hace así y no con la parte de "nifReparacion" SOLAMENTE pero cambiando importe>100 a importe<=100
                    % porque los que no hayan hecho reparaciones (como nif9) también entran en la categoría de no haber cobrado más de 100€.

     % 11. Las direcciones de inquilinos que no tienen alquileres.
          %ej11 := project direccion (((project nif (inquilinos)) difference (project nif (alquileres))) njoin (inquilinos));

% Intersección __ (a==b)?mostrar:noMostrar _____________________________________________________________________________________________________________
     % 12. Poblaciones que están en propietarios, inquilinos y repartidores.
          %ej12 := (project poblacion (propietarios)) intersect ((project poblacion (inquilinos)) intersect (project poblacion (reparadores)));

     % 13. Muestra los nif comunes a propietarios y reparadores.
          %ej13 := (project nif (propietarios)) intersect (project nif (reparadores));

     % 14. Muestra los id_comunes de (alquileres y reparaciones) y que sean de un piso con (id_piso menor que 4).
          idAlq:=select (id_piso<4) (project id_piso (alquileres));
          idRep:=project id_piso (reparaciones);
          ej14(id_comunes) := (idAlq) intersect (idRep);
               %ej14_completo:= (select (id_piso<4) (project id_piso (alquileres))) intersect (project id_piso (reparaciones));

     % 15. Reparadores que han reparado algo.
          %ej15 := (project nif (reparaciones)) njoin (reparadores);