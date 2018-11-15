
// BITalino helper class for Processing
// Example_09_Supercollider
// BITalino (r)evolution
// by @crcdng
// oscP5 library by Andreas Schlegel
// SuperCollider client for Processing library by Daniel Jones
// Resources are in the data folder
// SuperCollider SynthDefs are in the SynthDef tab

import oscP5.*;
import supercollider.*;

final int ECG = 1;  // Electrocardiography (heart, channel 2)
final int ACC = 4;  // Accelerometer (movement, channel 5)

OscP5 oscP5;
Server server;
Synth synth1, synth2;

Bitalino bitalino;
final int PORT = 0; // the index of the BITalino port displayed in the console
int data[] = new int[6]; // data of the 6 acquisition channels

void setup() {
  bitalino = new Bitalino2(this, PORT);
  bitalino.start(100); // data acquisition with 100 samples / second
  // bitalino.start(100, new int [] { 0, 1, 2, 3, 4, 5 }, 0x2); // emulation
  
  server = new Server ("127.0.0.1", 57110); // default values for Supercollider on the same machine
  synth1 = new Synth("synth1", server); 
  synth1.set("amp", 0.5); 
  synth1.create();
  synth2 = new Synth("synth2", server); 
  synth2.set("amp", 0.5); 
  synth2.create();
}

void draw() {
  background(0);
  data = bitalino.receive(); // read a sample of raw data
  int ecg = data[ECG];
  int acc = data[ACC];
  // send values to the Supercollider synths variable input
  synth1.set("input", map(ecg, 0, 1024, 220, 330)); 
  synth2.set("input", map(acc, 0, 64, 340, 400)); 
  // visualize the values
  float yEcg = map(ecg, 0, 1024, 0, height); // the ECG has 10 bit -> 1024 values
  fill(12, 18, 244);
  rect(10, height - yEcg, 30, yEcg); // visualize
  float yAcc = map(acc, 0, 64, 0, height); // the ACC has 6 bit -> 64 values
  fill(12, 244, 18);
  rect(60, height - yAcc, 30, yAcc); 
}

void exit() { // stop the synths
  synth1.free();
  synth2.free();
  super.exit();
}
