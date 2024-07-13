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

## Etapas
### IF
### ID
### EX
### MEM
### WB
