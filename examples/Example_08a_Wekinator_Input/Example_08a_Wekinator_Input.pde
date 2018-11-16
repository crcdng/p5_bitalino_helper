// BITalino helper class for Processing
// Example_08a_Wekinator_Input
// BITalino (r)evolution
// by @crcdng
// oscP5 library by Andreas Schlegel
// Wekinator by Rebecca Fiebrink http://www.wekinator.org
// Wekinator project resources are in the data folder
// run parallel with Example_08b_Wekinator_Output

// BITalino: EDA, EEG => 
// Wekinator_Input Sketch => 
// Port 6448 /wek/inputs Wekinator All continous (Regression) => 
// Record for given outputs, e.g. 0 when calm and 1 when agitated, train, then run => 
// Port 12000 /wek/outputs => 
// Wekinator_Output Sketch [0..1] 

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
  dest = new NetAddress("127.0.0.1", 6448);
  bitalino = new Bitalino2(this, PORT);
  bitalino.start(100); // data acquisition with 100 samples / second
  // bitalino.start(100, new int [] { 0, 1, 2, 3, 4, 5 }, 0x2); // emulation
}

void draw() {
  background(0);
  data = bitalino.receive(); // read a sample of raw data
  int eda = data[EDA];
  int eeg = data[EEG];
  // send raw EDA, EEG values to Wekinator
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
  OscMessage msg = new OscMessage("/wek/inputs");
  msg.add(values[0]); 
  msg.add(values[1]);
  oscP5.send(msg, dest);
}
