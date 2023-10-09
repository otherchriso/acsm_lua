function addFixedRestrictorsForCars(championship, entryList)
-- Assigns a fixed restrictor to drivers for the specified car(s) based on a championship's HTML-formatted `Info` field.
-- NB this will overwrite any pre-existing restrictor which might have been applied in the entrylist.
--
-- For example, the function will search for an HTML comment in the `Info` field with the following structure:
--
--     <!-- Fixed restrictor:ks_ford_escort_mk1|70,alfa_romeo_gtam|0 -->
--
-- Important syntax tips:
-- Use the string "Fixed restrictor:" including the colon and no extra space before the set
-- Specify restrictor values as whole numbers only
-- Remember only the first comment starting with "<!-- Fixed restrictor:" will be parsed
--

    -- search championship info for the Fixed setups HTML comment
    local commentStart, commentEnd = championship["Info"]:find("%<%!%--%sFixed%srestrictor:[^>]+-->")
    if commentStart == nil then
        -- Fixed setups comment not found, return the original entry list
        print("LUA: No comment found in the championship info defining any fixed restrictor to be applied.")
        return entryList
    end

    -- extract the comment text and parse the fixed setups
    local comment = championship["Info"]:sub(commentStart, commentEnd)
    print("LUA: Championship restrictor info found: "..comment)
    local restrictors = {}
    for car, restrictor in comment:gmatch("([%w_%-%(%)%s]+)|([0-9]+)") do
        table.insert(restrictors, {car=car, restrictor=tonumber(restrictor)})
    end

    for i, restrictor in ipairs(restrictors) do
        print("LUA: Fixed restrictor requested #"..i..": car="..restrictor.car..", restrictor="..restrictor.restrictor)
    end

    -- loop over cars in the entry list and assign fixed setups
    for carID, entrant in pairs(entryList) do
      for _, restrictor in ipairs(restrictors) do
        if entrant["Model"] == restrictor.car then
            entrant["Restrictor"] = restrictor.restrictor
        end
      end
    end

    -- return the updated entry list
    return entryList
end
