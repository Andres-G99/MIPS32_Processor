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


    def assamble(self, input: str) -> str:
        lines = input.split('\n')
        # Split input string into lines
        for line in lines:
            self.instructions_asm.append(line)
            self.translate_line(line)
            self.current_line += 1
        #print(self.labels_address_table)
        print(self.instructions_machine_code)

    
    def translate_line(self, line: str) -> str:
        print(line)
        # Split line into parts
        inst_parts = line.split(' ')
        # Remove empty strings from list
        inst_parts = [item.strip() for item in inst_parts if item != '']
        print(inst_parts)
        # Check if instruction is valid
        self.validate_syntax(inst_parts[0], self.current_line)
        self.current_address += 4 # Increment address by 4 bytes

        if len(inst_parts) > 1:
            mach_code = self.resolve_arguments(inst_parts)
            #print(mach_code)
            self.instructions_machine_code.append(mach_code)
            
        else:
            #print("No arg instruction" + str(inst_parts))
            pass

    
    def validate_syntax(self, inst: str, line_index: int) -> None:
        # Check if instruction is valid
        if inst in self.instruction_set:
            return
        else: # if is not an instruction, check if it is a label
            if ':' in inst:
                inst = inst.replace(':', '')
                self.labels_address_table[inst] = self.dec_to_bin(self.current_address, 26)
            else:
                raise Invalid_instruction_exception("Invalid instruction on line " + str(line_index) + ": " + inst)
    

    def resolve_arguments(self, inst: str) -> str:
        if inst[0] in self.instruction_set:
            #print("Instruction: " + str(inst))
            if self.instruction_set[inst[0]][0] == str(iset.OP_CODE_R):
                #print("R type instruction: " + str(inst))
                mach_code_r_type = self.resolve_R_type(inst)
                return mach_code_r_type
            else:
                #print("X")
                pass

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
            
            elif (inst[0] != 'JALR' or inst[0] != 'JR'):
                # Rd = Rs + Rt; Shamt = 0x00
                args_list = [args[0], args[2], args[1], '0'] # rd, rs, rt, shamt
                machine_code = self.machine_code('R', inst[0], args_list)
                return machine_code
            else:
                print("Invalid instruction")
                pass
                
                
            
    def machine_code(self, type: str, inst: str, args: str) -> str:
        if type == 'R':
            pass
        elif type == 'I':     
            pass
        elif type == 'J':
            pass

    def resolve_label(self, label: str) -> str:
        label = label.replace(':', '')
        self.labels_address_table[label] = None
        print(self.labels_address_table)

    # Hexadecimal to binary
    def hex_to_bin(self, hexnum: str) -> str:
        intnum = int(hexnum, 16)
        return bin(intnum)[2:]

    # Convert decimal number to binary
    #def dec_to_bin(self, decnum: str) -> str:
    #    intnum = int(decnum)
    #    return bin(decnum)[2:]
    
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
        

if __name__ == '__main__':
    print("pyASM")
