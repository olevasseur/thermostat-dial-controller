// Thermostat wheel-drive mount v0.2. Units: mm.
// Replaces the v0.1 cap/groove drive with a 20 mm friction wheel on the dial
// rim (user direction 2026-09-28). Hangs from the accepted clip v0.3.
//
// Model frame (installed): origin = dial axis on the thermostat front face.
// +X right viewed from the front, +Y up, +Z away from the wall.
//
// Reused, already-proven geometry (not re-tested here):
// - Clock motor plate voids `motor_voids_v2()` (28.0 mm body, 4.5 mm ear
//   holes at 35.5 mm pitch, 18.0 x 8.5 mm wire relief, 2.4 mm plate), in
//   the clock orientation: wire relief up, shaft 4.5 mm below body centre.
// - Clock shaft stack: D-flat stop 4.0 mm, shaft tip 10.0 mm from ear face.
// - Double-D wheel: 20 mm x 8 mm, 5.20 / 3.20 mm bore (passed fit test).
// - Clip v0.3 rail interface: rail Z 23.6..28.6, Y = case top - 11..-3.
//
// How it works: the motor plate pivots on an M3 pin at the left, level with
// the dial top. Gravity (plus an optional rubber band between two hooks)
// presses the wheel down onto the dial rim. The pivot absorbs the +/-1.18 mm
// dial-height uncertainty; a ledge stops the plate dropping when lifted off.
//
// Parts: frame, hinge plate, wheel. Hardware: 2 x M3 + nuts (motor ears),
// 1 x M3 x 20 hinge pin (19.8 mm clevis) with a nut in the back trap, 1 rubber band (opt.).
// New and unvalidated: hinge, preload/grip, frame stiffness, powered drive.

use <lib/dial_mount_lib.scad>; // motor_voids_v2(), double_d_bore()
use <thermostat_front_clip_v0_5.scad>; // installed clip (preview + collision check only)

part = "assembly"; // assembly, frame, plate, wheel, mount_plate, mount_plate_no_wheel,
                   // *_collision
plate_angle = 0;   // degrees; preview only (negative = wheel lowered)
$fn = 72;

// Measured / design parameters.

// --- Thermostat -----------------------------------------------------------------
front_panel_t = 2.3;
dial_d = 40.64;
dial_h = 7.3;
case_front_w = 72.0;
case_front_h = 113.0;
case_top_y = 73.0;
dial_axis_y_uncertainty = 1.18;

// --- Clock motor + wheel (reused) -------------------------------------------------
motor_plate_t = 2.4;
shaft_offset_from_body_center = 4.5;
motor_hole_x = 17.75;
motor_body_d = 28.0;
motor_body_depth = 19.0;
shaft_stop_from_datum = 4.0;
shaft_tip_from_datum = 10.0;
motor_boss_from_datum = 2.5;
motor_boss_envelope_d = 12.0;
ear_hardware_envelope_d = 7.0;
ear_hardware_envelope_h = 3.2;
wheel_d = 20.0;
wheel_t = 8.0;

// --- Hinge plate --------------------------------------------------------------------
plate_half_w = 25.0;
plate_y0 = 16.8;
plate_y1 = 57.8;
arm_h = 6.0;
pivot_x = -32.0;
pivot_ear_d = 7.0;
pin_hole_d = 3.4;
right_arm_x1 = 34.0;
hook_d = 4.0;
hook_cap_d = 7.0;
hook_h = 4.0;
plate_hook_x = 26.0;               // cap stays clear of the drop-stop ledge

// --- Frame ----------------------------------------------------------------------
frame_half_w = 42.0;
column_inner_x = 36.0;
column_z0 = 20.6;
rail_t = 5.0;
rail_h = 8.0;
rail_top_below_case_top = 3.0;
frame_front_z = 28.6;               // clip v0.3 rail front face
crossbar_y0 = -34.0;
crossbar_y1 = -28.0;
pad_d = 7.0;
pad_x = 25.0;
pad_y = -31.0;
pad_face_gap = 0.3;
clevis_x1 = -27.0;
clevis_half_h = 6.0;
clevis_slot_half_h = 4.0;
clevis_back_z = 8.8;                // 1.3 mm behind the M3 nut trap
clevis_clearance_per_side = 0.2;
nut_trap_af = 5.8;                  // M3 nut 5.5 mm across flats + 0.3
nut_trap_depth = 2.5;
stop_gap = 4.8;                     // at the right arm, plate level
frame_hook_x = 33.0;

// --- Derived ----------------------------------------------------------------------
dial_r = dial_d / 2;
wheel_r = wheel_d / 2;
shaft = [0, dial_r + wheel_r];                      // wheel on dial top
body_center = [0, shaft[1] + shaft_offset_from_body_center];
pivot = [pivot_x, dial_r];                          // level with contact
wheel_z0 = 0.8;
ear_datum_z = wheel_z0 + wheel_t + shaft_stop_from_datum; // wheel pushed to stop
plate_front_z = ear_datum_z + motor_plate_t;
rail_y1 = case_top_y - rail_top_below_case_top;
rail_y0 = rail_y1 - rail_h;
rail_z0 = frame_front_z - rail_t;
arm_y0 = pivot[1] - arm_h / 2;
arm_y1 = pivot[1] + arm_h / 2;
ledge_top_y = arm_y0 - stop_gap;
slot_z0 = ear_datum_z - clevis_clearance_per_side;
slot_z1 = plate_front_z + clevis_clearance_per_side;
dial_low_angle = -atan(dial_axis_y_uncertainty / (shaft[0] - pivot[0]));
dial_high_angle = -dial_low_angle;
stop_angle = -asin(stop_gap / (right_arm_x1 - pivot[0]));

// --- Assertions -------------------------------------------------------------------
assert(abs(pivot[1] - dial_r) < 1e-9,
       "Pivot must be level with the wheel/dial contact so drive force does not lift the wheel.");
assert(wheel_z0 >= 0.5, "Wheel must clear the thermostat face.");
assert(min(dial_h, wheel_z0 + wheel_t) - wheel_z0 >= 5.0, "Wheel/dial rim overlap too small.");
assert(ear_datum_z - ear_hardware_envelope_h - (wheel_z0 + wheel_t) >= 0.5,
       "Ear hardware must clear the wheel face.");
assert(ear_datum_z - motor_boss_from_datum - (wheel_z0 + wheel_t) >= 1.0,
       "Motor boss must clear the wheel.");
assert(stop_angle < dial_low_angle - 1, "Drop stop must not lift the wheel off a low dial.");
assert(slot_z0 - clevis_back_z >= nut_trap_depth + 1.2,
       "Clevis back lug must keep >= 1.2 mm behind the nut trap.");
assert(column_z0 >= plate_front_z + 3, "Columns must sit in front of the hinge plate.");

// --- Hinge plate ----------------------------------------------------------------------
module hook(h0) {
    translate([0, 0, h0]) cylinder(d = hook_d, h = hook_h + 0.01);
    translate([0, 0, h0 + hook_h]) cylinder(d = hook_cap_d, h = 1.0);
}

module hinge_plate_2d() {
    difference() {
        union() {
            translate([-plate_half_w, plate_y0]) square([2 * plate_half_w, plate_y1 - plate_y0]);
            translate([pivot_x, arm_y0]) square([-plate_half_w - pivot_x + 0.01, arm_h]);
            translate(pivot) circle(d = pivot_ear_d);
            translate([plate_half_w - 0.01, arm_y0]) square([right_arm_x1 - plate_half_w, arm_h]);
        }
        translate(pivot) circle(d = pin_hole_d, $fn = 24);
    }
}

module hinge_plate() {
    color([0.85, 0.45, 0.15]) difference() {
        union() {
            translate([0, 0, ear_datum_z]) linear_extrude(motor_plate_t) hinge_plate_2d();
            translate([plate_hook_x, pivot[1], 0]) hook(plate_front_z - 0.01);
        }
        translate([body_center[0], body_center[1], ear_datum_z]) motor_voids_v2(motor_plate_t);
    }
}

module wheel_part() {
    color([0.30, 0.55, 0.80]) difference() {
        cylinder(d = wheel_d, h = wheel_t);
        translate([0, 0, -0.01]) double_d_bore(wheel_t + 0.02);
    }
}

module wheel_installed() { translate([shaft[0], shaft[1], wheel_z0]) wheel_part(); }

module motor_shaft_side_envelope() {
    translate([shaft[0], shaft[1], ear_datum_z - motor_boss_from_datum])
        cylinder(d = motor_boss_envelope_d, h = motor_boss_from_datum);
    for (s = [-1, 1])
        translate([body_center[0] + s * motor_hole_x, body_center[1],
                   ear_datum_z - ear_hardware_envelope_h])
            cylinder(d = ear_hardware_envelope_d, h = ear_hardware_envelope_h);
}

module motor_reference() {
    color([0.75, 0.75, 0.78, 0.7]) {
        translate([body_center[0], body_center[1], ear_datum_z])
            cylinder(d = motor_body_d, h = motor_body_depth);
        translate([-9, body_center[1] + motor_body_d / 2 - 2.5, ear_datum_z])
            cube([18, 6, motor_body_depth]);
    }
}

// Everything that swings with the plate.
module swinging(angle = 0, with_wheel = true) {
    translate([pivot[0], pivot[1], 0]) rotate([0, 0, angle])
        translate([-pivot[0], -pivot[1], 0]) {
            hinge_plate();
            motor_shaft_side_envelope();
            if (with_wheel) wheel_installed();
        }
}

// --- Frame -----------------------------------------------------------------------------
module lower_pad() {
    translate([0, 0, pad_face_gap + pad_d / 2])
        cylinder(d = pad_d, h = column_z0 - pad_face_gap - pad_d / 2 + 0.01);
    translate([0, 0, pad_face_gap + pad_d / 2]) sphere(d = pad_d);
}

module frame() {
    color([0.20, 0.22, 0.25]) difference() {
        union() {
            // Top rail (clip v0.3 interface).
            translate([-frame_half_w, rail_y0, rail_z0])
                cube([2 * frame_half_w, rail_h, rail_t]);
            // Side columns and bottom crossbar.
            for (s = [-1, 1])
                translate([s > 0 ? column_inner_x : -frame_half_w, crossbar_y0, column_z0])
                    cube([frame_half_w - column_inner_x, rail_y1 - crossbar_y0,
                          frame_front_z - column_z0]);
            translate([-frame_half_w, crossbar_y0, column_z0])
                cube([2 * frame_half_w, crossbar_y1 - crossbar_y0, frame_front_z - column_z0]);
            for (s = [-1, 1]) translate([s * pad_x, pad_y, 0]) lower_pad();
            // Hinge clevis on the left column.
            translate([-frame_half_w, pivot[1] - clevis_half_h, clevis_back_z])
                cube([clevis_x1 + frame_half_w, 2 * clevis_half_h,
                      frame_front_z - clevis_back_z]);
            // Drop-stop ledge under the right arm.
            translate([right_arm_x1 - 4, ledge_top_y - 3, ear_datum_z])
                cube([column_inner_x - right_arm_x1 + 4.01, 3, frame_front_z - ear_datum_z]);
            // Rubber-band hook on the crossbar back face.
            translate([frame_hook_x, pad_y, column_z0 + 0.01]) mirror([0, 0, 1]) hook(0);
        }
        // Clevis slot for the plate ear, open toward +X.
        translate([pivot_x - pivot_ear_d / 2 - 0.6, pivot[1] - clevis_slot_half_h, slot_z0])
            cube([clevis_x1 - pivot_x + pivot_ear_d / 2 + 1.6, 2 * clevis_slot_half_h,
                  slot_z1 - slot_z0]);
        // M3 pin hole and nut trap on the back face.
        translate([pivot[0], pivot[1], clevis_back_z - 0.01])
            cylinder(d = pin_hole_d, h = frame_front_z - clevis_back_z + 0.02, $fn = 24);
        translate([pivot[0], pivot[1], clevis_back_z - 0.01])
            cylinder(d = nut_trap_af / cos(30), h = nut_trap_depth + 0.01, $fn = 6);
    }
}

// --- References ---------------------------------------------------------------------
contact_skin = 0.02;

module thermostat_proxy(skin = 0) {
    color([0.92, 0.92, 0.88, 0.45]) {
        translate([-case_front_w / 2, case_top_y - case_front_h, -front_panel_t])
            cube([case_front_w, case_front_h, front_panel_t - skin]);
        cylinder(d = dial_d - 2 * skin, h = dial_h, $fn = 144);
    }
}

// The frame is modelled in clip v0.4 coordinates. Printed clips seat about
// 6 mm deeper in the vents than modelled, so clip v0.5 raises its rail cradle
// by 6 mm. Here the v0.5 clip is drawn 6 mm lower so its cradle meets the
// frame rail; on the real thermostat the whole frame sits 6 mm higher.
clip_v0_5_rail_raise = 6.0;

module clips() {
    for (sx = [-25, 25]) translate([sx, case_top_y, 0])
        installed_clip(lift = -clip_v0_5_rail_raise);
}

module assembly() {
    thermostat_proxy();
    frame();
    swinging(plate_angle);
    translate([pivot[0], pivot[1], 0]) rotate([0, 0, plate_angle])
        translate([-pivot[0], -pivot[1], 0]) motor_reference();
    clips();
}

// --- Print layout -----------------------------------------------------------------
// Laid out compactly and centred on the origin so Bambu places it on the bed.
module mount_plate(with_wheel = true) {
    translate([-37, 18, 0]) {
        translate([0, 0, frame_front_z]) rotate([180, 0, 0]) frame();
        translate([82, -12, -ear_datum_z]) hinge_plate();
        if (with_wheel) translate([82, -50, 0]) wheel_part();
    }
}

// --- Collision references (each must render empty) ---------------------------------
module plate_frame_sweep_collision() {
    intersection() {
        union() for (a = [stop_angle + 0.2 : 0.5 : dial_high_angle + 1.0]) swinging(a, false);
        frame();
    }
}

module mount_thermostat_collision() {
    intersection() {
        union() { frame(); swinging(0); }
        thermostat_proxy(contact_skin);
    }
}

module clip_frame_collision() {
    intersection() { clips(); frame(); }
}

if (part == "assembly") assembly();
else if (part == "frame") frame();
else if (part == "plate") hinge_plate();
else if (part == "wheel") wheel_part();
else if (part == "mount_plate") mount_plate();
else if (part == "mount_plate_no_wheel") mount_plate(false);
else if (part == "plate_frame_sweep_collision") plate_frame_sweep_collision();
else if (part == "mount_thermostat_collision") mount_thermostat_collision();
else if (part == "clip_frame_collision") clip_frame_collision();
else assert(false, "Unknown part selector.");
