import time
import serial
import csv
import sys

from serial.serialutil import SerialException


class PortError(Exception):
    def __init__(self, message):
        self.message = message

    def __str__(self):
        return repr(self.message)


class BoundsError(Exception):
    def __init__(self, message):
        self.message = message

    def __str__(self):
        return repr(self.message)


class Arena:
    def __init__(self, dataPort, baseTemp):
        self.arduinoPort = dataPort
        try:
            # string to hold the port location
            self.serialHandle = serial.Serial(
                self.arduinoPort, 115200, write_timeout=None, timeout=None
            )
        except SerialException as e:
            print(
                "ERROR - Could not open USB serial port.  Please check your port name and permissions.\nExiting program."
            )
            sys.exit()
        # serial port
        self.version = "0.1"
        self.curTargetBaseTemp = baseTemp
        self.SetBaseTemp(baseTemp)
        # base temperature for the tiles
        self.curTargetTileTemp = {baseTemp, baseTemp, baseTemp}

        print(
            "LoB Arena interface code, version " + self.version + "\n"
        )  # initialization string

    def Close(self):
        try:
            self.CheckSerialPort()
        except PortError:
            return
        else:
            self.serialHandle.close()

    # function to check if the serial port is open
    def CheckSerialPort(self):
        if (not self.serialHandle.is_open) or self.serialHandle == -1:
            raise PortError("USB serial port is not open. Call Arena.Init() first")

    def GetVersion(self):
        # check port
        self.CheckSerialPort()

        # send message
        self.serialHandle.write(("VERSION\n").encode("utf-8"))

        # receive and print reply
        ser_bytes = self.serialHandle.readline()
        decoded_bytes = str(ser_bytes[0 : len(ser_bytes) - 2].decode("utf-8"))
        return decoded_bytes

    # function to display a message and wait dur amount of seconds
    def Wait(self, msg, dur, record=False):
        # print messages each second for the duration of dur
        endTime = time.time() + dur
        startTime = time.time()
        nextUpdate = 0
        while time.time() < endTime:
            if nextUpdate < time.time():
                print(msg + str(int(dur - round(time.time() - startTime))))
                nextUpdate = time.time() + 1

            # collect serial data to file if in debug mode
            if record:
                try:
                    # check if the serial port is still available
                    self.CheckSerialPort()
                    thermistor = serial.Serial(
                        "/dev/ttyAMC1", 9600, write_timeout=None, timeout=None
                    )
                except PortError as e:
                    print(e)

                ser_bytes = self.serialHandle.readline()
                decoded_bytes = str(ser_bytes[0 : len(ser_bytes) - 2].decode("utf-8"))

                ser_bytes_temperature = self.serialHandle.readline()
                decoded_bytes_temperature = str(
                    ser_bytes_temperature[0 : len(ser_bytes_temperature) - 2].decode(
                        "utf-8"
                    )
                )
                output = decoded_bytes + "\t" + decoded_bytes_temperature
                with open("arena_data.csv", "a") as f:
                    writer = csv.writer(f, delimiter="\t", quoting=csv.QUOTE_NONE)
                    writer.writerow([output])

        # print done when finished
        print(msg + " done")

    # function to define the base temperature at which the temperature arena will work
    def SetBaseTemp(self, temp):
        # throw error if base temperature is outside the normal bounds
        try:
            if temp < 5 or temp > 25:
                raise BoundsError(
                    "Base temperature should be between 5 and 25 degrees."
                )
            # check if the serial port is still available
            self.CheckSerialPort()
        except (BoundsError, PortError) as e:
            print(e)

        # change relevant field in self
        self.curTargetBaseTemp = temp
        # send message to arduino
        self.SetTileTemp(temp, temp, temp)

    # function to send message to arduino
    def Message(self, msg):
        try:
            # check if the serial port is still available
            self.CheckSerialPort()
        except PortError as e:
            print(e)

        self.serialHandle.write(("message=" + msg + "\n").encode("utf-8"))
        print("message=" + msg)

    # function to set a triplet of numbers as the temperature for the tiles
    def SetTileTemp(self, t1, t2, t3):
        tempList = [t1, t2, t3]

        try:
            # throw error if outside the normal temperature bounds
            if min(tempList) < 5 or max(tempList) > 60:
                raise BoundsError("Tile temperature should be between 5 and 60 degrees")
            # check if the serial port is still available
            self.CheckSerialPort()
        except (BoundsError, PortError) as e:
            print(e)

        # send tile temperatures to arduino
        self.serialHandle.write(
            ("settiletemp=" + str(t1) + "," + str(t2) + "," + str(t3) + "\n").encode(
                "utf-8"
            )
        )

    # function to check if the arduino is responding
    def AreYouThere(self):
        try:
            # check if the serial port is still available
            self.CheckSerialPort()
        except PortError as e:
            print(e)

        # Send message to arduino
        self.serialHandle.write(("AREYOUTHERE\n").encode("utf-8"))
        # receive and print reply
        ser_bytes = self.serialHandle.readline()
        decoded_bytes = str(ser_bytes[0 : len(ser_bytes) - 2].decode("utf-8"))
        print(decoded_bytes)

    # function to output the serial information
    def GetHandle(self):
        return self.serialHandle

    # function to close and reset the serial connection
    def Stop(self):
        try:
            # check if the serial port is still available
            self.CheckSerialPort()
        except PortError as e:
            print(e)
        if self.serialHandle != -1:
            self.serialHandle.close()
        self.serialHandle = -1

    # function to change the on/off postion of both LEDS in the temperature arena
    def LED(self, l1, l2):
        try:
            # check if the serial port is still available
            self.CheckSerialPort()
        except PortError as e:
            print(e)
        # send message to the arduino
        self.serialHandle.write(
            ("leds=" + str(l1) + "," + str(l2) + "\n").encode("utf-8")
        )

    # toggle debug to receive serial data
    def Debug(self, turn_on):
        try:
            # check if the serial port is still available
            self.CheckSerialPort()
        except PortError as e:
            print(e)

        # Send message to arduino
        self.serialHandle.write(("GETDEBUG\n").encode("utf-8"))
        # receive and print reply
        ser_bytes = self.serialHandle.readline()
        decoded_bytes = str(ser_bytes[0 : len(ser_bytes) - 2].decode("utf-8"))

        # the status of the arduino
        # if the message matches it means it is in debug mode
        status = not (decoded_bytes == "DEBUG_OFF")
        # if the wanted state is different
        if status != turn_on:
            # send message to the arduino
            self.serialHandle.write(("DEBUG\n").encode("utf-8"))
