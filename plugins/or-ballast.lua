function addFixedBallastsForCars(championship, entryList)
-- Assigns a fixed ballast to drivers for the specified car(s) based on a championship's HTML-formatted `Info` field.
-- NB this will overwrite any pre-existing ballast which might have been applied in the entrylist.
--
-- For example, the function will search for an HTML comment in the `Info` field with the following structure:
--
--     <!-- Fixed ballast:ks_ford_escort_mk1|70,alfa_romeo_gtam|0 -->
--
-- Important syntax tips: 
-- Use the string "Fixed ballast:" including the colon and no extra space before the set
-- Specify ballast values as whole numbers only
-- Remember only the first comment starting with "<!-- Fixed ballast:" will be parsed
--

    -- search championship info for the Fixed setups HTML comment
    local commentStart, commentEnd = championship["Info"]:find("%<%!%--%sFixed%sballast:[^>]+-->")
    if commentStart == nil then
        -- Fixed setups comment not found, return the original entry list
        print("LUA: No comment found in the championship info defining any fixed ballast to be applied.")
        return entryList
    end

    -- extract the comment text and parse the fixed setups
    local comment = championship["Info"]:sub(commentStart, commentEnd)
    print("LUA: Championship ballast info found: "..comment)
    local ballasts = {}
    for car, ballast in comment:gmatch("([%w_%-%(%)%s]+)|([0-9]+)") do
        table.insert(ballasts, {car=car, ballast=tonumber(ballast)})
    end

    for i, ballast in ipairs(ballasts) do
        print("LUA: Fixed ballast requested #"..i..": car="..ballast.car..", ballast="..ballast.ballast)
    end

    -- loop over cars in the entry list and assign fixed setups
    for carID, entrant in pairs(entryList) do
      for _, ballast in ipairs(ballasts) do
        if entrant["Model"] == ballast.car then
            entrant["Ballast"] = ballast.ballast
        end
      end
    end

    -- return the updated entry list
    return entryList
end
