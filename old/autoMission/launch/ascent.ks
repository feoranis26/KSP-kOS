//Load libs
run once "0:/lib/configurator".
run once "0:/lib/automission".
print "ASCENT!".
waitAndGetData().

run "0:/orbiter"(mission_config:ascent_orbit_incl, mission_config:ascent_orbit_target, mission_config:ascent_steepness, mission_config:discard_first_stage, 70000).

sendMessage("onOrbit").

nextCommand("cmd_ascent").

if mission_config:discard_first_stage {
    wait(5).
    set LASTMAXTHRUST to 100000000.
}

print "-----USE FMRS NOW-------".
beeper:play(beep).
wait 15.

reboot.
