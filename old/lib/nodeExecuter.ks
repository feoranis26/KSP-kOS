run once "0:/lib/dv".
run once "0:/lib/stage".

function executeNextNode {
    parameter warp, precise.
    set beeper to getvoice(0).
    set beep to note(400, 0.5).
    set beep2 to note(800, 0.5).
    set beep3 to note(400, 0.5).
    set beeper:release to 0.
    set node to nextnode.

    rcs off.

    lock steering to nextnode:DELTAV.

    PRINT "ESTIMATED BURN TIME: " + calc_Burn_Mean(nextnode:DELTAV:MAG, 0, 1)[1].

    set burnDuration to nextnode:DELTAV:MAG / (SHIP:MAXTHRUST / SHIP:MASS).

    SET LASTMAXTHRUST TO 1.
    WHEN MAXTHRUST < LASTMAXTHRUST THEN {
        print "STAGING!!".
        stage_func().
        wait 1.
        SET LASTMAXTHRUST TO MAXTHRUST. 
        PRESERVE.
    }.
    if warp {
        kuniverse:timewarp:warpto(time:seconds + (nextnode:eta - calc_Burn_Mean(nextnode:DELTAV:MAG, 0, 1)[0]) - 30).
    }
    wait until nextnode:eta - calc_Burn_Mean(nextnode:DELTAV:MAG, 0, 1)[0] < 60.

    rcs on.
    
    wait nextnode:eta - calc_Burn_Mean(nextnode:DELTAV:MAG, 0, 1)[0] - 2.

    LOCK DV_NEEDED TO nextnode:DELTAV:MAG.
    UNLOCK THROTTLE.

    if precise {
        UNTIL DV_NEEDED < 5 {
            PRINT "BEGIN BURN!" at (0, 7).
            IF SHIP:MAXTHRUST > 0 {
                SET THROTTLE TO min(1, DV_NEEDED * SHIP:MASS / SHIP:MAXTHRUST).
                beeper:play(beep2).
                wait 0.25.
                beeper:play(beep3).
                wait 0.25.
            }
        }

        UNTIL DV_NEEDED < 0.5 {
            lock THROTTLE TO min(1, DV_NEEDED * SHIP:MASS / SHIP:MAXTHRUST).
        }
    }
    else {
        UNTIL DV_NEEDED < 1 {
            PRINT "BEGIN BURN!" at (0, 7).
            IF SHIP:MAXTHRUST > 0 {
                SET THROTTLE TO min(1, DV_NEEDED * SHIP:MASS / SHIP:MAXTHRUST).
                beeper:play(beep2).
                wait 0.25.
                beeper:play(beep3).
                wait 0.25.
            }
        }
    }

    print "END BURN!!".
    unlock steering.
    unlock burnDuration.
    unlock DV_NEEDED.
    remove nextnode.
    LOCK THROTTLE TO 0.
}