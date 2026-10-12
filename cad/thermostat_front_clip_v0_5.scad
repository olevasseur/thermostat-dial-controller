// Inverted-U thermostat panel clip v0.5. Units: mm.
// v0.5 (2026-10-11): the frame hung ~6 mm too low on v0.4 clips. The user
// measured the hinge-screw centre 58 mm below the case top versus 52 mm
// needed (dial top edge, measured 52 mm). The vent-seating part is unchanged
// (proven); only the rail cradle and its captive-nut clamp move UP 6.0 mm
// relative to the bridge, so the same printed frame hangs 6 mm higher.
// Everything below is v0.4.
// v0.4 (2026-10-03): the v0.3 M3 screw self-tapped into a 2.5 mm pilot and
// split the clip along its print layers (clip prints on its side). v0.4
// uses a 3.4 mm clearance hole and a captive M3 nut in a side pocket of a
// thicker (7 mm) cradle front wall, so the screw never wedges the plastic.
// Panel/vent geometry is unchanged from v0.3, described below.
//
// v0.3 (2026-09-30): the v0.2 5.0 mm leg was too wide for the real vent;
// the leg and everything behind the front face are now 4.0 mm wide (-1 mm,
// user direction). The vent is modelled at <= 5.0 mm (observed bound).
// Otherwise identical to v0.2, described below.
//
// v0.2: clip-only revision after the v0.1 clip test (photos/2026-09-30_*).
//
// Physical result of v0.1: the rear leg only partly entered the vent and the
// wider clip body stopped at the vent edge; the 3.0 mm leg gap wobbled on the
// 2.3 mm panel. Changes (user direction 2026-09-30):
// - Leg gap = 2.3 mm panel thickness (snug, no designed clearance).
// - Rear leg 5 mm longer (13 mm below the top surface instead of 8 mm).
// - Everything behind the front-face plane is 5.0 mm wide, never wider
//   than the 6.25 mm vent; leg front corners chamfered for the vent's
//   rounded front end.
// Unchanged: 8 mm clip width in front of the face, arm, U-hook and M3
// clamp, so the v0.1 rail stub and rail interface still apply.
//
// Model frame as v0.1: +Y up (0 = case top surface), +Z away from the
// wall, Z=0 thermostat front face, panel Z=-2.3..0. Local X = 0..clip_w.

part = "clips_plate"; // clip, clip_print, clips_plate, installed,
                      // clip_thermostat_collision
clip_count = 2;
$fn = 48;

// Measured / design parameters.
front_panel_t = 2.3;
slot_w = 5.0;                   // observed bound: 5.0 mm leg did not fit
slot_len = 21.5;
vent_tip_behind_face = 2.0;     // recorded rough; rounded vent front end
top_wall_t_proxy = 6.0;         // proxy only; photo shows deep slot walls
safe_depth = 20.0;

panel_clearance_per_side = 0.0; // snug by request
clip_w = 8.0;
narrow_w = 4.0;                 // everything behind the front face
front_leg_t = 2.0;
front_leg_len = 6.0;
rear_leg_t = 3.5;
rear_leg_len = 13.0;            // v0.1: 8.0; +5 mm by request
rear_leg_chamfer = 1.5;
beam_t = 4.0;
leg_tip_chamfer = 1.0;

// Rail / cradle interface: identical to v0.1.
ear_datum_z = 26.2;
motor_plate_t = 2.4;
rail_t = 5.0;
rail_h = 8.0;
rail_raise = 6.0;                   // v0.5: frame hangs 6 mm higher
rail_top_below_case_top = -3.0;     // v0.4: 3.0; = 3.0 - rail_raise
rail_clearance_per_side = 0.2;
cradle_wall_t = 2.5;
cradle_front_wall_t = 7.0;          // v0.3: 5.0; holds the nut pocket
cradle_floor_t = 2.5;
cradle_front_top_below_case_top = -3.0; // v0.4: 3.0; level with rail top
clamp_screw_clearance_d = 3.4;      // M3 clearance; v0.3 used a 2.5 mm pilot
clamp_screw_below_case_top = 1.4;   // v0.4: 7.4
nut_af = 5.5;                       // M3 nut across flats
nut_t = 2.4;
nut_pocket_clearance = 0.3;
nut_inner_skin = 2.0;               // between rail-side face and nut pocket
nut_pocket_floor = 0.8;             // pocket opens at X = clip_w (print top)

// --- Derived ------------------------------------------------------------------
rear_leg_z1 = -front_panel_t - panel_clearance_per_side;
rear_leg_z0 = rear_leg_z1 - rear_leg_t;
front_leg_z0 = panel_clearance_per_side;
front_leg_z1 = front_leg_z0 + front_leg_t;
rail_z1 = ear_datum_z + motor_plate_t;
rail_z0 = rail_z1 - rail_t;
cradle_hole_z0 = rail_z0 - rail_clearance_per_side;
cradle_hole_z1 = rail_z1 + rail_clearance_per_side;
cradle_back_z0 = cradle_hole_z0 - cradle_wall_t;
cradle_front_z1 = cradle_hole_z1 + cradle_front_wall_t;
cradle_y0 = -rail_top_below_case_top - rail_h - rail_clearance_per_side - cradle_floor_t;

assert(front_leg_z0 - rear_leg_z1 >= front_panel_t - 1e-9,
       "Leg gap must be at least the 2.3 mm panel.");
assert(narrow_w <= slot_w - 1.0, "Narrow section must clear the vent width.");
assert(rear_leg_len <= safe_depth - 5, "Rear leg must stay well inside safe depth.");

function nut_pocket_w() = nut_af + nut_pocket_clearance;
function nut_pocket_t() = nut_t + nut_pocket_clearance;
function nut_outer_skin() = cradle_front_wall_t - nut_inner_skin - nut_pocket_t();
function nut_top_skin() = -cradle_front_top_below_case_top
                          - (-clamp_screw_below_case_top + nut_pocket_w() / 2);
function nut_bottom_skin() = (-clamp_screw_below_case_top - nut_pocket_w() / 2)
                             - (cradle_y0 + cradle_floor_t);
assert(nut_outer_skin() >= 2.0, "Nut pocket outer skin too thin.");
assert(nut_top_skin() >= 1.5 && nut_bottom_skin() >= 0.0, "Nut pocket breaks the wall.");
assert(nut_pocket_floor + (nut_af / cos(30)) / 2 <= clip_w / 2,
       "Nut pocket must reach past the screw axis.");

// --- Clip ------------------------------------------------------------------------
module rear_leg_section() {
    // XZ section of the rear leg; front corners chamfered for the round
    // vent end. Extruded along Y.
    polygon([[0, rear_leg_z0], [narrow_w, rear_leg_z0],
             [narrow_w, rear_leg_z1 - rear_leg_chamfer],
             [narrow_w - rear_leg_chamfer, rear_leg_z1],
             [rear_leg_chamfer, rear_leg_z1],
             [0, rear_leg_z1 - rear_leg_chamfer]]);
}

module clip_local() {
    difference() {
        union() {
            // Narrow bridge part behind the front face.
            translate([0, 0, rear_leg_z0])
                cube([narrow_w, beam_t, -rear_leg_z0 + 0.01]);
            // Full-width bridge / arm in front of the face.
            cube([clip_w, beam_t, cradle_hole_z0]);
            // Rear leg (chamfered section), down from the bridge.
            translate([0, 0.01, 0]) rotate([90, 0, 0])
                linear_extrude(rear_leg_len + 0.01) rear_leg_section();
            // Front leg outside the face.
            translate([0, -front_leg_len, front_leg_z0])
                cube([clip_w, front_leg_len + 0.01, front_leg_t]);
            // U-hook cradle (unchanged from v0.1).
            translate([0, cradle_y0, cradle_back_z0])
                cube([clip_w, beam_t - cradle_y0, cradle_wall_t]);
            translate([0, cradle_y0, cradle_back_z0])
                cube([clip_w, cradle_floor_t, cradle_front_z1 - cradle_back_z0]);
            translate([0, cradle_y0, cradle_hole_z1])
                cube([clip_w, -cradle_front_top_below_case_top - cradle_y0,
                      cradle_front_wall_t]);
        }
        // Lead-in chamfers on both leg tips, on the faces toward the panel.
        translate([-0.01, -rear_leg_len, rear_leg_z1]) rotate([0, 90, 0])
            linear_extrude(clip_w + 0.02)
                polygon([[leg_tip_chamfer, -0.01], [-0.01, -0.01],
                         [-0.01, leg_tip_chamfer]]);
        translate([-0.01, -front_leg_len, front_leg_z0]) rotate([0, 90, 0])
            linear_extrude(clip_w + 0.02)
                polygon([[0.01, -0.01], [-leg_tip_chamfer, -0.01],
                         [0.01, leg_tip_chamfer]]);
        // M3 clearance hole along Z through the cradle front wall.
        translate([clip_w / 2, -clamp_screw_below_case_top, cradle_hole_z1 - 0.5])
            cylinder(d = clamp_screw_clearance_d, h = cradle_front_wall_t + 1.0, $fn = 24);
        // Captive-nut pocket: slides in from the X = clip_w face (top as printed).
        translate([nut_pocket_floor, -clamp_screw_below_case_top - nut_pocket_w() / 2,
                   cradle_hole_z1 + nut_inner_skin])
            cube([clip_w - nut_pocket_floor + 0.01, nut_pocket_w(), nut_pocket_t()]);
    }
}

// --- Cover proxy around one vent (for the collision check only) -------------------
module vent_proxy(skin = 0) {
    color([0.92, 0.92, 0.88, 0.5]) difference() {
        union() {
            translate([-10, -30, -front_panel_t + skin])
                cube([20, 30, front_panel_t - 2 * skin]);
            translate([-10, -top_wall_t_proxy, -28.5]) cube([20, top_wall_t_proxy, 28.5]);
        }
        // Vent: rounded front end, tip at vent_tip_behind_face.
        translate([0, 1, -vent_tip_behind_face - slot_w / 2]) rotate([90, 0, 0])
            linear_extrude(top_wall_t_proxy + 2) hull() {
                circle(d = slot_w);
                translate([0, -(slot_len - slot_w)]) circle(d = slot_w);
            }
    }
}

module installed_clip(lift = 0) {
    color([0.35, 0.65, 0.35]) translate([-narrow_w / 2, lift, 0]) clip_local();
}

module clip_print() { rotate([0, -90, 0]) clip_local(); }

// Reuse the printed v0.1 rail stub; the rail interface is unchanged.
module clips_plate() {
    for (i = [0:clip_count - 1]) translate([0, i * 30, 0]) clip_print();
}

if (part == "clip") clip_local();
else if (part == "clip_print") clip_print();
else if (part == "clips_plate") clips_plate();
else if (part == "installed") { vent_proxy(); installed_clip(); }
else if (part == "clip_thermostat_collision")
    // Legs intentionally touch both panel faces; skin ignores that contact.
    intersection() { installed_clip(0.02); vent_proxy(0.02); }
else assert(false, "Unknown part selector.");
