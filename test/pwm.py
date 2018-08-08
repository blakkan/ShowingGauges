import RPi.GPIO as GPIO

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
 
# Setup GPIO Pins
GPIO.setup(12, GPIO.OUT)
GPIO.setup(13, GPIO.OUT)
GPIO.setup(18, GPIO.OUT)
GPIO.setup(19, GPIO.OUT)

 
# Set PWM instance and their frequency
pwm12= GPIO.PWM(12, 1000)
pwm13= GPIO.PWM(13, 1000)
pwm18= GPIO.PWM(18, 1000)
pwm19= GPIO.PWM(19, 1000)

 
# Start PWM with 33% Duty Cycle

pwm12.start(33)
pwm13.start(33)
pwm18.start(33)
pwm19.start(33)

 
raw_input('Press return to stop:')	#Wait
 
# Stops the PWM
pwm12.stop()
pwm13.stop()
pwm18.stop()
pwm19.stop()
 
# Cleans the GPIO
GPIO.cleanup()
