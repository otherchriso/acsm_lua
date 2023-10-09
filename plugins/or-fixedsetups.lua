function addFixedSetupsForCars(championship, entryList)
-- Assigns a fixed setup to drivers for the specified car(s) based on a championship's HTML-formatted `Info` field.
--
-- For example, the function will search for an HTML comment in the `Info` field with the following structure:
--
--     <!-- Fixed setups:ktm_xbow_r|default.ini,lotus_2_eleven|default.ini -->
--
-- Important syntax tips: 
-- Use the string "Fixed setups:" including the colon and no extra space before the set
-- Use setup filenames ending in ".ini"
-- Store setups in the "generic" track, which happens by default when uploading through ACSM
-- Remember only the first comment starting with "<!-- Fixed setups:" will be parsed
--

    -- search championship info for the Fixed setups HTML comment
    local commentStart, commentEnd = championship["Info"]:find("%<%!%--%sFixed%ssetups:[^>]+-->")
    if commentStart == nil then
        -- Fixed setups comment not found, return the original entry list
        print("LUA: No comment found in the championship info defining any fixed setups to be applied.")
        return entryList
    end

    -- extract the comment text and parse the fixed setups
    local comment = championship["Info"]:sub(commentStart, commentEnd)
    print("LUA: Championship setup info found: "..comment)
    local setups = {}
    for car, setup in comment:gmatch("([%w_%-%(%)%s]+)|([%w_%-%(%)%s]+%.ini)") do
        table.insert(setups, {car=car, setup=setup})
    end

    for i, setup in ipairs(setups) do
        print("LUA: Fixed setup requested #"..i..": car="..setup.car..", setup="..setup.setup)
    end

    -- loop over cars in the entry list and assign fixed setups
    for carID, entrant in pairs(entryList) do
      for _, setup in ipairs(setups) do
        if entrant["Model"] == setup.car then
            local fixedSetupPath = "assetto/setups/"..setup.car.."/generic/"..setup.setup
            local f = io.open(fixedSetupPath, "r")
            if f then
                f:close()
                entrant["FixedSetup"] = setup.car.."/generic/"..setup.setup
            else
                error("LUA: Could not find requested setup file for car "..setup.car.." and setup "..setup.setup..". No fixed setups for any cars will be applied.\n")
            end
        end
      end
    end

    -- return the updated entry list
    return entryList
end
