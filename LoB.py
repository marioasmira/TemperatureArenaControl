import time
import serial

class Arena:
    def __init__(self):
        self.bufSize = 100000; # in ms
        self.bufChannels = 9;
        self.arduinoPort = "";
        self.dataPort = "";
        self.serialHandle = -1;
        self.dataFile = [];
        self.dataHandle = -1;
        self.version = "1.0a"
        self.curTargetBaseTemp = 15;
        self.curTargetTileTemp = {25, 25, 25};
        print("LoB Arena interface code, version " + self.version + "\n")

    def Wait(self, msg, dur):
        endTime = time.time() + dur
        startTime = time.time() 
        nextUpdate = 0
        while time.time() < endTime:
            if nextUpdate < time.time():
                print(msg + str(int(dur-round(time.time()-startTime))));
                nextUpdate = time.time() + 1;
        print(msg + "done");


    def Init(self, dataPort):
        self.dataPort = dataPort;
        try:
            self.dataHandle = serial.Serial(self.dataPort, 115200, timeout=2)
            self.serialHandle = self.dataHandle
        except:
            print("ERROR - Could not open USB serial port.  Please check your port name and permissions.")
            print("Exiting program.")
            exit()

    def SetBaseTemp(self, temp):
        if temp < 5 or temp > 25:
            raise Exception("Base temperature should be between 5 and 25 degrees.")
        self.CheckSerialPort()
        self.curTargetBaseTemp = temp
        self.serialHandle.write(b"setcoppertemp=" + str(temp))

    def CheckSerialPort(self):
        if self.serialHandle == -1:
            raise Exception("Serial port is not open. Call Arena.Init() first")

    def Message(self, msg):
        self.serialHandle.write(b"message=" + msg)
        print("message="+msg)

    def SetTileTemp(self, t1, t2, t3):
        tempList = [t1, t2, t3]
        if min(tempList) < 5 or max(tempList) > 60:
            raise Exception("Tile temperature should be between 5 and 60 degrees")
        self.CheckSerialPort()
        self.serialHandle.write(b"settiletemp="+str(t1)+","+str(t2)+","+str(t3))

    def Boost(self, b1, b2, b3):
        boostList = [b1, b2, b3]
        if sum(boostList) > 2:
            raise Exception("Only two tiles can be boosted at the same time.")
        self.CheckSerialPort()
        self.serialHandle.write(b"boost="+str(b1)+","+str(b2)+","+str(b3))

    def AreYouThere(self):
        self.CheckSerialPort()
        self.Message(self, "Yes I am")

    def GetHandle(self):
        return(self.serialHandle)

    def Stop(self):
        if self.serialHandle != -1:
            self.serialHandle.close()
        self.serialHandle = -1

    def LED(self, l1, l2):
        self.CheckSerialPort()
        self.serialHandle.write(b"leds="+str(l1)+","+str(l2))

