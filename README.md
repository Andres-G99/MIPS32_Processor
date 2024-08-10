# Procesador MIPS - Arquitectura de Computadoras
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
![modo_continuo](/img/modo_continuo.png)
6. Elegir la acción _3. Step by step program_ y presionar "N" para ejecutar los siguientes pasos. Se imprimen los registros y datos de memoria en cada paso. MODO STEP
![modo_step](/img/modo_step.png)  
7. Verificamos que los datos sean correctos con un [análisis instrucción por instrucción](https://docs.google.com/spreadsheets/d/1HQWv1dA8hQ2l9KSv4gJhaPP8k8ei2q0zWhnZzRozxcY/edit?usp=sharing)
## Etapas

### IF

__Función__: Obtener la próxima instrucción de la memoria.  
__Funcionamiento__: 
- Se obtiene la instrucción basándose en la dirección del PC.
- El PC se actualiza para apuntar a la siguiente instrucción. Se incrementa en 32 bits si es secuencial. 
- Se implementan módulos para llevar la cuenta del pc y para guardar las intrucciones. 

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

## Debug
Modos de operación:
 - Continuo: Se envía un comando a la FPGA por la UART y esta inicia la ejecución del programa hasta llegar al final del mismo (Instrucción HALT). Llegado ese punto se muestran todos los valores en pantalla.
 - Paso a paso: Enviando un comando por la UART se ejecuta un ciclo de clock. Se debe mostrar a cada paso los valores.

Para ello se implementó un módulo Debug con una interfaz y buffers. La idea original fue la siguiente:  
![simple](img/debug_original.png)  
A partir de esta base, los distintos flujos de la máquina de estados, quedaron de la siguiente manera:  
![simple](img/debug_completo.png) 
