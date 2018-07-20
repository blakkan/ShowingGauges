import sys
import time
import random
# need to pip install paha-mqtt
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

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.username_pw_set('ttmprkzz', password='5xwOtwTxUcop')
client.connect("m13.cloudmqtt.com", 15797, 60)

while(True):
    sys.stdout.write('.')
    sys.stdout.flush()
    client.publish("test", payload=("%s %d %d" % ( "program", random.randrange(1,6), random.randrange(50,101))));
    time.sleep(2);
client.disconnect()

# Blocking call that processes network traffic, dispatches callbacks and
# handles reconnecting.
# Other loop*() functions are available that give a threaded interface and a
# manual interface.
#client.loop_forever()
