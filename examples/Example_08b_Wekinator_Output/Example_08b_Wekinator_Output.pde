// BITalino helper class for Processing
// Example_08b_Wekinator_Output
// BITalino (r)evolution
// by @crcdng
// oscP5 library by Andreas Schlegel
// Wekinator by Rebecca Fiebrink http://www.wekinator.org
// run parallel with Example_08a_Wekinator_Input

import oscP5.*;
import netP5.*;

OscP5 oscP5;

float red = 0;

void setup() {
  oscP5 = new OscP5(this, 12000); // receive data on this port
  colorMode(RGB, 1);
}

void draw() {
  background(red, 0, 0); // red value [0..1]
}

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/wek/outputs") && msg.checkTypetag("f")) {
    red = msg.get(0).floatValue();
  }
}
