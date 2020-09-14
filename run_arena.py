# Hipothetical script to control a temperature arena
# and record a video at the same time
# Author: Mário
# Date: 10/09/2020

#---------------- Setup -------------------------------
import picamera # for camera
import os # for conversion at the end
import time # for sleep
import LoB # for Arena class

# -------------- Parameters --------------------------
StimulusDur = 60 # duration of each stimulus in seconds
accomodation_steps = 7 # number of stimulus for accomodation
experimental_steps = 15 # number of experimental stimulus
total_steps = accomodation_steps + experimental_steps # total stimulus
initial_temperature = 16 # default temperature - should be 16
temperature_step = 2 # how much to  increase temperature per experimental step

# ----------- Initialize Arena ----------------------
# Start temperature-controlled box
arena = LoB.Arena() # starts the arena class
port_nat = '/dev/ttyACM0' # Change according to computer
arena.Init(port_nat) # connect and initialize the computer to the temperature arena
arena.Message('Init done') # Message will appear on LCD screen
arena.LED(0,0) # Both indicative red LEDs will be off
arena.SetBaseTemp(initial_temperature) # Minimum temperature for continuous cooling
arena.SetTileTemp(initial_temperature, initial_temperature, initial_temperature) #Start-up temperature of each of the three copper tiles

# --------- Initialize Camera ------------------------
# initiate file name and camera object
name = input("Video file name (avoid using spaces): ") # ask for video file name
file = name + ".h264" # append the video file format
camera = picamera.PiCamera() # initialize the camera class
camera.resolution = (1920, 1080) # set resolution
camera.framerate = 30 # set framerate to record
time.sleep(2) # wait 2 seconds for the camera to ajust to light conditions

# -------------------Experiment ----------------------
# stops here and waits for the user to press Enter
input("Press Enter to continue...")

camera.start_preview() # launches a window where the user can see what is being recorded
camera.start_recording(file, format = "h264") # starts the recording
exp_temp = initial_temperature # start the experimental temperature at the same temp as initial

# Start the experimental block
for i in range(1,total_steps):
    if (i % 2) == 0:            # if even number
        arena.LED(1,0)
    else:               # if uneven number
        arena.LED(0,1)
        
    if (i > accomodation_steps):    # The first 7 minutes happen at 16C to allow flies to explore
        exp_temp = exp_temp + temperature_step
    
    arena.SetTileTemp(exp_temp, exp_temp, exp_temp) # changes temperatures to experimental temperature
    arena.Wait(str(i) + "Stim", StimulusDur) # waits for the number of seconds in StimulusDur

# ---------------- Reset ---------------------------------------

# stop recording
camera.stop_recording() # stops recording
camera.stop_preview() # stops the window preview

# reset leds and temperatures
arena.LED(0,0) # turns off both leds
arena.SetTileTemp(initial_temperature, initial_temperature, initial_temperature) # returns temperature to initial temperatures

# commands to immediately convert to mp4
command = "ffmpeg -i " + file + " -vcodec copy " + name + ".mp4" # defines the command to run in the terminal
os.system(command) # runs the command defined above in the terminal
