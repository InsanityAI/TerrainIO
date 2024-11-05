if Debug then Debug.beginFile "TerrainIO/Tiles/AsyncTileTemplate" end
OnInit.module("TerrainIO/Tiles/AsyncTileTemplate", function(require)
    require.optional "TaskProcessor"

    if not TaskProcessor then
        return
    end

    local processor ---@type TaskProcessor

    ---@param tileTemplate TileTemplate
    ---@return Observable InMemoryTileTemplate
    function InMemoryTileTemplate.createAsync(tileTemplate)
        local newTileTemplate = setmetatable({}, InMemoryTileTemplate)
        newTileTemplate.sizeX = tileTemplate.sizeX
        newTileTemplate.sizeY = tileTemplate.sizeY

        local result = Subject.create()
        local tileIterator = tileTemplate:iterate()
        local task = processor:enqueuePeriodic(tileIterator, 0, 100, TaskAPI.REACTIVE) --[[@as TaskObservable]]

        ---@param delay number
        ---@param xIndex integer
        ---@param yIndex integer
        ---@---@param tile Tile
        task:subscribe(function(delay, xIndex, yIndex, tile)
            if newTileTemplate[xIndex] then
                newTileTemplate[xIndex][yIndex] = tile
            else
                newTileTemplate[xIndex] = { [yIndex] = tile }
            end
        end, result.onError, function(delay)
            result:onNext(delay, newTileTemplate)
            result:onCompleted()
        end)
        return result
    end

    OnInit.trig(function()
        processor = TaskProcessor.create(1)
    end)
end)
if Debug then Debug.endFile() end