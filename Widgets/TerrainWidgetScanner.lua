if Debug then Debug.beginFile "TerrainIO/Widgets/TerrainWidgetScanner" end
OnInit.module("TerrainIO/Widgets/TerrainWidgetScanner", function (require)
    require "TerrainIO/Widgets/TerrainWidget"
    require "TerrainIO/Widgets/TerrainWidgets"
    require "TerrainIO/Tiles/TileResolution"
    local singleTileResolution = TileResolution.get()

    TerrainWidgetScanner = {}

    ---@param rect rect
    ---@return TerrainWidgets
    function TerrainWidgetScanner.ScanRect(rect)
        return OnDemandTerrainWidgets.create(rect, singleTileResolution)
    end
end)
if Debug then Debug.endFile() end