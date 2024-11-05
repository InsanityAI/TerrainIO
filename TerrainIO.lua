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

    require "TerrainIO/Serialization/HeightMapSerialization"
    require "TerrainIO/Serialization/TileTemplateSerialization"
    require "TerrainIO/Serialization/TerrainWidgetsSerialization"

    require "TerrainIO/FileIO/TileIO"
    require "TerrainIO/FileIO/HeightMapIO"
    require "TerrainIO/FileIO/TerrainWidgetsIO"

    ---@enum TerrainIORotate
    TerrainIORotate = {
        NO_ROTATE = 1,
        ROTATE_CLOCKWISE_90 = 2,
        ROTATE_CLOCKWISE_180 = 3,
        ROTATE_CLOCKWISE_270 = 4
    }
end)
if Debug then Debug.endFile() end
