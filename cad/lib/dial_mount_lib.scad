// dial_mount_lib.scad
//
// Shared geometry for the thermostat dial controller mount. Units: mm.
// Every default below was printed (Bambu P2S, 0.4 mm nozzle, PLA) and
// passed a physical fit test before it was used here.
//
// Proven parameters are guarded: changing one fails an assert unless the
// caller passes a non-empty `override_reason`. With a reason, the module
// renders and echoes a WARNING naming the changed parameter.

// ---------------------------------------------------------------------------
// 28BYJ-48 stepper mount voids for a 2.4 mm plate.
// Origin = motor BODY centre on the plate's bottom face: 28.0 mm body
// opening, two 4.5 mm ear holes at +/-17.75 mm (35.5 mm pitch) and an
// 18.0 x 8.5 mm wire relief on +Y. The output shaft is 4.5 mm toward -Y.
// ---------------------------------------------------------------------------
motor_body_center = [0, 0];
motor_body_d = 28.0;
motor_hole_centers = [[-17.75, 0], [17.75, 0]];
motor_hole_d = 4.5;
connector_w = 18.0;
connector_notch_h = 8.5;
connector_y = 14.9738;

module motor_voids_v2(height) {
    translate([motor_body_center[0], motor_body_center[1], -0.01])
        cylinder(d = motor_body_d, h = height + 0.02);
    translate([-connector_w / 2,
               connector_y - connector_notch_h / 2, -0.01])
        cube([connector_w, connector_notch_h, height + 0.02]);
    for (hole = motor_hole_centers)
        translate([hole[0], hole[1], -0.01])
            cylinder(d = motor_hole_d, h = height + 0.02);
}

// ---------------------------------------------------------------------------
// Double-D bore for the 28BYJ-48 output shaft (5.0 mm, 3.0 mm across the
// flats) with 0.10 mm clearance per mating surface.
// ---------------------------------------------------------------------------
shaft_diameter = 5.0;
shaft_flat_to_flat = 3.0;
fit_clearance = 0.10;
bore_diameter = shaft_diameter + 2 * fit_clearance;
bore_flat_to_flat = shaft_flat_to_flat + 2 * fit_clearance;

module double_d_bore(height) {
    intersection() {
        cylinder(d = bore_diameter, h = height);
        translate([-bore_diameter / 2, -bore_flat_to_flat / 2, 0])
            cube([bore_diameter, bore_flat_to_flat, height]);
    }
}

// ---------------------------------------------------------------------------
// Proven literals: captive-M3-nut clamp and inverted-U panel clip.
// ---------------------------------------------------------------------------

// Captive-M3-nut clamp (clip v0.4, works 2026-10-04).
pb_m3_clearance_d = 3.4;
pb_m3_nut_af = 5.5;
pb_m3_nut_t = 2.4;
pb_m3_nut_pocket_clearance = 0.3;
pb_m3_nut_inner_skin = 2.0;
pb_m3_nut_pocket_floor = 0.8;
pb_m3_clamp_wall_t = 7.0;
pb_m3_clamp_part_w = 8.0;

// Inverted-U panel clip (clip v0.3/v0.4, accepted 2026-10-03).
pb_clip_panel_t = 2.3;
pb_clip_panel_clearance_per_side = 0.0;
pb_clip_w = 8.0;
pb_clip_narrow_w = 4.0;
pb_clip_front_leg_t = 2.0;
pb_clip_front_leg_len = 6.0;
pb_clip_rear_leg_t = 3.5;
pb_clip_rear_leg_len = 13.0;
pb_clip_rear_leg_chamfer = 1.5;
pb_clip_beam_t = 4.0;
pb_clip_leg_tip_chamfer = 1.0;
pb_clip_vent_w_max = 5.0;

// ---------------------------------------------------------------------------
// Guard helper
// ---------------------------------------------------------------------------

function _pb_differs(value, proven) =
    is_list(proven)
        ? (!is_list(value) || len(value) != len(proven)
           || max([for (i = [0:len(proven) - 1]) abs(value[i] - proven[i])]) > 1e-6)
        : abs(value - proven) > 1e-6;

// Fails when a proven parameter changed without a reason; warns otherwise.
module pb_guard(block, name, value, proven, override_reason) {
    if (_pb_differs(value, proven)) {
        assert(is_string(override_reason) && override_reason != "",
               str("proven block ", block, ": ", name, " = ", value,
                   " differs from the physically proven ", proven,
                   ". Pass override_reason=\"...\" to accept an UNPROVEN variant."));
        echo(str("WARNING: UNPROVEN ", block, ": ", name, " = ", value,
                 " (proven ", proven, "). Reason: ", override_reason));
    }
}

// ===========================================================================
// Captive-M3-nut clamp
// ===========================================================================
// A through M3 clearance hole along +Z in a wall of thickness `wall_t`,
// with a hex-nut pocket (rectangular slot, nut slides in from +X) in that
// wall. Proven in a wall printed ON ITS SIDE (screw axis in the bed plane):
// the bolt+nut clamps without splitting, unlike a 2.5 mm self-tap pilot.
// Cutter frame: hole axis is the Z axis at X=Y=0; Z=0 is the wall face
// that faces the clamped part (the "rail side"); the wall spans Z=0..wall_t;
// the part spans X = -part_w/2 .. part_w/2 and the pocket opens at
// X = +part_w/2. Subtract from your wall.

function pb_m3_nut_pocket_w(nut_af = pb_m3_nut_af,
                            clearance = pb_m3_nut_pocket_clearance) = nut_af + clearance;
function pb_m3_nut_pocket_t(nut_t = pb_m3_nut_t,
                            clearance = pb_m3_nut_pocket_clearance) = nut_t + clearance;

module pb_m3_captive_nut_clamp_cutter(
    wall_t = pb_m3_clamp_wall_t,
    part_w = pb_m3_clamp_part_w,
    clearance_d = pb_m3_clearance_d,
    nut_af = pb_m3_nut_af,
    nut_t = pb_m3_nut_t,
    nut_pocket_clearance = pb_m3_nut_pocket_clearance,
    nut_inner_skin = pb_m3_nut_inner_skin,
    nut_pocket_floor = pb_m3_nut_pocket_floor,
    override_reason = ""
) {
    b = "m3_captive_nut_clamp";
    pb_guard(b, "wall_t", wall_t, pb_m3_clamp_wall_t, override_reason);
    pb_guard(b, "part_w", part_w, pb_m3_clamp_part_w, override_reason);
    pb_guard(b, "clearance_d", clearance_d, pb_m3_clearance_d, override_reason);
    pb_guard(b, "nut_af", nut_af, pb_m3_nut_af, override_reason);
    pb_guard(b, "nut_t", nut_t, pb_m3_nut_t, override_reason);
    pb_guard(b, "nut_pocket_clearance", nut_pocket_clearance,
             pb_m3_nut_pocket_clearance, override_reason);
    pb_guard(b, "nut_inner_skin", nut_inner_skin, pb_m3_nut_inner_skin, override_reason);
    pb_guard(b, "nut_pocket_floor", nut_pocket_floor, pb_m3_nut_pocket_floor,
             override_reason);

    pocket_w = nut_af + nut_pocket_clearance;
    pocket_t = nut_t + nut_pocket_clearance;
    // Geometric invariants that hold for the proven values; keep them for
    // any override too.
    assert(clearance_d >= 3.4,
           "M3 must pass freely: never self-tap across print layers.");
    assert(wall_t - nut_inner_skin - pocket_t >= 2.0, "Nut pocket outer skin < 2.0 mm.");
    assert(nut_pocket_floor + (nut_af / cos(30)) / 2 <= part_w / 2,
           "Nut pocket must reach past the screw axis.");
    assert(pocket_w < part_w, "Nut pocket wider than the part.");

    translate([0, 0, -0.5]) cylinder(d = clearance_d, h = wall_t + 1.0, $fn = 24);
    translate([-part_w / 2 + nut_pocket_floor, -pocket_w / 2, nut_inner_skin])
        cube([part_w - nut_pocket_floor + 0.01, pocket_w, pocket_t]);
}

// ===========================================================================
// Inverted-U panel clip with chamfered vent leg
// ===========================================================================
// Straddles a thin front panel: a front leg outside the panel face and a
// narrow chamfered rear leg that drops through a vent slot behind it.
// Frame (as thermostat clip v0.4): +Y up, Y=0 = case top surface; Z=0 =
// panel front face; panel occupies Z=-panel_t..0; X = 0..clip_w; the
// narrow leg occupies X = 0..narrow_w. `arm_len` (free) is how far the
// full-width bridge runs forward (+Z) from the panel face for the caller
// to attach a cradle or rail; v0.4 used 23.4 mm.

module pb_panel_clip(
    arm_len = 23.4,                 // free: caller attachment length
    panel_t = pb_clip_panel_t,
    panel_clearance_per_side = pb_clip_panel_clearance_per_side,
    clip_w = pb_clip_w,
    narrow_w = pb_clip_narrow_w,
    front_leg_t = pb_clip_front_leg_t,
    front_leg_len = pb_clip_front_leg_len,
    rear_leg_t = pb_clip_rear_leg_t,
    rear_leg_len = pb_clip_rear_leg_len,
    rear_leg_chamfer = pb_clip_rear_leg_chamfer,
    beam_t = pb_clip_beam_t,
    leg_tip_chamfer = pb_clip_leg_tip_chamfer,
    vent_w_max = pb_clip_vent_w_max,
    override_reason = ""
) {
    b = "panel_clip";
    pb_guard(b, "panel_t", panel_t, pb_clip_panel_t, override_reason);
    pb_guard(b, "panel_clearance_per_side", panel_clearance_per_side,
             pb_clip_panel_clearance_per_side, override_reason);
    pb_guard(b, "clip_w", clip_w, pb_clip_w, override_reason);
    pb_guard(b, "narrow_w", narrow_w, pb_clip_narrow_w, override_reason);
    pb_guard(b, "front_leg_t", front_leg_t, pb_clip_front_leg_t, override_reason);
    pb_guard(b, "front_leg_len", front_leg_len, pb_clip_front_leg_len, override_reason);
    pb_guard(b, "rear_leg_t", rear_leg_t, pb_clip_rear_leg_t, override_reason);
    pb_guard(b, "rear_leg_len", rear_leg_len, pb_clip_rear_leg_len, override_reason);
    pb_guard(b, "rear_leg_chamfer", rear_leg_chamfer, pb_clip_rear_leg_chamfer,
             override_reason);
    pb_guard(b, "beam_t", beam_t, pb_clip_beam_t, override_reason);
    pb_guard(b, "leg_tip_chamfer", leg_tip_chamfer, pb_clip_leg_tip_chamfer,
             override_reason);
    pb_guard(b, "vent_w_max", vent_w_max, pb_clip_vent_w_max, override_reason);

    rear_z1 = -panel_t - panel_clearance_per_side;
    rear_z0 = rear_z1 - rear_leg_t;
    front_z0 = panel_clearance_per_side;
    assert(front_z0 - rear_z1 >= panel_t - 1e-9, "Leg gap must be at least the panel.");
    assert(narrow_w <= vent_w_max - 1.0,
           "Narrow leg must be >= 1 mm narrower than the vent (5.0 mm leg failed in a 5.0 mm vent).");
    assert(arm_len >= front_leg_t, "Arm must cover the front leg.");

    difference() {
        union() {
            translate([0, 0, rear_z0]) cube([narrow_w, beam_t, -rear_z0 + 0.01]);
            cube([clip_w, beam_t, arm_len]);
            translate([0, 0.01, 0]) rotate([90, 0, 0])
                linear_extrude(rear_leg_len + 0.01)
                    polygon([[0, rear_z0], [narrow_w, rear_z0],
                             [narrow_w, rear_z1 - rear_leg_chamfer],
                             [narrow_w - rear_leg_chamfer, rear_z1],
                             [rear_leg_chamfer, rear_z1],
                             [0, rear_z1 - rear_leg_chamfer]]);
            translate([0, -front_leg_len, front_z0])
                cube([clip_w, front_leg_len + 0.01, front_leg_t]);
        }
        translate([-0.01, -rear_leg_len, rear_z1]) rotate([0, 90, 0])
            linear_extrude(clip_w + 0.02)
                polygon([[leg_tip_chamfer, -0.01], [-0.01, -0.01],
                         [-0.01, leg_tip_chamfer]]);
        translate([-0.01, -front_leg_len, front_z0]) rotate([0, 90, 0])
            linear_extrude(clip_w + 0.02)
                polygon([[0.01, -0.01], [-leg_tip_chamfer, -0.01],
                         [0.01, leg_tip_chamfer]]);
    }
}
