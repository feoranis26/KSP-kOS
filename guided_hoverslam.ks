parameter land_tgt, hoverslam_height is 25, safety_margin is 0.7, touchdown_spd is 2.

set C_RCS_POWER to 0.2.
set C_ENGINE_POWER to 0.
set C_CANCEL_CORR_MAG to 0.5.
set C_ROCKET_HEIGHT to 38.
set C_HDESCENT_TRANSLATION_MAG to 0.2.
set C_STEERING_DTERM to 1.

SET STEERINGMANAGER:PITCHPID:KD TO C_STEERING_DTERM.
SET STEERINGMANAGER:YAWPID:KD TO C_STEERING_DTERM.
SET STEERINGMANAGER:ROLLPID:KD TO C_STEERING_DTERM.

set hoverslam_height to hoverslam_height + 10 + C_ROCKET_HEIGHT.
clearscreen.

switch to 0.

set beeper to getvoice(0).
set beep to note(400, 0.1).
set beep2 to note(800, 0.25).
set beep3 to note(400, 0.25).
set beeep to note(400, 0.5).
set beeep2 to note(800, 0.5).
set beeep3 to note(1200, 0.5).
set bip to note(1200, 0.1).
set beeper:release to 0.


print "-- WORST HOVERSLAM SCRIPT EVER ver 1.509 --" at (0, 2).
print "--  !GUARANTEED WORKS 1/2 THE TIME(tm)!  --" at (0, 3).
print "--  !NOW WITH BETTER  SURVIVAL CHANCES!  --" at (0, 3).
print "--  !           UP TO 2/3**           !  --" at (0, 4).
print "-------------------------------------------" at (0, 5).

print "--------- ! HOVER HEIGHT IS :" + floor(hoverslam_height) + "! --------" at (0, 6).
print "--------- ! SAFETY MARGN IS : " + floor(safety_margin) + " ! --------" at (0, 7).
print "--------- ! TOUCHDOWN SP IS : " + floor(touchdown_spd) + " ! --------" at (0, 8).

sas off.

set engines to ship:partsdubbed("translation").
set mainengine to ship:partsdubbed("mainengine")[0].

for engine in engines {
    set engine:thrustlimit to 0.
}

set mainengine:thrustlimit to 100.

print "PERFORMING COURSE CORRECTION!!!".

lock impactpos to addons:tr:impactpos.

// when altitude < 25000 then {
//     set impact_time to 0.
//     set calc_imp_pos to impact_data().
//     set last_update_time to time:seconds.

//     when time:seconds - last_update_time > 0.1 then{
//         set calc_imp_pos to impact_data().
//         set last_update_time to time:seconds.

//         preserve.
//     }
//     lock impactpos to calc_imp_pos.
// }

lock land_pos to ship:body:geopositionof(land_tgt:position).

lock dLatitude to land_pos:lat - impactpos:lat.
lock dLongitude to land_pos:lng - impactpos:lng.

set CORR_DIFF_TGT to 0.05.
set CORR_MAX_ANGLE to 0.
set CORR_MAX_THROTT to 10.

lock sinYaw to sin(ship:up:yaw).
lock cosYaw to cos(ship:up:yaw).
lock sinPitch to sin(ship:up:pitch).
lock cosPitch to cos(ship:up:pitch).

lock unitVectorEast to V(-cosYaw, 0, sinYaw).
lock unitVectorNorth to V(-sinYaw*sinPitch, cosPitch, -cosYaw*sinPitch).
lock shipVelocitySurface to ship:velocity:surface.
lock speedEast to vdot(shipVelocitySurface, unitVectorEast).
lock speedNorth to vdot(shipVelocitySurface, unitVectorNorth).
lock speedVertical to ship:verticalspeed.

lock zcorrection to dLatitude - SHIP:CONTROL:PILOTPITCH * 10.
lock xcorrection to dLongitude - SHIP:CONTROL:PILOTYAW * 10.
lock ycorrection to 0.

lock vec to v(xcorrection, 0, zcorrection).

lock lookDir to lookdirup(vec, v(0, 1, 0)).
lock yawc to lookdir:yaw.
lock rollc to lookdir:roll.

lock corrMag to min(v(xcorrection, 0, zcorrection):mag*2, 1).

lock steerdir to heading(yawc, CORR_MAX_ANGLE, rollc).

lock steering to steerdir.
lock diff to (steerdir:forevector - facing:forevector).
lock thrdiff to min((CORR_DIFF_TGT/diff:mag), 1).
lock throttle to corrMag * thrdiff * CORR_MAX_THROTT.

until abs(dLatitude + dLongitude) < 0.025 or altitude < 10000 {
    print "diff: " + diff:mag at(0, 9).
    print "VELOCITY IS: " + speedEast + ", " + speedNorth at (0, 10).
    print "LATLNG DIFF IS: " + dLatitude + ", " + dLongitude at (0, 11).
    print "THRUST_VECTOR: " + vec at (0,12).
    print "LAND LATLNG IS: " + land_pos:lat + ", " + land_pos:lng at (0, 13).
    print "CRNT LATLNG IS: " + impactpos:lat + ", " + impactpos:lng at (0, 14).
    print "VECTOR: " + v(0, 0, 1) * steerdir at (0, 15).
}

print "-------------------------------------------" at (0, 9).
print "--     WAITING UNTIL REENTRY IS DONE     --" at (0, 10).

set CORR_MAX_ANGLE to 1.

lock distToTarget to (impactpos:position - ship:body:position) - (land_pos:position - ship:body:position).

lock gcn to vcrs(impactpos:position - ship:body:position, land_pos:position - ship:body:position):normalized.
lock corr_vec to -vcrs(gcn, impactpos:position - ship:body:position):normalized.

lock corrvel to (abs(distToTarget:mag) / 20) * (1 / (max(ADDONS:TR:timetillimpact, 2) / 5)).
set control to ship:control.

lock translationvector to corr_vec:normalized * corrvel.
print control:translation.

unlock yawc.
unlock rollc.
lock throttle to 1.
set mainengine:thrustlimit to 0.

lock vector_mag to choose -3 if altitude < 16000 and ship:airspeed > 400 else 2 * mainengine:thrustlimit / 100.

lock steering to lookdirup(-(velocity:surface:normalized + translationvector:normalized * min(translationvector:mag, 0.5) * vector_mag), v(0, -1, 0)).

wait 1.
beeper:play(beep3).
wait 0.5.
beeper:play(beep3).
wait 2.
beeper:play(beep3).
wait 0.5.
beeper:play(beep3).

lock grav to body:mu/(body:radius+ship:altitude)^2.
lock dir to ship:sensors:acc:normalized.
lock engineLiftRatio to cos(vectorangle(ship:facing:vector, ship:up:vector)).
lock engineLiftPower to (mainengine:maxthrust / ship:mass - grav) * max(0.25, engineLiftRatio).
lock engineSafetyMargin to engineLiftPower * 0.9. //Safety margin because the calculation isn't 100% accurate.
lock timeToStop to abs((ship:verticalspeed) / engineSafetyMargin).
lock distToStop to abs((ship:verticalspeed) * timeToStop / 2).

until (distToStop - alt:radar) > -hoverslam_height {
    print "--------- !HOVERSLAM IN PROGRES!  --------" at (0, 13).
    print "--------- !    BURN IMMINENT   !  --------" at (0, 14).
    print "--------- ! EST DURATION IS :" + floor(timeToStop) + "! --------" at (0, 15).
    print "--------- !      ETA :      " + abs(floor((alt:radar - distToStop) / ship:verticalspeed)) + "! --------" at (0, 16).
    print "COURSE CORRECTION VELOCITY IS: " + corrvel at (0, 11).
    print "COURSECORRECTIONVECTOR: " + translationvector at (0, 12).
    print "LATLNG DIFF IS: " + dLatitude + ", " + dLongitude at (0, 13).
    print "VECTOR MAG: " + vector_mag at (0, 14).
    print "TRVEC MAG: " + translationvector:mag at (0, 15).
    if mod(time:seconds, 0.2) = 0 {beeper:play(beep).}


    for engine in engines {
        set thrustvector to (engine:facing:forevector).
        set thrustalignment to -vdot(thrustvector, translationvector).
        set engine:thrustlimit to thrustalignment * 100 * C_ENGINE_POWER.
    }

    //set ship:control:translation to (translationvector * -up) / C_RCS_POWER.

    wait 0.
}



clearscreen.

set slamDone to false.

when distToStop - alt:radar > -hoverslam_height and ship:verticalspeed < -touchdown_spd then{
    if not slamDone {
        set mainengine:thrustlimit to 100.
    }
    return not slamDone.
}

when distToStop - alt:radar < -(hoverslam_height - 10) and ship:verticalspeed < -touchdown_spd then {
    if not slamDone {
        set mainengine:thrustlimit to 0.
    }
    return not slamDone.
}

when alt:radar < 5000 then {
    set GEAR to false.
    wait 0.1.
    set GEAR to true.
}

when ship:verticalspeed > -touchdown_spd then{
    lock throttle to 0.
}

until ship:verticalspeed > -touchdown_spd {
    print "-- !HOVERSLAM IN PROGRES! --" at (0, 17).
    print "-- !!!!!!DECELERATE!!!!!! --" at (0, 18).
    print "ALTITUDE IS: " + ship:altitude at (0, 19).
    print "BURN DISTANCE IS: " + distToStop at (0, 20).
    print "VECTOR MAG: " + vector_mag at (0, 21).
    if mod(time:seconds, 0.25) < 0.125 {beeper:play(beep2).}
    if mod(time:seconds, 0.25) > 0.125 {beeper:play(beep3).}

    for engine in engines {
        set thrustvector to (engine:facing:forevector).
        set thrustalignment to -vdot(thrustvector, translationvector).
        set engine:thrustlimit to thrustalignment * 100 * C_ENGINE_POWER.
    }

    //set ship:control:translation to (translationvector * -up) / C_RCS_POWER.

    wait 0.
}
wait until ship:verticalspeed > -touchdown_spd.
set slamDone to true.

unlock throttle.
set mainengine:thrustlimit to 100.
for engine in engines {
    set engine:thrustlimit to 0.
}


unlock throttle.
set throttle to 1.
sas off.
//lock velcancel to ship:velocity:surface - up:forevector * vdot(v1, up:forevector).
//lock vel to VXCL(up:forevector, ship:velocity:surface).

unlock impactpos.

lock tvec to -(land_tgt:position) * C_HDESCENT_TRANSLATION_MAG + ship:velocity:surface.

lock zcorrection to -speedNorth + SHIP:CONTROL:PILOTPITCH * 10.
lock xcorrection to -speedEast + SHIP:CONTROL:PILOTYAW * 10.
lock vec to v(xcorrection, 0, zcorrection).

lock lookDir to lookdirup(vec, v(0, 1, 0)).
lock yawc to lookdir:yaw.
lock rollc to lookdir:roll.
lock corrMag to min(vec:mag*C_CANCEL_CORR_MAG, 25).

lock steering to lookdirup(heading(yawc, 90 - corrMag, rollc):forevector, v(0, 0, 1)).

lock t to mod(time:seconds, 1).

set throttle_pid to pidloop(0.00625, 0.010, 0.0015).
set throttle_pid:setpoint to -touchdown_spd.

set mainengine:thrustlimit to 100.
wait 0.
set tval to -((ship:mass * grav) / mainengine:maxthrust).

set hoverDone to false.

when ship:verticalspeed > -1 and alt:radar < C_ROCKET_HEIGHT then {
    wait 1.
    if ship:verticalspeed > -1 and ship:verticalspeed < 1 and alt:radar < 40 {
        print "HOVER DONE".
        set hoverDone to true.
    }
    else {
        preserve.
    }
}

until hoverDone { 
    set tval to min(max(tval + throttle_pid:update(time:seconds, ship:verticalspeed), 0), 1).
    print "VERTICAL DESCENT!" at (0, 21).
    print "VELOCITY IS: " + speedEast + ", " + speedNorth at (0, 22).
    print "CORRECTN IS: " + tvec:x + ", " + tvec:z at (0, 23).
    if (t < 0.125 and t > 0.1) or (t < 0.725 and t > 0.7) {beeper:play(bip).}
    wait 0. // yield

    for engine in engines {
        set thrustvector to (engine:facing:forevector).
        set thrustalignment to -vdot(thrustvector, tvec).
        set engine:thrustlimit to thrustalignment * 100.
    }

    print "THROTTLE: " + tval at (0, 24).
    set mainengine:thrustlimit to tval * 100.

    //set ship:control:translation to (tvec * -up) / C_RCS_POWER.
}

unlock throttle.
set throttle to 0.

for engine in engines {
    set engine:thrustlimit to 0.
}

set ship:control:translation to v(0, 0, 0).

set ship:control:neutralize to true.

sas on.
rcs on.

beeper:play(beeep).
wait 1.
beeper:play(beeep2).
wait 1.
beeper:play(beeep).

