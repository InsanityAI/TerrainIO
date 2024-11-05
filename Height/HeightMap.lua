if Debug then Debug.beginFile "TerrainIO/Height/HeightMap" end
OnInit.module("TerrainIO/Height/HeightMap", function(require)
    require "TerrainIO/Tiles/TileResolution"

    local singleTileResolution = TileResolution.get()

    ---@class HeightMap
    ---@field sizeX integer size in amount of tiles on X axis
    ---@field sizeY integer size in amount of tiles on Y axis
    ---@field iterate fun():fun():integer|nil, integer|nil, number|nil returns xIndex, yIndex, height?

    ---@class InMemoryHeightMap: HeightMap
    ---@field [integer] number[] self[x][y] = height
    InMemoryHeightMap = {}
    InMemoryHeightMap.__index = InMemoryHeightMap

    ---@param heightMap HeightMap
    ---@return InMemoryHeightMap
    function InMemoryHeightMap.create(heightMap)
        local newHeightMap = setmetatable({ sizeX = heightMap.sizeX, sizeY = heightMap.sizeY }, InMemoryHeightMap)

        for xIndex, yIndex, height in heightMap:iterate() do
            if newHeightMap[xIndex] then
                newHeightMap[xIndex][yIndex] = height
            else
                newHeightMap[xIndex] = { [yIndex] = height }
            end
        end

        return newHeightMap
    end

    ---@param x integer
    ---@param y integer
    ---@return number?
    function InMemoryHeightMap:getHeight(x, y)
        if self[x] then
            return self[x][y]
        end
        return nil
    end

    ---@return fun():integer|nil, integer|nil, number|nil
    function InMemoryHeightMap:iterate()
        local x, y = -1, 0
        return function()
            x = x + 1
            if x >= self.sizeX then x, y = 0, y + 1 end
            if y >= self.sizeY then return nil, nil, nil end
            return x, y, self:getHeight(x, y)
        end
    end

    ---@class OnDemandHeightMap: HeightMap
    ---@field startX number
    ---@field startY number
    ---@field endX number
    ---@field endY number
    ---@field relativeHeight number
    OnDemandHeightMap = {}
    OnDemandHeightMap.__index = OnDemandHeightMap

    ---@return fun():integer|nil, integer|nil, number|nil - xIndex, yIndex, height? (with offsetZ)
    function OnDemandHeightMap:iterate()
        local x, y, xIndex, yIndex = self.startX, self.startY, -1, 0
        return function()
            xIndex = xIndex + 1
            if xIndex >= self.sizeX then x, y, xIndex, yIndex = self.startX, singleTileResolution:nextTileCoordinate(y), 0, yIndex + 1 end
            if yIndex >= self.sizeY then return nil, nil, nil end

            local height = GetPointZ(x, y) - self.relativeHeight
            x = singleTileResolution:nextTileCoordinate(x)

            return xIndex, yIndex, height
        end
    end
end)
if Debug then Debug.endFile() end
