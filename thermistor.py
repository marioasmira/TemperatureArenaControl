import serial
import sys
from serial.serialutil import SerialException


class PortError(Exception):
    def __init__(self, message):
        self.message = message

    def __str__(self):
        return repr(self.message)


class Thermistor:
    def __init__(self, serial_port) -> None:
        self.port = serial_port
        try:
            self.serial_handle = serial.Serial(
                self.port, 9600, write_timeout=None, timeout=None
            )
        except SerialException as e:
            print(
                "ERROR - Could not open USB serial port for thermistor.  Please check your port name and permissions.\nExiting program."
            )
            sys.exit(1)

    def read(self):
        try:
            # check if the serial port is still available
            self.CheckSerialPort()
        except PortError as e:
            print(e)
        ser_bytes = self.serial_handle.readline()
        decoded_bytes = str(ser_bytes[0 : len(ser_bytes) - 2].decode("utf-8"))
        float_bytes = []
        error = False
        for val in decoded_bytes.split("\t"):
            try:
                float_bytes.append(float(val))
            except ValueError:
                continue
        return float_bytes

    # function to check if the serial port is open
    def CheckSerialPort(self):
        if not self.serial_handle.is_open:
            raise PortError("USB serial port for thermistor is not open.")

    def Close(self):
        try:
            self.CheckSerialPort()
        except PortError:
            return
        else:
            self.serial_handle.close()
