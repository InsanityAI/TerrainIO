if Debug then Debug.beginFile "TerrainIO/Widgets/TerrainWidgets" end
OnInit.module("TerrainIO/Widgets/TerrainWidgets", function(require)
    require "TerrainIO/Widgets/TerrainWidget"
    require "SetUtils"

    ---@class TerrainWidgets
    ---@field sizeX integer
    ---@field sizeY integer
    ---@field iterate fun(): fun():TerrainWidget|nil

    ---@class InMemoryTerrainWidgets: TerrainWidgets
    ---@field n integer
    ---@field [integer] TerrainWidget
    InMemoryTerrainWidgets = {}
    InMemoryTerrainWidgets.__index = InMemoryTerrainWidgets

    ---@param terrainWidgets TerrainWidgets
    ---@return InMemoryTerrainWidgets
    function InMemoryTerrainWidgets.create(terrainWidgets)
        local newTerrainWidgets = setmetatable({ sizeX = terrainWidgets.sizeX, sizeY = terrainWidgets.sizeY, n = 0 }, InMemoryTerrainWidgets)

        for terrainWidget in terrainWidgets:iterate() do
            newTerrainWidgets:add(terrainWidget)
        end

        return newTerrainWidgets
    end

    ---@param widget TerrainWidget
    function InMemoryTerrainWidgets:add(widget)
        self.n = self.n + 1
        self[self.n] = widget
    end

    ---@return fun(): TerrainWidget|nil
    function InMemoryTerrainWidgets:iterate()
        local i = 0
        return function()
            i = i + 1
            return self[i]
        end
    end

    ---@class OnDemandTerrainWidgets: TerrainWidgets
    ---@field rect rect
    ---@field resolution TileResolution
    OnDemandTerrainWidgets = {}
    OnDemandTerrainWidgets.__index = OnDemandTerrainWidgets

    ---@param resolution TileResolution
    ---@param rect rect
    ---@return OnDemandTerrainWidgets
    function OnDemandTerrainWidgets.create(rect, resolution)
        local x1 = resolution:getTileCenter(GetRectMinX(rect))
        local x2 = resolution:getTileCenter(GetRectMaxX(rect))
        local y1 = resolution:getTileCenter(GetRectMinY(rect))
        local y2 = resolution:getTileCenter(GetRectMaxY(rect))
        local startX, startY = resolution:getTileIndexes(x1, y1)
        local endX, endY = resolution:getTileIndexes(x2, y2)

        return setmetatable({
            rect = rect,
            resolution = resolution,
            sizeX = math.abs(endX - startX) + 1,
            sizeY = math.abs(endY - startY) + 1,
        }, OnDemandTerrainWidgets)
    end

    ---@return fun():TerrainWidget|nil
    function OnDemandTerrainWidgets:iterate()
        local destructables = SetUtils.getDestructablesInRect(self.rect)
        local items = SetUtils.getItemsInRect(self.rect)
        local units = SetUtils.getUnitsInRect(self.rect)

        local i = 0
        local destructablesDone = destructables.n == 0
        local itemsDone = items.n == 0
        local unitsDone = units.n == 0
        local relativeX = self.resolution:getTileCenter(GetRectMinX(self.rect))
        local relativeY = self.resolution:getTileCenter(GetRectMinY(self.rect))
        return function()
            i = i + 1

            if not destructablesDone then
                local destructable = destructables.orderedKeys[i]
                if destructables.n == i then
                    destructablesDone = true
                    i = 0
                end
                return TerrainDestructable.createFrom(destructable, relativeX, relativeY)
            end

            if not itemsDone then
                local item = items.orderedKeys[i]
                if items.n == i then
                    itemsDone = true
                    i = 0
                end
                return TerrainItem.createFrom(item, relativeX, relativeY)
            end

            if not unitsDone then
                local unit = units.orderedKeys[i]
                if units.n == i then
                    unitsDone = true
                    i = 0
                end
                return TerrainUnit.createFrom(unit, relativeX, relativeY)
            end

            return nil
        end
    end
end)
if Debug then Debug.endFile() end
