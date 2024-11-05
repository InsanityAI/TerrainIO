if Debug then Debug.beginFile "TerrainIO/Height/TerrainHeightPrinter" end
OnInit.module("TerrainIO/Height/TerrainHeightPrinter", function(require)
    local singleTileResolution = TileResolution.get()

    ---@class TerrainHeightPrinter
    TerrainHeightPrinter = {}

    -- prints template from starting point towards north and east, (up and right)
    ---@param startX number
    ---@param startY number
    ---@param heightMap HeightMap
    ---@param rotate TerrainIORotate?
    function TerrainHeightPrinter.PrintFrom(startX, startY, heightMap, rotate)
        if rotate == TerrainIORotate.ROTATE_CLOCKWISE_90 then
            startX = singleTileResolution:getTileCenter(startX)
            startY = singleTileResolution:getTileCenter(startY) + heightMap.sizeX * singleTileResolution.tileSize
        elseif rotate == TerrainIORotate.ROTATE_CLOCKWISE_180 then
            startX = singleTileResolution:getTileCenter(startX) + heightMap.sizeX * singleTileResolution.tileSize
            startY = singleTileResolution:getTileCenter(startY) + heightMap.sizeY * singleTileResolution.tileSize
        elseif rotate == TerrainIORotate.ROTATE_CLOCKWISE_270 then
            startX = singleTileResolution:getTileCenter(startX) + heightMap.sizeY * singleTileResolution.tileSize
            startY = singleTileResolution:getTileCenter(startY)
        else
            startX = singleTileResolution:getTileCenter(startX)
            startY = singleTileResolution:getTileCenter(startY)
        end

        for xIndex, yIndex, height in heightMap:iterate() do
            local x, y ---@type number, number
            if rotate == TerrainIORotate.ROTATE_CLOCKWISE_90 then
                x = startX + yIndex * singleTileResolution.tileSize
                y = startY - xIndex * singleTileResolution.tileSize
            elseif rotate == TerrainIORotate.ROTATE_CLOCKWISE_180 then
                x = startX - xIndex * singleTileResolution.tileSize
                y = startY - yIndex * singleTileResolution.tileSize
            elseif rotate == TerrainIORotate.ROTATE_CLOCKWISE_270 then
                x = startX - yIndex * singleTileResolution.tileSize
                y = startY + xIndex * singleTileResolution.tileSize
            else
                x = startX + xIndex * singleTileResolution.tileSize
                y = startY + yIndex * singleTileResolution.tileSize
            end

            TerrainDeformCrater(x, y, singleTileResolution.tileSize, GetPointZ(x, y) - GetCliffHeight(x,y) - height, 1, true)
        end
    end
end)
if Debug then Debug.endFile() end
