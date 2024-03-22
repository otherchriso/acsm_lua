function addSuccessBOPForCars(championship, entryList, standings)

    -- Assigns a BOP adjustment to cars triggered by hidden info in a championship's HTML-formatted `Info` field.
    -- N.B. This will overwrite any pre-existing BOP adjustment which might have been applied in the entrylist.
    --
    -- For example, the function will search for an HTML comment in the `Info` field with the following structure:
    --
    --     <!-- Success BOP:ballast|70|champposition -->
    --
    --     or...
    --
    --     <!-- Success BOP:restrictor|30|previousrace -->
    --
    -- Important tips: 
    -- Use the string "Success BOP:" including the colon and no extra space before the parameters
    -- * Specify either "ballast" or "restrictor" in the first parameter
    -- * Specify the maximum BOP adjustment value (as a whole number only) in the second parameter
    -- * Specify the third parameter to determine which type of success determines the adjustment:
        -- "champposition" to use the position of this driver in the championship at the moment
        -- "previousrace" to use their finishing order in the previous round's first or only race
        -- "previousrace2" to use the second race of the previous round, e.g. a reverse grid. USE WITH CAUTION
    -- Remember only the first comment starting with "<!-- Fixed ballast:" will be parsed

        -- search championship info for the Fixed setups HTML comment
        local commentStart, commentEnd = championship["Info"]:find("%<%!%--%sSuccess%sBOP:[^>]+-->")
        if commentStart == nil then
            -- Success BOP comment not found, return the original entry list
            print("LUA: No comment found in the championship info defining any success BOP measures to be applied.")
            return entryList
        end
    
        -- determine whether the BOP adjustment is for ballast or restrictor, by how much, and what triggers it
        local comment = championship["Info"]:sub(commentStart, commentEnd)
        local bopType, bopValue, bopTrigger = comment:match("Success%sBOP:([^|]+)|([0-9]+)|([^|%s%-]+)")
        print("LUA: Championship Success BOP info found: "..comment)
        print("LUA: Success BOP type: "..bopType..", value: "..bopValue..", trigger: "..bopTrigger)

        -- alter the BOP
        if bopType ~= "ballast" and bopType ~= "restrictor" then
            print("LUA: Error: Success BOP type must be either 'ballast' or 'restrictor'.")
            return entryList
        end
        -- if the BOP adjustment is triggered by championship position
        if bopTrigger == "champposition" then
            -- add ballast to drivers for the championship event based on their current championship position
            print("LUA:  Calling addBOPFromChampionshipPosition")
            entryList = addBOPFromChampionshipPosition(entryList, standings, bopValue, bopType)
        -- if the BOP adjustment is triggered by the results of a previous event
        elseif bopTrigger == "previousrace" then
            print("LUA:  Setting "..bopType.." based on the results of a previous first event.")
            -- add BOP to drivers for the championship event based on the results of some event
            entryList = addBOPFromChampionshipEventPosition(championship, entryList, bopValue, bopType, 1, false)
        elseif bopTrigger == "previousrace2" then
            print("LUA:  Setting "..bopType.." based on the results of a previous second event.")
            -- add BOP to drivers for the championship event based on the results of some event
            entryList = addBOPFromChampionshipEventPosition(championship, entryList, bopValue, bopType, 1, true)
        end
    return entryList
end


-- add ballast or restrictor to drivers for the championship event based on their current championship position
function addBOPFromChampionshipPosition(entryList, standings, bopValue, bopType)
    -- loop over each championship class
    for className,classStandings in pairs(standings) do
        -- loop over the standings for the class
        for pos,standing in pairs(classStandings) do
            -- loop over cars in the entry list
            for carID, entrant in pairs(entryList) do
                -- if standing and entrant guids match
                if entrant["GUID"] == standing["Car"]["Driver"]["Guid"] then
                    -- add BOP of correct type based on championship position
                    entrant[bopType] = math.floor(bopValue/(pos))
                    print("LUA: Applying "..bopType.." "..math.floor(bopValue/(pos)).." to car of "..entrant["Name"].." based on championship position: "..pos)
                end
            end
        end
    end

    return entryList
end


-- add ballast or restrictor to drivers for the championship event based on the results of some event
function addBOPFromChampionshipEventPosition(championship, entryList, bopValue, bopType, nthMostRecentEvent, reverseRace)
    table.sort(championship["Events"], function (left, right)
        return left["CompletedTime"] > right["CompletedTime"]
    end )

    -- event to apply ballast or restrictor from is now nth in championship["Events"]
    for sessionType,session in pairs(championship["Events"][nthMostRecentEvent]["Sessions"]) do
        if (not (session["CompletedTime"] == "0001-01-01T00:00:00Z")) and (sessionType == "RACE" and (not reverseRace)) or (sessionType == "RACEx2" and reverseRace) then
            -- start at bopValue, decrease for each driver by diff
            local diff = 5
            local value = bopValue

            for pos,result in pairs(session["Results"]["Result"]) do
                -- find our entrant and apply BOP
                for carID, entrant in pairs(entryList) do
                    -- if standing and entrant guids match
                    if entrant["GUID"] == result["DriverGuid"] then
                        -- add BOP based on result in nth most recent 
                        entrant[bopType] = value
                        print("LUA: applying "..bopType.." of "..value.." to the car for "..result["DriverName"]..", who finished in pos "..pos.." at "..session["Results"]["TrackName"])
                        break
                    end
                end

                value = value - diff
                if value < 0 then
                    value = 0
                end

                -- if you want non-linear BOP, modify the diff here
                if pos == 4 then
                    diff = 3
                end
            end
        end
    end

    return entryList
end
