# import the necessary packages
import argparse
import cv2


# variables

y = 20
h = 27
x = 975
w = 32
new_w = 16

# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument(
    "-i",
    "--image",
    type=str,
    required=True,
    help="path to input image where we'll apply template matching",
)
ap.add_argument("-o", "--one", type=str, required=True, help="first digit missing")
ap.add_argument("-t", "--two", type=str, required=True, help="second digit missing")
args = vars(ap.parse_args())

image = cv2.imread(args["image"])

image = image[y : y + h, x : x + w]
image_1 = image[1:h, 1:new_w]
image_2 = image[1:h, new_w : w - 1]
cv2.imwrite(args["one"] + ".jpg", image_1)
cv2.imwrite(args["two"] + ".jpg", image_2)
