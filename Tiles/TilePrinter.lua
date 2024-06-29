if Debug then Debug.beginFile "TerrainIO/Tiles/TilePrinter" end
OnInit.module("TerrainIO/Tiles/TilePrinter", function(require)
    require "TerrainIO/Tiles/TileResolution"

    local SHAPE_CIRCLE = 0
    local SHAPE_SQUARE = 1
    local playerNeutral = Player(PLAYER_NEUTRAL_PASSIVE)

    local singleTileResolution = TileResolution.create()

    ---@class TilePrinter
    TilePrinter = {}

    -- prints template from starting point towards north and east, (up and right)
    ---@param resolution TileResolution
    ---@param startX number
    ---@param startY number
    ---@param sourceTask TileTemplate
    ---@param addBlight boolean
    function TilePrinter.PrintFrom(resolution, startX, startY, sourceTask, addBlight)
        startX, startY = singleTileResolution:getTileCenter(startX), singleTileResolution:getTileCenter(startY)
        for tileInfo, xIndex, yIndex in sourceTask:iterateTiles() do
            local x, y = startX + xIndex * resolution.tileSize, startY + yIndex * resolution.tileSize
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
                -- SetBlight has this absurd problem where when coordinates are negative it pushed the x and y to the negative axis by 1 tile over...
                if x < 0 then x = x + singleTileResolution.tileSize end
                if y < 0 then y = y + singleTileResolution.tileSize end
                SetBlight(playerNeutral, x, y, resolution.tileSize, true)
            end
        end
    end

end)
if Debug then Debug.endFile() end
