if Debug then Debug.beginFile "TerrainIO/Widgets/TerrainWidget" end
OnInit.module("TerrainIO/Widgets/TerrainWidget", function(require)
    ---@enum TerrainWidgetType
    TerrainWidgetType = {
        DESTRUCTABLE = 1,
        ITEM = 2,
        UNIT = 3,
    }

    ---@class TerrainWidget
    ---@field objectId integer
    ---@field x number
    ---@field y number
    ---@field z number?
    ---@field facing number
    ---@field life number
    ---@field type fun(self:TerrainWidget):TerrainWidgetType
    ---@field spawnAt fun(self:TerrainWidget, x: number, y: number, z:number?): widget

    ---@class TerrainDestructable: TerrainWidget
    ---@field scale number?
    ---@field variation integer?
    TerrainDestructable = {}
    TerrainDestructable.__index = TerrainDestructable

    ---@param objectId integer
    ---@param x number
    ---@param y number
    ---@param z number
    ---@param facing number
    ---@param life number
    ---@param scale number
    ---@param variation integer
    ---@return TerrainDestructable
    function TerrainDestructable.create(objectId, x, y, z, facing, life, scale, variation)
        return setmetatable({
            objectId = objectId,
            x = x,
            y = y,
            z = z,
            facing = facing,
            life = life,
            scale = scale,
            variation = variation
        }, TerrainDestructable)
    end

    ---@param destructable destructable
    ---@param relativeX number
    ---@param relativeY number
    ---@return TerrainDestructable
    function TerrainDestructable.createFrom(destructable, relativeX, relativeY)
        assert(destructable ~= nil, "Destructable cannot be nil!")
        return setmetatable({
            objectId = GetDestructableTypeId(destructable),
            x = GetDestructableX(destructable) - relativeX,
            y = GetDestructableY(destructable) - relativeY,
            -- how to get Z?
            facing = bj_UNIT_FACING, -- how to get facing?
            life = GetDestructableLife(destructable)
            -- how to get scale?
            -- how to get variation?
        }, TerrainDestructable)
    end

    ---@return TerrainWidgetType
    function TerrainDestructable:type()
        return TerrainWidgetType.DESTRUCTABLE
    end

    ---@param x number
    ---@param y number
    ---@param z number
    ---@return destructable
    function TerrainDestructable:spawnAt(x, y, z)
        local isDead = self.life <= 0
        local destructable ---@type destructable

        if z or self.z then
            if isDead then
                destructable = CreateDeadDestructableZ(self.objectId, self.x + x, self.y + y, (self.z or 0) + (z or 0),
                    self.facing, self.scale or 1.00, self.variation or 1)
            else
                destructable = CreateDestructableZ(self.objectId, self.x + x, self.y + y, (self.z or 0) + (z or 0),
                    self.facing, self.scale or 1.00, self.variation or 1)
            end
        else
            if isDead then
                destructable = CreateDeadDestructable(self.objectId, self.x + x, self.y + y, self.facing,
                    self.scale or 1.00, self.variation or 1)
            else
                destructable = CreateDestructable(self.objectId, self.x + x, self.y + y, self.facing, self.scale or 1.00,
                    self.variation or 1)
            end
        end

        if not isDead then
            SetDestructableLife(destructable, self.life)
        end

        return destructable
    end

    ---@class TerrainItem: TerrainWidget
    ---@field pawnable boolean?
    ---@field visible boolean?
    ---@field invulnerable boolean?
    ---@field charges integer?
    TerrainItem = {}
    TerrainItem.__index = TerrainItem

    ---@param objectId integer
    ---@param x number
    ---@param y number
    ---@param life number
    ---@param pawnable boolean?
    ---@param visible boolean?
    ---@param invulnerable boolean?
    ---@param charges integer?
    ---@return TerrainItem
    function TerrainItem.create(objectId, x, y, life, pawnable, visible, invulnerable, charges)
        return setmetatable({
            objectId = objectId,
            x = x,
            y = y,
            life = life,
            pawnable = pawnable,
            visible = visible,
            invulnerable = invulnerable,
            charges = charges
        }, TerrainItem)
    end

    ---@param item item
    ---@param relativeX number
    ---@param relativeY number
    ---@return TerrainItem
    function TerrainItem.createFrom(item, relativeX, relativeY)
        return setmetatable({
            objectId = GetItemTypeId(item),
            x = GetItemX(item) - relativeX,
            y = GetItemY(item) - relativeY,
            life = GetWidgetLife(item),
            pawnable = IsItemPawnable(item),
            visible = IsItemVisible(item),
            invulnerable = IsItemInvulnerable(item),
            charges = GetItemCharges(item)
        }, TerrainItem)
    end

    ---@return TerrainWidgetType
    function TerrainItem:type()
        return TerrainWidgetType.ITEM
    end

    ---@param x number
    ---@param y number
    ---@return item
    function TerrainItem:spawnAt(x, y)
        local item = CreateItem(self.objectId, x + self.x, y + self.y)

        if self.pawnable ~= nil then
            SetItemPawnable(item, self.pawnable)
        end

        if self.visible ~= nil then
            SetItemVisible(item, self.visible)
        end

        if self.invulnerable ~= nil then
            SetItemInvulnerable(item, self.invulnerable)
        end

        if self.charges ~= nil then
            SetItemCharges(item, self.charges)
        end

        SetWidgetLife(item, self.life)

        return item
    end

    --- Unit is too complex, will only copy simple stuff
    ---@class TerrainUnit: TerrainWidget
    ---@field ownerId integer
    TerrainUnit = {}
    TerrainUnit.__index = TerrainUnit

    ---@param objectId integer
    ---@param x number
    ---@param y number
    ---@param z number?
    ---@param facing number
    ---@param life number
    ---@param ownerId integer
    function TerrainUnit.create(objectId, x, y, z, facing, life, ownerId)
        return setmetatable({
            objectId = objectId,
            x = x,
            y = y,
            z = z,
            facing = facing,
            life = life,
            ownerId = ownerId
        }, TerrainUnit)
    end

    ---@param unit unit
    ---@param relativeX number
    ---@param relativeY number
    ---@return TerrainUnit
    function TerrainUnit.createFrom(unit, relativeX, relativeY)
        return setmetatable({
            objectId = GetUnitTypeId(unit),
            x = GetUnitX(unit) - relativeX,
            y = GetUnitY(unit) - relativeY,
            z = GetUnitFlyHeight(unit),
            facing = GetUnitFacing(unit),
            life = GetUnitState(unit, UNIT_STATE_LIFE),
            ownerId = GetPlayerId(GetOwningPlayer(unit))
        }, TerrainUnit)
    end

    ---@return TerrainWidgetType
    function TerrainUnit:type()
        return TerrainWidgetType.UNIT
    end

    ---@param x number
    ---@param y number
    ---@param z number?
    ---@return unit
    function TerrainUnit:spawnAt(x, y, z)
        local unit = CreateUnit(Player(self.ownerId), self.objectId, self.x + x, self.y + y, self.facing)

        if self.z or z then --may require AutoFly
            SetUnitFlyHeight(unit, (self.z or 0) + (z or 0), 0)
        end

        SetUnitState(unit, UNIT_STATE_LIFE, self.life)

        return unit
    end
end)
if Debug then Debug.endFile() end
