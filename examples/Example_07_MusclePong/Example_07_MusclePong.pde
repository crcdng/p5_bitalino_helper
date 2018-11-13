// BITalino helper class for Processing
// Example_07_MusclePong
// BITalino (r)evolution
// by @crcdng
// based on code by Edwin Dertien, CC-BY-SA 2.0
// sounds made with jsfxr by Eric Fredricksen, http://sfxr.me
// Minim library by Damien Di Fede and Anderson Mills for sound; the Processing Sound library is currently broken

import ddf.minim.*;

final int EMG_CHANNEL = 0;
final float EMG_MAX = 1024.0;
final int PORT = 0; // the index of the BITalino port displayed in the console
final float SENSITVITY = 5.0; // tweak this value > 1.0

Direction ballDir;
float [] buffer = new float[20]; // 200 milliseconds
Bitalino2 bitalino;
int data[] = new int[6]; // data of the 6 acquisition channels
GameObject ball, paddleLeft, paddleRight;
PFont fontLarge, fontSmall;
boolean gameRunning = false;
int index = 0;
Minim minim;
float maximum = 0.0;
float minimum = 1024.0;
AudioPlayer player;
int [] score = { 0, 0 };
boolean sound = true;
AudioPlayer soundPing, soundMiss, soundPong;
int textHeight = 32;
int values[] = new int[6];
float var;

void setup() {
  size(600, 480);
  bitalino = new Bitalino2(this, PORT);
  bitalino.start(100); // data acquisition with 100 samples / second
  // bitalino.start(100, new int [] { 0, 1, 2, 3, 4, 5 }, 0x2); // emulation
  minim = new Minim(this);
  soundPing = minim.loadFile(dataPath("ping.wav"));
  soundPong = minim.loadFile(dataPath("pong.wav"));
  soundMiss = minim.loadFile(dataPath("miss.wav"));
  fontLarge = loadFont("Phosphate-Solid-96.vlw");
  fontSmall = loadFont("Phosphate-Solid-32.vlw");
  paddleLeft = new GameObject(40, 220, 20, 76);
  paddleRight = new GameObject(540, 220, 20, 76); 
  ball = new GameObject(width/2, height/2, 20, 20);
  background(0);
  drawScore(score);
  drawTitle("MusclePong"); 
  try {
    int m = bitalino.receive()[EMG_CHANNEL];
    drawMessage("Control Left Pad By Muscle", 0);
    drawMessage("'s' toggles Sound", 1);
    drawMessage("Bitalino detected", 2, color(0, 178, 0));
    drawMessage("Press Any Key To Start", 3);
  } 
  catch (Exception e) {
    drawMessage("NO Bitalino detected", 0, color(178, 0, 0));
  }
  noLoop();
}

void draw() {
  if (!gameRunning) { // skip draw() before a key is pressed, noLoop() runs it once or twice
    return;
  };
  if (frameCount > 50) { // discard the first iterations
    update(acquire(buffer));
  }
  background(0);
  drawScore(score);
  paddleLeft.draw();
  paddleRight.draw();
  ball.draw();
}

float acquire(float [] buf) {
  int muscle = bitalino.receive()[EMG_CHANNEL]; 
  buf[index] = muscle / EMG_MAX;
  index = (index + 1) % buf.length;
  var = variation(buf);
  maximum = max(maximum, var); 
  minimum = min(minimum, var);
  if (maximum == minimum) { return 0.0; }
  float adapted = (var - minimum) / (maximum - minimum);
  if (Float.isNaN(adapted)) { return 0.0; }
  println(minimum, maximum, muscle, var, adapted);
  return adapted;
}

void update(float value) {
  // left paddle - muscle
  paddleLeft.y = int(map(value, 0.0, 1.0 / SENSITVITY, float(height), 0.0));
  paddleLeft.update(Boundary.NONE, Boundary.CONSTRAIN);
  // right paddle - auto
  if (ball.directionHorizontal() == Direction.RIGHT) { 
    paddleRight.y = ball.y - paddleRight.h / 2;
  } 
  paddleRight.update(Boundary.NONE, Boundary.CONSTRAIN);
  // ball
  if (ball.x <= paddleLeft.x + paddleLeft.w && ball.y > paddleLeft.y && ball.y < paddleLeft.y + paddleLeft.h) {
    ball.dx = -ball.dx;
    if (sound) {
      soundPing.rewind();
      soundPing.play();
    }
  }
  if (ball.x + ball.w >= paddleRight.x && ball.y > paddleRight.y && ball.y < paddleRight.y + paddleRight.h) {
    ball.dx = -ball.dx;
    if (sound) {
      soundPong.rewind();
      soundPong.play();
    }
  } 
  int ballUpdate = ball.update(Boundary.SCORE, Boundary.REFLECT);
  if (ballUpdate != -1) { 
    score[ballUpdate] += 1;
    if (sound) {
      soundMiss.rewind();
      soundMiss.play();
    }
    startRound();
  } 
}

void drawScore(int [] sc) {
  String scoreString = sc[0] + " : " + sc[1];
  stroke(178);
  fill(178);
  textFont(fontLarge);
  textAlign(CENTER);
  text(scoreString, width / 2, 100);
}

void drawTitle(String msg) {
  stroke(255);
  fill(255);
  textFont(fontLarge);
  textAlign(CENTER);
  text(msg, width / 2, height / 2);
}

void drawMessage(String msg, int line) {
  drawMessage(msg, line, color(178));
}
void drawMessage(String msg, int line, color col) {
  stroke(col);
  fill(col);
  textFont(fontSmall);
  textAlign(CENTER);
  text(msg, width / 2, 2 * height / 3 + textHeight * line);
}

void startRound() { 
  ball.x = width/2; 
  ball.y = height/2;
  ball.dx = int(random(1.0, 3.0)); 
  do { // prevent pure horizontal movement
    ball.dy = int(random(-2.0, 2.0));
  } while (abs(ball.dy) < 0.5);
  gameRunning = true;
  loop();
}

boolean toggle(boolean b) { 
  b = !b; 
  return b;
}

float variation (float [] arr) {
  float sum = 0;
  for (float a : arr) { sum += a; } 
  float avg = sum / arr.length;
  sum = 0;
  for (float a : arr) { sum += abs(a - avg); }
  float var = sum / arr.length;
  return var;
}

void keyPressed() {
  if (key == 's') { 
    sound = toggle(sound);
  }
  startRound();
}
