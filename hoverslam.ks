parameter hoverslam_height is 85, safety_margin is 0.7, touchdown_spd is 2.
set hoverslam_height to hoverslam_height + 10.
clearscreen.

switch to 0.
run once "0:/lib/stage".
run once "0:/lib/impactpos".

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
print "-------------------------------------------" at (0, 9).
print "--     WAITING UNTIL REENTRY IS DONE     --" at (0, 10).

set throttle to 0.
sas off.
lock steering to lookdirup(-velocity:surface, v(0, -1, 0)).

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
lock engineLiftPower to (ship:maxthrust / ship:mass - grav) * max(0.25, engineLiftRatio).
lock engineSafetyMargin to engineLiftPower * 0.9. //Safety margin because the calculation isn't 100% accurate.
lock timeToStop to abs((ship:verticalspeed) / engineSafetyMargin).
lock distToStop to abs((ship:verticalspeed) * timeToStop / 2).

until (distToStop - alt:radar) > -hoverslam_height {
    print "--------- !HOVERSLAM IN PROGRES!  --------" at (0, 13).
    print "--------- !    BURN IMMINENT   !  --------" at (0, 14).
    print "--------- ! EST DURATION IS :" + floor(timeToStop) + "! --------" at (0, 15).
    print "--------- !      ETA :      " + abs(floor((alt:radar - distToStop) / ship:verticalspeed)) + "! --------" at (0, 16).

    if mod(time:seconds, 0.2) = 0 {beeper:play(beep).}
    wait 0.
}



clearscreen.

set slamDone to false.

when distToStop - alt:radar > -hoverslam_height and ship:verticalspeed < -touchdown_spd then{
    if not slamDone {
        set throttle to 1.
    }
    return not slamDone.
}
when distToStop - alt:radar < -(hoverslam_height - 10) and ship:verticalspeed < -touchdown_spd then {
    if not slamDone {
        set throttle to 0.
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
    if mod(time:seconds, 0.25) < 0.125 {beeper:play(beep2).}
    if mod(time:seconds, 0.25) > 0.125 {beeper:play(beep3).}
    wait 0.
}
wait until ship:verticalspeed > -touchdown_spd.
set slamDone to true.

lock throttle to 0.
sas off.
//lock velcancel to ship:velocity:surface - up:forevector * vdot(v1, up:forevector).
//lock vel to VXCL(up:forevector, ship:velocity:surface).

lock sinYaw to sin(ship:up:yaw).
lock cosYaw to cos(ship:up:yaw).
lock sinPitch to sin(ship:up:pitch).
lock cosPitch to cos(ship:up:pitch).

lock unitVectorEast to V(-cosYaw, 0, sinYaw).
lock unitVectorNorth to V(-sinYaw*sinPitch, cosPitch, -cosYaw*sinPitch).
lock shipVelocitySurface to ship:velocity:surface.
lock speedEast to vdot(shipVelocitySurface, unitVectorEast).
lock speedNorth to vdot(shipVelocitySurface, unitVectorNorth).

lock zcorrection to -speedNorth + SHIP:CONTROL:PILOTPITCH * 10.
lock xcorrection to -speedEast + SHIP:CONTROL:PILOTYAW * 10.
lock vec to v(xcorrection, 0, zcorrection).

lock lookDir to lookdirup(vec, v(0, 1, 0)).
lock yawc to lookdir:yaw.
lock rollc to lookdir:roll.
lock corrMag to min(vec:mag*2, 25).

lock steering to lookdirup(heading(yawc, 90 - corrMag, rollc):forevector, v(0, 0, 1)).

lock t to mod(time:seconds, 1).

set throttle_pid to pidloop(0.0625, 0.01, 0.001).
set throttle_pid:setpoint to -touchdown_spd.

set throttle to ((ship:mass * grav) / ship:maxthrust).
until ship:verticalspeed > -0.1 and alt:radar < hoverslam_height - 10 { 
    set throttle to throttle + throttle_pid:update(time:seconds, ship:verticalspeed).
    print "VERTICAL DESCENT!" at (0, 21).
    print "VELOCITY IS: " + speedEast + ", " + speedNorth at (0, 22).
    print "CORRECTN IS: " + xcorrection + ", " + zcorrection at (0, 23).
    if (t < 0.125 and t > 0.1) or (t < 0.725 and t > 0.7) {beeper:play(bip).}
    wait 0. // yield
}


lock throttle to 0.
beeper:play(beeep).
wait 1.
beeper:play(beeep2).
wait 1.
beeper:play(beeep).
wait 11.

sas on.