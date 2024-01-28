if Debug then Debug.beginFile "TerrainIO.Tiles.TerrainHeightPrinter" end
OnInit.module("TerrainIO.Tiles.TerrainHeightPrinter", function(require)
    local singleTileResolution = TileResolution.create()

    ---@class TerrainHeightPrinter
    TerrainHeightPrinter = {}

    -- prints template from starting point towards north and east, (up and right)
    ---@param startX number
    ---@param startY number
    ---@param heightMap HeightMap
    function TerrainHeightPrinter.PrintFrom(startX, startY, heightMap)
        startX, startY = singleTileResolution:getTileCenter(startX), singleTileResolution:getTileCenter(startY)
        for xIndex, yIndex, height in heightMap:iterateTiles() do
            local x, y = startX + xIndex * singleTileResolution.tileSize, startY + yIndex * singleTileResolution.tileSize
            TerrainDeformCrater(x, y, singleTileResolution.tileSize, -height, 1, true)
        end
    end

end)
if Debug then Debug.endFile() end