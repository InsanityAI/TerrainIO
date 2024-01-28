if Debug then Debug.beginFile "TerrainIO.Height.AsyncHeightMap" end
OnInit.module("TerrainIO.Height.AsyncHeightMap", function (require)
    require.optional "TaskProcessor"

    if not Processor then
        return
    end

    local processor ---@type Processor

    ---@param heightMap HeightMap
    ---@return Observable InMemoryHeightMap
    function InMemoryHeightMap.createAsync(heightMap)
        local newHeightMap = setmetatable({}, InMemoryHeightMap)
        newHeightMap.sizeX = heightMap.sizeX
        newHeightMap.sizeY = heightMap.sizeY

        local result = Subject.create()
        local tileIterator = heightMap:iterateTiles()
        local task = processor:enqueueTask(function(delay)
            return tileIterator()
        end, 100, nil, true)

        ---@param delay number
        ---@param xIndex integer
        ---@param yIndex integer
        ---@param height number
        task:subscribe(function(delay, xIndex, yIndex, height)
            if newHeightMap[xIndex] then
                newHeightMap[xIndex][yIndex] = height
            else
                newHeightMap[xIndex] = { [yIndex] = height }
            end
        end, result.onError, function(delay)
            result:onNext(delay, newHeightMap)
            result:onCompleted()
        end)
        return result
    end

    OnInit.trig(function()
        processor = Processor.create(1)
    end)
end)
if Debug then Debug.endFile() end