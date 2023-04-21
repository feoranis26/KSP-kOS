parameter discard_stage is false.
PRINT "--AutoDeorbiter--".

wait 1.

if ship:PERIAPSIS > 0 {
    wait 4.
    SET sasmode to "retrograde".
    SAS ON.
    wait 0.1.
    SET sasmode to "retrograde".
    SAS ON.
    wait(10).
    LOCK THROTTLE TO 1.

    WAIT UNTIL SHIP:PERIAPSIS < 2500.

    LOCK THROTTLE TO 0.1.

    WAIT UNTIL SHIP:PERIAPSIS < 0.
}



lock throttle to 0.

if stage:deltav:asl < 490 {
    set brakes to false.
    set brakes to true.
    set gear to false.
    set gear to true.
} else {
    copypath("0:/atmo_hoverslam.ks", "atmo_hoverslam.ks").
    run "atmo_hoverslam"(50, 0.5, 2, discard_stage).
}