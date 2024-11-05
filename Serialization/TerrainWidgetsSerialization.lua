if Debug then Debug.beginFile "TerrainIO/Serialization/TerrainWidgetsSerialization" end
OnInit.module("TerrainIO/Serialization/TerrainWidgetsSerialization", function(require)
    require "TerrainIO/Widgets/TerrainWidgets"
    require.optional "json"

    ---@class TerrainWidgetsSerialization
    TerrainWidgetsSerialization = {}

    ---@class TerrainWidgetSerialized
    ---@field type TerrainWidgetType
    ---@field objectId integer
    ---@field x number
    ---@field y number
    ---@field z number?
    ---@field facing number
    ---@field life number
    ---destructable
    ---@field scale number?
    ---@field variation number?
    ---item
    ---@field pawnable boolean?
    ---@field visible boolean?
    ---@field invulnerable boolean?
    ---@field charges integer?
    ---unit
    ---@field ownerId integer?

    ---@class TerrainWidgetsSerialized
    ---@field sizeX integer
    ---@field sizeY integer
    ---@field widgets TerrainWidgetSerialized[]

    ---@param terrainWidget TerrainWidget
    ---@return TerrainWidgetSerialized
    local function serializeWidget(terrainWidget)
        local o = { ---@type TerrainWidgetSerialized
            type = terrainWidget:type(),
            objectId = terrainWidget.objectId,
            x = terrainWidget.x,
            y = terrainWidget.y,
            z = terrainWidget.z,
            facing = terrainWidget.facing,
            life = terrainWidget.life,
        }

        if o.type == TerrainWidgetType.DESTRUCTABLE then
            o.scale = (terrainWidget --[[@as TerrainDestructable]]).scale
            o.variation = (terrainWidget --[[@as TerrainDestructable]]).variation
        elseif o.type == TerrainWidgetType.ITEM then
            o.pawnable = (terrainWidget --[[@as TerrainItem]]).pawnable
            o.visible = (terrainWidget --[[@as TerrainItem]]).visible
            o.invulnerable = (terrainWidget --[[@as TerrainItem]]).invulnerable
            o.charges = (terrainWidget --[[@as TerrainItem]]).charges
        elseif o.type == TerrainWidgetType.UNIT then
            o.ownerId = (terrainWidget --[[@as TerrainUnit]]).ownerId
        end

        return o
    end

    ---@param s TerrainWidgetSerialized
    ---@return TerrainWidget
    local function deserializeWidget(s)
        local o ---@type TerrainWidget

        if s.type == TerrainWidgetType.DESTRUCTABLE then
            o = TerrainDestructable.create(s.objectId, s.x, s.y, s.z, s.facing, s.life, s.scale, s.variation)
        elseif s.type == TerrainWidgetType.ITEM then
            o = TerrainItem.create(s.objectId, s.x, s.y, s.life, s.pawnable, s.visible, s.invulnerable, s.charges)
        elseif s.type == TerrainWidgetType.UNIT then
            o = TerrainUnit.create(s.objectId, s.x, s.y, s.z, s.facing, s.life, s.ownerId)
        end

        return o
    end

    ---@param terrainWidgets TerrainWidgets
    ---@return string serializedTerrainWidgets
    function TerrainWidgetsSerialization.Serialize(terrainWidgets)
        local serializeTable = {sizeX = terrainWidgets.sizeX, sizeY = terrainWidgets.sizeY, widgets = {}} ---@type TerrainWidgetsSerialized
        local i = 0
        for terrainWidget in terrainWidgets:iterate() do
            i = i + 1
            serializeTable.widgets[i] = serializeWidget(terrainWidget)
        end

        return json.encode(serializeTable)
    end

    ---@param terrainWidgetsString string
    ---@return InMemoryTerrainWidgets deserializedHeightMap
    function TerrainWidgetsSerialization.Deserialize(terrainWidgetsString)
        local parsedTable = json.decode(terrainWidgetsString) ---@type TerrainWidgetsSerialized
        local newTerrainWidgets = setmetatable({ sizeX = parsedTable.sizeX, sizeY = parsedTable.sizeY }, InMemoryTerrainWidgets)
        local i = 0
        for _, entry in ipairs(parsedTable.widgets) do
            i = i + 1
            newTerrainWidgets[i] = deserializeWidget(entry)
        end

        return newTerrainWidgets
    end
end)
if Debug then Debug.endFile() end
