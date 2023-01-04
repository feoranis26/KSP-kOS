run once "0:/lib/dv".
run once "0:/actions/autostage".
run once "0:/actions/autopilots".

set autopilot_running to false.

function execute_node {
    parameter wait_time is 2, precision is 1, autowarp is true.

    set autopilot_running to true.

    lock steering to nextnode:DELTAV:normalized.

    local burn_mean is calc_Burn_Mean(nextnode:DELTAV:MAG, 0, 1)[0].

    print "[NODE AUTOPILOT] Waiting...".
    wait until nextnode:eta - burn_mean < wait_time.

    wait nextnode:eta - burn_mean.

    print "[NODE AUTOPILOT] Start burn!".

    local LOCK DV_NEEDED TO nextnode:DELTAV:MAG.

    local lock alignment to abs(vdot(ship:facing:forevector, nextnode:deltav:normalized)).

    local lock t_val to min(1, DV_NEEDED * SHIP:MASS / SHIP:MAXTHRUST) * alignment * alignment * alignment * alignment * alignment * alignment * alignment.
    lock throttle to choose t_val if t_val > 0.1 else 0.

    wait UNTIL DV_NEEDED < precision or min(1, DV_NEEDED * SHIP:MASS / SHIP:MAXTHRUST) < 0.11.

    unlock throttle.
    set throttle to 0.

    print "[NODE AUTOPILOT] Execution OK.".

    unlock steering.
    unlock burnDuration.
    unlock DV_NEEDED.
    remove nextnode.
    set throttle to 0.

    set autopilot_running to true.
}