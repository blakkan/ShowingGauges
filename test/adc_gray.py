# Simple demo of setting the output voltage of the MCP4725 DAC.
# Will alternate setting 0V, 1/2VDD, and VDD each second.
# Author: Tony DiCola
# License: Public Domain
import time
import sys
import numpy as np
import cv2


# Import the MCP4725 module for DAC
import Adafruit_MCP4725

# Create a DAC instance.
dac = Adafruit_MCP4725.MCP4725()

# Note you can change the I2C address from its default (0x62), and/or the I2C
# bus by passing in these optional parameters:
#dac = Adafruit_MCP4725.MCP4725(address=0x49, busnum=1)

# Loop forever alternating through different voltage outputs.

def green_arc_percent_to_integer(the_percent):
    if the_percent < 7:
        linearize = 0.85
    if the_percent < 14:
	linearize = 0.95
    elif the_percent < 37:
	linearize = 0.97
    else:
        linearize = 1.00
    # with 2.186 K Ohm
    base = float(the_percent) * 40.960 * linearize * .185 #fudge factor .77
    return ( int( base + 0.5 ) )

def green_wedge_percent_to_integer(the_percent):
    if the_percent < 55 and the_percent > 15:
	linearize = 1.015
    elif the_percent > 60 and the_percent > 10:
        linearize = 1.0075
    else:
        linearize = 1.00
    # with 2.186 K Ohms
    base = float(the_percent) * 40.960 * .71 #fudge factor .
    return ( int( base + 0.5 ) )

def red_green_percent_to_integer(the_percent):
    # with 2.186 K Ohms
    base = float(the_percent) * 40.960 * .68 #fudge factor .
    return ( int( base + 0.5 ) )

def ma_percent_to_integer(the_percent):
    if the_percent < 85:
	linearize = 0.985
    else:
        linearize = 1.00
    # with 2.186 K Ohms
    base = float(the_percent) * 40.960 * linearize * .72 #fudge factor .
    return ( int( base + 0.5 ) )


requestedNumberOfFiles = int(sys.argv[2])
numberOfFilesOutput = 0
percentToInteger = None

cap = cv2.VideoCapture('/dev/video0') #In this part I put the route camera

cv2.startWindowThread()
cv2.namedWindow("preview")


if sys.argv[1] == "rg":
   percentToInteger = red_green_percent_to_integer
elif sys.argv[1] == "ma":
    percentToInteger = ma_percent_to_integer
elif sys.argv[1] == "ga":
    percentToInteger = green_arc_percent_to_integer
elif sys.argv[1] == "gw":
    percentToInteger = green_wedge_percent_to_integer
else:
   print ("first arg must be rg (red green), ma (milliamp), ga (green arc), or gw (green wedge)")
   exit()


print('Press Ctrl-C to quit...')
while (True):

    for percent in ( xrange(0,101,5) ):
        if numberOfFilesOutput >= requestedNumberOfFiles:
            exit()

    	print('Setting percentage to %d with value %d' % (percent, percentToInteger(percent)))
    	dac.set_voltage(percentToInteger(percent))
    	time.sleep( 2.0 if percent == 0  else 1.0)  #longer delay if it's going back to zero

        #Now take the picture (draining video buffer)
        for i in range(15):
          ret, frame = cap.read()

        # Our operations on the frame come here
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

	blurred = cv2.GaussianBlur(gray, (1,1),0)
	edged = cv2.Canny(blurred, 50, 250, 255)

        for i in range(3):
          ret, frame2 = cap.read()
        gray2 = cv2.cvtColor(frame2, cv2.COLOR_BGR2GRAY)

	blurred2 = cv2.GaussianBlur(gray2, (1,1),0)
	edged2= cv2.Canny(blurred2, 50, 250, 255)
	
	edged_final = cv2.bitwise_or(edged, edged2)
	
        cv2.imshow('preview', edged_final)
        #cv2.waitKey(0)


        #Now write it out   Name is <decile>.<percentile>.jpg
        cv2.imwrite("./%s_%03d_%03d_%08d.jpg" % \
	(sys.argv[1], percent, round(percent, -1),  numberOfFilesOutput + 1), edged_final)

        numberOfFilesOutput = numberOfFilesOutput + 1


