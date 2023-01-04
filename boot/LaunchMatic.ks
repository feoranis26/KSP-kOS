//LaunchMatic v0.5.9

//Load libs
run once "0:/lib/configurator".
run once "0:/lib/automission".

set beeper to getvoice(0).
set beep to note(400, 0.5).
set beep2 to note(800, 0.5).
set beeper:release to 0.

set mission_config to lexicon().

function countdown {
    from {local x is 0.} until x = 10 step {set x to x + 1.} do {
        set text to choose "----- LAUNCHING --------" if mod(x, 2) = 0 else "-------- LAUNCHING -----".
        print text at (0, 3).
        print "-----------" + (10 - x) + "-----------" at (0, 4).
        beeper:play(beep).
        wait 1.
    }.
    beeper:play(beep2).
}

WAIT UNTIL SHIP:UNPACKED.
wait 1.

clearscreen.
print "------------------------".
print "-  LaunchMatic v1.5.10  -".
print "------------------------".

getConfiguration().
countdown().
nextCommand("start").
reboot.