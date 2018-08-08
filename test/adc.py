# Simple demo of setting the output voltage of the MCP4725 DAC.
# Will alternate setting 0V, 1/2VDD, and VDD each second.
# Author: Tony DiCola
# License: Public Domain
import time
import sys
print ("\n").join(sys.argv)

# Import the MCP4725 module.
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

if sys.argv[1] == "rg":
   percentToInteger = red_green_percent_to_integer
elif sys.argv[1] == "ma":
    percentToInteger = ma_percent_to_integer
elif sys.arg[1] == "ga":
    percentToInteger = green_arc_percent_to_integer
elif sys.arg[1] == "gw":
    percentTponteger = green_wedge_percent_to_integer
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
    	time.sleep( 4.0 if percent == 0  else 2.0)  #longer delay if it's going back to zero

        #Now take the picture


        #Now write it out

        #Now increment total count by 1
        numberOfFilesOutput = numberOfFilesOutput + 1



