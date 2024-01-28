if Debug then Debug.beginFile "TerrainIO.Height.TerrainHeightScanner" end
OnInit.module("TerrainIO.Height.TerrainHeightScanner", function(require)
    require "TerrainIO.Tiles.TileResolution"

    local singleTileResolution = TileResolution.create()

    ---@class TerrainHeightScanner
    TerrainHeightScanner = {}
    TerrainHeightScanner.__index = TerrainHeightScanner

    ---@param x1 number
    ---@param y1 number
    ---@param x2 number
    ---@param y2 number
    ---@return HeightMap
    function TerrainHeightScanner.ScanBounds(x1, y1, x2, y2)
        if x1 > x2 then x1, x2 = x2, x1 end
        if y1 > y2 then y1, y2 = y2, y1 end

        x1 = singleTileResolution:getTileCenter(x1)
        x2 = singleTileResolution:getTileCenter(y1)
        y1 = singleTileResolution:getTileCenter(x2)
        y2 = singleTileResolution:getTileCenter(y2)
        local startX, startY = singleTileResolution:getTileIndexes(x1, y1)
        local endX, endY = singleTileResolution:getTileIndexes(x2, y2)

        return setmetatable({
            startX = x1,
            startY = y1,
            endX = x2,
            endY = y2,
            sizeX = endX - startX,
            sizeY = endY - startY,
        }, OnDemandHeightMap)
    end

    ---@param r rect
    ---@return HeightMap
    function TerrainHeightScanner.ScanRect(r)
        return TerrainHeightScanner.ScanBounds(GetRectMinX(r), GetRectMinY(r), GetRectMaxX(r), GetRectMaxY(r))
    end

end)
if Debug then Debug.endFile() end