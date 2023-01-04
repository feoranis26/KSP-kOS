set rotors to ship:partsdubbed("lift").
set rotors_reversed to ship:partsdubbed("lift_reverse").

lock spd to ship:velocity:surface * -up.

set pitch_pid to pidloop(0.3, 0.0, 0.7).
set yaw_pid to pidloop(0.3, 0.0, 0.7).
set roll_pid to pidloop(5, 0.025, 0.7).

set x_pid to pidloop(0.3, 0.001, 0.4).
set z_pid to pidloop(0.3, 0.001, 0.4).

lock z_corr to min(4, max(-4, z_pid:update(time:seconds, spd:y))).
lock x_corr to min(4, max(-4, x_pid:update(time:seconds, spd:x))).

lock vel_corr to v(-z_corr, x_corr, 0) * 0.5.

lock input_rotation to vel_corr.
lock heading_diff_raw to up:forevector - ship:rootpart:facing:forevector.
lock roll_diff_raw to vdot(up:upvector, ship:rootpart:facing:upvector).
lock heading_diff to v(heading_diff_raw:y, -heading_diff_raw:x, 0).

lock correction to v(pitch_pid:update(time:seconds, heading_diff:x), yaw_pid:update(time:seconds, heading_diff:y), 0).

lock rot to correction.

lock pitch_yaw to v(rot:x, rot:y, 0).
lock roll to ship:control:pilotroll * 1 + (choose roll_pid:update(time:seconds, roll_diff_raw) if heading_diff_raw:mag < 0.25 else 0).

set throttle_pid to pidloop(0.00625, 0.0001, 0.0055).

set tval to 0.

until false {
    print heading_diff at (0, 4).
    print input_rotation at (0, 5).
    print spd at (0, 6).
    print roll_diff_raw at (0, 7).
    set tval to min(max(tval + throttle_pid:update(time:seconds, ship:verticalspeed), 0), 5).
    set throttle_pid:setpoint to ship:control:pilottop * 100 * throttle.
    set x_pid:setpoint to ship:control:pilotpitch * 100 * throttle.
    set z_pid:setpoint to -ship:control:pilotyaw * 100 * throttle.

    set pitch_pid:setpoint to input_rotation:x * 0.4.
    set yaw_pid:setpoint to input_rotation:y * 0.4.

    for rotor in rotors {
        set rotationvector to vcrs(rotor:position,rotor:facing:forevector).
        set thrustalignment to vdot(rotationvector, pitch_yaw) + roll.
        set total to heading_diff:mag * thrustalignment * 1000 + tval * 200 + heading_diff:mag * 200.
        rotor:getmodule("ModuleRoboticServoRotor"):setfield("rpm limit", abs(total)).
        rotor:getmodule("ModuleRoboticServoRotor"):setfield("rotation direction", total < 0).

        rotor:getmodule("ModuleRoboticServoRotor"):setfield("torque limit(%)", 100).
    }
    
    for rotor in rotors_reversed {
        set rotationvector to vcrs(rotor:position,rotor:facing:forevector).
        set thrustalignment to -(vdot(rotationvector, pitch_yaw) + roll).
        set total to heading_diff:mag * thrustalignment * 1000 + tval * 200.
        rotor:getmodule("ModuleRoboticServoRotor"):setfield("rpm limit", abs(total)).
        rotor:getmodule("ModuleRoboticServoRotor"):setfield("rotation direction", total < 0).

        rotor:getmodule("ModuleRoboticServoRotor"):setfield("torque limit(%)", 100).
    }
}