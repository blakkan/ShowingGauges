import pigpio
import time

pi = pigpio.pi()

while(1):
    text = raw_input("percent")
    thevalue = int(text) * (2500) #8800 for the 15V meter

    #10 KHz (first arg, then  10%
    pi.hardware_PWM(18, 10000, thevalue)
