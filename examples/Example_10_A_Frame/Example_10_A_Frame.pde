// BITalino helper class for Processing
// Example_10_A-Frame
// BITalino (r)evolution
// by @crcdng
// oscP5 library by Andreas Schlegel
// A-Frame by A-Frame contributors https://aframe.io
// osc-j by Andreas Dzialocha
// A-Frame project is in the data/www folder
// serve index.html through a webserver 

import oscP5.*;
import netP5.*;

final int EDA = 2;  // Electrodermal activity signal (skin, channel 3)
final int EEG = 3;  // Electroencephalogram signal (brainz, channel 4)

OscP5 oscP5;
NetAddress dest;

Bitalino bitalino;
final int PORT = 0; // the index of the BITalino port displayed in the console
int data[] = new int[6]; // data of the 6 acquisition channels

void setup() {
  oscP5 = new OscP5(this, 11999);
  dest = new NetAddress("185.199.108.153", 9912);
  bitalino = new Bitalino2(this, PORT);
  // bitalino.start(100); // data acquisition with 100 samples / second
  bitalino.start(100, new int [] { 0, 1, 2, 3, 4, 5 }, 0x2); // emulation
}

void draw() {
  background(0);
  data = bitalino.receive(); // read a sample of raw data
  int eda = data[EDA];
  int eeg = data[EEG];
  // send raw EDA, EEG values to A-FRAMErame
  sendOsc(new float [] { eda, eeg }); 
  // visualize the values
  float yEda = map(eda, 0, 1024, 0, height);
  fill(12, 18, 244);
  rect(10, height - yEda, 30, yEda); // visualize
  float yEeg = map(eeg, 0, 1024, 0, height);
  fill(12, 244, 18);
  rect(60, height - yEeg, 30, yEeg); 
}

void sendOsc(float [] values) { 
  OscMessage msg = new OscMessage("/aframe/inputs");
  msg.add(values[0]); 
  msg.add(values[1]);
  oscP5.send(msg, dest);
}
