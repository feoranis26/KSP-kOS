//For automated reentry to kerbin

//Load libs
run once "0:/lib/configurator".
run once "0:/lib/automission".
run once "0:/lib/nodeexecuter".
waitAndGetData().

kuniverse:timewarp:warpto(time:seconds + 230).
wait 10.

sendMessage("onReentry").

nextCommand("cmd_p2pwait").
reboot.
