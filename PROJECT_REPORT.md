# Arduino Ultrasonic Radar System - Project Report

**Prepared by:** Ali Mursal Shah
**Programme:** BS Electronics
**Institution:** COMSATS University Islamabad

## Abstract

This report describes the design and implementation of a low-cost ultrasonic radar system built around an Arduino UNO. An HC-SR04 ultrasonic sensor is mounted on an SG90 servo motor that sweeps through an arc of 15 degrees to 165 degrees. At each angle, the Arduino measures the distance to the nearest object and sends the angle and distance pair to a computer over USB serial communication at 9600 baud. A Processing application then draws a radar-style display showing the sweep line, range rings up to 200 cm, and a red marker for each detected object. The project combines embedded programming, sensor interfacing, servo control, serial communication and data visualisation in one practical, affordable prototype.

## 1. Introduction and Background

Radar systems detect objects by emitting a signal and measuring the time taken for its reflection to return. Real radar uses radio waves, but the same principle can be demonstrated with ultrasonic sound. The HC-SR04 sensor emits a 40 kHz ultrasonic pulse and produces an echo pulse whose width is proportional to the distance of the nearest reflecting surface. By rotating the sensor with a servo motor, a single fixed-direction sensor can scan a whole sector and build up a picture of its surroundings. Such systems are widely used in education and in simple robotics, for example for obstacle detection and area scanning on small robots.

## 2. Problem Statement

A single ultrasonic sensor measures distance along one fixed direction only. It gives no information about where in the surrounding area objects are located, and raw numbers on a serial monitor are hard to interpret. There is a need for a simple, low-cost system that scans an area, measures distances at known angles, and presents the results visually in real time.

## 3. Objectives

1. Interface an HC-SR04 ultrasonic sensor and an SG90 servo motor with an Arduino UNO.
2. Sweep the sensor between 15 degrees and 165 degrees and measure the distance at each angle step.
3. Transmit angle and distance data to a computer as comma-separated serial lines at 9600 baud.
4. Develop a Processing sketch that displays the sweep line, range rings up to 200 cm, and detected objects as a radar screen.
5. Test and evaluate measurement accuracy against known distances, and document the limitations of the system.

## 4. Scope of the Project

In scope: a breadboard prototype; a detection range displayed up to 200 cm; a scanning arc of 15 degrees to 165 degrees; a real-time display on a computer; and accuracy testing with flat, hard targets.

Out of scope: wireless data transfer, 360-degree scanning, object classification, and use as a certified safety or navigation device. The system is a learning prototype.

## 5. System Overview

The system has three parts: the sensing and actuation unit (the HC-SR04 mounted on the servo), the control unit (the Arduino UNO, which positions the servo, triggers the sensor, calculates the distance and sends data over serial), and the display unit (a computer running Processing, which draws the radar screen).

Data flow: Arduino moves servo to angle -> HC-SR04 sends pulse and receives echo -> Arduino converts echo time to distance -> angle,distance sent over USB serial -> Processing draws the sweep and detected object.

Key parameters: scanning arc 15-165 degrees; angle step 2 degrees; display range up to 200 cm with range rings every 50 cm; serial format angle,distance per line (for example 75,42); baud rate 9600; a no-echo reading is reported as 400 cm.

## 6. Components Required

| Component | Qty. | Purpose |
|---|---|---|
| Arduino UNO or compatible | 1 | Controller and serial communication |
| HC-SR04 ultrasonic sensor | 1 | Distance measurement |
| SG90 (or similar) servo motor | 1 | Rotates the sensor |
| Breadboard and jumper wires | 1 set | Temporary connections |
| USB cable | 1 | Code upload and serial data |
| Computer with Arduino IDE and Processing IDE | 1 | Programming and radar display |
| External regulated 5V supply (optional) | 1 | Stable servo power if the board resets or the servo jitters |

## 7. Hardware Design and Wiring

All wiring is done with the USB cable disconnected. The HC-SR04 is mounted on the servo horn.

| Module / wire | Arduino connection | Notes |
|---|---|---|
| HC-SR04 VCC | 5V | Sensor power |
| HC-SR04 GND | GND | Common ground |
| HC-SR04 TRIG | D10 | Trigger output |
| HC-SR04 ECHO | D11 | Echo input |
| Servo signal (orange/yellow) | D12 | Control signal |
| Servo power (red) | 5V | Or an external regulated 5V supply |
| Servo ground (brown/black) | GND | Must be common with the Arduino ground |
| Arduino USB | Computer USB | Upload and serial data |

Power caution: a servo can draw more current than the Arduino 5V pin can supply reliably. If the board resets or the servo jitters, power the servo from a suitable regulated 5V supply and connect that supply's ground to the Arduino ground.

## 8. Working Principle

1. The Arduino moves the servo to a chosen angle and waits briefly for it to settle.
2. The HC-SR04 is triggered and sends an ultrasonic pulse, then waits for its echo.
3. The Arduino measures the echo duration with pulseIn() and calculates the distance.
4. The Arduino sends the angle and distance to the computer over USB serial communication.
5. Processing reads the serial line and draws the sweep, the range rings, and a red marker for a detected object.

## 9. Theory and Calculations

Distance (cm) = echo duration (microseconds) x 0.0343 / 2

The pulse travels to the object and back, so the total path is divided by two. Worked example: an echo duration of 2,000 microseconds gives 2,000 x 0.0343 / 2 = 34.3 cm.

The firmware allows a maximum echo wait of 30 ms. If no echo arrives, pulseIn() returns zero and the sketch reports 400 cm, outside the 200 cm display range, so no false object is drawn. The servo is given 25 ms to settle at each 2-degree step, with a further 20 ms pause after each reading. Both programs use 9600 baud. Processing maps 0-200 cm onto a radius of 42 percent of the window width, with range rings every 50 cm and angle lines every 30 degrees.

## 10. Arduino Firmware (radar.ino)

```cpp
// Arduino Ultrasonic Radar System
// Ali Mursal Shah — BS Electronics, COMSATS University Islamabad
// Servo on D12 sweeps HC-SR04 (TRIG D10, ECHO D11) from 15 to 165 degrees.
// Sends angle,distance over Serial at 9600 baud for the Processing radar display.

#include <Servo.h>

const int trigPin = 10;
const int echoPin = 11;
const int servoPin = 12;

Servo radarServo;

int readDistanceCm() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(3);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  long duration = pulseIn(echoPin, HIGH, 30000);
  if (duration == 0) return 400; // no echo received
  return (int)(duration * 0.0343 / 2.0);
}

void setup() {
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  radarServo.attach(servoPin);
  Serial.begin(9600);
}

void loop() {
  for (int angle = 15; angle <= 165; angle += 2) {
    radarServo.write(angle);
    delay(25);
    Serial.print(angle);
    Serial.print(',');
    Serial.println(readDistanceCm());
    delay(20);
  }
  for (int angle = 165; angle >= 15; angle -= 2) {
    radarServo.write(angle);
    delay(25);
    Serial.print(angle);
    Serial.print(',');
    Serial.println(readDistanceCm());
    delay(20);
  }
}
```

## 11. Processing Radar Display (radar_display.pde)

```java
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
```

The setup() function opens the serial port at 9600 baud and buffers data until a newline. The draw() function draws the range rings, angle lines and sweep line, and a red marker when the distance is between 1 and 200 cm. The serialEvent() function splits each incoming line at the comma to recover the angle and distance. Close the Arduino Serial Monitor before running this sketch, and check the Serial.list() output to select the correct port index.

## 12. Setup and Operating Procedure

1. Install the Arduino IDE and the Processing IDE.
2. Mount the HC-SR04 on the servo horn and wire the circuit with USB disconnected.
3. Test the servo and the sensor individually.
4. Connect the Arduino by USB, select the board and COM port, and upload radar.ino.
5. Open the Serial Monitor at 9600 baud and confirm lines such as 75,42 are printed.
6. Close the Serial Monitor, open radar_display.pde in Processing, select the correct port, and run.
7. Place a broad, flat, hard object in front of the sensor and observe the radar display.

## 13. Testing and Evaluation

Place a broad, flat, hard target at known distances of 10, 20, 50, 100 and 150 cm and record the measured value at each distance. Error = measured - actual; percentage error = error / actual x 100. The recording table is completed from the prototype's own readings during the practical session.

| Actual distance (cm) | Measured distance (cm) | Error (cm) | Error (%) | Notes |
|---|---|---|---|---|
| 10 | | | | |
| 20 | | | | |
| 50 | | | | |
| 100 | | | | |
| 150 | | | | |

Testing also covers detection at different angles across the sweep arc, different target surfaces (hard flat, angled, soft), and the time taken for one full sweep.

## 14. Troubleshooting

| Issue | Check |
|---|---|
| Serial error / blank display | Correct port selected, baud rate 9600 in both programs, Serial Monitor closed |
| No distance reading | TRIG D10, ECHO D11, 5V and GND connected, sensor facing the target |
| Servo does not move | Signal wire D12, servo power, common ground |
| Board restarts / servo jitters | External regulated 5V servo supply with common ground |
| Unstable readings | Broad, hard, flat target; avoid angled or soft objects |

## 15. Project Timeline

| Week | Activity |
|---|---|
| 1 | Literature review, component procurement, software installation |
| 2 | Circuit assembly and individual testing of sensor and servo |
| 3 | Arduino firmware development and serial output testing |
| 4 | Processing radar display development and integration |
| 5 | Calibration, accuracy testing and data collection |
| 6 | Analysis, documentation and final report/presentation |

## 16. Estimated Budget

Component prices vary between suppliers and are to be confirmed at the time of purchase: Arduino UNO or compatible; HC-SR04 sensor; SG90 servo; breadboard, jumper wires and USB cable; optional external 5V supply.

## 17. Limitations and Risks

- Servo current draw can cause resets or jitter - use an external regulated 5V supply with a common ground.
- Angled or soft surfaces give unstable readings - test with broad, hard, flat targets and document the effect.
- A wrong or blocked serial port stops the display - check Serial.list() and close the Serial Monitor first.
- The narrow sensor beam and 2-degree steps may miss thin objects.
- Accuracy is affected by temperature and surroundings - record the test conditions.
- Only the nearest reflecting surface at each angle is shown; this is inherent to a single-sensor design.

The prototype is for learning and demonstration, not a certified safety or navigation device.

## 18. Applications

Educational demonstrations of ranging and serial communication, simple obstacle detection for small robots, basic area scanning, and short-range presence sensing in classroom and laboratory prototypes.

## 19. Future Scope

A pan-tilt mount for 3D scanning, wireless transmission using Bluetooth or Wi-Fi, an LCD or OLED local display, buzzer or LED proximity alerts, filtering of readings to reduce noise, and a more accurate sensor such as a time-of-flight or LiDAR module.

## 20. Conclusion

This project provides a practical, low-cost introduction to ultrasonic ranging, servo control, pulse timing, digital I/O, serial communication and real-time visualisation. By building and evaluating the radar system, the student gains hands-on experience in integrating hardware and software, and produces a documented prototype with measured performance and a clear discussion of its limitations.

## 21. References

1. HC-SR04 ultrasonic sensor datasheet.
2. Arduino documentation: Servo library and pulseIn() function.
3. Processing documentation: Serial library.
4. Arduino Ultrasonic Radar Project Guide (supplied project guide).
5. Project Proposal: Arduino Ultrasonic Radar System (supplied project proposal).
