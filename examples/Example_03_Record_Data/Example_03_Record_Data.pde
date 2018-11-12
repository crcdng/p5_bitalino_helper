// BITalino helper class for Processing
// Example_03_Record_Data
// BITalino (r)evolution
// by @crcdng

// press 'r' to start recording and 's' to stop
// saves a timestamped text file to the sketch "data" directory

// CAVEAT
// bitalino.stopRecording() must be called to make sure the file is actually written
// either from an interaction like keyPressed or from the dispose() method shown below
// dispose() is automatically called when the sketch is closed with the Escape key,
// not when the stop button is clicked or when Processing is terminated.

Bitalino bitalino;
final int PORT = 0; // the index of the BITalino port displayed in the console
int data[] = new int[6]; // data of the 6 acquisition channels
boolean isRecording = false;

void setup() {
  bitalino = new Bitalino2(this, PORT);
  bitalino.start(10); // data acquisition with 10 samples / second
}

void draw() {
  if (isRecording) {
    data = bitalino.record(bitalino.receive()); // read a sample of rawd data and write it to the file
    if (frameCount % 25 == 0) { print("."); } // visualize the ongoing recording in the console
  }
}

void keyPressed() {
  if (key == 'r') {
    isRecording = true;
    bitalino.startRecording();
    print("start recording.");
  } else if (key == 's') {
    if (isRecording) {
      bitalino.stopRecording();
      isRecording = false;
      println(".stop recording.");
    }
  }
}

// this is called when stopping the sketch with ESC
void dispose () {
  if (isRecording) {
    bitalino.stopRecording();
    isRecording = false;
    println(".stop recording.");
  }
}
