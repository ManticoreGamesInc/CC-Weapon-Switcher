-- Internal properties
local ROOT = script:GetCustomProperty("Root"):WaitForObject()
local INVENTORY_PANEL = script:GetCustomProperty("InventoryPanel"):WaitForObject()
local ITEMS_PANEL = script:GetCustomProperty("ItemsPanel"):WaitForObject()
local ITEM_SLOT_TEMPLATE = script:GetCustomProperty("ItemSlotTemplate")

-- Exposed properties
local SPACING = ROOT:GetCustomProperty("Spacing")
local INVENTORY_TEMPLATE = ROOT:GetCustomProperty("InventoryTemplate")

local GET = function (obj, value) return obj:GetCustomProperty(value):WaitForObject() end

-- Constant variables
local LOCAL_PLAYER = Game.GetLocalPlayer()
local _, INVENTORY_NAME = CoreString.Split(INVENTORY_TEMPLATE, {delimiters = ":"})

-- Internal variables
local currentInventory = nil

-- Always check if player has the right inventory to display
function Tick()
    CheckForInventory()
end

function RefreshInventoryDisplay()
    for _, value in ipairs(ITEMS_PANEL:GetChildren()) do
        value:Destroy()
    end

    if not currentInventory then return end

    local totalWidth = 0        -- Width to set on the inventory panel

    for i = 1, currentInventory.slotCount do
        -- Spawn item slot template under panel
        local itemPanel = World.SpawnAsset(ITEM_SLOT_TEMPLATE, {parent = ITEMS_PANEL})
        local item = currentInventory:GetItem(i)

        -- Fill in item slot information if there is existing item in the inventory slot
        if item then
            -- Item should have reference to an Icon as property to display its icon
            -- Else show name of the weapon only
            local icon = item:GetCustomProperty("Icon")
            if icon then
                GET(itemPanel, "ItemIcon").visibility = Visibility.INHERIT
                GET(itemPanel, "ItemIcon"):SetImage(icon)
                GET(itemPanel, "ItemName").text = ""
            else
                GET(itemPanel, "ItemIcon").visibility = Visibility.FORCE_OFF
                GET(itemPanel, "ItemName").text = item.name
            end

            -- Get ammo information from weapon item
            local ammo = item:GetCustomProperty("Ammo")
            if ammo then
                GET(itemPanel, "ItemCount").text = tostring(ammo)
            else
                GET(itemPanel, "ItemCount").text = ""
            end
        else 
            GET(itemPanel, "ItemIcon").visibility = Visibility.FORCE_OFF
            GET(itemPanel, "ItemCount").text = ""
            GET(itemPanel, "ItemName").text = ""
        end

        -- Only show slot binding shortcut if player is using keyboard
        if Input.GetCurrentInputType() == InputType.KEYBOARD_AND_MOUSE then
            GET(itemPanel, "ItemBinding").text = tostring(i)
        else
            GET(itemPanel, "ItemBinding").text = ""
        end

        -- Highlight active slot using dynamic property on inventory
        if currentInventory:GetCustomProperty("ActiveSlot") == i then
            GET(itemPanel, "Highlight").visibility = Visibility.INHERIT
        else
            GET(itemPanel, "Highlight").visibility = Visibility.FORCE_OFF
        end

        -- Order the item slot template placement from left to right
        itemPanel.x = (i-1) * itemPanel.width + (i-1) * SPACING
        totalWidth = itemPanel.width + itemPanel.x
    end

    -- Set the total width of inventory panel
    INVENTORY_PANEL.width = totalWidth
end

function CheckForInventory()
    if currentInventory == nil then
        INVENTORY_PANEL.visibility = Visibility.FORCE_OFF
        for _, value in ipairs(LOCAL_PLAYER:GetInventories()) do
            if value.name == INVENTORY_NAME then
                currentInventory = value

                currentInventory.changedEvent:Connect(RefreshInventoryDisplay)
                currentInventory.customPropertyChangedEvent:Connect(RefreshInventoryDisplay)
                currentInventory.itemPropertyChangedEvent:Connect(RefreshInventoryDisplay)

                RefreshInventoryDisplay()

                break
            end
        end
    else
        INVENTORY_PANEL.visibility = Visibility.INHERIT
    end
end

CheckForInventory()