# import the necessary packages
import argparse
import time
import cv2
import sys
import csv
from os import walk


class FileError(Exception):
    def __init__(self, message):
        self.message = message

    def __str__(self):
        return repr(self.message)


def split_time(duration):
    sec_value = duration % (24 * 3600)
    hour_value = sec_value // 3600
    sec_value %= 3600
    min_value = sec_value // 60
    sec_value %= 60
    return [hour_value, min_value, sec_value]


# function that matches the digits provided with the video
def digit_match(video_file, data_list, digit_numbers, gray_digits, positions):
    print(video_file + ": Started reading file...")

    stopped = False
    counter = 1
    vs = cv2.VideoCapture(video_file)
    if not vs.isOpened():
        raise FileError("Couldn't open video file.")

    # runs for all frames
    sucess = True
    while sucess:
        sucess, frame = vs.read()

        if not sucess:
            break

        short_frame = frame[
            positions["y"] : positions["y"] + positions["h"],
            positions["x"] : positions["x"] + positions["w"],
            :,
        ]
        short_frame = cv2.cvtColor(short_frame, cv2.COLOR_BGR2GRAY)

        # breaks the frame into 2 small parts to read the digits
        image_1 = short_frame[1 : positions["h"], 1 : positions["new_w"]]
        image_2 = short_frame[
            1 : positions["h"], positions["new_w"] : positions["w"] - 1
        ]

        first_match = []
        second_match = []

        for d in gray_digits:
            result = cv2.matchTemplate(image_1, d, cv2.TM_CCOEFF_NORMED)
            (minVal, maxVal, minLoc, maxLoc) = cv2.minMaxLoc(result)
            first_match.append(maxVal)

            result = cv2.matchTemplate(image_2, d, cv2.TM_CCOEFF_NORMED)
            (minVal, maxVal, minLoc, maxLoc) = cv2.minMaxLoc(result)
            second_match.append(maxVal)

        # find the best matching digit
        max_first = first_match.index(max(first_match))
        max_second = second_match.index(max(second_match))

        # output into the list
        data_list.append(
            [
                counter,
                digit_numbers[max_first] * 10 + digit_numbers[max_second],
                max(first_match),
                max(second_match),
            ]
        )

        # for debugging and position adjusting purposes
        """ print(
            [
                digit_numbers[max_first] * 10 + digit_numbers[max_second],
                max(first_match),
                max(second_match),
            ]
        )
        if max(first_match) < 0.9:
            print(first_match)
        if max(second_match) < 0.9:
            print(second_match)
        cv2.imshow("1", image_1)
        cv2.imshow("2", image_2)
        cv2.waitKey()
        cv2.destroyAllWindows """

        counter += 1
    print(video_file + ": Finished! Outputing results...")
    return stopped, counter


def main():

    # argumets
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "-v",
        "--video",
        type=str,
        required=True,
        help="path to input video to read temperature",
    )
    ap.add_argument(
        "-d",
        "--digits",
        type=str,
        required=True,
        help="path to the digits to compare with video",
    )
    args = vars(ap.parse_args())

    # check if only one file or a directory
    video_extension = ".mp4"
    if args["video"].find(video_extension) != -1:
        video_file = [args["video"]]
    else:
        video_file = []
        filenames = next(walk(args["video"]), (None, None, []))[2]  # [] if no file
        files = [k for k in filenames if video_extension in k]
        for v in files:
            video_file.append(v[:0] + args["video"] + v[0:])

    # positions for the 2 digits
    positions = {"y": 17, "h": 32, "x": 972, "w": 38, "new_w": 19}

    # load the digits
    digit_numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    gray_digits = []
    for d in digit_numbers:
        gray_digits.append(
            cv2.imread(args["digits"] + str(d) + ".jpg", cv2.IMREAD_GRAYSCALE)
        )

    # loop through all the vidoes in the folder (or just the provided video)
    for video in video_file:
        result_list = []
        start = time.time()
        output = video.replace(".mp4", ".csv")

        # find the digits
        try:
            stopped, counter = digit_match(
                video,
                result_list,
                digit_numbers,
                gray_digits,
                positions,
            )
        except FileError as e:
            print(e)
            sys.exit(1)

        # output data to csv
        try:
            f = open(output, "w")
        except IOError:
            print("Couldn't open output file.")

        writer = csv.writer(f)
        for i in range(len(result_list)):
            writer.writerow(result_list[i])
        f.close()

        # report back on how it went
        end = time.time()
        duration = split_time(end - start)
        if not stopped:
            outcome = "Sucessfuly reached the end of the file."
        else:
            outcome = "Failed to read the end of the file."
        print(
            video
            + ": Took {} hours, {} minutes and {} seconds. ".format(
                int(duration[0]), int(duration[1]), int(duration[2])
            )
            + outcome
        )


if __name__ == "__main__":
    main()
