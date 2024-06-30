if Debug then Debug.beginFile "TerrainIO" end
OnInit.module("TerrainIO", function(require)
    require "TerrainIO/IsTerrainPathableFixed"

    require "TerrainIO/Tiles/TileResolution"
    require "TerrainIO/Tiles/Tile"
    require "TerrainIO/Tiles/TileTemplate"
    require "TerrainIO/Tiles/AsyncTileTemplate"
    require "TerrainIO/Tiles/TileScanner"
    require "TerrainIO/Tiles/TilePrinter"

    require "TerrainIO/Height/HeightMap"
    require "TerrainIO/Height/AsyncHeightMap"
    require "TerrainIO/Height/TerrainHeightScanner"
    require "TerrainIO/Height/TerrainHeightPrinter"

    require "TerrainIO/Widgets/TerrainWidget"
    require "TerrainIO/Widgets/TerrainWidgets"
    require "TerrainIO/Widgets/TerrainWidgetScanner"
    require "TerrainIO/Widgets/TerrainWidgetPrinter"
end)
if Debug then Debug.endFile() end
