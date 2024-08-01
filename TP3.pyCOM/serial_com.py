import serial
from serial.tools import list_ports

class Uart():
    port = None
    baudrate = 19200
    data_size = 1 # one byte default
    byteorder = 'little' # little endian default

    def __init__(self, port):
        self.port = port
        self.ser = serial.Serial(
            port=self.port,
            baudrate=self.baudrate,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            bytesize=serial.EIGHTBITS,
            #timeout=1
        )

    def set_serial_port(self):
        try:
            ports_avail = list_ports.comports()
        except:
            print("Error getting serial ports.")
            input("Press Enter to exit...")
            exit(1)
        if len(ports_avail) == 0:
            print("No serial ports available.")
            input("Press Enter to try again...")
            self.set_serial_port()

        print("Available serial ports:")
        i = 1
        for port in ports_avail:
            ports[i] = port
            print(f"{i}) {port}")
        
        port = int(input("Select a port: "))
        if port in ports:
            self.port = ports[port]
        else:
            raise Exception("Invalid port selected.")
        

    # Read data from serial port:
    def read(self):
        res = int.from_bytes(self.ser.read(self.data_size), self.byteorder)
        return res

    # Write data to serial port:
    def write(self, data):
        self.ser.write(
            int(data).to_bytes(self.data_size, self.byteorder)
        )
    
    # Check if data is available to read (size of data_size):
    def check_data_available(self):
        return self.ser.in_waiting >= self.data_size

    # Close serial port:
    def close(self):
        self.ser.close()

    # Clear input and output buffers:
    def clear(self):
        self.ser.reset_input_buffer()
        self.ser.reset_output_buffer()
