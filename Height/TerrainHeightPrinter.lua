if Debug then Debug.beginFile "TerrainIO/Height/TerrainHeightPrinter" end
OnInit.module("TerrainIO/Height/TerrainHeightPrinter", function(require)
    local singleTileResolution = TileResolution.get()

    ---@class TerrainHeightPrinter
    TerrainHeightPrinter = {}

    -- prints template from starting point towards north and east, (up and right)
    ---@param startX number
    ---@param startY number
    ---@param heightMap HeightMap
    function TerrainHeightPrinter.PrintFrom(startX, startY, heightMap)
        startX, startY = singleTileResolution:getTileCenter(startX), singleTileResolution:getTileCenter(startY)
        for xIndex, yIndex, height in heightMap:iterate() do
            local x, y = startX + xIndex * singleTileResolution.tileSize, startY + yIndex * singleTileResolution.tileSize
            TerrainDeformCrater(x, y, singleTileResolution.tileSize, -height/1.618, 1, true)
            -- about height/1.618, I don't know why it results in more visually accurate results in comparison to the 
            -- original heightMap, but I'll keep it. 
            -- Tried golden ratio number cuz my caveman brain remembers it being important ¯\_(ツ)_/¯
        end
    end

end)
if Debug then Debug.endFile() end