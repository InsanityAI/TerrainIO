if Debug then Debug.beginFile "TerrainIO.Tiles.AsyncTileTemplate" end
OnInit.module("TerrainIO.Tiles.AsyncTileTemplate", function(require)
    require.optional "TaskProcessor"

    if not Processor then
        return
    end

    local processor ---@type Processor

    ---@param terrainTemplate TerrainTemplate
    ---@return Observable InMemoryTerrainTemplate
    function InMemoryTerrainTemplate.createAsync(terrainTemplate)
        local newTerrainTemplate = setmetatable({}, InMemoryTerrainTemplate)
        newTerrainTemplate.sizeX = terrainTemplate.sizeX
        newTerrainTemplate.sizeY = terrainTemplate.sizeY

        local result = Subject.create()
        local tileIterator = terrainTemplate:iterateTiles()
        local task = processor:enqueueTask(function(delay)
            return tileIterator()
        end, 100, nil, true)

        local tiles = {}
        ---@param delay number
        ---@param tile Tile
        ---@param xIndex integer
        ---@param yIndex integer
        task:subscribe(function(delay, tile, xIndex, yIndex)
            if tiles[xIndex] then
                tiles[xIndex][yIndex] = tile
            else
                tiles[xIndex] = { [yIndex] = tile }
            end
        end, result.onError, function(delay)
            result:onNext(delay, newTerrainTemplate)
            result:onCompleted()
        end)
        newTerrainTemplate.tiles = tiles
        return result
    end

    OnInit.trig(function()
        processor = Processor.create(1)
    end)
end)
if Debug then Debug.endFile() end