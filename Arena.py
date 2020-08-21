#!/usr/bin/env python3
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


    def Init(self, dataPort)
        self.dataPort = dataPort;

        try:
            self.dataHandle = serial.Serial(self.dataPort, 115200, timeout=2)
            self.serialHandle = self.dataHandle
        except:
            print("ERROR - Could not open USB serial port.  Please check your port name and permissions.")
            print("Exiting program.")
            exit()

t = Arena()

t.Wait("Init... ", 5)
