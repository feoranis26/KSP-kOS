//LaunchMatic v0.5.9

//Load libs
run once "0:/lib/stage".
run once "0:/rsvp/main".
run once "0:/lib/configurator".
run once "0:/lib/automission".
run once "0:/lib/nodeExecuter".
waitAndGetData().

wait until body = mission_config:target_body. //We don't want to circularize around kerbin.

until not hasnode {
    print "Removed node".
    remove nextnode.
}

lock CIRCULARIZATION_DV TO sqrt(ship:body:mu * (2 / (BODY:RADIUS + periapsis) - 1 / ((mission_config:target_orbit_target + periapsis) / 2 + ship:body:radius))) - VELOCITYAT(SHIP, ETA:periapsis + TIME:SECONDS):ORBIT:MAG.
set CIRCULARIZATION_NODE TO Node(TimeSpan(ETA:periapsis), 0, 0, CIRCULARIZATION_DV).
add CIRCULARIZATION_NODE.

print "Executing periapsis node".
executeNextNode(true, true).

lock CIRCULARIZATION_DV TO sqrt(ship:body:mu * (2 / (BODY:RADIUS + apoapsis) - 1 / ((mission_config:target_orbit_target + apoapsis) / 2 + ship:body:radius))) - VELOCITYAT(SHIP, ETA:apoapsis + TIME:SECONDS):ORBIT:MAG.
set CIRCULARIZATION_NODE2 TO Node(TimeSpan(ETA:apoapsis), 0, 0, CIRCULARIZATION_DV).
add CIRCULARIZATION_NODE2.

print "Executing apoapsis node".

executeNextNode(true, true).

nextCommand("cmd_normalizeorbit").
reboot.