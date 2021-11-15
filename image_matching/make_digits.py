# import the necessary packages
import argparse
import cv2


# positions of where the digits are found in the input video
y = 20 # top bound
h = 27 # height of the digits
x = 975 # left bound
w = 32 # width of both digits
new_w = 16 # middle point between digits

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

# reads the image
image = cv2.imread(args["image"])

# cuts the image into de small zone defined by the parameters at the start
image = image[y : y + h, x : x + w]
# image 1 is the first digit
image_1 = image[1:h, 1:new_w]
# image 2 is the second digit
image_2 = image[1:h, new_w : w - 1]

# save both digits
cv2.imwrite(args["one"] + ".jpg", image_1)
cv2.imwrite(args["two"] + ".jpg", image_2)
