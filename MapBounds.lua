if Debug then Debug.beginFile "MapBounds" end
OnInit.module("MapBounds", function()
    MapBounds = setmetatable({}, {})
    WorldBounds = setmetatable({}, getmetatable(MapBounds))

    local mt = getmetatable(MapBounds)
    mt.__index = mt

    function mt:getRandomX()
        return GetRandomReal(self.minX, self.maxX)
    end

    function mt:getRandomY()
        return GetRandomReal(self.minY, self.maxY)
    end

    function mt:getRandomXY()
        return self:getRandomX(), self:getRandomY()
    end

    local function GetBoundedValue(bounds, v, minV, maxV, margin)
        margin = margin or 0.00

        if v < (bounds[minV] + margin) then
            return bounds[minV] + margin
        elseif v > (bounds[maxV] - margin) then
            return bounds[maxV] - margin
        end

        return v
    end

    function mt:getBoundedX(x, margin)
        return GetBoundedValue(self, x, "minX", "maxX", margin)
    end

    function mt:getBoundedY(y, margin)
        return GetBoundedValue(self, y, "minY", "maxY", margin)
    end

    function mt:getBoundedXY(x, y, margin)
        return self:getBoundedX(x, margin), self:getBoundedY(y, margin)
    end

    function mt:containsX(x)
        return self:getBoundedX(x) == x
    end

    function mt:containsY(y)
        return self:getBoundedY(y) == y
    end

    function mt:containsXY(x, y)
        return self:containsX(x) and self:containsY(y)
    end

    local function InitData(bounds)
        bounds.region = CreateRegion()
        bounds.minX = GetRectMinX(bounds.rect)
        bounds.minY = GetRectMinY(bounds.rect)
        bounds.maxX = GetRectMaxX(bounds.rect)
        bounds.maxY = GetRectMaxY(bounds.rect)
        bounds.centerX = (bounds.minX + bounds.maxX) / 2.00
        bounds.centerY = (bounds.minY + bounds.maxY) / 2.00
        RegionAddRect(bounds.region, bounds.rect)
    end

    OnInit.global(function()
        MapBounds.rect = bj_mapInitialPlayableArea
        WorldBounds.rect = GetWorldBounds()

        InitData(MapBounds)
        InitData(WorldBounds)
    end)
end)
if Debug then Debug.endFile() end
