#include <WiFi.h>
#include <ESP32Servo.h>

Servo myServo;
#define GREEN_LED 26
#define RED_LED 27
#define BUZZER 25

const char* ssid = "Aman_DoorLock";
WiFiServer server(80);

void setup() {
  Serial.begin(115200);

  myServo.attach(18);
  myServo.write(0);
  pinMode(GREEN_LED, OUTPUT);
pinMode(RED_LED, OUTPUT);

digitalWrite(GREEN_LED, LOW);
digitalWrite(RED_LED, LOW);

pinMode(BUZZER, OUTPUT);
digitalWrite(BUZZER, LOW);

digitalWrite(BUZZER, HIGH);
delay(2000);
digitalWrite(BUZZER, LOW);

  WiFi.softAP(ssid);
  server.begin();

  Serial.println("Aman Door Lock Started");
  Serial.print("IP Address: ");
  Serial.println(WiFi.softAPIP());
}

void loop() {
  WiFiClient client = server.available();

  if (client) {

    while (client.connected() && !client.available()) {
      delay(1);
    }

    String request = client.readStringUntil('\r');
    Serial.println(request);
  

if (request.indexOf("/STATUS") != -1) {

  client.println("HTTP/1.1 200 OK");
  client.println("Content-type:text/plain");
  client.println();
  client.println("ONLINE");
  client.stop();
  return;
}


    if (request.indexOf("/OPEN") != -1) {

  for (int i = 0; i < 5; i++) {
    digitalWrite(GREEN_LED, HIGH);
    delay(100);
    digitalWrite(GREEN_LED, LOW);
    delay(100);
  }

  Serial.println("Door Unlocked");

 for (int pos = 0; pos <= 90; pos += 3) {
  myServo.write(pos);
  delay(15);
}

delay(4000);

for (int pos = 90; pos >= 0; pos -= 3) {
  myServo.write(pos);
  delay(15);
}
  Serial.println("Door Locked");
}
if (request.indexOf("/RED") != -1) {

  for (int i = 0; i < 5; i++) {
    digitalWrite(RED_LED, HIGH);
    digitalWrite(BUZZER, HIGH);

    delay(100);

    digitalWrite(RED_LED, LOW);
    digitalWrite(BUZZER, LOW);

    delay(100);
  }

  Serial.println("Access Denied");
}
    client.println("HTTP/1.1 200 OK");
    client.println("Content-type:text/html");
    client.println();
    client.println("<html><body style='text-align:center;'>");
    client.println("<h1>Aman Smart Door Lock</h1>");
    client.println("<a href='/OPEN'><button style='font-size:30px;'>UNLOCK DOOR</button></a>");
    client.println("</body></html>");
    client.println();

    client.stop();
  }
}