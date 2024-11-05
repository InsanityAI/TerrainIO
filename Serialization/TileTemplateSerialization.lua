if Debug then Debug.beginFile "TerrainIO/Serialization/TileTemplateSerialization" end
OnInit.module("TerrainIO/Serialization/TileTemplateSerialization", function(require)
    require "TerrainIO/Tiles/TileTemplate"
    require.optional "json"

    if not json then return end

    ---@class TileTemplateSerializer
    TileTemplateSerializer = {}

    ---@enum TilePathingType
    TilePathingType = {
        ANY = 0,
        WALKABILITY = 1,
        FLYABILITY = 2,
        BUILDABILITY = 3,
        PEONHARVEST = 4,
        BLIGHT = 5,
        FLOAT = 6,
        AMPHIBIOUS = 7
    }

    pathingToEnum = { ---@type table<pathingtype, TilePathingType>
        [PATHING_TYPE_ANY] = TilePathingType.ANY,
        [PATHING_TYPE_WALKABILITY] = TilePathingType.WALKABILITY,
        [PATHING_TYPE_FLYABILITY] = TilePathingType.FLYABILITY,
        [PATHING_TYPE_BUILDABILITY] = TilePathingType.BUILDABILITY,
        [PATHING_TYPE_PEONHARVESTPATHING] = TilePathingType.PEONHARVEST,
        [PATHING_TYPE_BLIGHTPATHING] = TilePathingType.BLIGHT,
        [PATHING_TYPE_FLOATABILITY] = TilePathingType.FLOAT,
        [PATHING_TYPE_AMPHIBIOUSPATHING] = TilePathingType.AMPHIBIOUS
    }

    enumToPathing = {
        [TilePathingType.ANY] = PATHING_TYPE_ANY,
        [TilePathingType.WALKABILITY] = PATHING_TYPE_WALKABILITY,
        [TilePathingType.FLYABILITY] = PATHING_TYPE_FLYABILITY,
        [TilePathingType.BUILDABILITY] = PATHING_TYPE_BUILDABILITY,
        [TilePathingType.PEONHARVEST] = PATHING_TYPE_PEONHARVESTPATHING,
        [TilePathingType.BLIGHT] = PATHING_TYPE_BLIGHTPATHING,
        [TilePathingType.FLOAT] = PATHING_TYPE_FLOATABILITY,
        [TilePathingType.AMPHIBIOUS] = PATHING_TYPE_AMPHIBIOUSPATHING
    }

    ---@alias TilePathing {type: TilePathingType, value: boolean}
    ---@alias Bitmask integer

    ---@class TileSerialized
    ---@field type TileType
    ---@field pathingTrue Bitmask
    ---@field pathingFalse Bitmask
    ---simple
    ---@field tile integer?
    ---@field blighted boolean?
    ---@field variation integer?
    ---random
    ---@field randomTileset RandomTileSetup[]?
    ---@field blightChance number?

    ---@class TileTemplateSerialized
    ---@field sizeX integer
    ---@field sizeY integer
    ---@field tiles TileSerialized[]

    ---@param pathing table<pathingtype, boolean>
    ---@return integer pathingTrueBitmap, integer pathingFalseBitmap
    local function serializePathing(pathing)
        local result = {} ---@type boolean[]
        for path, value in pairs(pathing) do
            result[pathingToEnum[path]] = value
        end

        local pathingTrue = 0
        local pathingFalse = 0

        for index, value in pairs(result) do
            if value then
                pathingTrue = pathingTrue + 2 ^ index
            else
                pathingFalse = pathingFalse + 2 ^ index
            end
        end

        return pathingTrue, pathingFalse
    end

    ---@param pathingTrueBitmap integer
    ---@param pathingFalseBitmap integer
    ---@return table<pathingtype, boolean> pathing
    local function deserializePathing(pathingTrueBitmap, pathingFalseBitmap)
        local result = {} ---@type table<pathingtype, boolean>
        for i = 7, 0, -1 do
            if math.modf(pathingTrueBitmap / 2 ^ i) then
                result[enumToPathing[i]] = true
            elseif math.modf(pathingFalseBitmap / 2 ^ i) then
                result[enumToPathing[i]] = false
            end

            pathingFalseBitmap = math.fmod(pathingFalseBitmap, 2 ^ i)
            pathingFalseBitmap = math.fmod(pathingFalseBitmap, 2 ^ i)
        end

        return result
    end

    ---@param tile Tile
    ---@return TileSerialized
    local function serializeTile(tile)
        local pathingTrue, pathingFalse = serializePathing(tile.pathing)
        local o = { ---@type TileSerialized
            type = tile.type,
            pathingTrue = pathingTrue,
            pathingFalse = pathingFalse
        }

        if tile.type == TileType.SIMPLE then
            o.tile = (tile --[[@as SimpleTile]]).tile
            o.blighted = (tile --[[@as SimpleTile]]).blighted
            o.variation = (tile --[[@as SimpleTile]]).variation
        elseif tile.type == TileType.RANDOM then
            o.randomTileset = {}
            for index, value in ipairs(tile --[[@as RandomTile]]) do
                o.randomTileset[index] = value
            end
            o.blightChance = (tile --[[@as RandomTile]]).blightChance
        end

        return o
    end

    ---@param tile TileSerialized
    ---@return Tile
    local function deserializeTile(tile)
        local pathing = deserializePathing(tile.pathingTrue, tile.pathingFalse)
        local o ---@type Tile
        if tile.type == TileType.SIMPLE then
            o = SimpleTile.create(tile.tile, tile.variation, pathing, tile.blighted)
        elseif tile.type == TileType.RANDOM then
            o = RandomTile.create(pathing, table.unpack(tile.randomTileset))
        end

        return o
    end

    ---@param tileTemplate TileTemplate
    ---@return string serializedTileTemplate
    function TileTemplateSerializer.Serialize(tileTemplate)
        local sizeX, sizeY = tileTemplate.sizeX, tileTemplate.sizeY
        local serializeTable = { tiles = {}, sizeX = sizeX, sizeY = sizeY } ---@type TileTemplateSerialized

        for x, y, tile in tileTemplate:iterate() do
            serializeTable.tiles[sizeX * y + x + 1] = serializeTile(tile)
        end

        ser = serializeTable
        return json.encode(serializeTable)
    end

    ---@param heightMapString string
    ---@return InMemoryTileTemplate deserializedTileTemplate
    function TileTemplateSerializer.Deserialize(heightMapString)
        local parsedTable = json.decode(heightMapString) ---@type TileTemplateSerialized
        local sizeX, sizeY = parsedTable.sizeX, parsedTable.sizeY
        local tileTemplate = setmetatable({ sizeX = sizeX, sizeY = sizeY }, InMemoryTileTemplate)

        for index, tile in ipairs(parsedTable.tiles) do
            local x, y = math.fmod(index - 1, sizeX), math.modf((index - 1)/ sizeX)
            if tileTemplate[x] then
                tileTemplate[x][y] = deserializeTile(tile)
            else
                tileTemplate[x] = { [y] = deserializeTile(tile) }
            end
        end

        return tileTemplate
    end
end)
if Debug then Debug.endFile() end
