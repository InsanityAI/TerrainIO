if Debug then Debug.beginFile "TerrainIO.Serialization.HeightMapSerializer" end
OnInit.module("TerrainIO.Serialization.HeightMapSerializer", function(require)
    require.optional "json"
    require "TerrainIO.Height.HeightMap"

    if not json then return end

    ---@class HeightMapSerializer
    HeightMapSerializer = {}

    ---@class HeightMapSerialized
    ---@field sizeX integer
    ---@field sizeY integer
    ---@field heightMap table<integer, {x: integer, y: integer, height: number}>

    ---@param heightMap HeightMap
    ---@return string serializedHeightMap
    function HeightMapSerializer.serialize(heightMap)
        local serializeTable = { heightMap = {}, sizeX = heightMap.sizeX, sizeY = heightMap.sizeY } ---@type HeightMapSerialized
        local i = 0
        for x, y, height in heightMap:iterate() do
            i = i + 1
            serializeTable.heightMap[i] = { x = x, y = y, height = height }
        end

        return json.encode(serializeTable)
    end

    ---@param heightMapString string
    ---@return InMemoryHeightMap deserializedHeightMap
    function HeightMapSerializer.deserialize(heightMapString)
        local parsedTable = json.decode(heightMapString) ---@type HeightMapSerialized
        local newHeightMap = setmetatable({}, InMemoryHeightMap)

        for _, entry in ipairs(parsedTable.heightMap) do
            if newHeightMap[entry.x] then
                newHeightMap[entry.x][entry.y] = entry.height
            else
                newHeightMap[entry.x] = { [entry.y] = entry.height }
            end
        end

        return newHeightMap
    end
end)
if Debug then Debug.endFile() end
