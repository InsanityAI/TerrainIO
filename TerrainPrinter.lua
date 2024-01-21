if Debug then Debug.beginFile "TerrainIO.TerrainPrinter" end
OnInit.module("TerrainIO.TerrainPrinter", function(require)
    require "TerrainIO.TileResolution"

    local SHAPE_CIRCLE = 0
    local SHAPE_SQUARE = 1

    local singleTileResolution = TileResolution.create()

    ---@class TerrainPrinter
    TerrainPrinter = {}

    ---@param resolution TileResolution
    ---@param x1 number
    ---@param y1 number
    ---@param x2 number
    ---@param y2 number
    ---@param sourceTask TerrainTemplate
    function TerrainPrinter.PrintBounds(resolution, x1, y1, x2, y2, sourceTask)
        if x1 > x2 then x1, x2 = x2, x1 end
        if y1 > y2 then y1, y2 = y2, y1 end
        x1, y1 = singleTileResolution:getTileCenter(x1), singleTileResolution:getTileCenter(y1)
        x2, y2 = singleTileResolution:getTileCenter(x2), singleTileResolution:getTileCenter(y2)

        for tileInfo, xIndex, yIndex in sourceTask:iterateTiles() do
            local x, y = x1 + xIndex * resolution.tileSize, y1 + yIndex * resolution.tileSize
            SetTerrainType(x, y, tileInfo.tile, tileInfo.variation, resolution.sizeInTiles, SHAPE_SQUARE)
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

    ---@param resolution TileResolution
    ---@param rect rect
    ---@param sourceTask TerrainTemplate
    function TerrainPrinter.PrintRect(resolution, rect, sourceTask)
        TerrainPrinter.PrintBounds(resolution, GetRectMinX(rect), GetRectMinY(rect), GetRectMaxX(rect), GetRectMaxY(rect), sourceTask)
    end

end)
if Debug then Debug.endFile() end
