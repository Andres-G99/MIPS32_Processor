import instruction_set as iset
import re

class pyASM():
    labels_address_table = {}
    instruction_set = {}
    instructions_asm = []
    instructions_machine_code = []
    current_address = 0
    register_table = {}

    def __init__(self):
        self.labels_address_table = {}
        self.instruction_set = iset.instructionTable
        self.register_table = iset.registerTable
        self.instructions_asm = []
        self.instructions_machine_code = []
        self.current_address = 0


    def assamble(self, input: str) -> str:
        lines = input.split('\n')
        line_index = 1
        # Split input string into lines
        for line in lines:
            self.instructions_asm.append(line)
            self.translate_line(line, line_index)
            line_index += 1
        #print(self.labels_address_table)

    
    def translate_line(self, line: str, line_index: int) -> str:
        # Split line into parts
        inst_parts = line.split(' ')
        # Remove empty strings from list
        inst_parts = [item.strip() for item in inst_parts if item != '']
        #print(inst_parts)
        # Check if instruction is valid
        self.validate_syntax(inst_parts[0], line_index)
        self.current_address += 4 # Increment address by 4 bytes

        if len(inst_parts) > 1:
            self.resolve_arguments(inst_parts[0])
        else:
            print("No arg instruction" + str(inst_parts))

    
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
    

    def resolve_arguments(self, inst: str) -> None:
        if inst in self.instruction_set:
            if self.instruction_set[inst][0] == str(iset.OP_CODE_R):
                print("R type instruction")
            else:
                #print("X")
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

        print(bin)
        return bin


class Invalid_instruction_exception(Exception):
    def __init__(self, msj):
        super().__init__(msj)

class Invalid_reg_exception(Exception):
    def __init__(self, msj):
        super().__init__(msj)
        

if __name__ == '__main__':
    print("pyASM")
