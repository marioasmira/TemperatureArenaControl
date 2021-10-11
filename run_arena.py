# Default script to control a temperature arena
# and record a video at the same time
# Author: Mário
# Date: 10/09/2020

# ---------------- Setup -------------------------------
import picamera  # for camera
import os  # for conversion at the end
import time  # for sleep
from arena import Arena  # for Arena class
from thermistor import Thermistor
import sys, traceback
import csv


def wait(step, step_duration, exp_temp, sensors, record_data) -> None:
    # print messages each second for the duration of dur
    endTime = time.time() + step_duration
    startTime = time.time()
    nextUpdate = 0
    while time.time() < endTime:
        if nextUpdate < time.time():
            print(
                "Step: "
                + str(step)
                + ", temperature = "
                + str(exp_temp)
                + ", time left = "
                + str(int(step_duration - round(time.time() - startTime)))
            )
            nextUpdate = time.time() + 1

        # collect serial data to file if in debug mode
        output = []
        if record_data:
            for sensor in sensors:
                read = sensor.read()
                output += read
            # box_bytes = arena.Read()
            # sensor_bytes = thermistor.read()
            # output = box_bytes + sensor_bytes
            with open("arena_data.csv", "a") as f:
                writer = csv.writer(f, delimiter=",", quoting=csv.QUOTE_MINIMAL)
                writer.writerow(output)


def main() -> None:
    # -------------- Parameters --------------------------
    step_duration = 10  # duration of each stimulus in seconds
    accommodation_steps = 1  # number of stimulus for accomodation
    experimental_steps = 2  # number of experimental stimulus
    total_steps = accommodation_steps + experimental_steps  # total stimulus
    initial_temperature = 16  # default temperature - should be 16
    temperature_step = 2  # how much to  increase temperature per experimental step
    port_nat = "/dev/ttyACM0"  # Change according to computer
    port_nat_thermistor = "/dev/ttyACM1"  # Change according to computer
    record_data = True
    file_save_location = ""  # where to save the video files
    have_preview = True  # if camera preview will be shown
    convert = True  # if the file should be converted at the end
    cam_resolution = (1920, 1080)  # camera resolution (needs to be a tuple)
    cam_framerate = 30  # camera framerate

    try:
        # ----------- Initialize Arena ----------------------
        # Start temperature-controlled box
        arena = Arena(port_nat, initial_temperature)  # starts the arena class
        arena.LED(0, 0)  # Both indicative red LEDs will be off
        arena.SetBaseTemp(
            initial_temperature
        )  # Minimum temperature for continuous cooling
        arena.Message("Init done")  # Message will appear on LCD screen
        sensors = [arena]
        if record_data:
            thermistor = Thermistor(port_nat_thermistor)
            sensors.append(thermistor)

        # --------- Initialize Camera ------------------------
        # initiate file name and camera object
        name_input = input(
            "Video file name (avoid using spaces): "
        )  # ask for video file name
        name = file_save_location + name_input  # add the folder location
        file = name + ".h264"  # append the video file format
        camera = picamera.PiCamera(
            resolution=cam_resolution, framerate=cam_framerate
        )  # initialize the camera class
        time.sleep(2)  # wait 2 seconds for the camera to ajust to light conditions

        # -------------------Experiment ----------------------
        # stops here and waits for the user to press Enter
        input("Press Enter to start the experiment...")

        if have_preview:
            camera.start_preview()  # launches a window where the user can see what is being recorded
        camera.start_recording(file, format="h264")  # starts the recording
        exp_temp = initial_temperature  # start the experimental temperature at the same temp as initial
        camera.annotate_text = "T = " + str(exp_temp)

        # Start the experimental block
        for step in range(
            1, total_steps + 1
        ):  # +1 because range ends before the second value
            if (step % 2) == 0:  # if even number
                arena.LED(1, 0)
            else:  # if uneven number
                arena.LED(0, 1)

            if (
                step > accommodation_steps
            ):  # The first 7 minutes happen at 16C to allow flies to explore
                exp_temp = exp_temp + temperature_step

            arena.SetTileTemp(
                exp_temp, exp_temp, exp_temp
            )  # changes temperatures to experimental temperature
            # annotation on the video to track temperature afterwards
            annotation_string = "T = " + str(exp_temp)
            camera.annotate_text = annotation_string

            wait(step, step_duration, exp_temp, sensors, record_data)

            # print done when finished
            print("Step: " + str(step) + ", temperature = " + str(exp_temp) + " done")

        # ---------------- Reset ---------------------------------------
        # stop recording
        camera.stop_recording()  # stops recording
        if have_preview:
            camera.stop_preview()  # stops the window preview

        # reset leds and temperatures
        arena.LED(0, 0)  # turns off both leds
        arena.SetBaseTemp(
            initial_temperature
        )  # returns temperature to initial temperatures

        # ---------------- Convert to mp4 ---------------------------------------
        if convert:
            # commands to immediately convert to mp4
            command = (
                "ffmpeg -i " + file + " -vcodec copy " + name + ".mp4"
            )  # defines the command to run in the terminal
            os.system(command)  # runs the command defined above in the terminal

    except KeyboardInterrupt:
        print("Interrupted... Exiting.")
    finally:
        camera.close()
        arena.Close()
        sys.exit(0)


if __name__ == "__main__":
    main()
