// BITalino helper class for Processing
// Example_02_Muscle
// by @crcdng 

// make sure to have the electrodes connected to the EMG (Electromyography) channel 

Bitalino bitalino;
final int EMG = 0;
final int PORT = 0; // the index of the BITalino port displayed in the console 
int data[] = new int[6]; // data of the 6 acquisition channels
float x, y;

void setup() {
  size(600, 200);
  bitalino = new Bitalino(this, PORT); 
  bitalino.start(10); // data acquisition with 10 samples / second
}

void draw() {
  if (x == 0) { background(0); }
  strokeWeight(4);
  stroke(250);
  data = bitalino.receive(); // read a sample
  int emg = data[EMG]; 
  float y = map(emg, 0, 1024, height, 0);
  point(x, y);
  x = (x + 1) % width;
}
