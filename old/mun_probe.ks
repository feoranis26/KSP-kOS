clearscreen.
run once "0:/lib/configurator".

print "------------------------".
print "-  Mun probe   v0.125  -".
print "------------------------".

//Mission data
set mission_config to lexicon(
    //Mission metadata
    "mission_type", "visit", "isManned", true, "p2p", false,


    //##### Mission config #####

    //Commands
    "mission_commands", list(
        "start", "launch/ascent", "ascent",
        "cmd_ascent", "transfer/transfercalc", "transfercalc",
        "cmd_transfercalc", "transfer/transfernode1", "transfernode1", 
        "cmd_transfernode1", "transfer/normalize_orbit", "normalizeorbit", 
        "cmd_normalizeorbit", "descent/descent_wait", "descentwait", 
        "cmd_descentwait", "descent/hoverslam", "hoverslam"
    ),

    //Ascent
    "ascent_orbit_target", 80000, "ascent_orbit_incl", 90, "ascent_steepness", 2, "discard_first_stage", true,  //We won't need the first stage for the transfer.
    
    //Transfer
    "target_body", body("mun"), "target_orbit_target", 50000, 

    //Landing
    "discard_second_stage", true, "drop_longitude", 178,

    //#####     EVENTS     #####

    //Extend solar panels when in orbit
    "onOrbit", { 
        print "Reached orbit".

        
        set AG1 to false. //For some reason it doesn't work without doing it this stupid way using 2 AGs.
        set AG1 to true.
        wait 5.
        set AG2 to false.
        set AG2 to true.
    }
).

//Start configurator
configurator(mission_config).