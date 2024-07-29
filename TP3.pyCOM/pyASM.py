import instruction_set as iset
import re

class pyASM():
    labels_address_table = {}
    instruction_set = {}
    instructions_asm = []
    instructions_machine_code = []
    current_address = 0
    register_table = {}
    current_line = None

    def __init__(self):
        self.labels_address_table = {}
        self.instruction_set = iset.instructionTable
        self.register_table = iset.registerTable
        self.instructions_asm = []
        self.instructions_machine_code = []
        self.current_address = 0
        self.current_line = 1

    def validate_asm_code(self, input: str) -> bool:
        lines = input.split('\n')
        # Split input string into lines
        for line in lines:
            if not line.startswith("#"): # Check if line is a comment
                self.instructions_asm.append(line)
        if self.validate_operation():
            print("OPCODES and LABELS Syntax OK!")
            #print(self.labels_address_table)
            if self.validate_arguments():
                print("ARGUMENTS Syntax OK!")
                return True
            else:
                return False
        else :
            return False
        

    def assamble(self, input: str) -> str:
        for line in self.instructions_asm:
            inst = line.split(' ')
            inst = [item.strip() for item in inst if item != '']
            #print(self.labels_address_table)
            machine_code = self.resolve_instruction(inst)
            self.instructions_machine_code.append(machine_code)
            #print(machine_code)
            print(self.bin_to_hex(machine_code))

    
    def translate_line(self, line: str) -> str:
        pass

        

    
    def validate_operation(self) -> bool:
        for inst in self.instructions_asm:
            inst_parts = inst.split(' ')
            # Remove empty strings from list
            inst_parts = [item.strip() for item in inst_parts if item != '']
            if inst_parts[0] in self.instruction_set:
                self.current_line += 1
            else: # if is not an instruction, check if it is a label
                if ':' in inst_parts[0]:
                    #print("Label: " + inst_parts[0])
                    inst_parts[0] = inst_parts[0].replace(':', '')
                    self.labels_address_table[inst_parts[0]] = self.dec_to_bin(self.current_address, 26)
                    self.current_line += 1
                else:
                    raise Invalid_instruction_exception("Invalid instruction on line " + str(self.line_index) + ": " + inst_parts[0])
            self.current_address += 1 # Increment address 
            self.current_line = 1 # Reset line counter
        return True
    
    def validate_arguments(self) -> bool:
        for inst in self.instructions_asm:
            inst = inst.split(' ')
            inst = [item.strip() for item in inst if item != '']
            if len(inst) == 3: # Label: OP arg1,arg2,arg3
                op = inst[1]
                args = inst[2].split(',')
                if op not in self.instruction_set:
                    raise Invalid_instruction_exception("Invalid instruction on line " + str(self.current_line) + ": " + op)
                
            elif len(inst) == 2: # Op arg1,arg2,arg3 o Op Label
                args = inst[1].split(',')
                if len(args) == 1:
                    #print("Label: " + args[0])
                    if args[0] not in self.labels_address_table:
                        raise Label_not_found_exception("Label not found on line " + str(self.current_line) + ": " + args[0])
                        #print("Label not found on line " + str(self.current_line) + ": " + args[0])
            self.current_line += 1
        return True
                
    
    def resolve_instruction(self, inst: str) -> str:
        #print(inst)
        if inst[0] in self.instruction_set:
            if self.instruction_set[inst[0]][0] == str(iset.OP_CODE_R): # R type instruction
                #print("R type instruction: " + str(inst))
                mach_code_r_type = self.resolve_R_type(inst)
                return mach_code_r_type
            elif (self.instruction_set[inst[0]][0] == str(iset.OP_CODE_J) or self.instruction_set[inst[0]][0] == str(iset.OP_CODE_JAL)): # J type instruction
                mach_code_j_type = self.resolve_J_type(inst)
                return mach_code_j_type
            elif inst[0] == 'NOP' or inst[0] == 'HALT':
                
                return self.hex_to_bin(self.instruction_set[inst[0]][0], 32)
            else: # I type instruction
                mach_code_i_type = self.resolve_I_type(inst)
                return mach_code_i_type
        else:
            label = inst[0].replace(':', '')
            if label in self.labels_address_table:
                inst_label = [inst[1], inst[2]]
                label_mach_code = self.resolve_instruction(inst_label)
                return label_mach_code

    def resolve_R_type(self, inst: str) -> str:
        args = inst[1].split(',')
        #print(args)
        if len(args) == 3:
            if (inst[0] == 'SLL' or inst[0] == 'SRL' or inst[0] == 'SRA'):
                # XXXX $rd, $rt, shamt
                rs = self.dec_to_bin(0, 5)
                rt = self.to_register(args[1])
                rd = self.to_register(args[0])
                shamt = self.dec_to_bin(int(args[2]), 5)
                func = self.instruction_set[inst[0]][5]
                machine_code = self.instruction_set[inst[0]][0] + rs + rt + rd + shamt + func
                return machine_code
            
            elif (inst[0] == 'SLLV' or inst[0] == 'SRLV' or inst[0] == 'SRAV'):
                # XXXX $rd, $rt, $rs
                rs = self.to_register(args[2])
                rt = self.to_register(args[1])
                rd = self.to_register(args[0])
                shamt = self.dec_to_bin(0, 5)
                func = self.instruction_set[inst[0]][5]
                print("RS: " + rs)
                print("RT: " + rt)
                print("RD: " + rd)
                machine_code = self.instruction_set[inst[0]][0] + rs + rt + rd + shamt + func
                return machine_code
        
            else: #From ADDU to SLT
                # XXXX $rd, $rs, $rt
                rs = self.to_register(args[1])
                rt = self.to_register(args[2])
                rd = self.to_register(args[0])
                shamt = self.dec_to_bin(0, 5)
                func = self.instruction_set[inst[0]][5]
                machine_code = self.instruction_set[inst[0]][0] + rs + rt + rd + shamt + func
                return machine_code
        else:
            if inst[0] == 'JALR': #rd = R31 = PC + 4; rs = PC 
                # JARL $rs
                rs = self.to_register(args[0])
                rt = self.dec_to_bin(0, 5)
                rd = self.dec_to_bin(31, 5) # R31
                shamt = self.dec_to_bin(0, 5)
                func = self.instruction_set[inst[0]][5]
                machine_code = self.instruction_set[inst[0]][0] + rs + rt + rd + shamt + func
                print(machine_code)
                return machine_code
            
            elif inst[0] == 'JR': #PC = Rs
                # JR $rs
                rs = self.to_register(args[0])
                rt = self.dec_to_bin(0, 5)
                rd = self.dec_to_bin(0, 5)
                shamt = self.dec_to_bin(0, 5)
                func = self.instruction_set[inst[0]][5]
                machine_code = self.instruction_set[inst[0]][0] + rs + rt + rd + shamt + func
                return machine_code
            
    def resolve_J_type(self, inst: str) -> str:
        if inst[0] == 'J':
            # J DIR
            if inst[1] in self.labels_address_table:
                dir = self.labels_address_table[inst[1]]
                machine_code = self.instruction_set[inst[0]][0] + dir
                return machine_code
                
    def resolve_I_type(self, inst: str) -> str:
        return None   

  
            
    def machine_code(self, type: str, inst: str, args: str) -> str:
        if type == 'R':
            pass
        elif type == 'I':     
            pass
        elif type == 'J':
            pass

    #def resolve_label(self, label: str) -> str:
    #    label = label.replace(':', '')
    #    self.labels_address_table[label] = None
    #    print(self.labels_address_table)

    # Hexadecimal to binary
    def hex_to_bin(self, hexnum: str, size: int) -> str:
        intnum = int(hexnum, 16)
        
        binnum = bin(intnum)[2:]
        binnum_filled = binnum.zfill(size)
        return binnum_filled

    def bin_to_hex(self, binum: str) -> str:
        # Convertir el número binario a entero
        intnum = int(binum, 2)
        # Convertir el entero a hexadecimal y eliminar el prefijo '0x'
        hexnum = hex(intnum)[2:]
        # Rellenar con ceros a la izquierda para asegurar 8 caracteres (32 bits)
        hexnum_32 = hexnum.zfill(8)
        return '0x' + hexnum_32
        
        return hexnum
    
    def dec_to_bin(self, num: int, size: int) -> int:
        if num < 0:
            bin = format((1 << size) + num, '0{}b'.format(size))
        else:
            bin = format(num, '0{}b'.format(size))

        #print(bin)
        return bin

    def to_register(self, reg: str) -> str:
        if reg in self.register_table:
            return self.dec_to_bin(self.register_table[reg], 5)
        else:
            raise Invalid_reg_exception("Invalid register on line " + str(self.current_line) + ": " + reg)

class Invalid_instruction_exception(Exception):
    def __init__(self, msj):
        super().__init__(msj)

class Invalid_reg_exception(Exception):
    def __init__(self, msj):
        super().__init__(msj)
        
class Label_not_found_exception(Exception):
    def __init__(self, msj):
        super().__init__(msj)

if __name__ == '__main__':
    print("pyASM")
