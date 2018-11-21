// BITalino helper class for Processing
// Example_12_Arduino
// BITalino (r)evolution
// Arduino Uno
// by @crcdng

// Use with the Processing sketch Example_12_Arduino
// Based on http://www.arduino.cc/en/Tutorial/Dimmer by David A. Mellis, Tom Igoe and Scott Fitzgerald, Public domain.
// Uses the built-in LED on pin LED_BUILTIN (13)

void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  byte brightness;
  if (Serial.available()) {
    brightness = Serial.read();
    analogWrite(LED_BUILTIN, brightness);
  }
}
