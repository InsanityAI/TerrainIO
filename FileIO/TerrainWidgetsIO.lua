if Debug then Debug.beginFile "TerrainIO/FileIO/TerrainWidgetsIO" end
OnInit.module("TerrainIO/FileIO/TerrainWidgetsIO", function (require)
    require "TerrainIO/Serialization/TerrainWidgetsSerialization"
    require "FileIO"

    ---@class TerrainWidgetsIO
    TerrainWidgetsIO = {
        ---@param templateName string
        ---@param terrainWidgets TerrainWidgets
        Save = function(templateName, terrainWidgets)
            FileIO.Save("widgets" .. templateName .. ".pld", TerrainWidgetsSerialization.Serialize(terrainWidgets))
        end,

        ---@param templateName string
        ---@return TerrainWidgets
        Load = function(templateName)
            return TerrainWidgetsSerialization.Deserialize(FileIO.Load("widgets" .. templateName .. ".pld"))
        end
    }
end)
if Debug then Debug.endFile() end