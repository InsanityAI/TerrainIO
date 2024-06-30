if Debug then Debug.beginFile "TerrainIO/Tiles/AsyncTileTemplate" end
OnInit.module("TerrainIO/Tiles/AsyncTileTemplate", function(require)
    require.optional "TaskProcessor"

    if not TaskProcessor then
        return
    end

    local processor ---@type TaskProcessor

    ---@param TileTemplate TileTemplate
    ---@return Observable InMemoryTileTemplate
    function InMemoryTileTemplate.createAsync(TileTemplate)
        local newTileTemplate = setmetatable({}, InMemoryTileTemplate)
        newTileTemplate.sizeX = TileTemplate.sizeX
        newTileTemplate.sizeY = TileTemplate.sizeY

        local result = Subject.create()
        local tileIterator = TileTemplate:iterateTiles()
        local task = processor:enqueuePeriodic(tileIterator, 0, 100, TaskAPI.REACTIVE) --[[@as TaskObservable]]

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
            result:onNext(delay, newTileTemplate)
            result:onCompleted()
        end)
        newTileTemplate.tiles = tiles
        return result
    end

    OnInit.trig(function()
        processor = TaskProcessor.create(1)
    end)
end)
if Debug then Debug.endFile() end