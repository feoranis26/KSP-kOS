//Terrible launch script ver 0.5.12

run once "0:/lib/nodeExecuter".

set beeper to getvoice(0).
set beep to note(400, 0.5).
set beep2 to note(800, 0.5).
set beep3 to note(400, 0.5).
set beep4 to note(400, 0.125).
set beeper:release to 0.


parameter angle, ORBIT_TARGET, ASCENT_STEEPNESS, DISCARD_ASCENT_STAGE, ATMOSTHERE_HEIGHT.
SET LASTMAXTHRUST TO 1. //If the thrust value is lower than the thrust value when the rocket last staged an engine must have ran out of fuel.
WHEN MAXTHRUST < LASTMAXTHRUST * 0.9 THEN { //Small thrust variations caused by different thrust values at sea level and vacuum cause random staging, multiplying LASTMAXTHRUST by 0.9 fixes this.
    lock THROTTLE_VAL to 0.
    wait 1.
    print "STAGING!!".
    lock THROTTLE_VAL to 0.
    stage_func().
    wait 0.25.
    SET LASTMAXTHRUST TO MAXTHRUST. 
    unlock throttle_val.
    set THROTTLE_VAL to 1.
    PRESERVE.
    print LASTMAXTHRUST.
}.
when stage:deltav:vacuum < 500 and stage:deltav:vacuum > 490 then { // Save enough fuel for stages that land using a hoverslam burn. 
    //Don't calculate it continuously if the Δv is less than 500 to save processing power.

    set pList to ship:partsDubbed("stage_" + stage:number).
    if pList:length > 0 { // If there is a kOS processor for the stage it is recoverable so save some Δv for recovery.
        print "Staging recoverable rocket...".
        set LASTMAXTHRUST to 100000. //Can't call stage_func() directly, otherwise the WHEN loop above would also stage.
    }
    preserve.
}
when stage:deltav:vacuum < 1 then { // Sometimes the first WHEN loop doesn't work, this is a backup in case it breaks.
    set LASTMAXTHRUST to 100000. //Can't call stage_func() directly, otherwise the WHEN loop above would also stage.
    preserve.
}

PRINT "PHASE: ASCENT" at (0, 5).

set ASCENT_STEEPNESS to ASCENT_STEEPNESS * (ORBIT_TARGET / 100000). //If the orbit target is higher, the gravity burn will also last longer.

SET STEERING_VAL TO HEADING(angle,90).
LOCK STEERING TO STEERING_VAL.
SET THROTTLE_VAL TO 1.0.
LOCK THROTTLE TO THROTTLE_VAL.
RCS ON.

WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG > 100.

WHEN ALTITUDE > 1000 THEN {
    SET GEAR TO FALSE.
}.

UNTIL SHIP:ALTITUDE > ATMOSTHERE_HEIGHT - 20000 {
    //Throttle
    IF SHIP:APOAPSIS < ORBIT_TARGET {
        SET THROTTLE_VAL TO 1.
        IF SHIP:APOAPSIS > ORBIT_TARGET - 5000 {
            SET THROTTLE_VAL TO 0.25.
        }.
    } ELSE {
        SET THROTTLE_VAL TO 0.0.
    }

    // "Gravity" turn.
    SET ASCENT_TGT_DEG TO 90 - (SHIP:VELOCITY:SURFACE:MAG - 100) / (ASCENT_STEEPNESS * 10).
    SET STEERING_VAL TO CHOOSE HEADING(angle, ASCENT_TGT_DEG) IF ASCENT_TGT_DEG > 0 ELSE HEADING(angle, 0).
    if throttle > 0.5 and mod(time:SECONDS, 0.5) < 0.1  {
        beeper:play(beep4).
    }

    PRINT "APOAPSIS: " + ship:APOAPSIS at (0, 6).
    PRINT "TARGET APOAPSIS: " + ORBIT_TARGET at (0, 7).
}.

clearscreen.
PRINT "PHASE: CIRCULARIZATION" at (0, 5).

LOCK THROTTLE TO 0.0.

LOCK CIRCULARIZATION_DV TO sqrt(SHIP:BODY:MU /(BODY:RADIUS + 1 * ORBIT_TARGET)) - VELOCITYAT(SHIP, ETA:APOAPSIS + TIME:SECONDS):ORBIT:MAG.
SET CIRCULARIZATION_NODE TO Node(TimeSpan(ETA:APOAPSIS), 0, 0, CIRCULARIZATION_DV).
ADD CIRCULARIZATION_NODE.

executeNextNode(false, false).

LOCK THROTTLE TO 0.