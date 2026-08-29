# Guión de exposición oral: Semana 04

## Multiplicación, división y punto flotante (IEEE 754)

**Curso:** IC3101: Arquitectura de computadores  
**Estructura:** Bi-sesional (Sesión 1: Teoría / Sesión 2: Práctica y Taller)

---

### Diapositiva 01: Multiplicación, división y punto flotante

¡Hola a todos! Bienvenidos a la cuarta semana de tutorías de Arquitectura de Computadores.

En las sesiones anteriores dominamos la representación de enteros en complemento a dos y el diseño básico de la ALU para sumas, restas y operaciones lógicas.

Hoy daremos un salto fundamental hacia operaciones más complejas, estudiando cómo el hardware realiza multiplicaciones y divisiones eficientes, y analizando en profundidad el estándar IEEE 754 para números en punto flotante.

---

### Diapositiva 02: Objetivos de la primera sesión

Antes de entrar en detalle, repasemos los objetivos de esta primera sesión teórica:

[click] Primero, entenderemos la multiplicación iterativa sin signo y cómo se gestionan los productos de tamaño doble.

[click] Segundo, analizaremos el algoritmo de Booth para operar directamente números con signo sin necesidad de convertirlos previamente a magnitud positiva.

[click] Tercero, estudiaremos la división en hardware y por qué el enfoque no restaurador optimiza el rendimiento.

[click] Cuarto, entraremos de lleno en la anatomía del estándar IEEE 754 para números en punto flotante de 32 y 64 bits.

[click] Y quinto, analizaremos los estados especiales como NaN e infinitos, y fenómenos críticos como la pérdida de significancia y errores por redondeo.

---

### Diapositiva 03: Multiplicación de enteros sin signo

Comencemos revisando la multiplicación básica sin signo. En papel, cuando multiplicamos números binarios, realizamos exactamente la misma lógica que en el sistema decimal.

[click] Observemos el ejemplo en pantalla: si multiplicamos once por trece, examinamos cada bit del multiplicador de derecha a izquierda. Si el bit actual es uno, copiamos el multiplicando desplazado, mientras que si es cero, colocamos ceros, sumando al final los productos parciales.

[click] En hardware no podemos sumar todos los productos parciales al mismo tiempo sin un área enorme de compuertas. Por tanto, el procesador utiliza un acumulador y procesa un bit por ciclo de reloj según la regla que vemos a la derecha.

[click] Tras cada decisión de suma, el acumulador y el multiplicador se desplazan juntos a la derecha para evaluar el siguiente bit en la siguiente iteración.

[click] Noten un detalle clave de diseño: el producto de dos números de n bits ocupa hasta dos n bits. Por esta razón, en arquitecturas como x86, la multiplicación almacena el resultado combinado en dos registros, como EDX y EAX.

---

### Diapositiva 04: Organización del hardware de multiplicación

Analicemos la microarquitectura de este multiplicador. 

El hardware consta de tres registros principales: el registro M que retiene el multiplicando, el acumulador A que comienza en cero para almacenar la mitad superior del producto, y el registro Q que contiene inicialmente el multiplicador. Fíjense en cómo se conectan: el bit C retiene el acarreo que pueda generar la suma de n bits.

[click] Al activarse el ciclo de control, en cada iteración la unidad de control mira únicamente el bit menos significativo de Q. Si es uno, activa la ALU para sumar A con M; si es cero, no hace suma. Inmediatamente después, toda la cadena compuesta por C, A y Q se desplaza un bit a la derecha. Tras n ciclos, el producto exacto queda en A y Q.

---

### Diapositiva 05: Multiplicación con enteros con signo

¿Qué sucede cuando queremos multiplicar números enteros con signo? Si aplicamos el algoritmo anterior a números negativos en complemento a dos, obtendremos un resultado completamente erróneo.

[click] La razón matemática es que en complemento a dos, el bit más significativo no vale dos a la n menos uno positivo, sino menos dos a la n menos uno, teniendo un peso negativo.

[click] Una primera idea sería la estrategia ingenua: calcular el valor absoluto de ambos números, multiplicarlos como enteros sin signo, y luego aplicar el signo al resultado.

[click] Sin embargo, esto resulta costoso en hardware porque exige pasos adicionales de conversión antes y después de la multiplicación.

[click] Por ello, la solución óptima es el algoritmo de Booth, que opera directamente con números en complemento a dos sin conversiones y optimiza la cantidad de operaciones requeridas.

---

### Diapositiva 06: Fundamento del algoritmo de Booth

Veamos cuál es la intuición detrás del algoritmo de Booth. 

Imaginen que tienen una cadena con muchos unos seguidos, como treinta en decimal. En lugar de sumar cuatro veces el multiplicando desplazado, podemos notar que treinta es igual a treinta y dos menos dos, es decir, dos a la cinco menos dos a la uno. Por tanto, podemos reemplazar cuatro sumas por solo una resta al inicio del bloque de unos y una suma al final del bloque.

[click] Para implementar esto, examinamos la tabla de transiciones: si vemos uno cero, entramos a un bloque de unos y restamos el multiplicando; si vemos cero uno, salimos del bloque y sumamos; y si vemos ceros o unos continuos, no realizamos operación aritmética y solo desplazamos.

---

### Diapositiva 07: Flujo operativo del algoritmo de Booth

Revisemos el ciclo de ejecución completo del algoritmo de Booth.

El proceso arranca inicializando el acumulador A en cero y la bandera Q sub menos uno en cero. Cargamos los operandos de n bits y fijamos el contador en n. En cada iteración, evaluamos el par Q sub cero y Q sub menos uno, aplicamos la suma o resta según corresponda, y ejecutamos el desplazamiento.

[click] Noten con mucha atención la tarjeta de la derecha sobre el desplazamiento aritmético. A diferencia del desplazamiento lógico, aquí el bit más significativo de A se copia a sí mismo al desplazarse, garantizando que el signo se preserve de forma exacta a lo largo de todos los ciclos.

---

### Diapositiva 08: Traza de cálculo con algoritmo de Booth

Sigamos una traza real paso a paso en la tabla. Vamos a multiplicar siete por menos tres en palabras de cuatro bits, con resultado esperado de menos veintiuno.

En el ciclo uno, evaluamos uno cero, restamos M y desplazamos. En el ciclo dos, evaluamos cero uno, sumamos M y desplazamos. En el ciclo tres, evaluamos uno cero, restamos M y desplazamos. Y en el ciclo cuatro, evaluamos uno uno, donde solo desplazamos aritméticamente.

[click] Al finalizar, el resultado combinado de A y Q revela la cadena binaria de ocho bits que corresponde exactamente a menos veintiuno en base diez.

---

### Diapositiva 09: División de enteros en hardware

Pasemos ahora a la división de enteros en hardware. La división busca calcular el cociente Q y el residuo R a partir de un dividendo D y un divisor V según la fórmula que vemos arriba.

[click] A nivel microarquitectónico, el dividendo se coloca en la pareja de registros A y Q, mientras que el divisor reside en M. En cada ciclo desplazamos a la izquierda, restamos el divisor y evaluamos el signo para fijar el bit de cociente.

[click] Un aspecto crítico que todo procesador debe validar antes de empezar es comprobar si el divisor es cero, disparando una excepción de división por cero inmediatamente para proteger el sistema.

---

### Diapositiva 10: División restauradora y no restauradora

Existen dos formas clásicas de implementar la división en hardware. En el método restaurador que vemos a la izquierda, si al restar el acumulador queda negativo, tenemos que sumar de nuevo el divisor para restaurar el valor previo de A, lo que introduce ciclos dobles.

[click] Para optimizar esto, el método no restaurador de la derecha pospone la corrección al ciclo siguiente, sumando o restando el divisor según el signo del residuo parcial previo y logrando exactamente una sola operación de ALU por ciclo de reloj.

---

### Diapositiva 11: Limitaciones de la coma fija

Hasta aquí hemos trabajado con enteros. Pero cuando necesitamos representar números reales en ingeniería, la coma fija se queda corta.

[click] Si reservamos dieciséis bits enteros y dieciséis decimales, nuestro número máximo es apenas sesenta y cinco mil, resultando insuficiente para escalas dispares como la masa de una estrella o el radio de un átomo.

[click] Para solucionar esto nació el punto flotante, donde la posición de la coma flota dinámicamente según un exponente en base dos, adaptándose a cualquier escala numérica.

---

### Diapositiva 12: El estándar IEEE 754

El estándar universal que gobierna el punto flotante es el IEEE 754. Toda palabra se divide en tres campos: el bit de signo, el exponente sesgado de k bits y la mantisa o significando de m bits.

[click] La fórmula matemática inferior nos permite evaluar el valor de cualquier número normalizado combinando el signo, la potencia de dos desplazada por el sesgo y la fracción con su uno entero.

---

### Diapositiva 13: Formatos estándar de 32 y 64 bits

El estándar define dos formatos predominantes. A la izquierda tenemos la simple precisión de treinta y dos bits, correspondiente al tipo float en C, con ocho bits de exponente, sesgo de ciento veintisiete y veintitrés bits de mantisa.

[click] A la derecha encontramos la doble precisión de sesenta y cuatro bits, correspondiente al tipo double en C, con once bits de exponente, sesgo de mil veintitrés y cincuenta y dos bits de mantisa, brindando dieciséis dígitos significativos de resolución.

---

### Diapositiva 14: Representación del exponente con sesgo

El exponente se guarda desplazado por una constante de sesgo. En treinta y dos bits el sesgo vale ciento veintisiete, por lo que un exponente de tres se almacena como ciento treinta.

[click] ¿Por qué no usar complemento a dos? Como explica la tarjeta de la derecha, al usar sesgo todos los exponentes son enteros positivos, permitiendo que la CPU compare órdenes de magnitud con comparadores sin signo sencillos y ultrarrápidos.

---

### Diapositiva 15: Normalización y el bit implícito

En el sistema binario, todo número normalizado comienza obligatoriamente con un uno antes de la coma, pues no hay otros dígitos distintos de cero.

[click] Como el hardware ya sabe que siempre hay un uno antes de la coma, no lo almacena físicamente, logrando veinticuatro bits de precisión real en treinta y dos bits de espacio.

---

### Diapositiva 16: Valores especiales en el estándar IEEE 754

El estándar reserva combinaciones especiales para evitar caídas del sistema. Cuando el exponente y la mantisa son cero, representa el cero con signo. Cuando el exponente es cero pero la mantisa no, representa números subnormales sin bit implícito. Cuando el exponente llega al máximo con mantisa en cero, representa infinito, y con mantisa no nula codifica un NaN para operaciones matemáticamente indefinidas.

---

### Diapositiva 17: Errores numéricos y fenómenos de cálculo

Las fracciones decimales como cero punto uno son periódicas infinitas en base dos, requiriendo truncamiento forzoso en la mantisa.

[click] A la derecha vemos dos fenómenos críticos: la cancelación catastrófica al restar números casi idénticos, y los desbordamientos superior e inferior cuando los cálculos exceden los límites del formato.

---

### Diapositiva 18: Síntesis de la primera sesión

Con esto concluimos la primera sesión teórica. Hemos cubierto los algoritmos de hardware para multiplicación y división, junto con la estructura matemática del estándar IEEE 754.

[click] Les dejo esta pregunta detonante para reflexionar antes del taller práctico: al sumar dos números con exponentes muy dispares, ¿cómo los alinea la CPU antes de operar?

---

### Diapositiva 19: Sesión 02: Taller práctico

¡Bienvenidos a la segunda sesión de la semana!

Habiendo cubierto toda la base teórica de la aritmética digital y el estándar IEEE 754, dedicaremos esta jornada completa al taller práctico y la resolución de ejercicios paso a paso.

---

### Diapositiva 20: Objetivos de la segunda sesión

Antes de iniciar los ejercicios, repasemos los objetivos de esta segunda sesión práctica:

[click] Primero, aplicaremos la metodología sistemática para convertir números decimales con fracción a IEEE 754.

[click] Segundo, realizaremos el proceso inverso: decodificar una palabra hexadecimal de memoria para recuperar su valor real.

[click] Tercero, resolveremos sumas paso a paso ejecutando manualmente las cuatro etapas que realiza la FPU del procesador.

[click] Cuarto, analizaremos cómo se manifiestan estos fenómenos en programas reales de C y cómo evitar errores con épsilon.

[click] Y quinto, realizaremos ejercicios prácticos en parejas y dejaremos problemas recomendados para reforzar el aprendizaje autónomo.

---

### Diapositiva 21: Metodología de conversión decimal a IEEE 754

Para convertir cualquier número decimal al estándar IEEE 754 de 32 bits seguimos un flujo algorítmico estricto en cuatro etapas.

[click] Primero, inspeccionamos el signo del número decimal para fijar directamente el bit treinta y uno: cero si es positivo o uno si es negativo.

[click] Segundo, transformamos la magnitud absoluta a binario en coma fija, dividiendo la parte entera entre dos y multiplicando la fracción por dos.

[click] Tercero, normalizamos la expresión desplazando la coma para aislar el exponente real E y la mantisa fraccionaria con su bit uno implícito.

[click] Y cuarto, calculamos el exponente con sesgo sumando ciento veintisiete, rellenamos los veintitrés bits de mantisa y agrupamos los treinta y dos bits en hexadecimal.

---

### Diapositiva 22: Ejemplo guiado 1: Número con fracción exacta

Apliquemos el método al número positivo veintiséis punto seiscientos veinticinco. El signo es cero, la parte entera es once cero diez y la fracción es cero punto ciento uno.

[click] Al normalizar desplazando cuatro lugares obtenemos exponente real cuatro, sesgo de ciento treinta y uno, y la mantisa empaquetada produce el valor hexadecimal cero cuatro uno de cinco cuatro cero cero cero.

---

### Diapositiva 23: Ejemplo guiado 2: Fracción periódica y truncamiento

Para el número negativo menos trece punto uno, el signo es uno y la parte entera es once cero uno, pero la fracción de cero punto uno entra en un ciclo periódico infinito de ceros y unos.

[click] Al normalizar con exponente tres y aplicar el redondeo obligatorio al bit más cercano sobre los veintitrés bits de mantisa, obtenemos el valor hexadecimal C uno cinco uno nueve nueve nueve A.

---

### Diapositiva 24: Decodificación inversa: De hexadecimal a decimal

Para el camino inverso, expandimos la palabra hexadecimal C dos cuatro C cero cero cero cero a binario, extrayendo el signo negativo y el exponente ciento treinta y dos, que corresponde a un exponente real de cinco.

[click] Al agregar el uno implícito y desplazar la coma cinco lugares a la derecha, reconstruimos el entero binario cincuenta y uno, confirmando que el valor codificado es exactamente menos cincuenta y uno punto cero.

---

### Diapositiva 25: Aritmética de punto flotante: Suma y resta

Sumar dos números en punto flotante en hardware no es directo; la FPU ejecuta un pipeline de cuatro fases obligatorias.

[click] Primero, alinea los exponentes calculando la diferencia y desplazando la mantisa menor a la derecha para equiparar sus escalas de magnitud.

[click] Segundo, realiza la suma o resta aritmética de los significandos ya alineados en la ALU.

[click] Tercero, normaliza el resultado forzando la forma uno punto f y ajustando el exponente según haya ocurrido desbordamiento o cancelación.

[click] Y cuarto, redondea a la cantidad exacta de bits del formato verificando posibles desbordamientos hacia infinito o cero.

---

### Diapositiva 26: Traza práctica de suma en punto flotante

En el ejemplo de ocho más tres, alineamos B desplazando su mantisa dos posiciones, sumamos obteniendo uno punto cero once, y al multiplicarlo por dos al cubo obtenemos once punto cero en decimal.

[click] Noten la advertencia inferior sobre la absorción: si la diferencia de exponentes supera veinticuatro, todos los bits del sumando menor se expulsan al desplazarse, haciendo que el número pequeño sea absorbido por completo como si fuera cero.

---

### Diapositiva 27: Fenómenos en software: La ilusión de los flotantes

En el código de la izquierda vemos por qué cero punto uno más cero punto dos no es igual a cero punto tres en C, imprimiendo cero punto trescientos millones doce debido al redondeo de fracciones periódicas.

[click] La solución profesional mostrada a la derecha consiste en comparar siempre con una tolerancia épsilon y tener sumo cuidado con la acumulación progresiva de error en ciclos repetitivos.

---

### Diapositiva 28: Taller en vivo: Ejercicios para resolver en parejas

Llegó el momento del taller en parejas. Tienen diez minutos para resolver en papel estos dos retos: convertir menos cuarenta y cinco punto setenta y cinco a hexadecimal, y decodificar el valor cuatro dos E ocho cero cero cero cero a decimal.

[click] Trabajen con su compañero y levanten la mano si tienen dudas para asistirles de inmediato.

---

### Diapositiva 29: Solución detallada de los ejercicios de taller

Revisemos las soluciones: para el Reto A de la izquierda, la normalización da exponente sesgado ciento treinta y dos y mantisa que empaqueta en C dos tres seis C cero cero cero.

[click] Para el Reto B de la derecha, al desempaquetar el exponente ciento treinta y tres y desplazar la mantisa seis lugares obtenemos exactamente ciento dieciséis punto cero.

---

### Diapositiva 30: Ejercicios de práctica recomendados

Para consolidar todo lo aprendido hoy, les dejo esta serie de ejercicios de práctica recomendados.

[click] Incluyen conversiones directas, decodificaciones inversas, sumas en punto flotante y trazas completas de Booth para afianzar el dominio operativo de forma autónoma.

---

### Diapositiva 31: Quiz formativo interactivo

Para cerrar la jornada, hagamos un quiz formativo interactivo.

[click] Pregunta uno: en el algoritmo de Booth, cuando evaluamos la pareja uno cero, ¿qué operación realiza la ALU sobre el acumulador?

[click] Pregunta dos: ¿cuál es el valor exacto del sesgo en simple precisión de treinta y dos bits?

[click] Y pregunta tres: ¿qué representa en IEEE 754 una palabra con exponente lleno de unos y mantisa no nula? Piénsenlo unos segundos antes de ver las soluciones.

---

### Diapositiva 32: Respuestas comentadas del quiz

Revisemos las respuestas:

[click] Para la pregunta uno, la opción correcta es B: restar M del acumulador, pues uno cero señala la entrada a una cadena de unos.

[click] Para la pregunta dos, la opción correcta es B: ciento veintisiete en simple precisión.

[click] Y para la pregunta tres, la opción correcta es C: NaN, codificando una indeterminación matemática por operaciones inválidas.

---

### Diapositiva 33: Conclusiones y preparación para la Semana 05

Hemos llegado al final de nuestra sesión y con ello cerramos el primer bloque del curso. 

La próxima semana daremos inicio a la programación en ensamblador x86 con NASM y C. No olviden repasar los ejercicios prácticos recomendados. ¡Muchas gracias a todos y nos vemos en la próxima tutoría!

---
