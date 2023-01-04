//LaunchMatic v0.5.9

//Load libs
run once "0:/lib/stage".
run once "0:/rsvp/main".
run once "0:/lib/configurator".
run once "0:/lib/automission".
waitAndGetData().

switch to 0.
local options is lexicon("create_maneuver_nodes", "first", "verbose", true).
rsvp:goto(mission_config:target_body, options).

nextCommand("cmd_transfercalc").
reboot.
