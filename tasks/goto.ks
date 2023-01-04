run once "0:/actions/transfer".
run once "0:/actions/autostage".
run once "0:/actions/node".

function transferTo{
    parameter target.

    print "[TRANSFER TASK] Starting.".

    if ship:periapsis < 0 {
        print "[TRANEFR TASK] Not in orbit! Get into orbit first.".
        return.
    }

    if allnodes:length = 0 {
        print "[TRANSFER TASK] Planning transfer.".
        plan_transfer(target).

        if allnodes:length < 2 {
            print "[TRANSFER TASK] Planning failed! No nodes were found after planning.".
            return.
        }
    }

    local end_orbit is orbitat(ship, allnodes[allnodes:length - 1]:time + 5).

    if not (end_orbit:body = target) {
        print "[TRANSFER TASK] Planning failed! Resulting orbit is not around the target body.".
        print "[TRANSFER TASK] Resulting orbit is around " + end_orbit:body:name.
    }

    if defined craft_config and craft_config:haskey("transfer_stage") and stage:number > craft_config:transfer_stage {
        print "[TRANSFER TASK] Staging to transfer stage: " + craft_config:transfer_stage + ".".
        until stage:number <= craft_config:transfer_stage {
            print "[TRANSFER TASK] Staging.".
            stage.
            wait 1.
        }
    }

    start_autostage().

    until not hasNode {
        execute_node().
        wait 1.
    }

    stop_autostage().
}