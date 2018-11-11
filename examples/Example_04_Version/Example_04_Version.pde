// BITalino helper class for Processing
// Example_04_Version
// BITalino (r)evolution
// by @crcdng

Bitalino2 bitalino;
final int PORT = 0; // the index of the BITalino port displayed in the console
String versionString = "";

void setup() {
  bitalino = new Bitalino2(this, PORT);
  // Call version() only when BITalino is idle. 
  // The result will be assembled in a number of calls to serialEvent().
  // Currently, mixing this with data acquision is not recommended.
  delay(100);
  bitalino.version(); 
}

void draw() {
}

void serialEvent(Serial port) {
  if (bitalino.isIdle()) {
    while (port.available () > 0) {
      char c = port.readChar();
      versionString += c; 
    }
  } 
  if (versionString.indexOf("BITalino") >= 0 && 
    versionString.charAt(versionString.length()-1) == '\n') { 
    println(versionString); 
  }
}
