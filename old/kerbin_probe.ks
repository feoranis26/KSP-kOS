clearscreen.
run once "0:/lib/configurator".

print "------------------------".
print "- Kerbin probe  v0.821 -".
print "------------------------".

//Mission data
set mission_config to lexicon(
    //Mission metadata
    "mission_type", "probe", "isManned", false,


    //##### Mission config #####

    "mission_commands", list(
        "start", "launch/ascent", "ascent"
    ),

    
    "target_body", body("kerbin"),

    //Ascent
    "ascent", true, "ascent_orbit_target", 80000, "ascent_orbit_incl", 90, "ascent_steepness", 3, "discard_first_stage", true,


    //#####     EVENTS     #####

    //Extend solar panels when in orbit
    "onOrbit", { 
        print "Reached orbit".

        
        set AG1 to false. //For some reason it doesn't work without doing it this stupid way.
        set AG1 to true.

        stage.
    },
    
    //Close bay doors in reentry
    "onReentry", {
        set AG1 to false.
    }
).

//Start configurator
configurator(mission_config).