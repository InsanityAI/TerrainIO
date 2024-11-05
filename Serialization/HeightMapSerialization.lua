if Debug then Debug.beginFile "TerrainIO/Serialization/HeightMapSerialization" end
OnInit.module("TerrainIO/Serialization/HeightMapSerialization", function(require)
    require "TerrainIO/Height/HeightMap"
    require.optional "json"

    if not json then return end

    ---@class HeightMapSerializer
    HeightMapSerializer = {}

    ---@class HeightMapSerialized
    ---@field sizeX integer
    ---@field sizeY integer
    ---@field heightMap number[]

    ---@param heightMap HeightMap
    ---@return string serializedHeightMap
    function HeightMapSerializer.Serialize(heightMap)
        local sizeX, sizeY = heightMap.sizeX, heightMap.sizeY
        local serializeTable = { heightMap = {}, sizeX = sizeX, sizeY = sizeY } ---@type HeightMapSerialized
        for x, y, height in heightMap:iterate() do
            serializeTable.heightMap[sizeX * y + x + 1] = height
        end

        return json.encode(serializeTable)
    end

    ---@param heightMapString string
    ---@return InMemoryHeightMap deserializedHeightMap
    function HeightMapSerializer.Deserialize(heightMapString)
        local parsedTable = json.decode(heightMapString) ---@type HeightMapSerialized
        local sizeX, sizeY = parsedTable.sizeX, parsedTable.sizeY
        local newHeightMap = setmetatable({ sizeX = sizeX, sizeY = sizeY }, InMemoryHeightMap)

        for index, height in ipairs(parsedTable.heightMap) do
            local x, y = math.fmod(index - 1, sizeX), math.modf((index - 1) / sizeX)
            if newHeightMap[x] then
                newHeightMap[x][y] = height
            else
                newHeightMap[x] = { [y] = height }
            end
        end

        return newHeightMap
    end
end)
if Debug then Debug.endFile() end
