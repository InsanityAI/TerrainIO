if Debug then Debug.beginFile "TerrainIO/Tiles/Tile" end
OnInit.module("TerrainIO/Tiles/Tile", function(require)
    ---@class Tile
    ---@field pathing table<pathingtype, boolean>
    ---@field getTileVariation fun(self: Tile):integer, integer
    ---@field isBlighted fun(self: Tile): boolean

    ---@class SimpleTile: Tile
    ---@field tile integer
    ---@field blighted boolean
    ---@field variation integer
    SimpleTile = {}
    SimpleTile.__index = SimpleTile

    ---@param tile integer
    ---@param variation integer
    ---@param pathing table<pathingtype, boolean>
    ---@return Tile
    function SimpleTile.create(tile, variation, pathing)
        return setmetatable({
            tile = tile,
            variation = variation,
            pathing = pathing
        }, SimpleTile)
    end

    ---@return integer tile, integer variation
    function SimpleTile:getTileVariation()
        return self.tile, self.variation
    end

    function SimpleTile:isBlighted()
        return self.pathing[PATHING_TYPE_BLIGHTPATHING] or false
    end

    ---@alias RandomTileSetup {varStart: integer, varEnd: integer, weight: number, tile: integer}

    ---@class RandomTile: Tile, table
    ---@field n integer
    ---@field [integer] RandomTileSetup
    RandomTile = {}
    RandomTile.__index = RandomTile

    ---@param pathing table<pathingtype, boolean>
    ---@param ... RandomTileSetup
    ---@return RandomTile
    function RandomTile.create(pathing, ...)
        local o = setmetatable(table.pack(...), RandomTile)
        local totalWeight = 0.00
        local cumWeight = 0.00

        for _, randomTile in ipairs(o) do
            totalWeight = totalWeight + randomTile.weight
        end

        for _, randomTile in ipairs(o) do
            cumWeight = cumWeight + randomTile.weight/totalWeight
            randomTile.weight = cumWeight
        end

        o.pathing = pathing
        return o
    end

    ---@return integer tile, integer variation
    function RandomTile:getTileVariation()
        local chance = math.random()
        for _, randomTile in ipairs(self) do
            if chance < randomTile.weight then
                return randomTile.tile, math.random(randomTile.varStart, randomTile.varEnd)
            end
            ---@diagnostic disable-next-line: missing-return
        end
    end
end)
if Debug then Debug.endFile() end
