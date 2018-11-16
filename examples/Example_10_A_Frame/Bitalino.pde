// BITalino helper class for Processing //<>//
// by @crcdng 

import java.util.Arrays;  //<>//
import processing.serial.*;

enum Mode {
  IDLE, ACQUIRE, EMULATE
}

class Bitalino2 extends Bitalino {

  Bitalino2(PApplet applet, int portnumber) {  
    super(applet, portnumber);
  }

  Bitalino2(PApplet applet, String portname) {  
    super(applet, portname);
  }

  void pwm() { 
    pwm(100);
  }
  void pwm(int analog) { 
    send(0xA3); // set analog output
    send(analog); // 0 <= analog <= 255
  }
  
  // 0, 0 > 10110011
  // 1, 0 > 10110111 LED
  // 0, 1 > 10111011 Buzzer
  // 1, 1 > 10111011 LED + Buzzer 
  void trigger(int [] digital) { // expected format: array [1/0,1/0]
    int output = 0x0;
    for (int i = 0; i < digital.length; i++) {
      if (digital[i] == 1) { 
        output = output | (1 << i);
      }
    }
    send((output << 2) | 0xB3); // set digital outputs 1 0 1 1 O1 O2 1 1
  }
}

abstract class Bitalino {
  int [] buffer = { 0, 0, 0, 0, 0, 0, 0, 0 };
  PrintWriter file;  
  int index = 0;
  int numChannels = 6;
  Serial port;
  Integer [] samplingRates = { 1, 10, 100, 1000 };
  Mode mode;
  int [] values = new int[numChannels];
  
  Bitalino(PApplet applet, int portnumber) {  
    this(applet, Serial.list()[portnumber]);
    println("Bitalino: Available ports:");    
    printArray(Serial.list());
  }
  
  Bitalino(PApplet applet, String portname) { 
    try {
      port = new Serial(applet, portname, 115200);
    } catch (Exception e) {
      println("Bitalino: Could not open a connection to the BITalino at port: " + portname);    
      println("Exiting...");
      exit();
    } 
    
    registerMethod("dispose", applet);  // CAREFUL registerMethod is undocumented
    mode = Mode.IDLE;
  }

  void battery() { 
    battery(0);
  }
  void battery(int value) {
    if (!isIdle()) { throw new Error("Bitalino: battery() can only be called in idle mode"); }
    send(value << 2 | 0x00);
  }

  boolean checkCRC (int [] buf) {
    int crc = buf[7] & 0x0F; 
    buf[7] &= 0xF0;  // clear CRC bits in frame
    int x = 0;
    for (int i = 0; i < buf.length; i++) {
      for (int bit = 7; bit >= 0; bit--) {
        x <<= 1;
        if ((x & 0x10) > 0)  x = x ^ 0x03;
        x ^= ((buf[i] >> bit) & 0x01);
      }
    }
    return (crc == (x & 0x0F));
  }
  
  void close() { 
    port.stop();
  }
    
  boolean isAcquiring() { return mode == Mode.ACQUIRE; }
  boolean isEmulating() { return mode == Mode.EMULATE; }
  boolean isIdle() { return mode == Mode.IDLE; }
  
  int [] read() { 
    return read(100);
  }
  int [] read(int numSamples) {  
    throw new Error("Bitalino: not implemented"); 
    // return null;
  }
  
  int [] receive () {
    while (port.available () > 0) {
      buffer[index] = port.read(); // read an unsigned byte 0..255
      if ((index == (buffer.length - 1)) && checkCRC(buffer)) {
        values = toRawValues(buffer);
      }
      index = (index + 1) % buffer.length;
    }
    return values;
  }
  
  int [] record (int [] data) {
    file.println(join(str(data), ","));
    return data;
  }

  void send(int data) {
    try {
      port.write(data);
    } catch (Exception e) {}
  } 

  void start() { 
    start(1000, new int [] { 0, 1, 2, 3, 4, 5 }, 0x1);
  }
  void start(int samplingRate) { 
    start(samplingRate, new int [] { 0, 1, 2, 3, 4, 5 }, 0x1);
  }
  void start(int samplingRate, int [] acquisitionChannels, int acquisitionMode) { 
    int commandSRate = Arrays.asList(samplingRates).indexOf(samplingRate);
    send((commandSRate << 6) | 0x03); // set sampling rate S S 0 0 0 0 1 0
    delay(10);  
    int channels = 0x0;
    for (int c : acquisitionChannels) {
      channels = channels | (1 << c);
    }
    send((channels << 2) | acquisitionMode); // set live (0x1) or emulation (0x2) mode with channels A6 A5 A4 A3 A2 A1 M M
    if (acquisitionMode == 1) { 
      mode = Mode.ACQUIRE; 
    } else if (acquisitionMode == 2) { 
      mode = Mode.EMULATE; 
    }
  }
  
  void startRecording () { 
    String filename = "bitalino-data-" + nf(year(), 4) + "-" + nf(month(), 2) + "-" + 
    nf(day(), 2) + "-" + nf(hour(), 2) + "-" + nf(minute(), 2) + 
    "-" + String.valueOf(second()) + ".txt";
    startRecording(dataPath(filename)); // CAREFUL dataPath is undocumented
  } 
  void startRecording (String path) {
    file = createWriter(path);
  }

  void state() { 
    throw new Error("Bitalino: not implemented"); 
    // return null;
  }

  void stopRecording () {
    file.flush(); 
    file.close();
  }
  
  void stop() { 
    send(0x0); // stop acquisition and set idle mode
    mode = Mode.IDLE;
  }
  
 int [] toRawValues(int [] data) {  
    values[0] = ((data[6] & 0x0F) << 6) | (data[5] >> 2);
    values[1] = ((data[5] & 0x03) << 8) | (data[4]);
    values[2] = ((data[3]       ) << 2) | (data[2] >> 6);
    values[3] = ((data[2] & 0x3F) << 4) | (data[1] >> 4);
    values[4] = ((data[1] & 0x0F) << 2) | (data[0] >> 6);
    values[5] = ((data[0] & 0x3F));  
    return values;
  }
  
  abstract void trigger(int [] digital);

  void version() {
    if (!isIdle()) { throw new Error("Bitalino: version() can only be called in idle mode"); }
    send(0x7); // ask for version. the result is assembled in the serialEvent(Serial port) callback.    
  }
}
