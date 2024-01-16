if Debug then Debug.beginFile "TerrainScannerAndPrinter" end
OnInit.module("TerrainScannerAndPrinter", function()
    Require.strict "TaskProcessor"
    Require.strict "IsTerrainPathableOverride"

    local SHAPE_CIRCLE = 0
    local SHAPE_SQUARE = 1

    ---@class TileInformation
    ---@field xIndex integer
    ---@field yIndex integer
    ---@field x number
    ---@field y number
    ---@field tile integer
    ---@field variation integer
    ---@field pathing table<pathingtype, boolean>

    ---@class TerrainTemplate
    ---@field x1 number
    ---@field y1 number
    ---@field x2 number
    ---@field y2 number
    ---@field sizeX integer size in amount of tiles on X axis
    ---@field sizeY integer size in amount of tiles on Y axis
    ---@field iterateTiles fun():fun():nil|TileInformation

    ---@class InMemoryTerrainTemplate : TerrainTemplate
    ---@field tiles table<integer, table<integer, TileInformation>> -- tiles[y][x] = tileInfo
    InMemoryTerrainTemplate = {}
    InMemoryTerrainTemplate.__index = InMemoryTerrainTemplate

    ---@param terrainTemplate TerrainTemplate
    ---@return InMemoryTerrainTemplate
    function InMemoryTerrainTemplate.create(terrainTemplate)
        local newTerrainTemplate = setmetatable({}, InMemoryTerrainTemplate)
        newTerrainTemplate.sizeX = terrainTemplate.sizeX
        newTerrainTemplate.sizeY = terrainTemplate.sizeY
        newTerrainTemplate.x1 = terrainTemplate.x1
        newTerrainTemplate.y1 = terrainTemplate.y1
        newTerrainTemplate.x2 = terrainTemplate.x2
        newTerrainTemplate.y2 = terrainTemplate.y2

        local tiles = {}
        for tileInfo in terrainTemplate:iterateTiles() do
            local x, y = tileInfo.xIndex, tileInfo.yIndex
            if tiles[x] then
                tiles[x][y] = tileInfo
            else
                tiles[x] = { [y] = tileInfo }
            end
        end
        newTerrainTemplate.tiles = tiles

        return newTerrainTemplate
    end

    local processor ---@type Processor

    ---@param terrainTemplate TerrainTemplate
    ---@return Observable InMemoryTerrainTemplate
    function InMemoryTerrainTemplate.createAsync(terrainTemplate)
        local newTerrainTemplate = setmetatable({}, InMemoryTerrainTemplate)
        newTerrainTemplate.sizeX = terrainTemplate.sizeX
        newTerrainTemplate.sizeY = terrainTemplate.sizeY
        newTerrainTemplate.x1 = terrainTemplate.x1
        newTerrainTemplate.y1 = terrainTemplate.y1
        newTerrainTemplate.x2 = terrainTemplate.x2
        newTerrainTemplate.y2 = terrainTemplate.y2

        local result = Subject.create()
        local tileIterator = terrainTemplate:iterateTiles()
        local task = processor:enqueueTask(function(delay)
            return tileIterator()
        end, 100, nil, true)

        local tiles = {}
        ---@param tileInfo TileInformation
        ---@param delay number
        task:subscribe(function(tileInfo, delay)
            local x, y = tileInfo.xIndex, tileInfo.yIndex
            if tiles[x] then
                tiles[x][y] = tileInfo
            else
                tiles[x] = { [y] = tileInfo }
            end
        end, result.onError, function(delay)
            result:onNext(delay, newTerrainTemplate)
            result:onCompleted()
        end)
        newTerrainTemplate.tiles = tiles
        return result
    end

    function InMemoryTerrainTemplate:iterateTiles()
        local x, y = 0, 0
        ---@return TileInformation?
        return function()
            if y > self.sizeY then x, y = x + 1, 0 end
            if x > self.sizeX then return nil end
            local tileInfo = self.tiles[x][y]
            y = y + 1
            return tileInfo
        end
    end

    ---@class OnDemandTerrainTemplate: TerrainTemplate
    OnDemandTerrainTemplate = {}
    OnDemandTerrainTemplate.__index = OnDemandTerrainTemplate

    ---@return fun():nil|TileInformation
    function OnDemandTerrainTemplate:iterateTiles()
        local x, y, xIndex, yIndex = self.x1, self.y1, 0, 0
        ---@return TileInformation?
        return function()
            if x > self.x2 then x, y, xIndex, yIndex = self.x1, GetNextTileCoordinate(y), 0, y + 1 end
            if y > self.y2 then return nil end
            local tileInfo = {
                xIndex = xIndex,
                yIndex = yIndex,
                x = x,
                y = y,
                tile = GetTerrainType(x, y),
                variation = GetTerrainVariance(x, y),
                pathing = {
                    [PATHING_TYPE_AMPHIBIOUSPATHING] = IsTerrainPathable(x, y, PATHING_TYPE_AMPHIBIOUSPATHING),
                    -- [PATHING_TYPE_ANY] = IsTerrainPathable(x,y, PATHING_TYPE_ANY), -- this one can probably be ignored...
                    [PATHING_TYPE_BLIGHTPATHING] = IsTerrainPathable(x, y, PATHING_TYPE_BLIGHTPATHING),
                    [PATHING_TYPE_BUILDABILITY] = IsTerrainPathable(x, y, PATHING_TYPE_BUILDABILITY),
                    [PATHING_TYPE_WALKABILITY] = IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY),
                    [PATHING_TYPE_FLOATABILITY] = IsTerrainPathable(x, y, PATHING_TYPE_FLOATABILITY),
                    [PATHING_TYPE_FLYABILITY] = IsTerrainPathable(x, y, PATHING_TYPE_FLYABILITY),
                    [PATHING_TYPE_PEONHARVESTPATHING] = IsTerrainPathable(x, y, PATHING_TYPE_PEONHARVESTPATHING),
                }
            }
            x = GetNextTileCoordinate(x)
            xIndex = xIndex + 1

            return tileInfo
        end
    end

    TerrainScanner = {}
    TerrainPrinter = {}

    ---@param x1 number
    ---@param y1 number
    ---@param x2 number
    ---@param y2 number
    ---@return OnDemandTerrainTemplate
    function TerrainScanner.ScanBounds(x1, y1, x2, y2)
        if x1 > x2 then x1, x2 = x2, x1 end
        if y1 > y2 then y1, y2 = y2, y1 end

        x1 = GetTileCenterCoordinate(x1)
        y1 = GetTileCenterCoordinate(y1)
        x2 = GetTileCenterCoordinate(x2)
        y2 = GetTileCenterCoordinate(y2)

        return setmetatable({
            x1 = x1,
            y1 = y1,
            x2 = x2,
            y2 = y2,
            sizeX = math.modf((x2 - x1) / GetTileSize()),
            sizeY = math.modf((y2 - y1) / GetTileSize()),
        }, OnDemandTerrainTemplate)
    end

    ---@param rect rect
    ---@return OnDemandTerrainTemplate
    function TerrainScanner.ScanRect(rect)
        return TerrainScanner.ScanBounds(GetRectMinX(rect), GetRectMinY(rect), GetRectMaxX(rect), GetRectMaxY(rect))
    end

    ---@param x1 number
    ---@param y1 number
    ---@param x2 number
    ---@param y2 number
    ---@param sourceTask TerrainTemplate
    function TerrainPrinter.PrintBounds(x1, y1, x2, y2, sourceTask)
        if x1 > x2 then x1, x2 = x2, x1 end
        if y1 > y2 then y1, y2 = y2, y1 end
        x1, y1 = GetTileCenterCoordinate(x1), GetTileCenterCoordinate(y1)
        x2, y2 = GetTileCenterCoordinate(x2), GetTileCenterCoordinate(y2)
        local tileSize = GetTileSize()

        --TODO: scaling?
        -- sourceTask.sizeX, sourceTask.sizeY

        for tileInfo in sourceTask:iterateTiles() do
            local x, y = x1 + tileInfo.xIndex * tileSize, y1 + tileInfo.yIndex * tileSize
            SetTerrainType(x, y, tileInfo.tile, tileInfo.variation, 1, SHAPE_SQUARE)
            SetTerrainPathable(x, y, PATHING_TYPE_AMPHIBIOUSPATHING, tileInfo.pathing[PATHING_TYPE_AMPHIBIOUSPATHING])
            -- SetTerrainPathable(x, y, PATHING_TYPE_ANY, tileInfo.pathing[PATHING_TYPE_ANY])
            SetTerrainPathable(x, y, PATHING_TYPE_BLIGHTPATHING, tileInfo.pathing[PATHING_TYPE_BLIGHTPATHING])
            SetTerrainPathable(x, y, PATHING_TYPE_BUILDABILITY, tileInfo.pathing[PATHING_TYPE_BUILDABILITY])
            SetTerrainPathable(x, y, PATHING_TYPE_FLOATABILITY, tileInfo.pathing[PATHING_TYPE_FLOATABILITY])
            SetTerrainPathable(x, y, PATHING_TYPE_FLYABILITY, tileInfo.pathing[PATHING_TYPE_FLYABILITY])
            SetTerrainPathable(x, y, PATHING_TYPE_PEONHARVESTPATHING, tileInfo.pathing[PATHING_TYPE_PEONHARVESTPATHING])
            SetTerrainPathable(x, y, PATHING_TYPE_WALKABILITY, tileInfo.pathing[PATHING_TYPE_WALKABILITY])
        end
    end

    ---@param rect rect
    ---@param sourceTask TerrainTemplate
    function TerrainPrinter.PrintRect(rect, sourceTask)
        TerrainPrinter.PrintBounds(GetRectMinX(rect), GetRectMinY(rect), GetRectMaxX(rect), GetRectMaxY(rect), sourceTask)
    end

    OnInit.trig(function()
        processor = Processor.create(1)
    end)
end)
if Debug then Debug.endFile() end
