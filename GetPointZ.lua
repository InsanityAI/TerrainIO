if Debug then Debug.beginFile "TerrainIO/GetPointZ" end
OnInit.global("GetPointZ", function(require)
    -- Honestly this should have been a part of WC3 API, every system is either forced to be dependant on something that does this
    -- or create it's own variation, wish there was a standardized helper lib for lil snippets like these.
    local point = Location(0, 0)
    ---@param x number
    ---@param y number
    ---@return number z
    GetPointZ = function(x, y)
        MoveLocation(point, x, y)
        return GetLocationZ(point)
    end
end)
if Debug then Debug.endFile() end
