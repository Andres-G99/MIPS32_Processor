from serial_com import Uart
from enum import Enum, auto
import time

class Command(Enum):
    LOAD = 0x4c
    EXEC = 0x45
    EXEC_BY_STEPS = 0x53
    NEXT_STEP = 0x4e

class ExecMode(Enum):
    RUN = auto()
    STEP = auto()

class Response(Enum):
    END = 0x1
    LOAD_OK = 0x2
    STEP_END = 0x3
    EMPTY_PROGRAM = 0x2

class Result(Enum):
    ERROR = 0xff
    INFO = 0x00
    REG = 0x01
    MEM = 0x02

class Mask(Enum):
    TYPE = 0xFF00000000000000000000
    CICLE = 0x00FF000000000000000000
    ADDR = 0x0000FF0000000000000000
    DATA = 0x000000FFFFFFFF00000000
    PC = 0x0000000000000000FFFFFFFF

class Shift(Enum):
    TYPE = 80
    CICLE = 72
    ADDR = 64
    DATA = 32
    PC = 0

class Utils(Enum):
    FILL_BYTES_ZERO = 0x00
    RES_SIZE_BYTES = 11

class Interface():
    uart = None
    step_mode_flg = False
    registers = []
    memory = []

    def __init__(self, uart: Uart):
        self.uart = uart

    # Load program to the board
    def load_program(self, inst: list):
        self._send_cmd(Command.LOAD.value)
        type, _, _, data = self._read_response()
        if type != None:
            raise LoadProgramException(f"Error loading program: {hex(data)}")
    
        print("Loading program...")
        for i in range(0, len(inst), 4):
            for j in range(3, -1, -1):
                if i+j < len(inst):
                    self.uart.write(int(inst[i+j], 16), byteorder = 'big')
                else:
                    break
        
        type, _, _, data = self._read_response(locked = True)
        if type == Result.ERROR.value:
            raise LoadProgramException(f"Error loading program: {hex(data)}")


    # Send command to the board
    def _send_cmd(self, cmd: int):
        # Command = 0xZZ + 0x00 + 0x00 + 0x00
        self.uart.write(cmd)
        for i in range(3):
            self.uart.write(Utils.FILL_BYTES_ZERO.value)
        time.sleep(0.1)

    # Read response from the board
    def _read_response(self, locked = False):
        if (self.uart.check_data_available(Utils.RES_SIZE_BYTES.value) or locked): # Verify if data is available
            res = self.uart.read(Utils.RES_SIZE_BYTES.value)
            
            res_type = (res & Mask.TYPE.value) >> Shift.TYPE.value
            res_cicle = (res & Mask.CICLE.value) >> Shift.CICLE.value
            res_addr = (res & Mask.ADDR.value) >> Shift.ADDR.value
            res_data = (res & Mask.DATA.value) >> Shift.DATA.value
            res_pc = (res & Mask.PC.value) >> Shift.PC.value

            return res_type, res_cicle, res_addr, res_data, res_pc
        else:
            return None, None, None, None, None

    # Read registers and memory from the board
    def _read_result(self) -> bool:
        while(True):
            res_type, res_cicle, res_addr, res_data, res_pc = self._read_response()
            if res_type == Result.ERROR.value:
                if res_data == Response.EMPTY_PROGRAM.value:
                    print("Empty program.")
                else:
                    raise ValueError(f"Error: {hex(res_data)}")

            elif res_type == Result.INFO.value:
                if res_data == Response.END.value:
                    print("Program ended.")
                    return True
                elif res_data == Response.STEP_END.value:
                    print("Step ended.")
                    return False

            elif res_type == Result.REG.value:
                self.registers.append({'cicle': res_cicle, 'addr': res_addr, 'data': res_data, 'pc': res_pc})
            elif res_type == Result.MEM.value:
                self.memory.append({'cicle': res_cicle, 'addr': res_addr, 'data': res_data, 'pc': res_pc})
            else:
                time.sleep(0.1)

    def run_program(self, mode: ExecMode):
        self.registers = []
        self.memory = []

        self.step_mode_flg = False

        if mode == ExecMode.RUN:
            self._send_cmd(Command.EXEC.value)
        elif mode == ExecMode.STEP:
            self._send_cmd(Command.EXEC_BY_STEPS.value)
            self.step_mode_flg = True
            input("Modo step")
        else:
            raise ValueError("Invalid mode.")
        return self._read_result()

    def run_next_step(self) -> bool:
        if not self.step_mode_flg:
            raise ValueError("Not in step mode.")
        
        print("Running next step...")
        self._send_cmd(Command.NEXT_STEP.value)
        return self._read_result()


    def reg_sumary(self):
        print("Registers:")
        for reg in self.registers:
            print(f"Cicle: {reg['cicle']} Addr: {reg['addr']} Data: {reg['data']}")
    
    def mem_sumary(self):
        print("Memory:")
        for mem in self.memory:
            print(f"Cicle: {mem['cicle']} Addr: {mem['addr']} Data: {mem['data']}")

    # Probar en placa

    def get_reg_by_cicle(self, cicle: int):
        return [reg for reg in self.registers if reg['cicle'] == cicle]

    def get_mem_by_cicle(self, cicle: int):
        return [mem for mem in self.memory if mem['cicle'] == cicle]

    # by Address?

    def get_reg_last_cicle(self):
        if not self.registers:
            return None
        last_cicle = self.registers[-1]['cicle']
        return self.get_reg_by_cicle(last_cicle)
    
    def get_mem_last_cicle(self):
        if not self.memory:
            return None
        last_cicle = self.memory[-1]['cicle']
        return self.get_mem_by_cicle(last_cicle)

class LoadProgramException(Exception):
    pass