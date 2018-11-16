// BITalino helper class for Processing
// Example_10_A-Frame
// BITalino (r)evolution
// by @crcdng
// oscP5 library by Andreas Schlegel
// A-Frame by A-Frame contributors https://aframe.io
// osc-j by Andreas Dzialocha
// reqires a webserver and node.js/npm https://nodejs.org/

// A-Frame project is in the data/www folder
// bridge server is in the data/server folder
// in this folder run "npm install" 

// start in this order:
// 1. in data/server, run "node server.js" 
// 2. in data/www, serve index.html through a webserver on a different port than 8080
// 3. start this sketch

// BITalino: EDA, EEG => 
// A_Frame Sketch => 
// OSC over UDP =>
// Websocket / UDP bridge server on port 9130 /aframe/inputs => 
// OSC over Websocket =>
// Web page A-Frame VR Scene  

// You also can send data from the VR Scene to Processing, for example:  
// A-Frame VR Scene => 
// OSC over Websocket =>
// Websocket / UDP bridge server on port 8080 /connect => 
// OSC over UDP =>
// A_Frame Sketch on port 9129

import oscP5.*;
import netP5.*;

final int EDA = 2;  // Electrodermal activity signal (skin, channel 3)
final int EEG = 3;  // Electroencephalogram signal (brainz, channel 4)

final int MY_UDP_PORT = 9129;  
final int RECEIVER_UDP_PORT = 9130;  

OscP5 oscP5;
NetAddress destination;
boolean connected = false;

Bitalino bitalino;
final int PORT = 0; // the index of the BITalino port displayed in the console
int data[] = new int[6]; // data of the 6 acquisition channels

void setup() {
  oscP5 = new OscP5(this, MY_UDP_PORT);
  destination = new NetAddress("127.0.0.1", RECEIVER_UDP_PORT);
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
  sendOsc(new float [] { eda, eeg }, destination); 
  // visualize the values
  float yEda = map(eda, 0, 1024, 0, height);
  fill(12, 18, 244);
  rect(10, height - yEda, 30, yEda); // visualize
  float yEeg = map(eeg, 0, 1024, 0, height);
  fill(12, 244, 18);
  rect(60, height - yEeg, 30, yEeg); 
}

void sendOsc(float [] values, NetAddress dest) { 
  OscMessage msg = new OscMessage("/aframe/inputs");
  msg.add(values[0]); 
  msg.add(values[1]);
  oscP5.send(msg, dest);
}

void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}
