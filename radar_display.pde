// Processing Radar Display — Arduino Ultrasonic Radar System
// Ali Mursal Shah — BS Electronics, COMSATS University Islamabad
// Reads angle,distance from the Arduino over Serial at 9600 baud
// and draws a radar-style display: sweep line, range rings to 200 cm,
// angle lines every 30 degrees, and a red marker for detected objects.
//
// IMPORTANT: Close the Arduino Serial Monitor before running this.
// Check the console output of Serial.list() and change [0] below
// if your Arduino is on a different port.

import processing.serial.*;

Serial myPort;
String incoming = "";
int angle = 90, distance = 0;
int maxDistance = 200;

void setup() {
  size(1000, 600);
  smooth();
  println(Serial.list()); // Check console for Arduino port
  // Change [0] if the Arduino is listed at another index.
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.bufferUntil('\n');
}

void draw() {
  background(0);
  translate(width/2, height*0.88);
  stroke(0, 255, 70);
  noFill();
  for (int d = 50; d <= maxDistance; d += 50) {
    float r = map(d, 0, maxDistance, 0, width*0.42);
    arc(0, 0, 2*r, 2*r, PI, TWO_PI);
  }
  for (int a = 0; a <= 180; a += 30) {
    float x = cos(radians(a))*width*0.42;
    float y = -sin(radians(a))*width*0.42;
    line(0, 0, x, y);
  }
  float rMax = width*0.42;
  stroke(120, 255, 150);
  line(0, 0, cos(radians(angle))*rMax, -sin(radians(angle))*rMax);
  if (distance > 0 && distance <= maxDistance) {
    float r = map(distance, 0, maxDistance, 0, rMax);
    noStroke();
    fill(255, 40, 40);
    ellipse(cos(radians(angle))*r, -sin(radians(angle))*r, 10, 10);
  }
  fill(0, 255, 70);
  textAlign(CENTER);
  textSize(16);
  text("ULTRASONIC RADAR", 0, -height*0.78);
  text("Angle: " + angle + " deg Distance: " + distance + " cm", 0, -height*0.70);
}

void serialEvent(Serial p) {
  String line = p.readStringUntil('\n');
  if (line != null) {
    String[] values = split(trim(line), ',');
    if (values.length == 2) {
      angle = int(values[0]);
      distance = int(values[1]);
    }
  }
}
