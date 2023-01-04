//Load libs
run once "0:/lib/configurator".
run once "0:/lib/automission".
run once "0:/lib/nodeexecuter".
waitAndGetData().

switch to 0.

set sasmode to "retrograde".
sas on.

run "0:/deorbiter"(mission_config:discard_second_stage).

sendMessage("onLanded").
