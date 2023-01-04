run "0:/rsvp/main".

function plan_transfer{
    parameter transfer_target.

    print "[TRANSFER PLANNER] Starting search...".
    local options is lexicon(
        "create_maneuver_nodes", "both",
        "verbose", true,
        "search_duration", timestamp(1, 2, 0, 0, 0):seconds
    ).
    rsvp:goto(transfer_target, options).
    print "[TRANSFER PLANNER] Planned transfer.".
}