# Wiring

## Parts

| Qty | Part |
|---|---|
| 1 | ESP32 dev board ("ESP32 Dev Module", ESP32-WROOM) |
| 1 | 28BYJ-48 5 V stepper motor |
| 1 | ULN2003 stepper driver board |
| 1 | 5 V supply, 1 A or more |
| - | Jumper wires (24 AWG is fine), and a way to join the +5 V and GND wires (e.g. WAGO 221 lever connectors) |

## Connections

| From | To | Purpose |
|---|---|---|
| ULN2003 IN1 | ESP32 GPIO 16 | Coil A |
| ULN2003 IN2 | ESP32 GPIO 17 | Coil B |
| ULN2003 IN3 | ESP32 GPIO 18 | Coil C |
| ULN2003 IN4 | ESP32 GPIO 19 | Coil D |
| ULN2003 `+` | +5 V supply | Motor power |
| ULN2003 `-` | GND | Motor ground |
| ESP32 5V / VIN | +5 V supply | Board power |
| ESP32 GND | GND | Shared ground |
| 28BYJ-48 plug | ULN2003 motor socket | Keyed, 5 wires |

```
 5 V supply (+) ----+--------------------+
                    |                    |
               ESP32 5V/VIN         ULN2003 (+)
 5 V supply (-) ----+--------------------+
                    |                    |
               ESP32 GND            ULN2003 (-)

 ESP32 GPIO16 ----- ULN2003 IN1
 ESP32 GPIO17 ----- ULN2003 IN2      ULN2003 socket ==== 28BYJ-48
 ESP32 GPIO18 ----- ULN2003 IN3
 ESP32 GPIO19 ----- ULN2003 IN4
```

## Notes

- Do not power the motor from the ESP32's 3V3 pin.
- The ESP32 and the ULN2003 must share ground.
- If you power the ESP32 from USB while the motor runs from a separate 5 V supply, connect only the grounds. Do not join the two 5 V sources.
- The firmware turns the coils off after every move, so the motor and the driver stay cool when idle.
- If the dial turns the wrong way for `+`, tap **Reverse** on the web page. Swapping IN1-IN4 wires is not needed.
