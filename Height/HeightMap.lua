if Debug then Debug.beginFile "TerrainIO.Height.HeightMap" end
OnInit.module("TerrainIO.Height.HeightMap", function(require)
    require "TerrainIO.Tiles.TileResolution"

    local singleTileResolution = TileResolution.create()

    ---@class HeightMap
    ---@field sizeX integer size in amount of tiles on X axis
    ---@field sizeY integer size in amount of tiles on Y axis
    ---@field iterateTiles fun():fun():integer|nil, integer|nil, number|nil returns xIndex, yIndex, height?

    ---@class InMemoryHeightMap: HeightMap
    ---@field [integer] number[] self[x][y] = height
    InMemoryHeightMap = {}
    InMemoryHeightMap.__index = InMemoryHeightMap

    ---@param x integer
    ---@param y integer
    ---@return number?
    function InMemoryHeightMap:getHeight(x, y)
        local result = self[x] ---@type number[]|number
        if result then result = result[y] end
        return result
    end

    ---@return fun():integer|nil, integer|nil, number|nil
    function InMemoryHeightMap:iterate()
        local x, y = 0, 1
        return function()
            x = x + 1
            if x > self.sizeX then x, y = 1, y + 1 end
            if y > self.sizeY then return nil, nil, nil end
            return x, y, self:getHeight(x, y)
        end
    end

    -- Honestly this should have been a part of WC3 API, every system is either forced to be dependant on something that does this
    -- or create it's own variation, wish there was a standardized helper lib for lil snippets like these.
    if not GetPointZ then
        local point = Location(0, 0)
        ---@param x number
        ---@param y number
        ---@return number z
        GetPointZ = function(x, y)
            MoveLocation(point,x,y)
            return GetLocationZ(point)
        end
    end

    ---@class OnDemandHeightMap: HeightMap
    ---@field startX number
    ---@field startY number
    ---@field endX number
    ---@field endY number
    OnDemandHeightMap = {}
    OnDemandHeightMap.__index = OnDemandHeightMap

    ---@return fun():integer|nil, integer|nil, number|nil - xIndex, yIndex, height? (with offsetZ)
    function OnDemandHeightMap:iterate()
        local x, y, xIndex, yIndex = self.startX, self.startY, 0, 1
        return function()
            xIndex = xIndex + 1
            if xIndex > self.sizeX then x, y, xIndex, yIndex = self.startX, singleTileResolution:nextTileCoordinate(y), 1, yIndex + 1 end
            if yIndex > self.sizeY then return nil, nil, nil end

            local height = GetPointZ(x, y)
            x = singleTileResolution:nextTileCoordinate(x)

            return xIndex, yIndex, height
        end
    end
end)
if Debug then Debug.endFile() end