parameter hoverslam_height, safety_margin, touchdown_spd, discard_stage is false.

clearscreen.

switch to 0.
run once "0:/lib/stage".

set beeper to getvoice(0).
set beep to note(400, 0.1).
set beep2 to note(800, 0.25).
set beep3 to note(400, 0.25).
set beeep to note(400, 0.5).
set beeep2 to note(800, 0.5).
set beeep3 to note(1200, 0.5).
set beeper:release to 0.

print "-------------------------------------------".
print "-- WORST HOVERSLAM SCRIPT EVER ver 0.527 --".
print "--  !GUARANTEED WORKS 1/2 THE TIME(tm)!  --".
print "-------------------------------------------".

set sasmode to "retrograde".
sas on.
wait 1.
set sasmode to "retrograde".
sas on. 

wait until altitude < 17500.

wait until alt:radar < 10000.
print "--             REENTRY DONE              --".
wait 1.
if stage:deltav:vacuum < 500 or discard_stage {  
    stage_func().
}

lock grav to body:mu/(body:radius+ship:altitude)^2.
lock dir to ship:sensors:acc:normalized.
lock engineLiftRatio to cos(vectorangle(ship:facing:vector, ship:up:vector)).
lock engineLiftPower to (ship:maxthrust / ship:mass - grav) * engineLiftRatio.
lock engineSafetyMargin to engineLiftPower * 0.9. //Safety margin because the calculation isn't 100% accurate.
lock timeToStop to abs((ship:verticalspeed) / engineSafetyMargin).
lock distToStop to abs((ship:verticalspeed) * timeToStop / 2).

until distToStop - alt:radar > -hoverslam_height {
    print "-- !HOVERSLAM IN PROGRES! --" at (0, 9).
    print "-- !    BURN IMMINENT   ! --" at (0, 10).
    print "-- ! EST DURATION IS :" + floor(timeToStop) + "! --" at (0, 11).
    print "-- !      ETA :      " + abs(floor((alt:radar - distToStop) / ship:verticalspeed)) + "! --" at (0, 12).
    if mod(time:seconds, 0.2) = 0 {beeper:play(beep).}
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
    print "-- !HOVERSLAM IN PROGRES! --" at (0, 9).
    print "-- !!!!!!DECELERATE!!!!!! --" at (0, 10).
    print "ALTITIDE IS: " + ship:altitude at (0, 11).
    print "BURN DISTANCE IS: " + distToStop at (0, 12).
    if mod(time:seconds, 0.25) = 0 {beeper:play(beep2).}
    if mod(time:seconds, 0.25) = 0.125 {beeper:play(beep3).}
}
wait until ship:verticalspeed > -touchdown_spd.
set slamDone to true.
lock throttle to 0.
sas off.




lock steering to heading(90, 90).// + -ship:sensors:acc:normalized * 0.125.
until ship:verticalspeed > -0.1 { 
    if ship:verticalspeed < -touchdown_spd {
        set throttle to ((ship:mass * grav) / ship:maxthrust) + 0.125.
    }
    else {
        set throttle to 0.
    }
}


lock throttle to 0.
beeper:play(beeep).
wait 1.
beeper:play(beeep2).
wait 1.
beeper:play(beeep).
wait 10.

sas on.