import sys
import time
import random
# need to pip install paha-mqtt.  sys, and t
import paho.mqtt.client as mqtt

# The callback for when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))

    # Subscribing in on_connect() means that if we lose the connection and
    # reconnect then subscriptions will be renewed.
    client.subscribe("test")

# The callback for when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload))
client = mqtt.Client(client_id="CID_%08d" % (random.randint(0,99999999)))
print("built client")
client.on_connect = on_connect
client.on_message = on_message

client.username_pw_set(username='vzorwmts', password='cEJXsO-urZNa')
print("setup name and password")
client.connect("fantastic-gardener.cloudmqtt.com")
print ("made connection")

#
# Now just loop and spew random data to the five
while(True):
    sys.stdout.write('.')
    sys.stdout.flush()
    #Note that currently Panel1 isn't used for anything, but we can later use it as a locator
    #This version leaves the highest gauge (#5) untouched by the random generator, so it can be used for testing
    client.publish("test", payload=("%s %d %d" % ( "Panel1", random.randrange(1,5), random.randrange(50,101))));
    time.sleep(2);

client.disconnect()
