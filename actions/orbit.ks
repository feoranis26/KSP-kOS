run once "0:/actions/node.ks".
run once "0:/actions/autopilots".

function launch_to_orbit {
    parameter orbit_height, inc, turn_start_speed is 100, ascent_steepness is 1, aero_multiplier is 1, height_precision is 80.
    if ship:apoapsis >= orbit_height - 1000 {
        return.
    }

    rcs on.

    print "[ASCENT GUIDANCE] Started.".

    local lock speed_reached to max(0, min(ship:velocity:surface:mag / turn_start_speed, 1)).
    local lock slp to (altitude / orbit_height) * ascent_steepness.
    local lock ascent_profile_value to sqrt(slp).
    local lock pitch to 90 - max(0, min(90, ascent_profile_value * 90) * speed_reached).
    
    lock steering to heading(inc, pitch, 0).

    local lock apoapsis_diff to ship:apoapsis - orbit_height.

    local lock thr_reduction to sqrt(ship:dynamicpressure * (ship:airspeed * ship:airspeed) / 500000) * aero_multiplier.

    local lock thr_val to max(min(-apoapsis_diff / height_precision, 1) - thr_reduction, 0).
    lock throttle to choose thr_val if thr_val > 0.1 else 0.

    wait until altitude > 70000 and ship:apoapsis > orbit_height - 1000.

    print "[ASCENT GUIDANCE] Ascent OK.".

    unlock throttle.
    unlock steering.

    set throttle to 0.
}

function plan_circularization {
    parameter orbit_height.

    if ship:periapsis >= orbit_height - 1000 {
        return.
    }

    if(ship:periapsis)
    set CIRCULARIZATION_DV TO sqrt(SHIP:BODY:MU /(BODY:RADIUS + 1 * orbit_height)) - VELOCITYAT(SHIP, ETA:APOAPSIS + TIME:SECONDS):ORBIT:MAG.
    SET CIRCULARIZATION_NODE TO Node(TimeSpan(ETA:APOAPSIS), 0, 0, CIRCULARIZATION_DV).
    ADD CIRCULARIZATION_NODE.
}