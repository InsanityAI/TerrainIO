if Debug then Debug.beginFile "TerrainIO.TerrainTemplate" end
OnInit.module("TerrainIO.TerrainTemplate", function(require)
    require "TerrainIO.Tile"

    ---@class TerrainTemplate
    ---@field sizeX integer size in amount of tiles on X axis
    ---@field sizeY integer size in amount of tiles on Y axis
    ---@field iterateTiles fun():fun():nil|Tile, integer|nil, integer|nil returns tile, xIndex, yIndex

    ---@class InMemoryTerrainTemplate : TerrainTemplate
    ---@field tiles table<integer, table<integer, Tile>> -- tiles[x][y] = tile
    InMemoryTerrainTemplate = {}
    InMemoryTerrainTemplate.__index = InMemoryTerrainTemplate

    ---@param terrainTemplate TerrainTemplate
    ---@return InMemoryTerrainTemplate
    function InMemoryTerrainTemplate.create(terrainTemplate)
        local newTerrainTemplate = setmetatable({}, InMemoryTerrainTemplate)
        newTerrainTemplate.sizeX = terrainTemplate.sizeX
        newTerrainTemplate.sizeY = terrainTemplate.sizeY

        local tiles = {}
        for tileInfo, xIndex, yIndex in terrainTemplate:iterateTiles() do
            if tiles[xIndex] then
                tiles[xIndex][yIndex] = tileInfo
            else
                tiles[xIndex] = { [yIndex] = tileInfo }
            end
        end
        newTerrainTemplate.tiles = tiles

        return newTerrainTemplate
    end

    ---@return fun():nil|Tile, integer|nil, integer|nil
    function InMemoryTerrainTemplate:iterateTiles()
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

    ---@class OnDemandTerrainTemplate: TerrainTemplate
    ---@field resolution TileResolution
    ---@field startX number
    ---@field startY number
    ---@field endX number
    ---@field endY number
    OnDemandTerrainTemplate = {}
    OnDemandTerrainTemplate.__index = OnDemandTerrainTemplate

    ---@return fun():nil|Tile, integer|nil, integer|nil
    function OnDemandTerrainTemplate:iterateTiles()
        local x, y, xIndex, yIndex = self.startX, self.startY, 0, 1
        return function()
            xIndex = xIndex + 1
            if xIndex > self.sizeX then x, y, xIndex, yIndex = self.startX, self.resolution:nextTileCoordinate(y), 1, y + 1 end
            if yIndex > self.sizeY then return nil, nil, nil end
            local tileInfo = self.resolution:getTileForCoordinates(x, y)
            x = self.resolution:nextTileCoordinate(x)

            return tileInfo, xIndex, yIndex
        end
    end
end)
if Debug then Debug.endFile() end