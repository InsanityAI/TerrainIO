if Debug then Debug.beginFile "TerrainIO/Widgets/TerrainWidgetPrinter" end
OnInit.module("TerrainIO/Widgets/TerrainWidgetPrinter", function (require)
    require "TerrainIO/Widgets/TerrainWidgets"

    ---@class TerrainWidgetPrinter
    TerrainWidgetPrinter = {}

    ---@param startX number
    ---@param startY number
    ---@param terrainWidgets TerrainWidgets
    function TerrainWidgetPrinter.PrintFrom(startX, startY, terrainWidgets)
        for terrainWidget in terrainWidgets:iterate() do
            terrainWidget:spawnAt(startX, startY)
        end
    end

end)
if Debug then Debug.endFile() end