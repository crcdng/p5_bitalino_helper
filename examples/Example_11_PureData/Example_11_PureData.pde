// BITalino helper class for Processing
// Example_11_PureData
// BITalino (r)evolution
// by @crcdng
// oscP5 library by Andreas Schlegel http://www.sojamo.de/libraries/oscP5/
// Resources are in the data folder
// PureData patch is in data/pd, requires oscx library

import oscP5.*;
import netP5.*;

final int ECG = 1;  // Electrocardiography (heart, channel 2)

final int MY_UDP_PORT = 9298;  
final int RECEIVER_UDP_PORT = 9299;  

OscP5 oscP5;
NetAddress destination;
boolean connected = false;

Bitalino bitalino;
final int PORT = 0; // the index of the BITalino port displayed in the console
int data[] = new int[6]; // data of the 6 acquisition channels
int inValue = 0;
float sendValues[] = new float[1]; 

void setup() {
  oscP5 = new OscP5(this, MY_UDP_PORT);
  destination = new NetAddress("127.0.0.1", RECEIVER_UDP_PORT);
  bitalino = new Bitalino2(this, PORT);
  bitalino.start(100); // data acquisition with 100 samples / second
  // bitalino.start(100, new int [] { 0, 1, 2, 3, 4, 5 }, 0x2); // emulation
}

void draw() {
  background(0);
  data = bitalino.receive(); // read a sample of raw data
  int ecg = data[ECG];
  // send a normalized ECG value to PureData
  sendValues[0] = norm(ecg, 0, 1024);
  sendOsc(sendValues, destination);  
  // visualize the ecg value
  float yEcg = map(ecg, 0, 1024, 0, height);
  fill(12, 18, 244);
  rect(10, height - yEcg, 30, yEcg); // visualize
  // visualize incoming values
  float yPd = map(inValue, 0, 1024, 0, height);
  fill(124, 18, 244);
  rect(60, height - yPd, 30, yPd); 
}

void sendOsc(float [] values, NetAddress dest) { 
  OscMessage msg = new OscMessage("/pd/inputs");
  for (float value : values) { msg.add(value); }
  oscP5.send(msg, dest);
}

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/pd") && msg.checkTypetag("i")) {
    // println("received message " + msg);
    inValue = msg.get(0).intValue();    
  }
}
