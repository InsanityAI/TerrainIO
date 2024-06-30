if Debug then Debug.beginFile "TerrainIO/Tiles/TileResolution" end
OnInit.global("TerrainIO/Tiles/TileResolution", function(require)
    require "TerrainIO/Tiles/Tile"
    require "MapBounds"
    require "TerrainIO/IsTerrainPathableFixed"

    local TILE_SIZE_DISTANCE_UNITS = 128
    local TILE_SIZE_REVERSE = 1 / TILE_SIZE_DISTANCE_UNITS

    ---@class TileResolution
    ---@field sizeInTiles number
    ---@field tileSize number
    ---@field reverseTileSize number
    ---@field maxIndexX integer
    ---@field maxIndexY integer
    ---@field cache Cache
    TileResolution = {}
    TileResolution.__index = TileResolution

    ---@param self TileResolution
    ---@param xIndex integer
    ---@param yIndex integer
    ---@param x number
    ---@param y number
    ---@return Tile
    local function fetchTile(self, xIndex, yIndex, x, y)
        local tile = GetTerrainType(x, y)
        local variation = GetTerrainVariance(x, y)
        local pathing = {
            [PATHING_TYPE_AMPHIBIOUSPATHING] = IsTerrainPathableFixed(x, y, PATHING_TYPE_AMPHIBIOUSPATHING),
            -- [PATHING_TYPE_ANY] = IsTerrainPathableFixed(x,y, PATHING_TYPE_ANY), -- this one can probably be ignored...
            [PATHING_TYPE_BLIGHTPATHING] = IsTerrainPathableFixed(x, y, PATHING_TYPE_BLIGHTPATHING),
            [PATHING_TYPE_BUILDABILITY] = IsTerrainPathableFixed(x, y, PATHING_TYPE_BUILDABILITY),
            [PATHING_TYPE_WALKABILITY] = IsTerrainPathableFixed(x, y, PATHING_TYPE_WALKABILITY),
            [PATHING_TYPE_FLOATABILITY] = IsTerrainPathableFixed(x, y, PATHING_TYPE_FLOATABILITY),
            [PATHING_TYPE_FLYABILITY] = IsTerrainPathableFixed(x, y, PATHING_TYPE_FLYABILITY),
            [PATHING_TYPE_PEONHARVESTPATHING] = IsTerrainPathableFixed(x, y, PATHING_TYPE_PEONHARVESTPATHING),
        }

        return SimpleTile.create(tile, variation, pathing, IsPointBlighted(x, y))
    end

    ---@param sizeInTiles? integer 1 tilesize is 128 wc3 distance units (default: 1)
    ---@return TileResolution
    function TileResolution.create(sizeInTiles)
        if sizeInTiles ~= nil then
            assert(type(sizeInTiles) == "number" and math.fmod(sizeInTiles, 1) == sizeInTiles,
                "Argument 'sizeInTiles' must be an integer!")
            assert(sizeInTiles ~= 0, "Argument 'sizeInTiles' cannot be 0!")
            assert(sizeInTiles > 0, "Argument 'sizeInTiles' cannot be negative!")
        else
            sizeInTiles = 1
        end

        local o = setmetatable({
            sizeInTiles = sizeInTiles,
            size = sizeInTiles * TILE_SIZE_DISTANCE_UNITS,
            cache = Cache.create(fetchTile, 5, 1, 2, 3),
            tileSize = TILE_SIZE_DISTANCE_UNITS * sizeInTiles,
            reverseTileSize = TILE_SIZE_REVERSE * sizeInTiles
        }, TileResolution)
        o.maxIndexX = WorldBounds.sizeX / o.size
        o.maxIndexY = WorldBounds.sizeY / o.size
        return o
    end

    ---@param a number
    ---@param ratio number [0.00, 1.00]
    function TileResolution:getTileCoordinateAtRatio(a, ratio)
        return (math.modf(a * self.reverseTileSize) + ratio - 0.5) * self.tileSize
    end

    ---@param a number
    ---@return number
    function TileResolution:getTileCenter(a)
        return self:getTileCoordinateAtRatio(a, 0.5)
    end

    ---@param a number
    ---@return number min, number center, number max
    function TileResolution:getTileMinCenterMax(a)
        local center = self:getTileCenter(a)
        local offset = 0.5 * self.tileSize
        return center - offset, center, center + offset
    end

    ---@param xIndex integer
    ---@param yIndex integer
    ---@return Tile
    function TileResolution:getTileForIndexes(xIndex, yIndex)
        local x = self:getTileCenter(WorldBounds.minX + xIndex * self.tileSize)
        local y = self:getTileCenter(WorldBounds.minY + yIndex * self.tileSize)
        return self.cache:get(self, xIndex, yIndex, x, y)
    end

    ---@param x number
    ---@param y number
    ---@return Tile
    function TileResolution:getTileForCoordinates(x, y)
        x = self:getTileCenter(x)
        y = self:getTileCenter(y)
        local xIndex, yIndex = self:getTileIndexes(x, y)
        return self.cache:get(self, xIndex, yIndex, x, y)
    end

    ---@param a number
    ---@param b number
    ---@return boolean
    function TileResolution:areCoordinatesInSameTime(a, b)
        return self:getTileCenter(a) == self:getTileCenter(b)
    end

    -- Attention: Only makes sense if both coordinates are of same type. Or x or y coordinates. May bring wrong result, if you compare x with y coordinates.
    ---@param x1 number
    ---@param y1 number
    ---@param x2 number
    ---@param y2 number
    ---@return boolean
    function TileResolution:arePointsInSameTile(x1, y1, x2, y2)
        return self:areCoordinatesInSameTime(x1, x2) and self:areCoordinatesInSameTime(y1, y2)
    end

    ---@param a number
    ---@return number
    function TileResolution:previousTileCoordinate(a)
        return a - self.tileSize
    end

    ---@param a number
    ---@return number
    function TileResolution:nextTileCoordinate(a)
        return a + self.tileSize
    end

    ---@param xIndex integer
    ---@return number minX, number centerX, number maxX
    function TileResolution:getTileMinCenterMaxByXIndex(xIndex)
        return self:getTileMinCenterMax(WorldBounds.minX + xIndex * self.tileSize)
    end

    ---@param yIndex integer
    ---@return number minY, number centerY, number maxY
    function TileResolution:getTileMinCenterMaxByYIndex(yIndex)
        return self:getTileMinCenterMax(WorldBounds.minY + yIndex * self.tileSize)
    end

    local indexX, indexY ---@type number, number

    ---@param x number
    ---@param y number
    ---@return integer xIndex, integer yIndex
    function TileResolution:getTileIndexes(x, y)
        indexX = math.modf((x - WorldBounds.minX) * self.reverseTileSize)
        indexY = math.modf((y - WorldBounds.minY) * self.reverseTileSize)
        return indexX, indexY
    end
end)
if Debug then Debug.endFile() end
