// BITalino helper class for Processing
// Example_07_MusclePong
// BITalino (r)evolution
// by @crcdng
// based on code by Edwin Dertien, CC-BY-SA 2.0
// sounds made with jsfxr by Eric Fredricksen, http://sfxr.me
// Minim library by Damien Di Fede and Anderson Mills for sound, as the Processing Sound library is currently broken
// Signal Filter library by Raphael de Courville to smoothen the EMG signal 

import ddf.minim.*;
import signal.library.*;

final int EMG_CHANNEL = 0;
final float EMG_MAX = 1024.0;
final int PORT = 0; // the index of the BITalino port displayed in the console

Direction ballDir;
Bitalino2 bitalino;
int data[] = new int[6]; // data of the 6 acquisition channels
GameObject ball, paddleLeft, paddleRight;
SignalFilter filter;
PFont fontLarge, fontSmall;
boolean gameRunning = false;
Minim minim;
AudioPlayer player;
int [] score = { 0, 0 };
boolean sound = true;
AudioPlayer soundPing, soundMiss, soundPong;
int textHeight = 32;
int values[] = new int[6];

void setup() {
  size(600, 480);
  // bitalino = new Bitalino2(this, PORT);
  // bitalino.start(10); // data acquisition with 10 samples / second
  // bitalino.start(100, new int [] { 0, 1, 2, 3, 4, 5 }, 0x2); // emulation
  filter = new SignalFilter(this);
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
    drawMessage("Press Any Key To Start", 2);
    drawMessage("Bitalino detected", 3);   
  } catch (Exception e){
    drawMessage("NO Bitalino detected", 0);   
  }
  noLoop();
}

void draw() {
  if (!gameRunning) { return; };
  // int muscle = bitalino.receive()[EMG_CHANNEL];
  int muscle = int(512.0 + random(-8, 8));
  float filtered = filter.filterUnitFloat(float(muscle) / EMG_MAX);
  //println(filtered);
  
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
   // lerp(start, stop, amt)
  if (ball.directionHorizontal() == Direction.LEFT) { 
    paddleLeft.y = ball.y - paddleLeft.h / 2; 
  }  
  paddleLeft.update(Boundary.NONE, Boundary.CONSTRAIN);
 
  if (ball.directionHorizontal() == Direction.RIGHT) { 
    paddleRight.y = ball.y - paddleRight.h / 2; 
  } 
  paddleRight.update(Boundary.NONE, Boundary.CONSTRAIN);

  background(0);
  drawScore(score);
  paddleLeft.draw();
  paddleRight.draw();
  ball.draw();
}

void drawScore(int [] sc) {
  String scoreString = sc[0] +  " : " +  sc[1];
  stroke(178);
  fill(178);
  textFont(fontLarge);
  float tw = textWidth("0 : 0");  
  text(scoreString, width / 2 - tw / 2, 100);
}

void drawTitle(String msg) {
  stroke(255);
  fill(255);
  textFont(fontLarge);
  float tw = textWidth(msg);
  text(msg, width / 2 - tw / 2, height / 2);
}

void drawMessage(String msg, int line) {
  stroke(178);
  fill(178);
  textFont(fontSmall);
  float tw = textWidth(msg);
  text(msg, width / 2 - tw / 2, 2 * height / 3 + textHeight * line);
}

void startRound() { 
  ball.x = width/2; 
  ball.y = height/2;
    ball.dx = int(random(1.0, 3.0)); 
  do {
  ball.dy = int(random(-2.0, 2.0));
  } while (abs(ball.dy) < 0.5);
  gameRunning = true;
  loop(); 
}

boolean toggle(boolean b) { b = !b; return b; }

void keyPressed() {
  if (key == 's') { sound = toggle(sound); }
  startRound();
}
