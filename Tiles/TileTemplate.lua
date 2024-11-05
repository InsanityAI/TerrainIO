if Debug then Debug.beginFile "TerrainIO/Tiles/TileTemplate" end
OnInit.module("TerrainIO/Tiles/TileTemplate", function(require)
    require "TerrainIO/Tiles/Tile"

    ---@class TileTemplate
    ---@field sizeX integer size in amount of tiles on X axis
    ---@field sizeY integer size in amount of tiles on Y axis
    ---@field iterate fun():fun():integer|nil, integer|nil, nil|Tile returns xIndex, yIndex, tile

    ---@class InMemoryTileTemplate : TileTemplate
    ---@field [integer] Tile[] -- tiles[x][y] = tile
    InMemoryTileTemplate = {}
    InMemoryTileTemplate.__index = InMemoryTileTemplate

    ---@param tileTemplate TileTemplate
    ---@return InMemoryTileTemplate
    function InMemoryTileTemplate.create(tileTemplate)
        local newTileTemplate = setmetatable({ sizeX = tileTemplate.sizeX, sizeY = tileTemplate.sizeY }, InMemoryTileTemplate)

        for xIndex, yIndex, tileInfo in tileTemplate:iterate() do
            if newTileTemplate[xIndex] then
                newTileTemplate[xIndex][yIndex] = tileInfo
            else
                newTileTemplate[xIndex] = { [yIndex] = tileInfo }
            end
        end

        return newTileTemplate
    end

    ---@return fun():integer|nil, integer|nil, Tile|nil
    function InMemoryTileTemplate:iterate()
        local x, y = -1, 0
        ---@return Tile?
        return function()
            x = x + 1
            if x >= self.sizeX then x, y = 0, y + 1 end
            if y >= self.sizeY then return nil, nil, nil end
            return x, y, self[x][y]
        end
    end

    ---@class OnDemandTileTemplate: TileTemplate
    ---@field resolution TileResolution
    ---@field startX number
    ---@field startY number
    ---@field endX number
    ---@field endY number
    OnDemandTileTemplate = {}
    OnDemandTileTemplate.__index = OnDemandTileTemplate

    ---@return fun():integer|nil, integer|nil, Tile|nil
    function OnDemandTileTemplate:iterate()
        local x, y, xIndex, yIndex = self.startX, self.startY, -1, 0
        return function()
            xIndex = xIndex + 1
            if xIndex >= self.sizeX then x, y, xIndex, yIndex = self.startX, self.resolution:nextTileCoordinate(y), 0, yIndex + 1 end
            if yIndex >= self.sizeY then return nil, nil, nil end
            local tileInfo = self.resolution:getTileForCoordinates(x, y)
            x = self.resolution:nextTileCoordinate(x)

            return xIndex, yIndex, tileInfo
        end
    end
end)
if Debug then Debug.endFile() end
