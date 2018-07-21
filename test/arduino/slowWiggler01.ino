//
// The slow wiggle will be 10 and 1.  The fast wiggle will be 1 and 3
//

#define SPEED_MULTIPLY 1
#define SPEED_DIVIDE 3

int meterDrive( int sequence, int halfPeriod, int maxVal );
void bipolarDrive( int address, int value );
int tick = 0;

// the setup function runs once when you press reset or power the board
void setup() {
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(2, OUTPUT);
  pinMode(4, OUTPUT);

  //Serial.begin(115200);
}

// the loop function runs over and over again forever
void loop() {
  tick = tick+1;
  digitalWrite(LED_BUILTIN, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(2);                       // wait for a second
  digitalWrite(LED_BUILTIN, LOW);    // turn the LED off by making the voltage LOW
  delay(8);                       // wait for a second


  analogWrite(10, meterDrive(tick, 231 * SPEED_MULTIPLY/SPEED_DIVIDE, 190, 0)
             //     + meterDrive(tick, 193 * SPEED_MULTIPLY/SPEED_DIVIDE, 90, 0)
                  );  //Medium-sized meter

  analogWrite(11, meterDrive(tick, 430 * SPEED_MULTIPLY/SPEED_DIVIDE, 250, 0)
             //     + meterDrive(tick, 321 * SPEED_MULTIPLY/SPEED_DIVIDE,100, 0)
                  );  //Bigger meter

  bipolarDrive(3,meterDrive(tick,191 * SPEED_MULTIPLY/SPEED_DIVIDE, 510, -255) ); //Right meter

  bipolarDrive(5, meterDrive(tick, 250 * SPEED_MULTIPLY/SPEED_DIVIDE, 510, -255) ); //Left meter

}

/////////////////////////////////////////////////////////////////////
//
// meterDrive
//
// This generates the triangle waves
//
/////////////////////////////////////////////////////////////////////
int meterDrive( int sequence, int halfPeriod, int maxVal, int bias) {
  float absIndex, driveValFloat;
  absIndex =  (float) abs(2 * (sequence % halfPeriod) - ( (sequence % (2 * halfPeriod))));
  driveValFloat = ( absIndex * (float) maxVal ) / ( (float) halfPeriod);

  return (int) ( driveValFloat + 0.5 ) + bias;

}

//////////////////////////////////////////////////////////////////////
//
// bipolarDrive
//
// This handles drives which drive below zero
//
// This only works on two meters, which must have adjascent digital and analog pins
//
//////////////////////////////////////////////////////////////////////
void bipolarDrive( int address, int value ) {

  int digitalPart = LOW;

  if (value < 0) {
    digitalPart = HIGH;
    value += 255;
  }

  digitalWrite(address - 1, digitalPart);
  analogWrite(address, value);
}
