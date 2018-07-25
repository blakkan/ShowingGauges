# README - W251 project

## Overview

Project is to monitor gauges (using camera-equipped Raspberry Pi).  

The first part of the project uses a camera-equipped Raspberry Pi running a CNN to interpret the gauge
(either taking a reading (as percent of full scale deflection) or
indicating error state, then publishes the results via mosquitto.  

Second part is a Javascript/D3 enabled webpage (served via Rails) which subscribes to the mosquitto stream and updates the
webpage.  We'll use little of the rails framework's full power (mostly just the javascript), but will have it available
if we need it for multi-page operations (e.g. might have different page formats for different gauges or gauge panels.)

Third part is the training of the CNN, which will take place in the cloud.

Fourth part is generating all the training images.   This also uses a Raspberry Pi to capture the images of the gauges driven
to a known state (This could also be done with an Arduino, but it's convenient to consolidate the setting of the gauge and
the recording of labeled training images in one microcomputer).

And of course, preparing a powerpoint presentation and any written documentation.

## Structure of this repo

The repo is set up using the rails framework, so the great majority of the files and directories are rails boilerplate.  Rails
does have various directories suitable for holding miscellaneous code-  These are the "lib" (library) and the "test" directories.


