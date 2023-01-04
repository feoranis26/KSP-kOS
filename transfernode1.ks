//LaunchMatic v0.5.9

//Load libs
run "0:/lib/stage".
run once "0:/rsvp/main".
run once "0:/lib/configurator".
run once "0:/lib/automission".
waitAndGetData().

executeNextNode(true).
wait 5.

nextCmd("transfer/transfernode1").
reboot.
