// BITalino helper class for Processing
// Example_06_Graphwriter
// BITalino (r)evolution
// by @crcdng
// based on code by Edwin Dertien, CC-BY-SA 2.0

int PORTNUMBER = 0;

Bitalino2 bitalino;
final int PORT = 0; // the index of the BITalino port displayed in the console
int data[] = new int[6]; // data of the 6 acquisition channels

int lines = 6;
float amplitude = 1.0;
int previousValues[] = new int[lines];
PFont font;
int linecolor[] = { 0, 40, 80, 120, 160, 200, 240, 1 }; //HSB color mode
int offsetX = 30;
int offsetY = 0;
float scaling = 0.25;
int values[] = new int[lines];
int x = offsetX;

void setup() {
  size(533, 286);
  bitalino = new Bitalino2(this, PORT);
  bitalino.start(10); // data acquisition with 10 samples / second
  colorMode(HSB);
  font = loadFont("SansSerif-10.vlw");
  textFont(font, 10);
  background(255);
  drawAxes();
}

void draw() {
  values = bitalino.receive();
  stroke(255);
  fill(255);
  rect(300, 0, 100, 12);
  stroke(0);
  fill(0);
  text("time " + (millis() - 500) / 1000 + " s", 300, 12);
  for (int line = 0; line<lines; line++) {
    stroke(linecolor[line], 255, 255);
    line(x - 1, (height - 12 - offsetY) - previousValues[line] * scaling, 
      x, (height - 12 - offsetY) - values[line] * scaling);
  }
  x = x + 1;
  if (x > width) {                
    x = offsetX;                        
    background(255);             
    drawAxes();
  }
  for (int line = 0; line < lines; line++) {  
    previousValues[line] = values[line];
  }
}

void drawAxes() {
  stroke(255, 0, 0);
  line(offsetX, height - 11, width, height - 11);
  line(offsetX, 13, width, 13);
  line(offsetX, 0, offsetX, height);
  fill(255, 0, 0);
  text(nf(0), 2, height - 7 + offsetY);
  text(nf(512), 2, (height / 2) + offsetY);
  text(nf(1024), 2, 23 + offsetY);
  text("scaling x " + nf(scaling, 1, 2), 50, 12);
  text("offset " + offsetY + " px", 220, 12);
}

void keyPressed() {
  switch(key) {
  case 'c':
    x = offsetX; 
    background(255);
    drawAxes();
    break;    
  case 'w': 
    scaling -= 0.1;
    break;    
  case 'z': 
    scaling += 0.1;
    println(scaling);
    break;    
  case '0':  
    bitalino.stop();
    break;
  case '1': // values measured by the device  
    bitalino.stop();
    bitalino.start();
    break;
  case '2': // emulated values  
    bitalino.stop();
    bitalino.start(100, new int [] { 0, 1, 2, 3, 4, 5 }, 0x2);
    break;
  default:
    break;
  }
}
