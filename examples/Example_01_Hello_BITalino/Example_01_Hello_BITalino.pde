// BITalino helper class for Processing
// Example_01_Hello_BITalino
// BITalino (r)evolution
// by @crcdng

Bitalino bitalino;
final int PORT = 0; // the index of the BITalino port displayed in the console
int data[] = new int[6]; // data of the 6 acquisition channels

void setup() {
  bitalino = new Bitalino2(this, PORT);
  bitalino.start(10); // data acquisition with 10 samples / second
}

void draw() {
  data = bitalino.receive(); // read a sample of raw data
  printArray(data); // print it to the console
}
