if Debug then Debug.beginFile "TerrainIO.Tiles.Tile" end
OnInit.module("TerrainIO.Tiles.Tile", function(require)
    ---@class Tile
    ---@field pathing table<pathingtype, boolean>
    ---@field getTileVariation fun():integer, integer

    ---@class SimpleTile: Tile
    ---@field tile integer
    ---@field variation integer
    SimpleTile = {}
    SimpleTile.__index = SimpleTile

    ---@param tile integer
    ---@param variation integer
    ---@param pathing table<pathingtype, boolean>
    ---@param height number
    ---@return Tile
    function SimpleTile.create(tile, variation, pathing, height)
        return setmetatable({
            tile = tile,
            variation = variation,
            pathing = pathing,
            height = height
        }, SimpleTile)
    end

    ---@return integer tile, integer variation
    function SimpleTile:getTileVariation()
        return self.tile, self.variation
    end

    ---@alias RandomTileSetup {varStart: integer, varEnd: integer, weight: number, tile: integer}

    ---@class RandomTile: Tile, table
    ---@field n integer
    ---@field [integer] RandomTileSetup
    RandomTile = {}
    RandomTile.__index = RandomTile

    ---@param pathing table<pathingtype, boolean>
    ---@param height number
    ---@param ... RandomTileSetup
    ---@return RandomTile
    function RandomTile.create(pathing, height, ...)
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