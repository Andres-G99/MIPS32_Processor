# pyASM

## Uso

## Requisitos

- [ ] Reconocer instrucciones del set
- [ ] Reconocer labels y asignarles una dirección
- [ ] Reconocer Comentarios
- [ ] Reconocer formato hexadecimal y binario
- [ ] ...

## Instrucciones de salto y direcciones
```
'JALR' : [ OP_CODE_R, 'RS', 'RT', 'RD', 'SHAMT', FUNC_CODE_JALR ], #R31 = PC + 4; PC = Rs; Shamt = 0x00  
'JR'   : [ OP_CODE_R, 'RS', 'RT', 'RD', 'SHAMT', FUNC_CODE_JR   ], #PC = Rs  
'J'    : [ OP_CODE_J,   'DIR' ], #PC = (PC & 0xf0000000) | (DIR << 2)  
'JAL'  : [ OP_CODE_JAL, 'DIR' ], #R31 = PC + 4; PC = (PC & 0xf0000000) | (DIR << 2)  
'BEQ'  : [ OP_CODE_BEQ,  'RS', 'RT', 'INM' ], #if (Rs == Rt) PC = PC + 4 + (INM << 2)  
'BNE'  : [ OP_CODE_BNE,  'RS', 'RT', 'INM' ], #if (Rs != Rt) PC = PC + 4 + (INM << 2)
```

## Notas
El registro que corresponde a guardar las direcciones de retorno (En le teórico llamado $ra) en nuestro caso es el registro $r31