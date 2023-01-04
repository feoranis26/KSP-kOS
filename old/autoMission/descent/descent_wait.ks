//Load libs
run once "0:/lib/configurator".
run once "0:/lib/automission".
run once "0:/lib/nodeexecuter".
waitAndGetData().

switch to 0.
wait until body = mission_config:target_body.

set sasmode to "retrograde".
sas on.

until mission_config:drop_longitude = -1 or abs(ship:geoposition:lng - mission_config:drop_longitude) < 0.1 {
    print "Reaching drop location in " + abs(ship:geoposition:lng - mission_config:drop_longitude) + " degrees".
}.
print "Reached drop location".

nextCommand("cmd_descentwait").
reboot.