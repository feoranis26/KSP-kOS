run once "0:/actions/orbit".
run once "0:/actions/autostage".

function orbit {
    parameter orbit_height, inclination.
    local turn_start_speed is 100.
    local ascent_steepness is 1.
    local aero_multiplier is 1.

    print "[ORBIT TASK] Orbit task starting! Target height is: " + orbit_height + ", inclination is" + inclination.

    if defined craft_config and craft_config:haskey("turn_start_speed") {
        set turn_start_speed to craft_config:turn_start_speed.
        print "[ORBIT TASK] Craft-specific turn start speed is " + turn_start_speed + "m/s.".
    }

    if defined craft_config and craft_config:haskey("ascent_steepness") {
        set ascent_steepness to craft_config:ascent_steepness.
        print "[ORBIT TASK] Craft-specific ascent steepness is " + ascent_steepness + ".".
    }

    if defined craft_config and craft_config:haskey("aero_multiplier") {
        set aero_multiplier to craft_config:aero_multiplier.
        print "[ORBIT TASK] Craft-specific aerodynamic heating factor is " + aero_multiplier + ".".
    }

    start_autostage().

    if ship:apoapsis < orbit_height - 1000 { 
        launch_to_orbit(orbit_height, inclination, turn_start_speed, ascent_steepness, aero_multiplier).
    }

    if defined craft_config and craft_config:haskey("circularization_stage") and stage:number > craft_config:circularization_stage {
        print "[ORBIT TASK] Staging to circularization stage: " + craft_config:circularization_stage + ".".
        until stage:number <= craft_config:circularization_stage {
            print "[ORBIT TASK] Staging.".
            stage.
            wait 1.
        }
    }

    if ship:periapsis < orbit_height - 1000 and apoapsis > orbit_height - 1000 and eta:apoapsis < ship:orbit:period / 2 { 
        plan_circularization(orbit_height).
        execute_node().
    }
    
    print "[ORBIT TASK] Finished.".
    stop_autostage().
    set ship:control:neutralize to true.
    wait 0.
}