function configurator {
    parameter mission_data.
    until false {
        if not core:messages:empty {
            set msg to core:messages:pop.
            print msg:content:content.
            if msg:content:content = "get_cfg" {
                ship:partsDubbed(msg:content:sendername)[0]:getModule("kOSProcessor"):connection:sendMessage(mission_data).
            }
            else if msg:content:content = "do_mission" {
                print "Start Mission!".
                set doMission to true.
            } else if mission_data:haskey(msg:content:content) {
                mission_data[msg:content:content]().
            }
        }
    }
}

function getConfiguration {
    set pList to ship:partsDubbed("mission").
    if pList:length > 0 { 
        print "Getting data from configurator cpu...".
        set msg to lexicon("sendername", "ctl", "content", "get_cfg").
        pList[0]:getModule("kOSProcessor"):connection:sendMessage(msg).
        print "Message sent, waiting for data...".
        wait until not core:messages:empty.
        set mission_config to core:messages:pop:content.
        print "Got mission data.".
    }
    else {
        mission_config:add("ascent_orbit_target", 80000).
        mission_config:add("ascent_orbit_incl", 90).
        mission_config:add("ascent_steepness", 1).
        mission_config:add("discard_first_stage", true).
    }
}

function sendMessage {
    parameter event_name.
    ship:partsDubbed("mission")[0]:getModule("kOSProcessor"):connection:sendMessage(lexicon("sendername", "ctl", "content", event_name)).
}