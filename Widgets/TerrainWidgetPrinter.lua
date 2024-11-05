if Debug then Debug.beginFile "TerrainIO/Widgets/TerrainWidgetPrinter" end
OnInit.module("TerrainIO/Widgets/TerrainWidgetPrinter", function (require)
    require "TerrainIO/Widgets/TerrainWidgets"
    require "TerrainIO/Tiles/TileResolution"
    local singleTileResolution = TileResolution.get()

    ---@class TerrainWidgetPrinter
    TerrainWidgetPrinter = {}

    ---@param startX number
    ---@param startY number
    ---@param terrainWidgets TerrainWidgets
    ---@param rotate TerrainIORotate?
    function TerrainWidgetPrinter.PrintFrom(startX, startY, terrainWidgets, rotate)
        if rotate == TerrainIORotate.ROTATE_CLOCKWISE_90 then
            startX = singleTileResolution:getTileCenter(startX)
            startY = singleTileResolution:getTileCenter(startY) + terrainWidgets.sizeX * singleTileResolution.tileSize
        elseif rotate == TerrainIORotate.ROTATE_CLOCKWISE_180 then
            startX = singleTileResolution:getTileCenter(startX) + terrainWidgets.sizeX * singleTileResolution.tileSize
            startY = singleTileResolution:getTileCenter(startY) + terrainWidgets.sizeY * singleTileResolution.tileSize
        elseif rotate == TerrainIORotate.ROTATE_CLOCKWISE_270 then
            startX = singleTileResolution:getTileCenter(startX) + terrainWidgets.sizeY * singleTileResolution.tileSize
            startY = singleTileResolution:getTileCenter(startY)
        else
            startX = singleTileResolution:getTileCenter(startX)
            startY = singleTileResolution:getTileCenter(startY)
        end
        startX, startY = singleTileResolution:getTileCenter(startX), singleTileResolution:getTileCenter(startY)
        for terrainWidget in terrainWidgets:iterate() do
            terrainWidget:spawnAt(rotate or TerrainIORotate.NO_ROTATE, startX, startY)
        end
    end

end)
if Debug then Debug.endFile() end