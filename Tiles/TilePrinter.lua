if Debug then Debug.beginFile "TerrainIO.Tiles.TilesPrinter" end
OnInit.module("TerrainIO.Tiles.TilesPrinter", function(require)
    require "TerrainIO.Tiles.TileResolution"

    local SHAPE_CIRCLE = 0
    local SHAPE_SQUARE = 1

    local singleTileResolution = TileResolution.create()

    ---@class TerrainPrinter
    TerrainPrinter = {}

    -- prints template from starting point towards north and east, (up and right)
    ---@param resolution TileResolution
    ---@param startX number
    ---@param startY number
    ---@param sourceTask TileTemplate
    function TerrainPrinter.PrintFrom(resolution, startX, startY, sourceTask)
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
                SetTerrainPathable(x, y, PATHING_TYPE_BLIGHTPATHING, tileInfo.pathing[PATHING_TYPE_BLIGHTPATHING])
                SetTerrainPathable(x, y, PATHING_TYPE_BUILDABILITY, tileInfo.pathing[PATHING_TYPE_BUILDABILITY])
                SetTerrainPathable(x, y, PATHING_TYPE_FLOATABILITY, tileInfo.pathing[PATHING_TYPE_FLOATABILITY])
                SetTerrainPathable(x, y, PATHING_TYPE_FLYABILITY, tileInfo.pathing[PATHING_TYPE_FLYABILITY])
                SetTerrainPathable(x, y, PATHING_TYPE_PEONHARVESTPATHING, tileInfo.pathing[PATHING_TYPE_PEONHARVESTPATHING])
                SetTerrainPathable(x, y, PATHING_TYPE_WALKABILITY, tileInfo.pathing[PATHING_TYPE_WALKABILITY])
            end
        end
    end

end)
if Debug then Debug.endFile() end
