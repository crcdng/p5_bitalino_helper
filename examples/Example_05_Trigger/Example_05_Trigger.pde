// BITalino helper class for Processing
// Example_04_Trigger
// BITalino (r)evolution
// by @crcdng

Bitalino bitalino;
final int PORT = 0; // the index of the BITalino port displayed in the console
int data[] = new int[6]; // data of the 6 acquisition channels

void setup() {
  bitalino = new Bitalino2(this, PORT);
  bitalino.start(10); 
 
  // 0, 0 LED and Buzzer off
  bitalino.trigger(new int [] {0, 0});
  delay(5000);
  // 1, 0 LED on
  bitalino.trigger(new int [] {1, 0});
  delay(5000);
  // 0, 1 Buzzer on
  bitalino.trigger(new int [] {0, 1});
  delay(5000);
  // 1, 1 LED and Buzzer on
  bitalino.trigger(new int [] {1, 1});
  delay(5000);
  // LED and Buzzer off
  bitalino.trigger(new int [] {0, 0}); 

  noLoop();
}

void draw() {
  // do nothing
}
