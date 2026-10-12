// Thermostat bottom slider clip v0.1. Units: mm.
//
// Purpose: stop the PRINTED wheel-drive frame v0.2 from wobbling left/right
// or lifting at the bottom, with no frame reprint. The frame hangs from two
// clip v0.4s on its top rail; nothing holds its bottom crossbar.
//
// Why a slider: a rigid one-piece frame cannot carry downward-hooking top
// clips and an upward-hooking bottom clip. This separate part
// hangs on the frame's bottom crossbar, then slides UP so its rear leg
// enters a bottom vent and its bridge sits under the case bottom. One M3
// push screw through a captive nut then clamps the crossbar.
//
// Model frame = wheel-drive mount v0.2 (installed): origin = dial axis on the
// thermostat front face, +X right viewed from the front, +Y up, +Z away from
// the wall. Front panel Z = -2.3..0. Case bottom at the front face is
// Y = case_top_y - case_front_h = 73 - 113 = -40.0 (+/-1.0).
//
// Slider-local frame (`slider_local()`): the proven panel clip (library
// block pb_panel_clip, i.e. clip v0.3/v0.4 profile) MIRRORED to point up:
// Y = 0 is the case bottom surface, legs go +Y; X = 0..8 with the 4 mm
// narrow leg at X = 0..4; Z as installed.
//
// Shape (section in the Y-Z plane, all 8 mm wide unless noted):
//   - clip: rear leg 13 mm up into a bottom vent (4.0 mm wide), front leg
//     6 mm up the front face, 4 mm bridge under the case bottom (proven);
//   - arm: the clip bridge continued forward to the front wall, with a
//     4 mm doubler underneath (new, below the bridge, no mating surface);
//   - channel around the crossbar: lower back wall (behind the crossbar),
//     front wall (7 mm, captive-nut clamp, proven block), top bridge and a
//     4 mm back lip that hooks over the crossbar so the slider HANGS on the
//     frame while the screw is loose.
//
// Install (frame already hung on its top clips):
//   1. Screw backed out until its tip is flush inside the front wall.
//   2. Hold the slider in front of the crossbar, about 17 mm lower than its
//      final height, push it toward the wall so the back lip passes over the
//      crossbar, and let it drop: it hangs on the crossbar ("parked",
//      slide_s = -24). Rear leg tip is then ~11 mm below the case.
//   3. Slide it sideways along the crossbar until the rear leg is under a
//      bottom vent (vent 3 assumed at X = 0; any vent between the frame feet
//      works). Push it UP until the bridge is snug under the case bottom.
//   4. Hold it up and tighten the M3 screw until snug.
//
// UNVERIFIED ASSUMPTION: the bottom vent row is centred on the dial axis
// (vent 3 at X = 0). This is NOT fit-critical: the slider can sit anywhere
// along the crossbar between the frame feet (leg centre X = -19..+15).
//
// Parts: 1 slider. Hardware: 1 x M3 screw (10-16 mm), 1 x M3 hex nut.

use <lib/dial_mount_lib.scad>;
use <thermostat_wheel_drive_mount_v0_2.scad>;

part = "assembly"; // assembly, assembly_parked, assembly_hookover, assembly_section
                   // (X slice through the leg; uses slide_s / hook_dz), slider,
                   // slider_print, print_plate, seated_collision,
                   // slide_path_collision, hookover_path_collision
slide_s = 0;       // install sweep: 0 = seated, -24 = parked (hanging), -17 = hook-over height
hook_dz = 0;       // install sweep: forward offset during hook-over (0..12)
case_bottom_shift = 0; // check sweep only: real case bottom vs nominal (+/-1)
$fn = 48;

// Measured / design parameters.

// --- Thermostat (v0.2 frame values; check asserts equality) -----------------
front_panel_t = 2.3;
case_top_y = 73.0;
case_front_h = 113.0;                 // caliper 2026-10-11
case_bottom_uncertainty = 1.0;
case_front_w = 72.0;
case_depth = 28.5;
dial_d = 40.64;
dial_h = 7.3;

// Bottom vents (identical to the top vents; v0.4 clip fits them, 2026-10-11).
vent_w_min = 4.6;                     // narrowest plausible (5.0 leg failed)
vent_w_max = 5.0;
vent_len = 21.5;
vent_tip_behind_face = 2.0;
vent_pitch = 11.3;                    // (50 - ~4.8) / 4
vent_row_center_x = 0.0;              // ASSUMED: row centred on dial axis
safe_depth = 20.0;                    // free depth above the vent opening
vent_w_collision = 4.6;               // collision proxy uses the narrow bound

// --- Frame v0.2 crossbar (printed; check asserts equality with v0.2) ---------
frame_half_w = 42.0;
column_inner_x = 36.0;
column_z0 = 20.6;
frame_front_z = 28.6;
crossbar_y0 = -34.0;
crossbar_y1 = -28.0;
pad_d = 7.0;
pad_x = 25.0;
pad_y = -31.0;
pad_face_gap = 0.3;
frame_hook_x = 33.0;
plate_hook_x = 26.0;
hook_cap_d = 7.0;

// --- Proven clip profile (library block pb_panel_clip defaults) -------------
clip_w = 8.0;
narrow_w = 4.0;
rear_leg_len = 13.0;
rear_leg_t = 3.5;
rear_leg_chamfer = 1.5;
front_leg_t = 2.0;
front_leg_len = 6.0;
beam_t = 4.0;
panel_clearance_per_side = 0.0;       // snug, as proven

// --- Slider channel and lock -------------------------------------------------
channel_clearance_per_side = 0.2;     // = v0.4 cradle on this frame's top rail
back_wall_t = 2.5;                    // = v0.4 cradle_wall_t
front_wall_t = 7.0;                   // proven captive-nut clamp wall
top_bridge_t = 4.0;
lip_len = 4.0;                        // hook engagement behind the crossbar
lower_back_wall_top = 12.0;           // local Y (= crossbar top when seated)
arm_doubler_t = 4.0;
arm_doubler_z0 = 2.0;
travel = 24.0;                        // seated (0) to parked (-travel)
hookover_s = -17.0;                   // slide_s used for the hook-over move
hookover_dz = 12.0;                   // forward start of the hook-over move
screw_local_y = 9.0;                  // = crossbar centre (pad_y) when seated

// --- Derived ------------------------------------------------------------------------
case_bottom_nominal_y = case_top_y - case_front_h;   // -40.0
case_bottom_y = case_bottom_nominal_y + case_bottom_shift;
bar_local_y0 = crossbar_y0 - case_bottom_nominal_y;  // 6
bar_local_y1 = crossbar_y1 - case_bottom_nominal_y;  // 12
rear_leg_z1 = -front_panel_t - panel_clearance_per_side;
rear_leg_z0 = rear_leg_z1 - rear_leg_t;
back_wall_z1 = column_z0 - channel_clearance_per_side;   // 20.4
back_wall_z0 = back_wall_z1 - back_wall_t;               // 17.9
front_wall_z0 = frame_front_z + channel_clearance_per_side; // 28.8
front_wall_z1 = front_wall_z0 + front_wall_t;            // 35.8
arm_len = front_wall_z1;
top_bridge_y0 = bar_local_y1 + travel;                   // 36
top_bridge_y1 = top_bridge_y0 + top_bridge_t;            // 40
lip_y0 = top_bridge_y0 - lip_len;                        // 32
slider_y0 = -beam_t - arm_doubler_t;                     // -8

assert(lower_back_wall_top >= bar_local_y1 - 1e-9,
       "Lower back wall must back the full crossbar height when seated.");
// The screw (3.0 mm thread) must stay on the 6 mm crossbar face for the
// whole case-bottom uncertainty (slider seats on the case, frame does not).
assert(case_bottom_nominal_y + screw_local_y - case_bottom_uncertainty - 1.5 >= crossbar_y0 - 1e-9 &&
       case_bottom_nominal_y + screw_local_y + case_bottom_uncertainty + 1.5 <= crossbar_y1 + 1e-9,
       "Screw must stay on the crossbar face across the case-bottom uncertainty.");
assert(travel >= 18, "Slider needs >= 18 mm travel.");

// --- Slider -------------------------------------------------------------------------
module slider_local() {
    color([0.30, 0.60, 0.85]) difference() {
        union() {
            // Proven clip, mirrored to hook UP into a bottom vent.
            mirror([0, 1, 0]) pb_panel_clip(
                arm_len = arm_len,
                rear_leg_chamfer = rear_leg_chamfer,
                override_reason = rear_leg_chamfer == 1.5 ? "" : "collision negative control only");
            // Arm doubler under the bridge, in front of the front face.
            translate([0, slider_y0, arm_doubler_z0])
                cube([clip_w, arm_doubler_t + 0.01, arm_len - arm_doubler_z0]);
            // Front wall (clamp wall), full height.
            translate([0, slider_y0, front_wall_z0])
                cube([clip_w, top_bridge_y1 - slider_y0, front_wall_t]);
            // Lower back wall, behind the crossbar when seated.
            translate([0, -0.01, back_wall_z0])
                cube([clip_w, lower_back_wall_top + 0.01, back_wall_t]);
            // Top bridge and hook lip (hangs the slider while unlocked).
            translate([0, top_bridge_y0, back_wall_z0])
                cube([clip_w, top_bridge_t, front_wall_z1 - back_wall_z0]);
            translate([0, lip_y0, back_wall_z0])
                cube([clip_w, lip_len + 0.01, back_wall_t]);
        }
        // Proven captive-M3-nut push-screw clamp; pocket opens at X = clip_w
        // (print top); screw tip pushes the crossbar against the back wall.
        translate([clip_w / 2, screw_local_y, front_wall_z0])
            pb_m3_captive_nut_clamp_cutter();
    }
}

module slider_installed(s = 0, dz = 0, x = vent_row_center_x) {
    translate([x - narrow_w / 2, case_bottom_y + s, dz]) slider_local();
}

// Print: on its side, profile in the bed plane, narrow leg face (X = 0) on
// the bed (same as clip v0.4), centred on the origin for Bambu.
module slider_print() {
    translate([(front_wall_z1 + rear_leg_z0) / 2, -(slider_y0 + top_bridge_y1) / 2, 0])
        rotate([0, -90, 0]) slider_local();
}

// --- Thermostat case proxy with bottom vents -------------------------------------
module bottom_vent(x, w) {
    translate([x, case_bottom_y - 1, -vent_tip_behind_face - w / 2]) rotate([-90, 0, 0])
        linear_extrude(safe_depth + 1) hull() {
            circle(d = w);
            translate([0, vent_len - w]) circle(d = w);
        }
}

module case_proxy(skin = 0, w = vent_w_collision) {
    color([0.92, 0.92, 0.88, 0.45]) {
        difference() {
            translate([-case_front_w / 2, case_bottom_y + skin, -case_depth])
                cube([case_front_w, case_front_h - skin, case_depth - skin]);
            for (k = [-2 : 2]) bottom_vent(vent_row_center_x + k * vent_pitch, w);
        }
        translate([0, 0, -0.01]) cylinder(d = dial_d - 2 * skin, h = dial_h + 0.01, $fn = 144);
    }
}

// Everything already installed: frame, hinge plate + wheel, motor, top clips.
module installed_hardware() {
    frame();
    swinging(0);
    motor_reference();
    clips();
}

module obstacles(skin = 0.02) {
    installed_hardware();
    case_proxy(skin);
}

module assembly(s = slide_s, dz = hook_dz) {
    case_proxy();
    installed_hardware();
    slider_installed(s, dz);
}

// Slice through the rear leg (X = -1.9..1.9) so the vent, panel and channel
// are visible in a side view.
module section_slab() { translate([vent_row_center_x - 1.9, -200, -200]) cube([3.8, 400, 400]); }

module assembly_section(s = slide_s, dz = hook_dz) {
    // Preview colours cut faces with the slab colour, so colour each slab.
    intersection() { case_proxy(); color([0.80, 0.80, 0.74]) section_slab(); }
    intersection() { installed_hardware(); color([0.20, 0.22, 0.25]) section_slab(); }
    intersection() { slider_installed(s, dz); color([0.30, 0.60, 0.85]) section_slab(); }
}

// --- Collision selectors (each must render empty) -----------------------------------
module seated_collision() {
    intersection() { slider_installed(0); obstacles(); }
}

// Slide from just above parked (top bridge resting on the crossbar) to seated.
module slide_path_collision() {
    intersection() {
        // Parked is set by the frame (nominal), seated by the real case bottom.
        union() for (s = [-travel - case_bottom_shift + 0.1 : 0.5 : 0]) slider_installed(s);
        obstacles();
    }
}

// Hook-over: move toward the wall at hookover_s, then drop to parked.
module hookover_path_collision() {
    intersection() {
        union() {
            // Hook-over height and parked position are frame-referenced.
            for (dz = [0 : 0.5 : hookover_dz])
                slider_installed(hookover_s - case_bottom_shift, dz);
            for (s = [-travel + 0.1 : 0.5 : hookover_s]) slider_installed(s - case_bottom_shift);
        }
        obstacles();
    }
}

if (part == "assembly") assembly();
else if (part == "assembly_parked") assembly(-travel, 0);
else if (part == "assembly_hookover") assembly(hookover_s, hookover_dz);
else if (part == "assembly_section") assembly_section();
else if (part == "slider") slider_local();
else if (part == "slider_print" || part == "print_plate") slider_print();
else if (part == "seated_collision") seated_collision();
else if (part == "slide_path_collision") slide_path_collision();
else if (part == "hookover_path_collision") hookover_path_collision();
else assert(false, "Unknown part selector.");
