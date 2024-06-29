if Debug then Debug.beginFile "TerrainIO/Height/TerrainHeightScanner" end
OnInit.module("TerrainIO/Height/TerrainHeightScanner", function(require)
    require "TerrainIO/Tiles/TileResolution"

    local singleTileResolution = TileResolution.create()

    ---@class TerrainHeightScanner
    TerrainHeightScanner = {}
    TerrainHeightScanner.__index = TerrainHeightScanner

    ---@param x1 number
    ---@param y1 number
    ---@param x2 number
    ---@param y2 number
    ---@param relativeHeight number?
    ---@return HeightMap
    function TerrainHeightScanner.ScanBounds(x1, y1, x2, y2, relativeHeight)
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
            sizeX = math.abs(endX - startX),
            sizeY = math.abs(endY - startY),
            relativeHeight = relativeHeight or 0
        }, OnDemandHeightMap)
    end

    ---@param r rect
    ---@param relativeHeight number?
    ---@return HeightMap
    function TerrainHeightScanner.ScanRect(r, relativeHeight)
        return TerrainHeightScanner.ScanBounds(GetRectMinX(r), GetRectMinY(r), GetRectMaxX(r), GetRectMaxY(r), relativeHeight)
    end

end)
if Debug then Debug.endFile() end