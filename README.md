# Procesador MIPS - Arquitectura de Computadoras
## Integrantes
+ Careggio, Camila.
+ Garella, Andrés Esteban.
## Introducción
Se implementa el pipeline del procesador MIPS con las siguientes etapas:

- IF (Instruction Fetch): Búsqueda de la instrucción en la memoria de programa.
- ID (Instruction Decode): Decodificación de la instrucción y lectura de registros.
- EX (Excecute): Ejecución de la instrucción.
- MEM (Memory Access): Lectura o escritura desde/hacia la memoria de datos.
- WB (Write back): Escritura de resultados en los registros.  

Y permite las siguientes instrucciones:
- R-type: SLL, SRL, SRA, SLLV, SRLV, SRAV, ADDU, SUBU, AND, OR, XOR, NOR, SLT
- I-Type: LB, LH, LW, LWU, LBU, LHU, SB, SH, SW, ADDI, ANDI, ORI, XORI, LUI, SLTI, BEQ, BNE, J, JAL
- J-Type: JR, JALR

## Ejecución
1. Ejecutar `py main.py`
2. Elegir el puerto donde está la placa conectada e ingresar el path del archivo a ejecutar, en este caso utilizamos como ejemplo _a.asm_
3. Seleccionar la acción a realizar (primero será _1. Compile and Load_)
![choose_mode](/img/choose_mode.png)
4. El programa será compilado y cargado
![load_program](/img/load_program.png)
5. Volver a elegir la acción a realizar, en este caso _2. Run program_ y observaremos el estado de los registros y datos de memoria al finalizar la ejecución completa. MODO CONTINUO
![modo_continuo](/img/modo_continuo_pc.png)
6. Elegir la acción _3. Step by step program_ y presionar "N" para ejecutar los siguientes pasos. Se imprimen los registros y datos de memoria en cada paso. MODO STEP
![modo_step](/img/modo_step_pc.png)  
7. Verificamos que los datos sean correctos con un [análisis instrucción por instrucción](https://docs.google.com/spreadsheets/d/1HQWv1dA8hQ2l9KSv4gJhaPP8k8ei2q0zWhnZzRozxcY/edit?usp=sharing)
## Etapas
Partimos del pipeline del libro:
![book_diagram](/img/book_diagram.png) 

### IF

__Función__: Obtener la próxima instrucción de la memoria.  
__Funcionamiento__: 
- Se obtiene la instrucción basándose en la dirección del PC.
- El PC se actualiza para apuntar a la siguiente instrucción. Se incrementa en 32 bits si es secuencial. 
- Se implementan módulos para llevar la cuenta del pc y para guardar las instrucciones. 

__Output__: Instrucción obtenida y el PC actualizado se prepara para el siguiente fetch.

### ID  
__Función__: Decodificar la instrucción y leer los datos necesarios del banco de registros.  
__Funcionamiento__:  
- Se determina la operación
- Se identifican los registros de origen y destino.  
- Se generan señales de control desde la ctrl_unit.  
- Se accede al banco de registros para leer o almacenar los valores de los operandos si la instrucción lo requiere.  

[Conjunto de instrucciones](https://phoenix.goucher.edu/~kelliher/f2009/cs220/mipsir.html)  
![instrucciones_mips](/img/instrucciones_formato.png)
- op: identificador de instrucción
- rs, rt: identificadores de los primer y segundo registros fuente 
- rd: identificador del registro destino
- shamt: cantidad a desplazar (en operaciones de desplazamiento)
- funct: selecciona la operación aritmética a realizar
- inmediato: operando inmediato o desplazamiento en direccionamiento a registro-base
- dirección: dirección destino del salto  

__Output__: La instrucción decodificada, las señales de control y los valores de los operandos.

### EX
__Función__: Realizar operaciones aritméticas y lógicas.  
__Funcionamiento__:  
- La ALU realiza la operación especificada por la instrucción (por ejemplo, suma, resta, and, etc).  
- Se impementan multiplexores para seleccionar los operandos de la ALU, la dirección de destino para la etapa WB y los datos de forwarding.

__Output__: El resultado de la operación de la ALU, el dato fowarded y el destino de WB.

### MEM
__Función__: Acceder a la memoria de datos si la instrucción lo requiere (operaciones de lectura/escritura).  
__Funcionamiento__:
- Se utiliza un módulo data_memory para acceder a los datos en memoria.
- Se manipulan los datos a leer o escribir (extension con signo, sin signo, halfword, byte, etc).  

__Output__: Los datos leídos de la memoria se pasan a la etapa WB o se completa la operación de escritura.  

### WB
__Función__: Escribir en memoria los resultados de la ejecución de instrucciones provenientes de las etapas anteriores.
__Funcionamiento__:
- Se usa la señal de control `i_mem_to_reg` para ecribir o no las señales:
  - `i_alu_result`: Resultado de operación de la ALU.
  - `i_mem_result`: Resultado de operación de memoria.

__Output__: Los datos a escribir en los registros (`o_wb_data`).

## Hazard
### Risk Detection
__Función__: Detección e intervención de riesgos. Previene situaciones donde aparecen riegos de datos y control.
__Funcionamiento__:
El módulo tiene como input señales de control que permiten tomar acción en las siguientes situaciones:
+ Riesgos de saltos:
  | i_jmp_stop | i_if_id_funct == (CODE_FUNCT_JALR or CODE_FUNCT_JR) | i_if_id_op == CODE_OP_R_TYPE | i_if_id_op == (CODE_OP_BNE or CODE_OP_BEQ)| o_jmp_stop | 
  |:---:|:---:|:------------:|:---:|:----------------:|
  | 0 | 1 | 1 | x | 1 |
  | 0 | x | x | 1 | 1 |
  | 1/x | x | x | x | 0 |
  + Si se detecta una instrucción `JAR`, `JR`, `BNQ` o `BEQ` y la señal `i_jmp_stop` está inactiva, la señal `o_jmp_stop` se enciende.

+ Riesgo de datos:
  | i_id_ex_rt == (i_if_id_rs or i_if_id_rd) | i_id_ex_op == CODE_OP[`LW`, `LB`, `LBU`, `LH`, `LHU`, `LUI`, o `LWU`] | o_jmp_stop | o_not_load |
  |:---:|:---:|:---:|:-----:|
  | 1 | 1 | x | 1 |
  | x | x | 1 | 1 |
  | 0 | x | 0 | 0 |
  + Si los registros destino de IF/ID e ID/EX coinciden y son instrucciones de carga o la señal `o_jmp_stop` está activa, se activa `o_not_load`.
+ Propagación de control:
  + La señal `o_ctr_reg_src` es igual a `o_not_load`, pero las diferenciamos para mejor comprensión y control del circuito.
+ Detección de Halt:
  | i_if_id_op == CODE_OP_HALT | o_halt | 
  |:-------------------------:|:--------:|
  | 1 | 1 |
  | 0 | 0 |
  + Si se detecta una instrucción Halt, se termina el programa.

__Output__: Señales que indican si el procesador debe introducir un _stall_ dependiendo de las condiciones antes mencionadas

### Shortcut
__Función__: Permite el adelantamiento de datos para evitar colocar un _stall_ cada vez que una instrucción depende de un valor que aún no se ha escrito en memoria.
__Funcionamiento__:  
+ Data source A:
  | Data SRC A | i_ex_mem_wb | i_mem_wb_wb | i_ex_mem_addr == i_id_ex_rs |i_mem_wb_addr == i_id_ex_rs|
  |:------------:|:-------------:|:-------------:|:-------------:|:----------:|
  | EX_MEM | 1 | x | 1 | x |
  | MEM_WB | 0/x | 1 | x | 1 |
  | ID_EX | 0/x | 0/x | 0/x | 0/x |
  + Si `i_ex_mem_addr` es igual a `i_id_ex_rs` (Data source A) y `i_id_ex_rs` no es 0 y `i_ex_mem_wb` es válido, la fuente de datos es EX/MEM.
  + Si `i_mem_wb_addr` es igual a `i_id_ex_rs` y `i_id_ex_rs` no es 0 y `i_mem_wb_wb` es válido, la fuente de datos es MEM/WB.
  + Cualquier otro caso, el data source es ID/EX.

+ Data source B:
  | Data SRC B | i_ex_mem_wb | i_mem_wb_wb | i_ex_mem_addr == i_id_ex_rt |i_mem_wb_addr == i_id_ex_rt|
  |:------------:|:-------------:|:-------------:|:-------------:|:----------:|
  | EX_MEM | 1 | x | 1 | x |
  | MEM_WB | 0/x | 1 | x | 1 |
  | ID_EX | 0/x | 0/x | 0/x | 0/x |
  + Si `i_ex_mem_addr` es igual a `i_id_ex_rt` (Data source B) y `i_id_ex_rt` no es 0 y `i_ex_mem_wb` es válido, la fuente de datos es EX/MEM.
  + Si `i_mem_wb_addr` es igual a `i_id_ex_rt` y `i_id_ex_rt` no es 0 y `i_mem_wb_wb` es válido, la fuente de datos es MEM/WB.
  + Entonces el data source B es dato en EX/MEM.

__Output__: Data sources de los operandos A y B según dichas condiciones.

## Debug
Modos de operación:
 - Continuo: Se envía un comando a la FPGA por la UART y esta inicia la ejecución del programa hasta llegar al final del mismo (Instrucción HALT). Llegado ese punto se muestran todos los valores en pantalla.
 - Paso a paso: Enviando un comando por la UART se ejecuta un ciclo de clock. Se debe mostrar a cada paso los valores.

Para ello se implementó un módulo Debug con una interfaz y buffers. La idea original fue la siguiente:  
![simple](img/debug_original.png)  
A partir de esta base, los distintos flujos de la máquina de estados, quedaron de la siguiente manera:  
![simple](img/debug_completo.png) 

## pyCOM
API diseñada para comunicarse con la placa y ejecutar comandos e instrucciones. Módulos:

### UI
User interface. Permite la interación con la placa a través de la consola.
Opciones del Menú:
+ Compile and load.
+ Run program.
+ Step by step program.
+ Exit.

__Compile and load__: Compila y carga el programa.  
__Run program__: Ejecuta el programa normalmente y al terminar, imprime el estado de los registros y la memoria.  
__Step by step program__: Ejecuta el programa de a un ciclo de reloj e imprime el estado de los registros y la memoria en cada ciclo.  
__Exit__: Cierre de la comunicación y de la API.  

### instruction_set
Set de isntrucciones de referencia que le indica al compilador los reemplazos pertientes según cada instrucción y registro.

### pyASM
Compilador de assembler. Diseñado para entender y compilar las intrucciones propuestas en la consigna y siguiendo el formato de instrucción especificado [aquí](https://phoenix.goucher.edu/~kelliher/f2009/cs220/mipsir.html)

__Características__:
+ Reconoce etiquetas (o funciones) para facilitar las instrucciones de salto.
  + Formato: `LABEL: INSTURCTION rx,ry,rz`.
+ Reconoce variables de tipo _integer_ de 8, 16 y 32 bits, con o sin signo.
  + Formato: `DEFINE [U/]INT[8/16/32] = VALUE`.
+ Acepta valores en formato binario, decimal y hexadecimal.
+ Ignora líneas que empiezan con `#` y saltos de línea.

__Funcionamiento__:
Consta de dos etapas:
+ `validate_asm_code()`: Recibe el código a compilar y luego:
  + Detecta saltos de línea y comentarios, los cuales son ignorados.
  + Valida las instrucciones y le asigna una dirección a las labels que encuentre.
  + Valida los argumentos y controla que las labels estén definidas.
  + Devuelve `True` si no hay problemas de sintaxis o dependencias.
  
+ `assemble()`: Es la compilación propiamente dicha.
  + Reemplaza los opcodes, los registros y las labels según corresponda.
  + Construye cada instrucción según su tipo.
  + Devuelve una lista con cada instrucción en machine code.

### UART - (Universal Asynchronous Receiver-Transmitter)
Módulo de comunicación asincrónica para enviar y reicibir datos de la unidad UART del proyecto.
Utiliza las utilidades de la librería serial de Python para configurar la comunicación.

__Configuración__:
+ Baudrate: 19200.
+ Bytesize: 8 bytes.
+ No parity bits
+ Stop bit: 1

### Interface
Módulo que se encarga de codificar los comandos e instrucciones a enviar y decodificar los datos recibidos.
__Función__:
+ Provee una interfaz entre la placa, la UART, el código a ejecutar y la UI.
+ Envía comandos a la palca según la función que solicite el usuario.
+ Codifica y decodifica los comandos y/o códigos enviados y las respuestas recibidas respectivamente.
+ Recupera los datos para su lectura.

__Envío de datos__:
Usamos el método `send_cmd()` para comandar a la placa a través del debuger. Con las opciones:
- `L`: `load_program()`: Carga del programa en la placa.
- `C`: `run_program()`: Ejecución en modo continuo.
- `S`: `run_next_step()`: Siguiente ciclo del step by step.

__Formato y recepción de datos__:
Cada respuesta de recibida de la UART conta de 7 bytes (Definido en `RES_SIZE_BYTES` = 7), y contiene la siguiente información:
![](img/response_format.png)
```
response # dato de 7 bytes de respuesta

type = (reponse || MASK.TYPE) >> SHIFT.TYPE
cicle = (reponse || MASK.CICLE) >> SHIFT.CICLE
address = (reponse || MASK.ADDRESS) >> SHIFT.ADDRESS
data = (reponse || MASK.DATA) >> SHIFT.DATA
```
Enmascaramos cada dato y los desplazamos según el lugar que ocupan en la respuesta. Un vez hecho esto, podemos operar:
+ `type`: Indica el tipo de respuesta, información, error, tipo de dato, etc.
+ `cicle`: Ciclo de instrucción en el que se encuentra el programa.
+ `address`: Dirección de registro o memoria, según `type`.
+ `data`: Dato en sí, valor de un registro o memoria, según `type`.

### Funcionamiento
![states](<img/pyCOM.png>)

## Análisis en frecuencia

Agregando un clock wizard para variar la frecuencia del clock, vemos que a partir de los 65MHz comenzamos a tener path críticos que no cumplen las condiciones de timing.
![img](/img/path_criticos.png)  

El detalle de lo que sucede en este path es el siguiente.
![img](/img/path1.png) 
Lo que está sucediendo es que la etapa MEM/WB está pasando el Data source B a la unidad de cortocircuito. En ella se determina si se debe adelantar el dato a otra etapa del pipeline. Observando la matriz mencionada anteriormente (en la sección Shortcut Unit), vemos que una de las opciones es enviar el dato a ID/EX. Luego de ello se determina en la unidad is_equal si los datos son iguales y el salto debe hacerse efectivo o no. Se calcula el valor del PC y se envía a la pc unit para asignarlo.

## Repositorio
[Link al repositorio](https://github.com/Andres-G99/TP3_MIPS32_Processor)

