import shutil
import os
from pyASM import pyASM
from serial_com import Uart
from interface import Interface, ExecMode

class UI():
    def __init__(self):
        uart = None
        interface = None

    def main_menu(self):
        os.system("cls")
        #self.uart = self.uart_init()
        #self.interface = self.Interface_init(self.uart)
        #os.system("cls")
        terminal_size = shutil.get_terminal_size((80, 20))  # Valores por defecto si no se puede obtener el tamaño
        width = terminal_size.columns
        title = "MIPS32 UI"
        total_dashes = width - len(title)
        left_dashes = total_dashes // 2
        right_dashes = total_dashes - left_dashes
        print("-" * left_dashes + title + "-" * right_dashes + "\n")

        print("1) Compile and Load")
        print("2) Run program")
        print("3) Step by step program")
        print("4) Exit\n")

        input_option = input("Select an option: ")

        if input_option == "1":
            self.compile_and_load()
            input("\nPress Enter to continue...")
            self.main_menu()

        elif input_option == "2":
            self.run_program()

        elif input_option == "3":
            self.step_program()

        elif input_option == "4":
            exit(0)

    # Compile and load program
    def compile_and_load(self):
        os.system("cls")
        assembler = pyASM()

        input_file = input("Enter the file path: ")
        file = self.input_file(input_file)
        try:
            if assembler.validate_asm_code(file):
                print("Syntaxis OK!\n")
                assembler.assamble(file)
        except Exception as e:
            print(e)
            print("\nCompilation failed...")
            exit(1)
        code = self.prepare_code(assembler.get_compiled_code())
        self.interface.load_program(code)
        print("\nProgram loaded successfully.")
        input("\nPress Enter to continue...")

    # Normal execution
    def run_program(self):
        os.system("cls")
        print("Running program...\n")
        self.interface.run_program(Interface.ExecMode.RUN)
        reg = self.interface.get_registers()
        mem = self.interface.get_memory()
        self.print_table(reg, mem)

    # Step by step execution
    def step_program(self):
        try:
            os.system("cls")
            print("Stepping program...\n")
            self.interface.run_program(Interface.ExecMode.STEP)
            reg = self.interface.get_reg_last_cicle()
            mem = self.interface.get_mem_last_cicle()
            self.print_table(reg, mem)

            while usr_input := input("N to next step: "):
                if usr_input.lower() == 'n':
                    program_state = self.interface.run_next_step()
                    break
                else:
                    print("Invalid input.")
            
            os.system("cls")
            if program_state: # Program finished
                reg = self.interface.get_reg_last_cicle()
                mem = self.interface.get_mem_last_cicle()
                self.print_table(reg, mem)
                print("Program finished.")
            else:
                print("Error running program.")
        except ValueError as e:
            print(e)
            input("\nPress Enter to continue...")

    # Read file content
    def input_file(self, file_path: str) -> str:
        try:
            with open(file_path, 'r') as file:
                content = file.read()
            return content
        except FileNotFoundError:
            return "File not found."
        except IOError:
            return "Error reading file."


    def uart_init(self) -> Uart:
        uart = Uart(None)
        uart.set_serial_port()
        input("Press Enter to continue...")
        return uart

    def Interface_init(self, uart: Uart) -> Interface:
        interface = Interface(uart)
        return interface

    def prepare_code(self, codes: str) -> list:
        byte_list = []
        for code in codes:
            hex_byte = code[2:].zfill(8)
            byte_list.extend([hex_byte[i:i+2] for i in range(0, len(hex_byte), 2)])
        print(byte_list)

    def print_table(self, reg: list, mem: list):
        pass # TODO

ui = UI()
ui.__init__()
ui.main_menu()