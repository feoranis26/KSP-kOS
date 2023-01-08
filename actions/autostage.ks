run once "0:/actions/autopilots".

set exit_autostage to false.
set autostage_active to false.

function start_autostage {
    print "[AUTOSTAGE] Started.".
    if not autostage_active {
        set autostage_active to true.

        local dv_limit is 10.
        local last_staged_time is 0.
        local delay is 3.

        if defined craft_config and craft_config:haskey("stage_landing_deltav") and craft_config:stage_landing_deltav:haskey(stage:number) {
            set dv_limit to craft_config:stage_landing_deltav[stage:number].
        }

        if defined craft_config and craft_config:haskey("stage_delay") and craft_config:stage_delay:haskey(stage:number) {
            set delay to craft_config:stage_delay[stage:number].
        }
        print "[AUTOSTAGE] Stage :" + stage:number.
        //print "[AUTOSTAGE] Set delay :" + delay.

        when ((stage:deltav:current < dv_limit) and (time:seconds - last_staged_time) > delay) or exit_autostage then {
            set dv_limit to 10.
            set last_staged_time to 0.
            set delay to 3.

            if defined craft_config and craft_config:haskey("stage_landing_deltav") and craft_config:stage_landing_deltav:haskey(stage:number) {
                set dv_limit to craft_config:stage_landing_deltav[stage:number].
            }

            if defined craft_config and craft_config:haskey("stage_delay") and craft_config:stage_delay:haskey(stage:number) {
                set delay to craft_config:stage_delay[stage:number].
            }

            //print "[AUTOSTAGE] Set delay :" + delay.

            if stop_autostage {
                set autostage_active to false.
                set exit_autostage to false.
                print "[AUTOSTAGE] Stopped.".
            }
            else {
                set time_start_wait to time:seconds.
                wait until time:seconds - time_start_wait > 0.5 or stage:deltav:current > dv_limit.
                
                if stage:deltav:current < dv_limit {
                    print "[AUTOSTAGE] Staging!.".
                    stage.
                    wait 1.
                }

                if defined craft_config and craft_config:haskey("stage_landing_deltav") and craft_config:stage_landing_deltav:haskey(stage:number) {
                    set dv_limit to craft_config:stage_landing_deltav[stage:number].
                }

                set last_staged_time to time:seconds.
                preserve.
            }
        }
    }
    else {
        print "[AUTOSTAGE] Autostage already active!".
    }
}

function stop_autostage {
    set exit_autostage to true.
    wait 0.
    wait 0.
}