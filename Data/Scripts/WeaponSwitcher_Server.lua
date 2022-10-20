local ROOT = script:GetCustomProperty("Root"):WaitForObject()

local INVENTORY_TEMPLATE = ROOT:GetCustomProperty("InventoryTemplate")
local STARTING_INVENTORY = require(ROOT:GetCustomProperty("StartingInventoryTable"))

local inventories = {}

---Updates weapon item ammo property
local function UpdateWeaponAmmo(weapon)
    if not Object.IsValid(weapon) and not Object.IsValid(weapon.owner) then return end

    local inventory = inventories[weapon.owner].inventory
    local activeSlot = inventories[weapon.owner].activeSlot

    inventory:GetItem(activeSlot):SetCustomProperty("Ammo", weapon.currentAmmo)
end

---Sets up the new weapon on the player
local function SetupNewWeapon(player, inventory, slot)
    if not inventory:GetItem(slot) then
        return nil
    end

	local item = inventory:GetItem(slot)
    local weapon = World.SpawnAsset(item.itemTemplateId)
    weapon:Equip(player)

	if item:GetCustomProperty("Ammo") then
	    -- Connect the weapon events to update Ammo property
	    if not weapon.isHitscan and weapon.projectileSpawnedEvent then
	    	weapon.projectileSpawnedEvent:Connect(UpdateWeaponAmmo)
	    else
		    local shootAbility = weapon:GetAbilities()[1]
		    if shootAbility then
		        shootAbility.executeEvent:Connect(function(ability)
		        	Task.Wait()
		            UpdateWeaponAmmo(ability:FindAncestorByType('Weapon'))
		        end)
		    end    	
	    end
	    local reloadAbility = weapon:GetAbilities()[2]
	    if reloadAbility then
	        reloadAbility.executeEvent:Connect(function(ability)
	        	Task.Wait()
	            UpdateWeaponAmmo(ability:FindAncestorByType('Weapon'))
	        end)
	    end
	
	    -- Setup ammo for current weapon
	    if inventories[player].ammo then
	        weapon.currentAmmo = inventory:GetItem(slot):GetCustomProperty("Ammo")
	    else
	        inventory:GetItem(slot):SetCustomProperty("Ammo", weapon.currentAmmo)
	        inventories[player].ammo = true
	    end
	end
    return weapon
end

---Checks the inventory slot item and spawns a new weapon onto the player
local function AssignSlotWeapon(player, slot)
    local inventory = inventories[player].inventory

    if not slot or slot > inventory.slotCount then return end

    -- Remove any existing weapons tied to the slot
    local weapon = inventories[player].weapon
    if Object.IsValid(weapon) then
        weapon:Destroy()
    end

    local newWeapon = SetupNewWeapon(player, inventory, slot)
    -- If there is no new weapon, then reset player stance
    if not newWeapon then
        player.animationStance = "unarmed_stance"
    end

    -- Cache the weapon and the active slot
    inventories[player].weapon = newWeapon
    inventories[player].activeSlot = slot
    inventory:SetCustomProperty("ActiveSlot", slot)
end

---Swaps active slot and changes weapon if the slot has the weapon
local function ChangeWeapon(player, isNext)
    local slotCount = inventories[player].inventory.slotCount
    local currentSlot = inventories[player].activeSlot
    if isNext then
        currentSlot = currentSlot + 1
        if currentSlot > slotCount then
            currentSlot = 1
        end
    else
        currentSlot = currentSlot - 1
        if currentSlot < 1 then
            currentSlot = slotCount
        end
    end
    AssignSlotWeapon(player, currentSlot)
end

---Add new weapon item to inventory
local function AddWeapon(weapon, item)
    local player = weapon.owner
    if not inventories[player] then return end

    local inventory = inventories[player].inventory
    local slot = item:GetCustomProperty("Slot")

    local itemAssetId = item.itemAssetId

    weapon:Destroy()
	
    if slot and slot > 0 then
        -- Note: If needed, write your own drop weapon solution here.
        --       For simplicity, this inventory only removes weapon.
        local currentItem = inventory:GetItem(slot)
        if currentItem then            
            inventory:RemoveItem(currentItem.itemAssetId)
        end

        -- Add new weapon to the slot
        inventory:AddItem(itemAssetId)
        AssignSlotWeapon(player, slot)

    elseif (slot and slot > 0) or slot == nil then
        -- If there are no slot properties then it will try to add to inventory if there are still slots
        if inventory:CanAddItem(itemAssetId) then
            inventory:AddItem(itemAssetId)
            AssignSlotWeapon(player, slot)
        end
    end
end

local function OnActionPressed(player, action, value)
    if action == "Next Weapon" then
        ChangeWeapon(player, true)
    end
    if action == "Previous Weapon" then
        ChangeWeapon(player, false)
    end

    --Note: Add more weapon slot bindings here if you increase inventory size
    if action == "Weapon Slot 1" then
        AssignSlotWeapon(player, 1)
    end
    if action == "Weapon Slot 2" then
        AssignSlotWeapon(player, 2)
    end
    if action == "Weapon Slot 3" then
        AssignSlotWeapon(player, 3)
    end
    if action == "Weapon Slot 4" then
        AssignSlotWeapon(player, 4)
    end
    if action == "Weapon Slot 5" then
        AssignSlotWeapon(player, 5)
    end
end

---Spawns inventory template and assigns it to player
local function OnPlayerJoined(player)
    local inventory = World.SpawnAsset(INVENTORY_TEMPLATE)
    inventory:Assign(player)

    -- Cache the players inventory info
    inventories[player] = {
        inventory = inventory,
        activeSlot = 1,
        weapon = nil
    }

    -- Add the starting weapons of Items type
    for _, value in ipairs(STARTING_INVENTORY) do
        inventory:AddItem(value.Item)
    end

    -- Start with weapon slot 1
    AssignSlotWeapon(player, 1)
end

---When player leaves, remove all weapons information
local function OnPlayerLeft(player)
    local weapon = inventories[player].weapon
    if Object.IsValid(weapon) then
        weapon:Destroy()
    end
    if inventories[player].inventory then
        inventories[player].inventory:Destroy()
    end

    inventories[player] = nil
end

-- Initialize event connection
Input.actionPressedEvent:Connect(OnActionPressed)
Game.playerJoinedEvent:Connect(OnPlayerJoined)
Game.playerLeftEvent:Connect(OnPlayerLeft)

Events.Connect("AddInventoryWeapon", AddWeapon)