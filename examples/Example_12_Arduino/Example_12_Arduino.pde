// BITalino helper class for Processing
// Example_12_Arduino
// BITalino (r)evolution
// by @crcdng

// based on http://www.arduino.cc/en/Tutorial/Dimmer by David A. Mellis, Tom Igoe and Scott Fitzgerald, Public domain.

// Arduino code and material is in the data folder

// Please note that you can connect an Arduino directly to the BITalino
// In that case, the BITalino Bluetooth module must be disconnected 
// See: http://bitalino.com/docs/arduino-api/index.html

// Here we use a different approach with Processing as a bridge 

// BITalino: EMG => 
// Serial => 
// Arduino  

// 1. Connect the Arduino and start the Arduino IDE
// 2. Select the Arduino Board and Port and run (upload) the sketch
// 3. Start the BITalino and this Sketch 
// 4. Set ARDUINO_PORT to the port of the Arduino and restart if needed
// 5. The LED on the Arduino should go on

import processing.serial.*;

final int EMG = 0;  // Electromyogram (muscle, channel 1)
 
Serial arduino;
Bitalino bitalino;
final int PORT = 0; // the index of the BITalino port displayed in the console
final int ARDUINO_PORT = 2; // the index of the Arduino port 
int data[] = new int[6]; // data of the 6 acquisition channels

void setup() {
  bitalino = new Bitalino2(this, PORT);
  // bitalino.start(100); // data acquisition with 100 samples / second
  bitalino.start(100, new int [] { 0, 1, 2, 3, 4, 5 }, 0x2); // emulation
  arduino = new Serial(this, Serial.list()[ARDUINO_PORT], 9600);
}

void draw() {
  background(0);
  data = bitalino.receive(); // read a sample of raw data
  int emg = data[EMG];
  // send EMG to Arduino
  arduino.write(emg);  
  // visualize the value
  float yEmg = map(emg, 0, 1024, 0, height);
  fill(12, 18, 244);
  rect(10, height - yEmg, 30, yEmg); // visualize
}
