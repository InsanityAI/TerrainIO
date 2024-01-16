if Debug then Debug.beginFile "TileDefinition" end
OnInit.module("TileDefinition", function()
    Require.strict "MapBounds" --https://www.hiveworkshop.com/threads/mapbounds.330669/

    --[[TileDefinition v1.2b    By IcemanBo - Credits to WaterKnight (Converted to Lua by Insanity_AI and Wrda)



**                          Information
**                         _____________
**
**  TileDefinition provides an API to give information about a terrain tile.
**
**                             API
**                           _______
**
**      function GetTileCenterCoordinate takes real a returns real
**          Returns the coordinate for the center of the tile.
**          Works for x and y coordinates.
**
**
**      function GetTileMax takes real a returns real
**          Returns the max value, that is still in same terrain tile.
**          Works for x and y coordinates.
**
**
**      function GetTileMin takes real a returns real
**          Returns the min value, that is still in same terrain tile.
**          Works for x and y coordinates.
**
**
**      function AreCoordinatesInSameTile takes real a, real b returns boolean
**          Checks if two coordinates share the same terrain tile.
**
**          Attention: Only makes sense if both coordinates are of same type. Or x- or y coordinates.
**                     May bring wrong result, if you compare x with y coordinates.
**
**
**      function AreLocationsInSameTile takes real x1, real y1, real x2, real y2 returns boolean
**          Checks if two points share the same terrain tile.
**
**
**      funtion GetTileId takes real x, real y returns integer
**          Returns an unique index for tile of given coordinates.
**          Will return "-1" if it's invalid.
**
**      function GetTileCenterXById takes integer id returns real
**
**      function GetTileCenterYById takes integer id returns real
**
**********************************************************************************************************]]

    local TILE_SIZE = 64
    local TILE_SIZE_HALF = TILE_SIZE / 2

    function GetTileSize()
        return TILE_SIZE
    end

    ---@class Tile
    ---@field id integer
    ---@field x number
    ---@field y number
    Tile = {
        __eq = function(o1, o2)
            return o1.id == o2.id
        end
    }
    Tile.__index = Tile

    local WorldTilesX, WorldTilesY;
    local tileReferences = {}; ---@type table<integer, Tile>

    -- Returns the coordinates for the center of the tile.
    -- Works for x and y coordinates.
    ---@param a number
    ---@return integer tileCoordinate
    function GetTileCenterCoordinate(a)
        if (a >= 0.) then
            return R2I((a / TILE_SIZE) + .5) * TILE_SIZE
        else
            return R2I((a / TILE_SIZE) - .5) * TILE_SIZE
        end
    end

    -- Checks if two coordinates share the same terrain tile.
    -- Attention: Only makes sense if both coordinates are of same type. Or x or y coordinates. May bring wrong result, if you compare x with y coordinates.
    ---@param a number
    ---@param b number
    ---@return boolean
    function AreCoordinatesInSameTile(a, b)
        return GetTileCenterCoordinate(a) == GetTileCenterCoordinate(b)
    end

    -- Checks if two points share the same terrain tile.
    ---@param x1 number
    ---@param y1 number
    ---@param x2 number
    ---@param y2 number
    ---@return boolean
    function AreLocationsInSameTile(x1, y1, x2, y2)
        return AreCoordinatesInSameTile(x1, x2) and AreCoordinatesInSameTile(y1, y2)
    end

    -- Returns the min value, that is still in same terrain tile.
    -- Works for x and y coordinates.
    ---@param a number
    ---@return number
    function GetTileMin(a)
        return GetTileCenterCoordinate(a) - TILE_SIZE_HALF
    end

    -- Returns the max value, that is still in same terrain tile.
    -- Works for x and y coordinates.
    ---@param a number
    ---@return number
    function GetTileMax(a)
        return GetTileCenterCoordinate(a) + TILE_SIZE_HALF
    end

    -- Returns the a + TILE_SIZE coordinate
    -- Works for x and y coordinates.
    ---@param a number
    ---@return number
    function GetNextTileCoordinate(a)
        return a + TILE_SIZE
    end

    -- Returns the a - TILE_SIZE coordinate
    -- Works for x and y coordinates.
    ---@param a number
    ---@return number
    function GetPreviousTileCoordinate(a)
        return a - TILE_SIZE
    end

    -- Returns an unique index for tile of given coordinates. Will return "-1" if it's invalid.
    ---@param x number
    ---@param y number
    ---@return integer tileId
    function GetTileId(x, y)
        local xI = R2I(x - WorldBounds.minX + TILE_SIZE_HALF) / TILE_SIZE
        local yI = R2I(y - WorldBounds.minY + TILE_SIZE_HALF) / TILE_SIZE

        if ((xI < 0) or (xI >= WorldTilesX) or (yI < 0) or (yI >= WorldTilesY)) then
            return -1
        end

        return (yI * WorldTilesX + xI)
    end

    ---@param x number
    ---@param y number
    ---@return Tile?
    function GetTile(x, y)
        if x < WorldBounds.minX or x > WorldBounds.maxX then return nil end
        if y < WorldBounds.minY or y > WorldBounds.maxY then return nil end
        x = GetTileCenterCoordinate(x)
        y = GetTileCenterCoordinate(y)
        local tileId = GetTileId(x, y);
        local tile = tileReferences[tileId]
        if tile == nil then
            tile = setmetatable({
                id = tileId,
                x = x,
                y = y
            }, Tile)
            tileReferences[tileId] = tile
        end
        return tile
    end

    ---@param id integer
    ---@return number
    function GetTileCenterXById(id)
        if ((id < 0) or (id >= WorldTilesX * WorldTilesY)) then
            return 0.
        end

        return (WorldBounds.minX + ModuloInteger(id, WorldTilesX) * TILE_SIZE)
    end

    ---@param id integer
    ---@return number
    function GetTileCenterYById(id)
        if ((id < 0) or (id >= WorldTilesX * WorldTilesY)) then
            return 0.
        end

        return (WorldBounds.minY + id / WorldTilesX * TILE_SIZE)
    end

    OnInit.global(function()
        Require.strict "MapBounds"
        WorldTilesX = R2I(WorldBounds.maxX - WorldBounds.minX) / TILE_SIZE + 1
        WorldTilesY = R2I(WorldBounds.maxY - WorldBounds.minY) / TILE_SIZE + 1
    end)
end)
if Debug then Debug.endFile() end
