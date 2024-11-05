if Debug then Debug.beginFile "TerrainIO/Tiles/TilePrinter" end
OnInit.module("TerrainIO/Tiles/TilePrinter", function(require)
    require "TerrainIO/Tiles/TileResolution"

    local SHAPE_CIRCLE = 0
    local SHAPE_SQUARE = 1
    local playerNeutral = Player(PLAYER_NEUTRAL_PASSIVE)

    local singleTileResolution = TileResolution.get()

    ---@class TilePrinter
    TilePrinter = {}

    -- prints template from starting point towards north and east, (up and right)
    ---@param resolution TileResolution
    ---@param startX number
    ---@param startY number
    ---@param sourceTask TileTemplate
    ---@param addBlight boolean
    ---@param rotate TerrainIORotate?
    function TilePrinter.PrintFrom(resolution, startX, startY, sourceTask, addBlight, rotate)
        if rotate == TerrainIORotate.ROTATE_CLOCKWISE_90 then
            startX = singleTileResolution:getTileCenter(startX)
            startY = singleTileResolution:getTileCenter(startY) + sourceTask.sizeX * singleTileResolution.tileSize
        elseif rotate == TerrainIORotate.ROTATE_CLOCKWISE_180 then
            startX = singleTileResolution:getTileCenter(startX) + sourceTask.sizeX * singleTileResolution.tileSize
            startY = singleTileResolution:getTileCenter(startY) + sourceTask.sizeY * singleTileResolution.tileSize
        elseif rotate == TerrainIORotate.ROTATE_CLOCKWISE_270 then
            startX = singleTileResolution:getTileCenter(startX) + sourceTask.sizeY * singleTileResolution.tileSize
            startY = singleTileResolution:getTileCenter(startY)
        else
            startX = singleTileResolution:getTileCenter(startX)
            startY = singleTileResolution:getTileCenter(startY)
        end

        for xIndex, yIndex, tileInfo in sourceTask:iterate() do
            local x, y ---@type number, number
            if rotate == TerrainIORotate.ROTATE_CLOCKWISE_90 then
                x = startX + yIndex * resolution.tileSize
                y = startY - xIndex * resolution.tileSize
            elseif rotate == TerrainIORotate.ROTATE_CLOCKWISE_180 then
                x = startX - xIndex * resolution.tileSize
                y = startY - yIndex * resolution.tileSize
            elseif rotate == TerrainIORotate.ROTATE_CLOCKWISE_270 then
                x = startX - yIndex * resolution.tileSize
                y = startY + xIndex * resolution.tileSize
            else
                x = startX + xIndex * resolution.tileSize
                y = startY + yIndex * resolution.tileSize
            end
            local tile, variation = tileInfo:getTileVariation()
            if tile then
                SetTerrainType(x, y, tile, variation, resolution.sizeInTiles, SHAPE_SQUARE)
            end
            if tileInfo.pathing then
                SetTerrainPathable(x, y, PATHING_TYPE_AMPHIBIOUSPATHING, tileInfo.pathing[PATHING_TYPE_AMPHIBIOUSPATHING])
                -- SetTerrainPathable(x, y, PATHING_TYPE_ANY, tileInfo.pathing[PATHING_TYPE_ANY])
                -- SetTerrainPathable(x, y, PATHING_TYPE_BLIGHTPATHING, tileInfo.pathing[PATHING_TYPE_BLIGHTPATHING])
                SetTerrainPathable(x, y, PATHING_TYPE_BUILDABILITY, tileInfo.pathing[PATHING_TYPE_BUILDABILITY])
                SetTerrainPathable(x, y, PATHING_TYPE_FLOATABILITY, tileInfo.pathing[PATHING_TYPE_FLOATABILITY])
                SetTerrainPathable(x, y, PATHING_TYPE_FLYABILITY, tileInfo.pathing[PATHING_TYPE_FLYABILITY])
                SetTerrainPathable(x, y, PATHING_TYPE_PEONHARVESTPATHING, tileInfo.pathing[PATHING_TYPE_PEONHARVESTPATHING])
                SetTerrainPathable(x, y, PATHING_TYPE_WALKABILITY, tileInfo.pathing[PATHING_TYPE_WALKABILITY])
            end
            if addBlight and tileInfo:isBlighted() then
                SetBlight(playerNeutral, x, y, resolution.tileSize, true)
            end
        end
    end
end)
if Debug then Debug.endFile() end
