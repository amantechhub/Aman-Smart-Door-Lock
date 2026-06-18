# Aman Smart Door Lock

## Overview
An IoT-Based Smart Door Lock System developed using ESP32 and Flutter. The system uses QR Code Authentication to verify users and control a servo-based door locking mechanism.

## Features
- QR Code Authentication
- ESP32 Wi-Fi Communication
- Flutter Mobile Application
- Servo Motor Door Lock
- Green LED Access Granted Indicator
- Red LED Access Denied Indicator
- Security Alert Buzzer
- Real-Time User Verification
- Offline Local Network Operation

## Hardware Components
- ESP32 Dev Module
- SG90 Servo Motor
- Buzzer
- Red LED
- Green LED
- Li-ion Battery
- QR Code ID Cards

## Software Technologies
- Flutter
- Dart
- Arduino IDE
- ESP32 Libraries

## Working
1. User scans QR code using Flutter App.
2. QR data is verified.
3. ESP32 receives unlock command through Wi-Fi.
4. Servo motor opens the gate.
5. Green LED indicates successful access.
6. Invalid QR codes trigger Red LED and Buzzer alert.
7. Gate automatically locks after a few seconds.

## Future Enhancements
- Fingerprint Authentication
- Face Recognition
- Cloud Database Integration
- Access History Logs
- Remote Monitoring

## Developer
Aman Maurya
