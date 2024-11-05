if Debug then Debug.beginFile "TerrainIO/FileIO/HeightMapIO" end
OnInit.module("TerrainIO/FileIO/HeightMapIO", function(require)
    require "TerrainIO/Serialization/HeightMapSerialization"
    require "FileIO"

    ---@class HeightMapIO
    HeightMapIO = {
        ---@param templateName string
        ---@param heightMap HeightMap
        Save = function(templateName, heightMap)
            FileIO.Save("height" .. templateName .. ".pld", HeightMapSerializer.Serialize(heightMap))
        end,

        ---@param templateName string
        ---@return HeightMap
        Load = function(templateName)
            return HeightMapSerializer.Deserialize(FileIO.Load("height" .. templateName .. ".pld"))
        end
    }
end)
if Debug then Debug.endFile() end
