##################################################################
#
#  watcher.py
#
#    This program watches gauges and sends mqtt messages about gauge needle positions.
#  (Or the word "VOID" if it can't decypher a gauge)
#
#   Basic flow:
#      1. Initialize meter drive
#      2. Initialize video read
#      3. Initialize MQTT connection
#      4. Initialize keras classifier (i.e. load the model)
#      Then loop forever:
#           5. Drive the meter to a random value
#           6. Capture a video image
#           7. Run the classifier
#           8. Send the classification to the MQTT service (which publishes it for javascript access on the website)
#
#   Command line arguments: 
#        -m <keras classifier model file>
#        -n  <meter number for display [e.g. 1, 2, etc.>
#        -t   <meter type,  ma, rg, gw, or ga>
#       -d          # if present, a "dummy" classifier is used- the value returned is simply what was driven
#
##################################################################

import time
import sys
import numpy as np
import cv2					# Basic image capture, color desaturation
import Adafruit_MCP4725  	# Import the MCP4725 module for DAC
import argparse
import random
import paho.mqtt.client as mqtt   #use pip to install paho-mqtt

parser = argparse.ArgumentParser()
parser.add_argument("-d", "--dummy",  help="use dummy classifier", action = "store_true")
parser.add_argument("-t", "--type", type=str, help="meter type [rg, ma, gw, or ga]")
parser.add_argument("-m", "--model", type=str, help="name of model file")
parser.add_argument("-n", "--number", type=int, help="meter number on web display")

args = parser.parse_args()

#print args.dummy
#print args.type
#print args.model
#print args.number


########################################################
#
# Set up meter drive
#
# Create a DAC control instance and define some helper functions
#
########################################################

dac = Adafruit_MCP4725.MCP4725()


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

percentToInteger = None

if args.type == "rg": 
   percentToInteger = red_green_percent_to_integer
elif args.type == "ma":
    percentToInteger = ma_percent_to_integer
elif args.type == "ga":
    percentToInteger = green_arc_percent_to_integer
elif args.type == "gw":
    percentToInteger = green_wedge_percent_to_integer
else:
   print ("type must be rg (red green), ma (milliamp), ga (green arc), or gw (green wedge)")
   exit(1)

#################################################
#
#  Set up camera
#
#################################################

cap = cv2.VideoCapture('/dev/video0') 

# These two lines set up a separate thread for displaying a preview image
# locally.   For real systems, there probably wouldn't be a local preview

cv2.startWindowThread()    
cv2.namedWindow("preview")


###############################################
#
#  Initialize the MQTT connection
#
###############################################

# The callback for when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))

    # Subscribing in on_connect() means that if we lose the connection and
    # reconnect then subscriptions will be renewed.
    client.subscribe("test")

# The callback for when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload))

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.username_pw_set('vzorwmts', password='cEJXsO-urZNa')
client.connect("fantastic-gardener.cloudmqtt.com", 1883, 60)

#TODO: really should add our own nice, polite "client.disconnect()" in a ctrl-C handler

###############################################
#
#  Initialize the classifier (e.g. load the previously-trained model
#
###############################################

#TODO
# for now, we're relying on the -d to always be set
if not args.dummy:
	print "Sorry, must specify dummy classifier for now"
	exit(1)

################################################
#
#   And enter the endless loop, with the classic syntax
#
################################################

while (True):

    #We're going to cycle from bottom of scale to top of scale, then drop back to bottom of scale.
    #for percent in ( xrange(0,101,5) ):  #or, for more fun, use random.range instead of xrange
    if (True):
	percent = random.randrange(0,101,5)

	#
        # Set the meter
	#
    	print('Setting percentage to %d with value %d' % (percent, percentToInteger(percent)))
    	dac.set_voltage(percentToInteger(percent))
    	time.sleep( 0.5 if percent == 0  else 1.5)  #longer delay if it's going back to zero

	#
        # Take the picture (draining video buffer)
	#
        for i in range(5):
          ret, frame = cap.read()

        # Our operations on the frame come here
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

        cv2.imshow('preview', frame)
        #cv2.waitKey(0)

        #Now write out just last image (in color) for debug, if desired.
        cv2.imwrite("latest_frame.jpg", frame)

	#
        # Classify
	#

	if args.dummy:
		classification = str(percent)
	else:
		# TODO
		print "classifier not yet implemented, you need to specify -dummy"
		exit(1)
	# At this point, classification is either a string representation of a number 0 to 100, or the word "VOID"


	#
	# Send the result to the MQTT broker
	#

	client.publish("test", payload=("%s %d %s" % ( "unused", args.number,  classification)))

	time.sleep(1);   #just a go-slow, for now.



