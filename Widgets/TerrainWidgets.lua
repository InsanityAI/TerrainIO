if Debug then Debug.beginFile "TerrainIO.Widgets.TerrainWidgets" end
OnInit.module("TerrainIO.Widgets.TerrainWidgets", function(require)
    require "TerrainIO.Widgets.TerrainWidgets"
    require "SetUtils"

    ---@class TerrainWidgets
    ---@field iterate fun(): fun():TerrainWidget|nil

    ---@class InMemoryTerrainWidgets
    ---@field n integer
    ---@field [integer] TerrainWidget
    InMemoryTerrainWidgets = {}
    InMemoryTerrainWidgets.__index = InMemoryTerrainWidgets

    ---@return InMemoryTerrainWidgets
    function InMemoryTerrainWidgets.create()
        return setmetatable({}, InMemoryTerrainWidgets)
    end

    ---@param widget TerrainWidget
    function InMemoryTerrainWidgets:add(widget)
        self[self.n] = widget
        self.n = self.n + 1
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
    ---@field units Set
    ---@field destructables Set
    ---@field items Set
    OnDemandTerrainWidgets = {}
    OnDemandTerrainWidgets.__index = OnDemandTerrainWidgets

    ---@param rect rect
    ---@return OnDemandTerrainWidgets
    function OnDemandTerrainWidgets.create(rect)
        return setmetatable({
            rect = rect,
            units = Set.create(),
            destructables = Set.create(),
            items = Set.create()
    }, OnDemandTerrainWidgets)
    end

    ---@return fun():TerrainWidget|nil
    function OnDemandTerrainWidgets:iterate()
        SetUtils.getDestructablesInRect(self.rect, self.units)
        SetUtils.getItemsInRect(self.rect, self.destructables)
        SetUtils.getUnitsInRect(self.rect, self.items)

        local i = 0
        local destructablesDone = self.destructables.n == 0
        local itemsDone = self.items.n == 0
        local unitsDone = self.units.n == 0
        return function()
            i = i + 1

            if not destructablesDone then
                local destructable = self.destructables.orderedKeys[i]
                if self.destructables.n == i then
                    destructablesDone = true
                    i = 0
                end
                return TerrainDestructable.createFrom(destructable)
            end

            if not itemsDone then
                local item = self.items.orderedKeys[i]
                if self.items.n == i then
                    itemsDone = true
                    i = 0
                end
                return TerrainItem.createFrom(item)
            end

            if not unitsDone then
                local unit = self.units.orderedKeys[i]
                if self.units.n == i then
                    unitsDone = true
                    i = 0
                end
                return TerrainUnit.createFrom(unit)
            end

            return nil
        end
    end
end)
if Debug then Debug.endFile() end
