if Debug then Debug.beginFile "TerrainIO/Tiles/TileScanner" end
OnInit.module("TerrainIO/Tiles/TileScanner", function(require)
    require "TerrainIO/Tiles/TileResolution"
    require "TerrainIO/Tiles/TileTemplate"

    local singleTileResolution = TileResolution.create()

    ---@class TileScanner
    TileScanner = {}

    ---@param resolution TileResolution
    ---@param x1 number
    ---@param y1 number
    ---@param x2 number
    ---@param y2 number
    ---@return OnDemandTileTemplate
    function TileScanner.ScanBounds(resolution, x1, y1, x2, y2)
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
            resolution = resolution,
            sizeX = math.abs(endX - startX),
            sizeY = math.abs(endY - startY),
        }, OnDemandTileTemplate)
    end

    ---@param resolution TileResolution
    ---@param rect rect
    ---@return OnDemandTileTemplate
    function TileScanner.ScanRect(resolution, rect)
        return TileScanner.ScanBounds(resolution, GetRectMinX(rect), GetRectMinY(rect), GetRectMaxX(rect),
            GetRectMaxY(rect))
    end
end)
if Debug then Debug.endFile() end
