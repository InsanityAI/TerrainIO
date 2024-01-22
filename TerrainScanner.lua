if Debug then Debug.beginFile "TerrainIO.TerrainScanner" end
OnInit.module("TerrainIO.TerrainScanner", function(require)
    require "TerrainIO.TileResolution"
    require "TerrainIO.TerrainTemplate"

    local singleTileResolution = TileResolution.create()

    ---@class TerrainScanner
    TerrainScanner = {}

    ---@param resolution TileResolution
    ---@param x1 number
    ---@param y1 number
    ---@param x2 number
    ---@param y2 number
    ---@return OnDemandTerrainTemplate
    function TerrainScanner.ScanBounds(resolution, x1, y1, x2, y2)
        if x1 > x2 then x1, x2 = x2, x1 end
        if y1 > y2 then y1, y2 = y2, y1 end

        x1 = singleTileResolution:getTileCenter(x1)
        x2 = singleTileResolution:getTileCenter(y1)
        y1 = singleTileResolution:getTileCenter(x2)
        y2 = singleTileResolution:getTileCenter(y2)
        local startX, startY = resolution:getTileIndexes(x1, y1)
        local endX, endY = resolution:getTileIndexes(x2, y2)

        return setmetatable({
            startX = x1,
            startY = y1,
            endX = x2,
            endY = y2,
            sizeX = endX - startX,
            sizeY = endY - startY,
        }, OnDemandTerrainTemplate)
    end

    ---@param resolution TileResolution
    ---@param rect rect
    ---@return OnDemandTerrainTemplate
    function TerrainScanner.ScanRect(resolution, rect)
        return TerrainScanner.ScanBounds(resolution, GetRectMinX(rect), GetRectMinY(rect), GetRectMaxX(rect),
            GetRectMaxY(rect))
    end
end)
if Debug then Debug.endFile() end
