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
