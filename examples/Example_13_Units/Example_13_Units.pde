// BITalino helper class for Processing
// Example_13_Units
// BITalino (r)evolution
// by @crcdng
// source: BITalino Sensor Datasheets and P. Goncalves, https://forum.bitalino.com/viewtopic.php?f=12&t=128

// these functions might go into the API

Bitalino bitalino;
final int PORT = 0; // the index of the BITalino port displayed in the console
int data [] = new int[6]; // data of the 6 acquisition channels

void setup() {
  bitalino = new Bitalino2(this, PORT);
  bitalino.start(10); // data acquisition with 10 samples / second
}

void draw() {
  data = bitalino.receive(); // read a sample of raw data
  int emgRaw = data[0];
  println(emgRaw, emg(emgRaw)); // print raw EMG value and unit EMG value to the console
}

// emg :: Int -> [-1.64 mV, 1.64 mV]
float emg (int in) { 
  final float gain = 1009.0;
  final float voltage = 3.3;
  return 1000.0 * (float(in) / 1024.0 - 0.5) * voltage / gain;
}

// ecg :: Int -> [-1.5 mV : 1.5 mV]  
float ecg (int in) {   
  final float gain = 1100.0; // different gain than emg
  final float voltage = 3.3;
  return 1000.0 * (float(in) / 1024.0 - 0.5) * voltage / gain;
}

// TODO (re)volution datasheet vs. forum
// eda :: Int -> [0 µS .. 1024 µS]  
float eda (int in) { 
  return 1.0 / (1.0 - float(in) / 1024.0); 
}

// eeg :: Int -> [-41.25 µV .. 41.25 µV]
float eeg (int in) { 
  final float gain = 40000.0; 
  final float voltage = 3.3;
  return 1000000.0 * (float(in) / 1024.0 - 0.5) * voltage / gain; 
}

// acc :: Int -> [-3 g .. 3 g]
// by default, the accelerometer returns only the value from the z-axis
// see datasheet and https://www.youtube.com/watch?v=RaJQ3hcdJqU
float acc (int in) { 
  final float calibrationMin = 208.0;  // values from https://forum.bitalino.com/viewtopic.php?f=12&t=128
  final float calibrationMax = 312.0;
  return 2.0 * ((float(in) - calibrationMin) / (calibrationMax - calibrationMin)) - 1.0;
}

// lux :: Int -> [0 % .. 100 %] (not the SI-Unit)
float lux (int in) { return 100.0 * float(in) / 64.0; }
