#!/usr/bin/python
import sys
import numpy as np
import cv2
import time
import pigpio

# Here's how we cycle through
def frame_number_to_percent(frame_number):
	sawtooth = frame_number % 201
	if sawtooth <= 100:
		triangle = sawtooth
	else:
		triangle = 200 - sawtooth
	return triangle


if len(sys.argv) < 4:
    print( "Usage: capture  <number of files> <float sec delay> <starting value>")
    exit()

pi = pigpio.pi()

frame_number =int(sys.argv[3])
sleepy_time = float(sys.argv[2])

cap = cv2.VideoCapture('/dev/video1') #In this part I put the route camera



while(frame_number < int(sys.argv[1])):
    print frame_number_to_percent(frame_number)
    print frame_number
    # Constant is 2500; would be 8800 for the 15V meter  2500 for big meter
    thevalue = frame_number_to_percent(frame_number) * 8800
    #10 KHz (first arg, then  scaled percent)
    pi.hardware_PWM(18, 40000, thevalue)

    #time.sleep(sleepy_time)  #let the meter settle, and video flush
    for i in range(30):
      ret, frame = cap.read()

    # Our operations on the frame come here
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)


    cv2.imshow('frame', gray)
    cv2.imwrite("./%03d_%08d.jpg" % \
	(frame_number_to_percent(frame_number),  frame_number), gray)

    frame_number = frame_number+1

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break



# When everything done, release the capture

cap.release()

cv2.destroyAllWindows()
