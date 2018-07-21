#!/usr/bin/python
import sys
import numpy as np
import cv2
import time

if len(sys.argv) < 5:
    print( "Usage: capture <# frames to OR> <file output prefix> <number of files> <float sec delay>")
    exit()

list_of_frames = []
frame_number = 1
sleepy_time = float(sys.argv[4])

cap = cv2.VideoCapture('/dev/video0') #In this part I put the route camera

 

while(frame_number < int(sys.argv[3])):
    
    time.sleep(sleepy_time)

    # Capture frame-by-frame
    ret, frame = cap.read()
    # Our operations on the frame come here
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (1,1),0)
    edged = cv2.Canny(blurred, 50, 250, 255)


    list_of_frames.append(edged)
    while len(list_of_frames) > int(sys.argv[1]):
        list_of_frames.pop(0)
    if len(list_of_frames) < int(sys.argv[1]):
        continue
        
    display = reduce(cv2.bitwise_or, list_of_frames)

    cv2.imshow('frame', display)
    cv2.imwrite("./%s_%08d.jpg" % (sys.argv[2], frame_number), display)
    
    frame_number = frame_number+1

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

 

# When everything done, release the capture

cap.release()

cv2.destroyAllWindows()
