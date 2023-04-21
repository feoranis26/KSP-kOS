set pList to ship:partsDubbed("stage_" + stage:number).
if pList:length > 0 {
    for stage_comp in pList {
        stage_comp:getModule("kOSProcessor"):connection:sendMessage("deorbit").
    }
}
PRINT "Staging".    
STAGE.