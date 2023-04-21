//LaunchMatic v0.5.9

//Load libs
run "0:/lib/stage".
run once "0:/rsvp/main".
run once "0:/lib/configurator".
run once "0:/lib/automission".
waitAndGetData().

switch to 0.
local options is lexicon("create_maneuver_nodes", "both", "verbose", true).
rsvp:goto(mission_config:target_body, options).

copypath("0:/automission/transfer/transfernode1", "transfernode1.ks").
set core:bootfilename to "transfernode1.ks".
reboot.
