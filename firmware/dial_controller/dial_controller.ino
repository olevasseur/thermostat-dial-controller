// Thermostat dial controller: 28BYJ-48 + ULN2003 driven from a phone page.
// A 20 mm friction wheel turns the thermostat's existing dial.
//
// Board: ESP32 Dev Module (esp32:esp32:esp32). Upload at 115200 baud:
//   arduino-cli upload -p <serial-port> --fqbn esp32:esp32:esp32
//     --upload-property upload.speed=115200 firmware/dial_controller
// Wiring:
//   ULN2003 IN1..IN4 -> GPIO 16, 17, 18, 19
//   ULN2003 + and -  -> 5 V supply (WAGO), not the ESP32 3V3 pin
//   ESP32 GND and ULN2003 - share ground; ESP32 5V/VIN from the same 5 V
// Control: http://<DEVICE_HOSTNAME>.local (or the IP printed on serial at boot).
// Serial (115200): "m 128" moves +128 half-steps, "s" stops, "z" zeroes.
//
// Safety: each command is capped at kMaxPerCommand half-steps; zero is set
// with the dial at its LOWEST end stop; moves stay at or below kRangeMax
// (no lower limit: the bottom stop is harmless, the friction wheel slips).
// The position is a step count, not a measured dial angle: if the wheel
// slips, it drifts. Not a guarantee: supervise every move.
// The coils are switched off after every move so the motor and driver stay
// cool.
// 4096 half-steps = 1 motor turn; the 20 mm wheel on the 40.64 mm dial turns
// the dial about half as far (128 half-steps ~ 5.5 deg of dial).

#include <Arduino.h>
#include <ArduinoOTA.h>
#include <ESPmDNS.h>
#include <WebServer.h>
#include <WiFi.h>

// Wi-Fi and device settings live in config.h (git-ignored).
// Copy config.example.h to config.h and fill it in.
#if __has_include("config.h")
#include "config.h"
#define HAS_WIFI_SECRETS 1
#else
#define HAS_WIFI_SECRETS 0
#endif

#ifndef DEVICE_HOSTNAME
#define DEVICE_HOSTNAME "esp32-dial"
#endif

constexpr int kMotorPins[] = {16, 17, 18, 19};
constexpr uint8_t kHalfSteps[8][4] = {
    {1, 0, 0, 0}, {1, 1, 0, 0}, {0, 1, 0, 0}, {0, 1, 1, 0},
    {0, 0, 1, 0}, {0, 0, 1, 1}, {0, 0, 0, 1}, {1, 0, 0, 1},
};
constexpr long kMaxPerCommand = 600;   // ~26 deg of dial
constexpr long kRangeMax = 4600;       // ~199 deg: range-finding. Printed scale spans ~180 deg. Zero = dial at its LOWEST stop.
constexpr long kFineAbove = 4600;      // no fine-step zone: at the top stop the friction wheel just slips
constexpr int kSpeedChoices[] = {150, 300, 500};  // half-steps per second
constexpr float kDialDegPerHalfStep = 360.0f / 4096.0f * (20.0f / 40.64f);
const char *kMdnsName = DEVICE_HOSTNAME;

WebServer server(80);
int phase = 0;
long position = 0;      // half-steps from the zero point
long remaining = 0;     // signed half-steps still to move
int speedHz = 300;
bool reversed = false;  // flips which way the motor turns for "+"
uint32_t lastStepUs = 0;
uint32_t movesDone = 0;
String lastMessage = "ready";

void coilsOff() {
  for (int pin : kMotorPins) digitalWrite(pin, LOW);
}

void applyPhase() {
  for (int i = 0; i < 4; ++i) digitalWrite(kMotorPins[i], kHalfSteps[phase][i]);
}

String requestMove(long steps) {
  if (remaining != 0) return "busy: press stop or wait";
  if (steps == 0) return "nothing to do";
  if (labs(steps) > kMaxPerCommand) steps = steps > 0 ? kMaxPerCommand : -kMaxPerCommand;
  long target = position + steps;
  if (target > kFineAbove && labs(steps) > 32) {
    return "refused: above " + String(kFineAbove) + " use +32 / -32 only (creeping toward the top stop)";
  }
  if (target > kRangeMax) {
    return "refused: above the " + String(kRangeMax * kDialDegPerHalfStep, 0) +
           " deg limit from the lowest stop";
  }
  remaining = steps;
  lastStepUs = micros();
  applyPhase();
  return "moving " + String(steps) + " half-steps (~" +
         String(steps * kDialDegPerHalfStep, 1) + " deg of dial)";
}

void stepTask() {
  if (remaining == 0) return;
  uint32_t interval = 1000000UL / speedHz;
  if (micros() - lastStepUs < interval) return;
  lastStepUs += interval;
  int dir = remaining > 0 ? 1 : -1;
  phase = (phase + (reversed ? -dir : dir) + 8) % 8;
  applyPhase();
  position += dir;
  remaining -= dir;
  if (remaining == 0) {
    delay(20);  // let the last step settle before releasing
    coilsOff();
    movesDone++;
    lastMessage = "done at " + String(position) + " half-steps";
  }
}

void stopNow() {
  remaining = 0;
  coilsOff();
  lastMessage = "stopped at " + String(position) + " half-steps";
}

String statusJson() {
  return String("{\"position\":") + position + ",\"remaining\":" + remaining +
         ",\"speed_hz\":" + speedHz + ",\"dial_deg\":" +
         String(position * kDialDegPerHalfStep, 1) + ",\"moves\":" + movesDone + ",\"rssi\":" + WiFi.RSSI() +
         ",\"range_max\":" + kRangeMax + ",\"reversed\":" + (reversed ? "true" : "false") + ",\"message\":\"" + lastMessage + "\"}";
}

const char kPage[] PROGMEM = R"HTML(<!doctype html><html><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Dial motor test</title>
<style>
body{font-family:system-ui,sans-serif;margin:16px;background:#f3f5f2;color:#1d2421}
h1{font-size:22px;margin:0 0 6px}p{margin:4px 0;color:#5d6963}
.row{display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin:12px 0}
button{font-size:18px;padding:14px 6px;border-radius:10px;border:1px solid #b9c2bc;background:#fff}
button.stop{background:#d0392f;color:#fff;border:0;grid-column:1/-1;font-size:20px}
.status{background:#fff;border:1px solid #d5ddd8;border-radius:10px;padding:12px;font-variant-numeric:tabular-nums}
.big{font-size:28px;font-weight:700;color:#1d2421}
select{font-size:16px;padding:8px;border-radius:8px}
</style></head><body>
<h1>Dial motor test</h1>
<p>Each press moves the wheel a capped amount, then switches the motor off.
The dial turns the opposite way to the wheel. Hold the frame by its sides, not the motor plate.</p>
<div class="status"><div class="big" id="deg">0.0&deg;</div>
<div id="pos">position 0 half-steps</div><div id="msg">ready</div></div>
<div class="row">
<button onclick="mv(-512)">&minus; 512</button><button onclick="mv(-128)">&minus; 128</button><button onclick="mv(-32)">&minus; 32</button>
<button onclick="mv(32)">+ 32</button><button onclick="mv(128)">+ 128</button><button onclick="mv(512)">+ 512</button>
<button class="stop" onclick="go('/stop')">STOP</button>
</div>
<p>Speed: <select id="spd" onchange="go('/speed?hz='+this.value)">
<option value="150">150 half-steps/s (strongest)</option>
<option value="300" selected>300 half-steps/s</option>
<option value="500">500 half-steps/s</option></select></p>
<p><b>Before the first move:</b> turn the dial by hand all the way <b>down</b> until it stops, then:</p>
<p><button onclick="go('/zero')">Set zero here (dial at lowest stop)</button></p>
<p>First tap + 32. If the dial tried to go <b>down</b> instead of up, tap: <button onclick="go('/reverse')">Reverse</button></p>
<p>&plusmn;32 &asymp; 1.4&deg; of dial &middot; &plusmn;128 &asymp; 5.5&deg; &middot; &plusmn;512 &asymp; 22&deg;</p>
<script>
async function go(u){try{const r=await fetch(u);show(await r.json())}catch(e){document.getElementById('msg').textContent='no reply: check WiFi'}}
function mv(n){go('/move?steps='+n)}
function show(s){document.getElementById('deg').textContent=s.dial_deg.toFixed(1)+'° of dial';
document.getElementById('pos').textContent='position '+s.position+' half-steps'+(s.remaining?' · moving':'');
document.getElementById('msg').textContent=s.message;document.getElementById('spd').value=s.speed_hz}
setInterval(()=>{if(!document.hidden)go('/status')},1500);go('/status');
</script></body></html>)HTML";

void sendStatus() { server.send(200, "application/json", statusJson()); }

void setupServer() {
  server.on("/", [] { server.send_P(200, "text/html; charset=utf-8", kPage); });
  server.on("/status", sendStatus);
  server.on("/move", [] {
    lastMessage = requestMove(server.arg("steps").toInt());
    sendStatus();
  });
  server.on("/stop", [] { stopNow(); sendStatus(); });
  server.on("/zero", [] {
    if (remaining == 0) { position = 0; lastMessage = "zero set here"; }
    else lastMessage = "busy: stop first";
    sendStatus();
  });
  server.on("/reverse", [] {
    if (remaining == 0) { reversed = !reversed; lastMessage = reversed ? "direction reversed" : "direction normal"; }
    else lastMessage = "busy: stop first";
    sendStatus();
  });
  server.on("/speed", [] {
    int hz = server.arg("hz").toInt();
    bool ok = false;
    for (int choice : kSpeedChoices) ok = ok || hz == choice;
    if (ok) { speedHz = hz; lastMessage = "speed " + String(hz) + " half-steps/s"; }
    else lastMessage = "unknown speed";
    sendStatus();
  });
  server.begin();
}

void connectWifi() {
#if HAS_WIFI_SECRETS
  WiFi.mode(WIFI_STA);
  WiFi.setSleep(false);  // modem sleep caused 300-500 ms pings and 66% loss
  WiFi.begin(WIFI_STA_SSID, WIFI_STA_PASSWORD);
  Serial.print("Connecting to WiFi");
  for (int i = 0; i < 40 && WiFi.status() != WL_CONNECTED; ++i) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  if (WiFi.status() == WL_CONNECTED) {
    Serial.print("WiFi connected. IP: ");
    Serial.println(WiFi.localIP());
    Serial.printf("mDNS: http://%s.local\n", kMdnsName);
  } else {
    Serial.println("WiFi not connected yet; retrying every 10 s.");
  }
#else
  Serial.println("No config.h: serial control only.");
#endif
}

void handleSerial() {
  if (!Serial.available()) return;
  String line = Serial.readStringUntil('\n');
  line.trim();
  if (line.startsWith("m ")) lastMessage = requestMove(line.substring(2).toInt());
  else if (line == "s") stopNow();
  else if (line == "z" && remaining == 0) { position = 0; lastMessage = "zero set here"; }
  else lastMessage = "commands: m <half-steps>, s, z";
  Serial.println(statusJson());
}

void setup() {
  Serial.begin(115200);
  for (int pin : kMotorPins) pinMode(pin, OUTPUT);
  coilsOff();
  delay(300);
  Serial.println("DialMotorTest: ULN2003 on GPIO 16/17/18/19, coils off when idle");
  connectWifi();
  setupServer();
  // Over-the-air updates: arduino-cli upload -p <board-ip> ...
  ArduinoOTA.setHostname(kMdnsName);
#ifdef OTA_PASSWORD
  ArduinoOTA.setPassword(OTA_PASSWORD);
#endif
  ArduinoOTA.onStart([] { stopNow(); });
  ArduinoOTA.begin();
}

// Keep retrying WiFi: a failed connect at boot used to leave the board
// offline until reset (seen 2026-10-11).
void keepWifi() {
#if HAS_WIFI_SECRETS
  static uint32_t lastTry = 0;
  static bool mdnsStarted = false;
  if (WiFi.status() == WL_CONNECTED) {
    if (!mdnsStarted && MDNS.begin(kMdnsName)) {
      MDNS.addService("http", "tcp", 80);
      mdnsStarted = true;
      Serial.print("WiFi (re)connected. IP: ");
      Serial.println(WiFi.localIP());
    }
    return;
  }
  if (millis() - lastTry > 10000) {
    lastTry = millis();
    WiFi.disconnect();
    WiFi.begin(WIFI_STA_SSID, WIFI_STA_PASSWORD);
  }
#endif
}

void loop() {
  keepWifi();
  ArduinoOTA.handle();
  stepTask();
  server.handleClient();
  handleSerial();
}
