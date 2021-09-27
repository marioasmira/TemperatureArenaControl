import time
import serial
import csv


class Arena:
    def __init__(self):
        self.arduinoPort = ""
        # string to hold the port location
        self.serialHandle = -1
        # serial port
        self.version = "0.1"
        self.curTargetBaseTemp = 16
        # base temperature for the tiles
        self.curTargetTileTemp = {16, 16, 16}
        # current temperature of the tiles
        self.debug_on = (
            False  # to check if the arena is in debug mode (should not be by default)
        )
        print(
            "LoB Arena interface code, version " + self.version + "\n"
        )  # initialization string

    # function to display a message and wait dur amount of seconds
    def Wait(self, msg, dur):
        # print messages each second for the duration of dur
        endTime = time.time() + dur
        startTime = time.time()
        nextUpdate = 0
        while time.time() < endTime:
            if nextUpdate < time.time():
                print(msg + str(int(dur - round(time.time() - startTime))))
                nextUpdate = time.time() + 1

            # collect serial data to file if in debug mode
            if self.debug_on:
                ser_bytes = self.serialHandle.readline()
                decoded_bytes = str(ser_bytes[0 : len(ser_bytes) - 2].decode("utf-8"))
                with open("arena_data.csv", "a") as f:
                    writer = csv.writer(f, delimiter="\t")
                    writer.writerow([time.time(), decoded_bytes])

        # print done when finished
        print(msg + " done")

    # function to add the attributes and open the serial port to the arduino
    def Init(self, dataPort):
        self.arduinoPort = dataPort
        self.serialHandle = serial.Serial(
            self.arduinoPort, 115200, write_timeout=None, timeout=None
        )

        # throw error if the serial port is unavailable
        if True != self.serialHandle.is_open:
            print(
                "ERROR - Could not open USB serial port.  Please check your port name and permissions."
            )
            print("Exiting program.")
            exit()

    # function to define the base temperature at which the temperature arena will work
    def SetBaseTemp(self, temp):
        # throw error if base temperature is outside the normal bounds
        if temp < 5 or temp > 25:
            raise Exception("Base temperature should be between 5 and 25 degrees.")
        # check if the serial port is still available
        self.CheckSerialPort()
        # change relevant field in self
        self.curTargetBaseTemp = temp
        # send message to arduino
        self.serialHandle.write(("setcoppertemp=" + str(temp) + "\n").encode("utf-8"))

    # function to check if the serial port is open
    def CheckSerialPort(self):
        if self.serialHandle == -1:
            raise Exception("Serial port is not open. Call Arena.Init() first")

    # function to send message to arduino
    def Message(self, msg):
        self.serialHandle.write(("message=" + msg + "\n").encode("utf-8"))
        print("message=" + msg)

    # function to set a triplet of numbers as the temperature for the tiles
    def SetTileTemp(self, t1, t2, t3):
        tempList = [t1, t2, t3]

        # throw error if outside the normal temperature bounds
        if min(tempList) < 5 or max(tempList) > 60:
            raise Exception("Tile temperature should be between 5 and 60 degrees")
        # check if the serial port is still available
        self.CheckSerialPort()
        # send tile temperatures to arduino
        self.serialHandle.write(
            ("settiletemp=" + str(t1) + "," + str(t2) + "," + str(t3) + "\n").encode(
                "utf-8"
            )
        )

    # function to check if the arduino is responding
    def AreYouThere(self):
        # check if the serial port is still available
        self.CheckSerialPort()
        # Send message to arduino
        self.Message("Yes I am")

    # function to output the serial information
    def GetHandle(self):
        return self.serialHandle

    # function to close and reset the serial connection
    def Stop(self):
        if self.serialHandle != -1:
            self.serialHandle.close()
        self.serialHandle = -1

    # function to change the on/off postion of both LEDS in the temperature arena
    def LED(self, l1, l2):
        # check if the serial port is still available
        self.CheckSerialPort()
        # send message to the arduino
        self.serialHandle.write(
            ("leds=" + str(l1) + "," + str(l2) + "\n").encode("utf-8")
        )

    # toggle debug to receive serial data
    def Debug(self, turn_on):
        # if the wanted state is different
        if self.debug_on != turn_on:
            # check if the serial port is still available
            self.CheckSerialPort()
            # send message to the arduino
            self.serialHandle.write(("DEBUG\n").encode("utf-8"))
