ADDI r3,r0,85
JAL  FIRST
ADDI r4,r0,86
J    SECOND
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
FIRST: ADDI r5,r0,87
JALR r30,r31
SECOND: ADDI r6,r0,88
HALT