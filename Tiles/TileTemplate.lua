if Debug then Debug.beginFile "TerrainIO.Tiles.TileTemplate" end
OnInit.module("TerrainIO.Tiles.TileTemplate", function(require)
    require "TerrainIO.Tiles.Tile"

    ---@class TileTemplate
    ---@field sizeX integer size in amount of tiles on X axis
    ---@field sizeY integer size in amount of tiles on Y axis
    ---@field iterateTiles fun():fun():nil|Tile, integer|nil, integer|nil returns tile, xIndex, yIndex

    ---@class InMemoryTileTemplate : TileTemplate
    ---@field tiles table<integer, table<integer, Tile>> -- tiles[x][y] = tile
    InMemoryTileTemplate = {}
    InMemoryTileTemplate.__index = InMemoryTileTemplate

    ---@param TileTemplate TileTemplate
    ---@return InMemoryTileTemplate
    function InMemoryTileTemplate.create(TileTemplate)
        local newTileTemplate = setmetatable({}, InMemoryTileTemplate)
        newTileTemplate.sizeX = TileTemplate.sizeX
        newTileTemplate.sizeY = TileTemplate.sizeY

        local tiles = {}
        for tileInfo, xIndex, yIndex in TileTemplate:iterateTiles() do
            if tiles[xIndex] then
                tiles[xIndex][yIndex] = tileInfo
            else
                tiles[xIndex] = { [yIndex] = tileInfo }
            end
        end
        newTileTemplate.tiles = tiles

        return newTileTemplate
    end

    ---@return fun():nil|Tile, integer|nil, integer|nil
    function InMemoryTileTemplate:iterateTiles()
        local x, y = 0, 1
        ---@return Tile?
        return function()
            x = x + 1
            if x > self.sizeX then x, y = 1, y + 1 end
            if y > self.sizeY then return nil, nil, nil end
            local tileInfo = self.tiles[x][y]
            return tileInfo, x, y
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

    ---@return fun():nil|Tile, integer|nil, integer|nil
    function OnDemandTileTemplate:iterateTiles()
        local x, y, xIndex, yIndex = self.startX, self.startY, 0, 1
        return function()
            xIndex = xIndex + 1
            if xIndex > self.sizeX then x, y, xIndex, yIndex = self.startX, self.resolution:nextTileCoordinate(y), 1, yIndex + 1 end
            if yIndex > self.sizeY then return nil, nil, nil end
            local tileInfo = self.resolution:getTileForCoordinates(x, y)
            x = self.resolution:nextTileCoordinate(x)

            return tileInfo, xIndex, yIndex
        end
    end
end)
if Debug then Debug.endFile() end