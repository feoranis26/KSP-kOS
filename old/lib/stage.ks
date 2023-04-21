set beeper to getvoice(0).
set beep to note(200, 0.5).
set beeper:release to 0.

function stage_func {
    set pList to ship:partsDubbed("stage_" + stage:number).
    if pList:length > 0 {
        for stage_comp in pList {
            stage_comp:getModule("kOSProcessor"):connection:sendMessage("deorbit").
        }
    }
    PRINT "Staging".
    beeper:play(beep).
    STAGE.
}.