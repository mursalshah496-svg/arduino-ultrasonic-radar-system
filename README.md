# Arduino Ultrasonic Radar System

A low-cost ultrasonic radar built with an Arduino UNO, an HC-SR04 ultrasonic sensor and an SG90 servo motor. The servo sweeps the sensor from 15 degrees to 165 degrees; at each angle the Arduino measures the distance to the nearest object and sends `angle,distance` over USB serial at 9600 baud. A Processing sketch draws a live radar display with a sweep line, range rings up to 200 cm, and a red marker for detected objects.

**By:** Ali Mursal Shah - BS Electronics, COMSATS University Islamabad

## Files

| File | Contents |
|---|---|
| `radar.ino` | Arduino firmware: servo sweep, distance measurement, serial output |
| `radar_display.pde` | Processing sketch: serial input and radar display |
| `PROJECT_REPORT.md` | Complete formal project report (also delivered as a PDF) |
| `README.md` | This file |

## Components

- Arduino UNO or compatible (x1)
- HC-SR04 ultrasonic sensor (x1)
- SG90 (or similar) servo motor (x1)
- Breadboard and jumper wires (1 set)
- USB cable (x1)
- Computer with Arduino IDE and Processing IDE
- Optional: external regulated 5V supply for stable servo power

## Wiring

| Module / wire | Arduino connection |
|---|---|
| HC-SR04 VCC | 5V |
| HC-SR04 GND | GND |
| HC-SR04 TRIG | D10 |
| HC-SR04 ECHO | D11 |
| Servo signal (orange/yellow) | D12 |
| Servo power (red) | 5V (or external regulated 5V supply) |
| Servo ground (brown/black) | GND (must be common with Arduino) |

Power note: if the board resets or the servo jitters, power the servo from a separate regulated 5V supply with its ground tied to the Arduino ground.

## How it works

Distance (cm) = echo duration (microseconds) x 0.0343 / 2

Example: an echo of 2,000 microseconds gives about 34.3 cm. If no echo is received within 30 ms, the sketch reports 400 cm, which is outside the 200 cm display range.

## How to run

1. Wire the circuit with USB disconnected, with the HC-SR04 mounted on the servo horn.
2. Open `radar.ino` in the Arduino IDE, select the Arduino UNO board and the correct COM port, and upload.
3. Open the Serial Monitor at 9600 baud and confirm lines such as `75,42` are printed.
4. Close the Serial Monitor. Open `radar_display.pde` in Processing, check the `Serial.list()` output in the console, change the port index `[0]` if needed, and run.
5. Test with a broad, flat, hard object at 10, 20, 50, 100 and 150 cm.

## Troubleshooting

| Issue | Check |
|---|---|
| Serial error / blank display | Correct port, 9600 baud in both programs, Serial Monitor closed |
| No distance reading | TRIG D10, ECHO D11, 5V, GND, sensor facing the target |
| Servo does not move | Signal wire D12, servo power, common ground |
| Board restarts / servo jitters | External regulated 5V servo supply with common ground |
| Unstable readings | Use a broad, hard, flat target; avoid angled or soft objects |

## Future scope

Pan-tilt scanning, Bluetooth/Wi-Fi data transfer, a local LCD/OLED display with buzzer or LED alerts, filtering of readings, and a time-of-flight or LiDAR sensor.

This is a learning prototype, not a certified safety or navigation device.
