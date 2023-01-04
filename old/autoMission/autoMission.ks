function waitAndGetData {
    set beeper to getvoice(0).
    set beep to note(400, 0.5).
    set beep2 to note(800, 0.5).
    set beeper:release to 0.

    WAIT UNTIL SHIP:UNPACKED.
    wait 1.

    getConfiguration().
}

function nextCommand {
    parameter cmdPath.
    set currentCmd to mission_config:mission_commands:find(cmdPath).
    set nextCmdPath to mission_config:mission_commands[currentCmd + 1].
    set nextCmdName to mission_config:mission_commands[currentCmd + 2].
    copypath("0:/automission/" + nextCmdPath, "ctl:/" + nextCmdName).
    set core:bootfilename to nextCmdName.
}