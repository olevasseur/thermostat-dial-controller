#pragma once

// Copy this file to config.h (git-ignored) and fill in your details.
// Without config.h the firmware still runs, with serial control only
// (USB, 115200 baud).

// Wi-Fi network the ESP32 joins (2.4 GHz).
#define WIFI_STA_SSID "your-wifi-name"
#define WIFI_STA_PASSWORD "your-wifi-password"

// mDNS name: the page is served at http://<DEVICE_HOSTNAME>.local
#define DEVICE_HOSTNAME "esp32-dial"

// Optional: require a password for over-the-air (OTA) updates.
// Leave commented out to allow OTA without a password on your LAN.
// #define OTA_PASSWORD "choose-a-password"
