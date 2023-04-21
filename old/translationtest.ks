set engines to ship:partsdubbed("translation").
set throttle to 1.

lock desiredthrust to SHIP:CONTROL:PILOTTRANSLATION * facing.

until false {
    for engine in engines {
        set thrustvector to (engine:facing:forevector).
        set thrustalignment to vdot(thrustvector, desiredthrust).
        set engine:thrustlimit to thrustalignment * 100.
    }
}