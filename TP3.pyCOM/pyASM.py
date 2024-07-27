import instruction_set as iset
import re

class pyASM():

    labels_address_table = {}

    def __init__(self):
        self.labels_address_table = {}



    def assamble(self, input: str) -> str:
        lines = input.split('\n')
        line_index = 1
        # Split input string into lines
        for line in lines:
            self.translate_line(line, line_index)
            line_index += 1

    
    def translate_line(self, line: str, line_index: int) -> str:
        # Split line into parts
        inst_parts = line.split(' ')
        # Remove empty strings from list
        inst_parts = [item.strip() for item in inst_parts if item != '']

        print(inst_parts)

        # Check if instruction is valid
        if(self.validate_instruction(inst_parts[0], line_index) == "opcode"):
            self.resolve_label(inst_parts[0])
        for part in inst_parts:
            pass

    def validate_instruction(self, inst: str, line_index: int) -> str:
        if inst in iset.instructionTable:
            return "opcode"
        else:
            if ':' in inst:
                return "label"
            else:
                raise Invalid_instruction_exception("Invalid instruction on line " + str(line_index) + ": " + inst)
            
    def resolve_label(self, label: str) -> str:
        label = label.replace(':', '')
        self.labels_address_table[label] = 0 #TODO: Add address

    # Hexadecimal to binary
    def hex_to_bin(self, hexnum: str) -> str:
        intnum = int(hexnum, 16)
        return bin(intnum)[2:]

    # Convert decimal number to binary
    def dec_to_bin(self, decnum: str) -> str:
        intnum = int(decnum)
        return bin(decnum)[2:]


class Invalid_instruction_exception(Exception):
    def __init__(self, msj):
        super().__init__(msj)

class Invalid_reg_exception(Exception):
    def __init__(self, msj):
        super().__init__(msj)
        


