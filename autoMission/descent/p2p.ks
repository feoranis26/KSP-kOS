//For automated reentry to kerbin

//Load libs
run once "0:/lib/configurator".
run once "0:/lib/automission".
run once "0:/lib/nodeexecuter".
waitAndGetData().

copypath("0:/deorbiter.ks", "deorbiter.ks").
copypath("0:/hoverslam.ks", "hoverslam.ks").

nextCmd("cmd_p2p").
reboot.
