if Debug then Debug.beginFile "TerrainIO/FileIO/TileIO" end
OnInit.module("TerrainIO/FileIO/TileIO", function(require)
    require "TerrainIO/Serialization/TileTemplateSerialization"
    require "FileIO"

    ---@class TileIO
    TileIO = {
        ---@param templateName string
        ---@param tileTemplate TileTemplate
        Save = function(templateName, tileTemplate)
            FileIO.Save("tile" .. templateName .. ".pld", TileTemplateSerializer.Serialize(tileTemplate))
        end,

        ---@param templateName string
        ---@return TileTemplate
        Load = function(templateName)
            return TileTemplateSerializer.Deserialize(FileIO.Load("tile" .. templateName .. ".pld") --[[@as string]])
        end
    }
end)
if Debug then Debug.endFile() end
