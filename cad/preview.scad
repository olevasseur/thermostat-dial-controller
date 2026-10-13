// README pictures of the wheel-drive mount, stood upright as it hangs on the
// wall (model +Y becomes up). Preview only, not a print file.
// part = "installed" (with the thermostat stand-in) or "mount" (mount only).

use <thermostat_wheel_drive_mount_v0_2.scad>

part = "installed";
$fn = 72;

rotate([90, 0, 0]) {
    if (part == "installed") thermostat_proxy();
    frame();
    swinging(0);
    motor_reference();
    clips();
}
