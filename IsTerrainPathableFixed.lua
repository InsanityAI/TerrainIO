if Debug then Debug.beginFile "TerrainIO/IsTerrainPathableFixed" end
OnInit.module("TerrainIO/IsTerrainPathableFixed", function()
    --[[ by Insanity_AI
        Offers a fixed variation of IsTerrainPathable native, where most of pathingtypes results come out reversed in context to SetTerrainPathable native.
        PATHING_TYPE_BLIGHTPATHING stays the same, other PATHING_TYPES are reversed back into correct result.
        PATHING_TYPE_ANY is a special kind of screw-up which is now modified to return according to the following:
        If any of the other 7 corrected pathing types is true, return true, otherwise false.
    ]]

    local pathingTypes = {
        PATHING_TYPE_AMPHIBIOUSPATHING,
        PATHING_TYPE_BLIGHTPATHING,
        PATHING_TYPE_BUILDABILITY,
        PATHING_TYPE_FLOATABILITY,
        PATHING_TYPE_FLYABILITY,
        PATHING_TYPE_PEONHARVESTPATHING,
        PATHING_TYPE_WALKABILITY
    }

    ---@param x number
    ---@param y number
    ---@param pathingType pathingtype
    ---@return boolean
    IsTerrainPathableFixed = function(x, y, pathingType)
        if pathingType == PATHING_TYPE_BLIGHTPATHING then
            return IsTerrainPathable(x, y, pathingType)
        elseif pathingType == PATHING_TYPE_ANY then
            if IsTerrainPathable(x, y, pathingType) == false then
                return true
            else
                for _, type in ipairs(pathingTypes) do
                    if IsTerrainPathableFixed(x, y, type) == true then
                        return true
                    end
                end
                return false
            end
        end
        return not IsTerrainPathable(x, y, pathingType)
    end
end)
if Debug then Debug.endFile() end
