if Debug then Debug.beginFile "TerrainIO.Tile" end
OnInit.module("TerrainIO.Tile", function(require)
    ---@class Tile
    ---@field tile integer
    ---@field variation integer
    ---@field pathing table<pathingtype, boolean>
    Tile = {}
    Tile.__index = Tile

    ---@param tile integer
    ---@param variation integer
    ---@param pathing table<pathingtype, boolean>
    ---@return Tile
    function Tile.create(tile, variation, pathing)
        return setmetatable({
            tile = tile,
            variation = variation,
            pathing = pathing
        }, Tile)
    end
end)
if Debug then Debug.endFile() end
