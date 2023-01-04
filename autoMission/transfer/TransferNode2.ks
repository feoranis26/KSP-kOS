//LaunchMatic v0.5.9

//Load libs
run once "0:/lib/stage".
run once "0:/lib/nodeExecuter".
run once "0:/lib/configurator".
run once "0:/lib/automission".
waitAndGetData().

executeNextNode(true, true).
wait 5.

sendMessage("onTargetBodyReached").

nextCommand("cmd_transfernode2").
reboot.
