clearscreen.
run once "0:/lib/configurator".

print "------------------------".
print "- Mun orbiter   v0.125 -".
print "------------------------".

//Mission data
set mission_config to lexicon(
    //Mission metadata
    "mission_type", "visit", "isManned", true, "p2p", false,


    //##### Mission config #####

    //Ascent
    "ascent", true, "ascent_orbit_target", 80000, "ascent_orbit_incl", 90, "ascent_steepness", 2, "discard_first_stage", true,  //We won't need the first stage for the transfer.
    
    //Transfer
    "transfer", true, "target_body", body("mun"), 
    
    "target_landing_method", "none", "discard_second_stage", false,

    "return", false,

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