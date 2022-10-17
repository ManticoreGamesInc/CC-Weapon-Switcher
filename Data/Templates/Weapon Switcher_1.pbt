Assets {
  Id: 623178168257474299
  Name: "Weapon Switcher"
  PlatformAssetType: 5
  TemplateAsset {
    ObjectBlock {
      RootId: 339683438031138921
      Objects {
        Id: 339683438031138921
        Name: "TemplateBundleDummy"
        Transform {
          Location {
          }
          Rotation {
          }
          Scale {
            X: 1
            Y: 1
            Z: 1
          }
        }
        Folder {
          BundleDummy {
            ReferencedAssets {
              Id: 5873401194950168052
            }
            ReferencedAssets {
              Id: 11840076694154351930
            }
            ReferencedAssets {
              Id: 13526530623171806134
            }
            ReferencedAssets {
              Id: 736360303936294653
            }
            ReferencedAssets {
              Id: 13686915018416948746
            }
            ReferencedAssets {
              Id: 7436194052653179954
            }
            ReferencedAssets {
              Id: 17438692118890248845
            }
            ReferencedAssets {
              Id: 5441335048714837920
            }
            ReferencedAssets {
              Id: 2185484604682618257
            }
            ReferencedAssets {
              Id: 16788617737712185088
            }
            ReferencedAssets {
              Id: 9791663148394559353
            }
            ReferencedAssets {
              Id: 16660876440369051409
            }
            ReferencedAssets {
              Id: 6460910652340078702
            }
            ReferencedAssets {
              Id: 1108689888157251110
            }
            ReferencedAssets {
              Id: 9270236968685246877
            }
            ReferencedAssets {
              Id: 3402288870162705701
            }
            ReferencedAssets {
              Id: 1735943184043934463
            }
            ReferencedAssets {
              Id: 17085390824819963184
            }
            ReferencedAssets {
              Id: 16352106922200354611
            }
            ReferencedAssets {
              Id: 4087554182419681934
            }
            ReferencedAssets {
              Id: 14500583891837168340
            }
            ReferencedAssets {
              Id: 16052791129926391597
            }
            ReferencedAssets {
              Id: 3798900806209631770
            }
            ReferencedAssets {
              Id: 17504818798877675931
            }
            ReferencedAssets {
              Id: 1984342560853724922
            }
            ReferencedAssets {
              Id: 8814398338958840148
            }
            ReferencedAssets {
              Id: 4195502608665642632
            }
          }
        }
      }
    }
    Assets {
      Id: 4195502608665642632
      Name: "WeaponSwitcher_Server"
      PlatformAssetType: 3
      TextAsset {
        Text: "local ROOT = script:GetCustomProperty(\"Root\"):WaitForObject()\r\n\r\nlocal INVENTORY_TEMPLATE = ROOT:GetCustomProperty(\"InventoryTemplate\")\r\nlocal STARTING_INVENTORY = require(ROOT:GetCustomProperty(\"StartingInventoryTable\"))\r\n\r\nlocal inventories = {}\r\n\r\n---Updates weapon item ammo property\r\nlocal function UpdateWeaponAmmo(weapon)\r\n    if not Object.IsValid(weapon) and not Object.IsValid(weapon.owner) then return end\r\n\r\n    local inventory = inventories[weapon.owner].inventory\r\n    local activeSlot = inventories[weapon.owner].activeSlot\r\n\r\n    inventory:GetItem(activeSlot):SetCustomProperty(\"Ammo\", weapon.currentAmmo)\r\nend\r\n\r\n---Sets up the new weapon on the player\r\nlocal function SetupNewWeapon(player, inventory, slot)\r\n    if not inventory:GetItem(slot) then\r\n        return nil\r\n    end\r\n\r\n    local weapon = World.SpawnAsset(inventory:GetItem(slot).itemTemplateId)\r\n    weapon:Equip(player)\r\n\r\n    -- Connect the weapon events to update Ammo property\r\n    if not weapon.isHitscan then\r\n    \tweapon.projectileSpawnedEvent:Connect(UpdateWeaponAmmo)\r\n    else\r\n\t    local shootAbility = weapon:GetAbilities()[1]\r\n\t    if shootAbility then\r\n\t        shootAbility.executeEvent:Connect(function(ability)\r\n\t        \tTask.Wait()\r\n\t            UpdateWeaponAmmo(ability:FindAncestorByType(\'Weapon\'))\r\n\t        end)\r\n\t    end    \t\r\n    end\r\n    local reloadAbility = weapon:GetAbilities()[2]\r\n    if reloadAbility then\r\n        reloadAbility.executeEvent:Connect(function(ability)\r\n        \tTask.Wait()\r\n            UpdateWeaponAmmo(ability:FindAncestorByType(\'Weapon\'))\r\n        end)\r\n    end\r\n\r\n    -- Setup ammo for current weapon\r\n    if inventories[player].ammo then\r\n        weapon.currentAmmo = inventory:GetItem(slot):GetCustomProperty(\"Ammo\")\r\n    else\r\n        inventory:GetItem(slot):SetCustomProperty(\"Ammo\", weapon.currentAmmo)\r\n        inventories[player].ammo = true\r\n    end\r\n    return weapon\r\nend\r\n\r\n---Checks the inventory slot item and spawns a new weapon onto the player\r\nlocal function AssignSlotWeapon(player, slot)\r\n    local inventory = inventories[player].inventory\r\n\r\n    if not slot or slot > inventory.slotCount then return end\r\n\r\n    -- Remove any existing weapons tied to the slot\r\n    local weapon = inventories[player].weapon\r\n    if Object.IsValid(weapon) then\r\n        weapon:Destroy()\r\n    end\r\n\r\n    local newWeapon = SetupNewWeapon(player, inventory, slot)\r\n    -- If there is no new weapon, then reset player stance\r\n    if not newWeapon then\r\n        player.animationStance = \"unarmed_stance\"\r\n    end\r\n\r\n    -- Cache the weapon and the active slot\r\n    inventories[player].weapon = newWeapon\r\n    inventories[player].activeSlot = slot\r\n    inventory:SetCustomProperty(\"ActiveSlot\", slot)\r\nend\r\n\r\n---Swaps active slot and changes weapon if the slot has the weapon\r\nlocal function ChangeWeapon(player, isNext)\r\n    local slotCount = inventories[player].inventory.slotCount\r\n    local currentSlot = inventories[player].activeSlot\r\n    if isNext then\r\n        currentSlot = currentSlot + 1\r\n        if currentSlot > slotCount then\r\n            currentSlot = 1\r\n        end\r\n    else\r\n        currentSlot = currentSlot - 1\r\n        if currentSlot < 1 then\r\n            currentSlot = slotCount\r\n        end\r\n    end\r\n    AssignSlotWeapon(player, currentSlot)\r\nend\r\n\r\n---Add new weapon item to inventory\r\nlocal function AddWeapon(weapon, item)\r\n    local player = weapon.owner\r\n    if not inventories[player] then return end\r\n\r\n    local inventory = inventories[player].inventory\r\n    local slot = item:GetCustomProperty(\"Slot\")\r\n\r\n    local itemAssetId = item.itemAssetId\r\n\r\n    weapon:Destroy()\r\n\t\r\n    if slot and slot > 0 then\r\n        -- Note: If needed, write your own drop weapon solution here.\r\n        --       For simplicity, this inventory only removes weapon.\r\n        local currentItem = inventory:GetItem(slot)\r\n        if currentItem then            \r\n            inventory:RemoveItem(currentItem.itemAssetId)\r\n        end\r\n\r\n        -- Add new weapon to the slot\r\n        inventory:AddItem(itemAssetId)\r\n        AssignSlotWeapon(player, slot)\r\n\r\n    elseif (slot and slot > 0) or slot == nil then\r\n        -- If there are no slot properties then it will try to add to inventory if there are still slots\r\n        if inventory:CanAddItem(itemAssetId) then\r\n            inventory:AddItem(itemAssetId)\r\n            AssignSlotWeapon(player, slot)\r\n        end\r\n    end\r\nend\r\n\r\nlocal function OnActionPressed(player, action, value)\r\n    if action == \"Next Weapon\" then\r\n        ChangeWeapon(player, true)\r\n    end\r\n    if action == \"Previous Weapon\" then\r\n        ChangeWeapon(player, false)\r\n    end\r\n\r\n    --Note: Add more weapon slot bindings here if you increase inventory size\r\n    if action == \"Weapon Slot 1\" then\r\n        AssignSlotWeapon(player, 1)\r\n    end\r\n    if action == \"Weapon Slot 2\" then\r\n        AssignSlotWeapon(player, 2)\r\n    end\r\n    if action == \"Weapon Slot 3\" then\r\n        AssignSlotWeapon(player, 3)\r\n    end\r\n    if action == \"Weapon Slot 4\" then\r\n        AssignSlotWeapon(player, 4)\r\n    end\r\n    if action == \"Weapon Slot 5\" then\r\n        AssignSlotWeapon(player, 5)\r\n    end\r\nend\r\n\r\n---Spawns inventory template and assigns it to player\r\nlocal function OnPlayerJoined(player)\r\n    local inventory = World.SpawnAsset(INVENTORY_TEMPLATE)\r\n    inventory:Assign(player)\r\n\r\n    -- Cache the players inventory info\r\n    inventories[player] = {\r\n        inventory = inventory,\r\n        activeSlot = 1,\r\n        weapon = nil\r\n    }\r\n\r\n    -- Add the starting weapons of Items type\r\n    for _, value in ipairs(STARTING_INVENTORY) do\r\n        inventory:AddItem(value.Item)\r\n    end\r\n\r\n    -- Start with weapon slot 1\r\n    AssignSlotWeapon(player, 1)\r\nend\r\n\r\n---When player leaves, remove all weapons information\r\nlocal function OnPlayerLeft(player)\r\n    local weapon = inventories[player].weapon\r\n    if Object.IsValid(weapon) then\r\n        weapon:Destroy()\r\n    end\r\n    if inventories[player].inventory then\r\n        inventories[player].inventory:Destroy()\r\n    end\r\n\r\n    inventories[player] = nil\r\nend\r\n\r\n-- Initialize event connection\r\nInput.actionPressedEvent:Connect(OnActionPressed)\r\nGame.playerJoinedEvent:Connect(OnPlayerJoined)\r\nGame.playerLeftEvent:Connect(OnPlayerLeft)\r\n\r\nEvents.Connect(\"AddInventoryWeapon\", AddWeapon)"
        CustomParameters {
        }
      }
      VirtualFolderPath: "Weapon Switcher"
    }
    Assets {
      Id: 8814398338958840148
      Name: "WeaponSwitcher_README"
      PlatformAssetType: 3
      TextAsset {
        Text: "--[[\r\n __          __                             _____         _ _       _               \r\n \\ \\        / /                            / ____|       (_) |     | |              \r\n  \\ \\  /\\  / /__  __ _ _ __   ___  _ __   | (_____      ___| |_ ___| |__   ___ _ __ \r\n   \\ \\/  \\/ / _ \\/ _` | \'_ \\ / _ \\| \'_ \\   \\___ \\ \\ /\\ / / | __/ __| \'_ \\ / _ \\ \'__|\r\n    \\  /\\  /  __/ (_| | |_) | (_) | | | |  ____) \\ V  V /| | || (__| | | |  __/ |   \r\n     \\/  \\/ \\___|\\__,_| .__/ \\___/|_| |_| |_____/ \\_/\\_/ |_|\\__\\___|_| |_|\\___|_|   \r\n                      | |                                                           \r\n                      |_|                                                           \r\n\r\nWeapon Switcher is a template that allows players to switch between multiple weapons.\r\n\r\nThe template uses the inventory and item components, as well as data tables. The player\r\nwill be assigned a new inventory and be given weapons at the start of the game. A UI\r\nwill be created to display the current weapons the player has in their inventory.\r\nThe template also includes a binding set of actions for switching weapons.\r\n\r\nThis template works with the Weapon Spawner template.\r\n\r\n=====\r\nSetup\r\n=====\r\n\r\nDrag and drop the Weapon Switcher template into the Hierarchy.\r\n\r\nPreview the project and use \"Q\", \"E\", \"1\", \"2\", or \"3\" to switch weapons.\r\n\r\n==========\r\nHow to Use\r\n==========\r\n\r\n=================\r\nCustom Properties\r\n=================\r\n\r\nThe root object of the template has 3 custom properties.\r\n\r\n- Weapon Inventory\r\n\r\nA template of an inventory that each player will be assigned to hold the weapon slots.\r\n\r\n- Starting Inventory Table\r\n\r\nA data table of weapon items that each player will be assigned at the start of the game.\r\n\r\n- Spacing\r\n\r\nThe distance each UI weapon slot will be spaced from each other.\r\n\r\n======================\r\nCreating a Weapon Item\r\n======================\r\n\r\n1. Add a new networked weapon template to the Project Content.\r\n\r\n2. Find the Weapon Switcher items in the Project Content.\r\n\r\n3. Duplicate one of the items and rename to the new weapon name.\r\n\r\n4. Select the new item and open the Properties window.\r\n\r\n5. Change the item\'s properties (Item Template, Slot, Icon, Ammo).\r\n\r\n6. Open the Starting Weapon Inventory data table and add the new item.\r\n\r\n======================\r\nChange Inventory Slots\r\n======================\r\n\r\nTo change the amount of inventory slots, the Weapon Inventory template needs to be updated.\r\n\r\n1. From Project Content, drag and drop the Weapon Inventory template into the Hierarchy.\r\n\r\n2. Select the Weapon Inventory object and open the Properties window.\r\n\r\n3. Set the Slot Count property to the desired amount.\r\n\r\n4. Right click the Weapon Inventory object and Update Template From Object.\r\n\r\n5. Delete the Weapon Inventory object from the Hierarchy.\r\n\r\n======\r\nEvents\r\n======\r\n\r\nThe server script is connected to an event for the player to equip a new weapon\r\nand add the item to the inventory. The syntax is as follows:\r\n\r\n`Events.Broadcast(\"AddInventoryWeapon\", weapon, item)`\r\n\r\n]]--"
        CustomParameters {
        }
      }
      VirtualFolderPath: "Weapon Switcher"
    }
    Assets {
      Id: 1984342560853724922
      Name: "WeaponSwitcher_Client"
      PlatformAssetType: 3
      TextAsset {
        Text: "-- Internal properties\r\nlocal ROOT = script:GetCustomProperty(\"Root\"):WaitForObject()\r\nlocal INVENTORY_PANEL = script:GetCustomProperty(\"InventoryPanel\"):WaitForObject()\r\nlocal ITEMS_PANEL = script:GetCustomProperty(\"ItemsPanel\"):WaitForObject()\r\nlocal ITEM_SLOT_TEMPLATE = script:GetCustomProperty(\"ItemSlotTemplate\")\r\n\r\n-- Exposed properties\r\nlocal SPACING = ROOT:GetCustomProperty(\"Spacing\")\r\nlocal INVENTORY_TEMPLATE = ROOT:GetCustomProperty(\"InventoryTemplate\")\r\n\r\nlocal GET = function (obj, value) return obj:GetCustomProperty(value):WaitForObject() end\r\n\r\n-- Constant variables\r\nlocal LOCAL_PLAYER = Game.GetLocalPlayer()\r\nlocal _, INVENTORY_NAME = CoreString.Split(INVENTORY_TEMPLATE, {delimiters = \":\"})\r\n\r\n-- Internal variables\r\nlocal currentInventory = nil\r\n\r\n-- Always check if player has the right inventory to display\r\nfunction Tick()\r\n    CheckForInventory()\r\nend\r\n\r\nfunction RefreshInventoryDisplay()\r\n    for _, value in ipairs(ITEMS_PANEL:GetChildren()) do\r\n        value:Destroy()\r\n    end\r\n\r\n    if not currentInventory then return end\r\n\r\n    local totalWidth = 0        -- Width to set on the inventory panel\r\n\r\n    for i = 1, currentInventory.slotCount do\r\n        -- Spawn item slot template under panel\r\n        local itemPanel = World.SpawnAsset(ITEM_SLOT_TEMPLATE, {parent = ITEMS_PANEL})\r\n        local item = currentInventory:GetItem(i)\r\n\r\n        -- Fill in item slot information if there is existing item in the inventory slot\r\n        if item then\r\n            -- Item should have reference to an Icon as property to display its icon\r\n            -- Else show name of the weapon only\r\n            local icon = item:GetCustomProperty(\"Icon\")\r\n            if icon then\r\n                GET(itemPanel, \"ItemIcon\").visibility = Visibility.INHERIT\r\n                GET(itemPanel, \"ItemIcon\"):SetImage(icon)\r\n                GET(itemPanel, \"ItemName\").text = \"\"\r\n            else\r\n                GET(itemPanel, \"ItemIcon\").visibility = Visibility.FORCE_OFF\r\n                GET(itemPanel, \"ItemName\").text = item.name\r\n            end\r\n\r\n            -- Get ammo information from weapon item\r\n            local ammo = item:GetCustomProperty(\"Ammo\")\r\n            if ammo then\r\n                GET(itemPanel, \"ItemCount\").text = tostring(ammo)\r\n            else\r\n                GET(itemPanel, \"ItemCount\").text = \"\"\r\n            end\r\n        else \r\n            GET(itemPanel, \"ItemIcon\").visibility = Visibility.FORCE_OFF\r\n            GET(itemPanel, \"ItemCount\").text = \"\"\r\n            GET(itemPanel, \"ItemName\").text = \"\"\r\n        end\r\n\r\n        -- Only show slot binding shortcut if player is using keyboard\r\n        if Input.GetCurrentInputType() == InputType.KEYBOARD_AND_MOUSE then\r\n            GET(itemPanel, \"ItemBinding\").text = tostring(i)\r\n        else\r\n            GET(itemPanel, \"ItemBinding\").text = \"\"\r\n        end\r\n\r\n        -- Highlight active slot using dynamic property on inventory\r\n        if currentInventory:GetCustomProperty(\"ActiveSlot\") == i then\r\n            GET(itemPanel, \"Highlight\").visibility = Visibility.INHERIT\r\n        else\r\n            GET(itemPanel, \"Highlight\").visibility = Visibility.FORCE_OFF\r\n        end\r\n\r\n        -- Order the item slot template placement from left to right\r\n        itemPanel.x = (i-1) * itemPanel.width + (i-1) * SPACING\r\n        totalWidth = itemPanel.width + itemPanel.x\r\n    end\r\n\r\n    -- Set the total width of inventory panel\r\n    INVENTORY_PANEL.width = totalWidth\r\nend\r\n\r\nfunction CheckForInventory()\r\n    if currentInventory == nil then\r\n        INVENTORY_PANEL.visibility = Visibility.FORCE_OFF\r\n        for _, value in ipairs(LOCAL_PLAYER:GetInventories()) do\r\n            if value.name == INVENTORY_NAME then\r\n                currentInventory = value\r\n\r\n                currentInventory.changedEvent:Connect(RefreshInventoryDisplay)\r\n                currentInventory.customPropertyChangedEvent:Connect(RefreshInventoryDisplay)\r\n                currentInventory.itemPropertyChangedEvent:Connect(RefreshInventoryDisplay)\r\n\r\n                RefreshInventoryDisplay()\r\n\r\n                break\r\n            end\r\n        end\r\n    else\r\n        INVENTORY_PANEL.visibility = Visibility.INHERIT\r\n    end\r\nend\r\n\r\nCheckForInventory()"
        CustomParameters {
        }
      }
      VirtualFolderPath: "Weapon Switcher"
    }
    Assets {
      Id: 17504818798877675931
      Name: "Weapons Inventory Binding Set"
      PlatformAssetType: 29
      VirtualFolderPath: "Weapon Switcher"
      BindingSetAsset {
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:e"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:scrolldown"
              }
              Controller {
                Value: "mc:ebindinggamepad:dpadright"
              }
            }
          }
          Action: "Next Weapon"
          CoreBehavior {
            Value: "mc:ecorebehavior:none"
          }
          Networked: true
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:q"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:scrollup"
              }
              Controller {
                Value: "mc:ebindinggamepad:dpadleft"
              }
            }
          }
          Action: "Previous Weapon"
          CoreBehavior {
            Value: "mc:ecorebehavior:none"
          }
          Networked: true
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:one"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:none"
              }
            }
          }
          Action: "Weapon Slot 1"
          CoreBehavior {
            Value: "mc:ecorebehavior:none"
          }
          Networked: true
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:two"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:none"
              }
            }
          }
          Action: "Weapon Slot 2"
          CoreBehavior {
            Value: "mc:ecorebehavior:none"
          }
          Networked: true
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:three"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:none"
              }
            }
          }
          Action: "Weapon Slot 3"
          CoreBehavior {
            Value: "mc:ecorebehavior:none"
          }
          Networked: true
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:four"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:none"
              }
            }
          }
          Action: "Weapon Slot 4"
          CoreBehavior {
            Value: "mc:ecorebehavior:none"
          }
          Networked: true
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:five"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:none"
              }
            }
          }
          Action: "Weapon Slot 5"
          CoreBehavior {
            Value: "mc:ecorebehavior:none"
          }
          Networked: true
          IsEnabledOnStart: true
        }
      }
    }
    Assets {
      Id: 3798900806209631770
      Name: "Weapon Switcher"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 8203956615419791928
          Objects {
            Id: 8203956615419791928
            Name: "Weapon Switcher"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            ChildIds: 3066102479589974509
            ChildIds: 16885285390976852511
            ChildIds: 7308025861932015364
            ChildIds: 11330036095554585622
            UnregisteredParameters {
              Overrides {
                Name: "cs:InventoryTemplate"
                AssetReference {
                  Id: 16052791129926391597
                }
              }
              Overrides {
                Name: "cs:StartingInventoryTable"
                AssetReference {
                  Id: 14500583891837168340
                }
              }
              Overrides {
                Name: "cs:Spacing"
                Float: 5
              }
              Overrides {
                Name: "cs:InventoryTemplate:isrep"
                Bool: false
              }
              Overrides {
                Name: "cs:InventoryTemplate:ml"
                Bool: false
              }
              Overrides {
                Name: "cs:StartingInventoryTable:isrep"
                Bool: false
              }
              Overrides {
                Name: "cs:StartingInventoryTable:ml"
                Bool: false
              }
              Overrides {
                Name: "cs:Spacing:category"
                String: "Custom"
              }
              Overrides {
                Name: "cs:InventoryTemplate:tooltip"
                String: "The template of an inventory that each player will be assigned to hold the weapon slots."
              }
              Overrides {
                Name: "cs:StartingInventoryTable:tooltip"
                String: "A data table of weapon items that each player will be assigned at the start of the game."
              }
              Overrides {
                Name: "cs:Spacing:tooltip"
                String: "The distance each UI weapon slot will be spaced from each other."
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            Folder {
              IsGroup: true
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 3066102479589974509
            Name: "README"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 8203956615419791928
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            Script {
              ScriptAsset {
                Id: 8814398338958840148
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 16885285390976852511
            Name: "WeaponSwitcher_Server"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 8203956615419791928
            UnregisteredParameters {
              Overrides {
                Name: "cs:Root"
                ObjectReference {
                  SubObjectId: 8203956615419791928
                }
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            Script {
              ScriptAsset {
                Id: 4195502608665642632
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 7308025861932015364
            Name: "Weapons Inventory Binding Set"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 8203956615419791928
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            BindingSet {
              BindingSetAsset {
                Id: 17504818798877675931
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 11330036095554585622
            Name: "ClientContext"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 8203956615419791928
            ChildIds: 11251670230907459034
            ChildIds: 9453796214270239905
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            NetworkContext {
              MinDetailLevel {
                Value: "mc:edetaillevel:low"
              }
              MaxDetailLevel {
                Value: "mc:edetaillevel:ultra"
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 11251670230907459034
            Name: "WeaponSwitcher_Client"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 11330036095554585622
            UnregisteredParameters {
              Overrides {
                Name: "cs:Root"
                ObjectReference {
                  SubObjectId: 8203956615419791928
                }
              }
              Overrides {
                Name: "cs:InventoryPanel"
                ObjectReference {
                  SubObjectId: 16240992848080953822
                }
              }
              Overrides {
                Name: "cs:ItemsPanel"
                ObjectReference {
                  SubObjectId: 7331170195856990301
                }
              }
              Overrides {
                Name: "cs:ItemSlotTemplate"
                AssetReference {
                  Id: 3402288870162705701
                }
              }
              Overrides {
                Name: "cs:Root:isrep"
                Bool: false
              }
              Overrides {
                Name: "cs:Root:ml"
                Bool: false
              }
              Overrides {
                Name: "cs:InventoryPanel:isrep"
                Bool: false
              }
              Overrides {
                Name: "cs:InventoryPanel:ml"
                Bool: false
              }
              Overrides {
                Name: "cs:ItemsPanel:isrep"
                Bool: false
              }
              Overrides {
                Name: "cs:ItemsPanel:ml"
                Bool: false
              }
              Overrides {
                Name: "cs:ItemSlotTemplate:isrep"
                Bool: false
              }
              Overrides {
                Name: "cs:ItemSlotTemplate:ml"
                Bool: false
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            Script {
              ScriptAsset {
                Id: 1984342560853724922
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 9453796214270239905
            Name: "UI Container"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 11330036095554585622
            ChildIds: 16240992848080953822
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            Control {
              RenderTransformPivot {
                Anchor {
                  Value: "mc:euianchor:middlecenter"
                }
              }
              Canvas {
                ContentType {
                  Value: "mc:ecanvascontenttype:dynamic"
                }
                Opacity: 1
                IsHUD: true
                CanvasWorldSize {
                  X: 1024
                  Y: 1024
                }
                RedrawTime: 30
                UseSafeZoneAdjustment: true
              }
              AnchorLayout {
                SelfAnchor {
                  Anchor {
                    Value: "mc:euianchor:topleft"
                  }
                }
                TargetAnchor {
                  Anchor {
                    Value: "mc:euianchor:topleft"
                  }
                }
              }
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 16240992848080953822
            Name: "Inventory Panel"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 9453796214270239905
            ChildIds: 3714634142323792406
            ChildIds: 7331170195856990301
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            Control {
              Width: 350
              Height: 100
              UIX: -50
              UIY: -50
              RenderTransformPivot {
                Anchor {
                  Value: "mc:euianchor:middlecenter"
                }
              }
              Panel {
                Opacity: 1
                OpacityMaskBrush {
                }
              }
              AnchorLayout {
                SelfAnchor {
                  Anchor {
                    Value: "mc:euianchor:bottomright"
                  }
                }
                TargetAnchor {
                  Anchor {
                    Value: "mc:euianchor:bottomright"
                  }
                }
              }
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 3714634142323792406
            Name: "Background"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 16240992848080953822
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            Control {
              Width: 10
              Height: 10
              RenderTransformPivot {
                Anchor {
                  Value: "mc:euianchor:middlecenter"
                }
              }
              AddSizeToParentIfUsingParentSize: true
              UseParentWidth: true
              UseParentHeight: true
              Image {
                Brush {
                  Id: 5157433964169291355
                }
                Color {
                  A: 0.5
                }
                TeamSettings {
                }
                ShadowColor {
                  A: 1
                }
                ShadowOffset {
                }
                ScreenshotIndex: 1
              }
              AnchorLayout {
                SelfAnchor {
                  Anchor {
                    Value: "mc:euianchor:middlecenter"
                  }
                }
                TargetAnchor {
                  Anchor {
                    Value: "mc:euianchor:middlecenter"
                  }
                }
              }
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 7331170195856990301
            Name: "Items Panel"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 16240992848080953822
            ChildIds: 4496344133606082036
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            Control {
              Width: 100
              Height: 100
              RenderTransformPivot {
                Anchor {
                  Value: "mc:euianchor:middlecenter"
                }
              }
              UseParentWidth: true
              UseParentHeight: true
              Panel {
                Opacity: 1
                OpacityMaskBrush {
                }
              }
              AnchorLayout {
                SelfAnchor {
                  Anchor {
                    Value: "mc:euianchor:middlecenter"
                  }
                }
                TargetAnchor {
                  Anchor {
                    Value: "mc:euianchor:middlecenter"
                  }
                }
              }
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 4496344133606082036
            Name: "Helper_ShooterInventoryItemPanel"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 7331170195856990301
            TemplateInstance {
              ParameterOverrideMap {
                key: 3686956054674589503
                value {
                  Overrides {
                    Name: "Name"
                    String: "Helper_ShooterInventoryItemPanel"
                  }
                  Overrides {
                    Name: "Scale"
                    Vector {
                      X: 1
                      Y: 1
                      Z: 1
                    }
                  }
                  Overrides {
                    Name: "Position"
                    Vector {
                    }
                  }
                  Overrides {
                    Name: "Rotation"
                    Rotator {
                    }
                  }
                }
              }
              ParameterOverrideMap {
                key: 10109433933381915414
                value {
                  Overrides {
                    Name: "Image"
                    AssetReference {
                      Id: 14050456045404265983
                    }
                  }
                }
              }
              ParameterOverrideMap {
                key: 13195239993271327186
                value {
                  Overrides {
                    Name: "Color"
                    Color {
                      R: 1
                      G: 0.903576195
                      B: 0.0899999738
                      A: 0.8
                    }
                  }
                }
              }
              TemplateAsset {
                Id: 3402288870162705701
              }
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
    }
    Assets {
      Id: 14050456045404265983
      Name: "Survival Rifle 001"
      PlatformAssetType: 9
      PrimaryAsset {
        AssetType: "PlatformBrushAssetRef"
        AssetId: "UI_Survival_Weapon_Rifle_001"
      }
    }
    Assets {
      Id: 5157433964169291355
      Name: "BG Flat 001"
      PlatformAssetType: 9
      PrimaryAsset {
        AssetType: "PlatformBrushAssetRef"
        AssetId: "BackgroundNoOutline_020"
      }
    }
    Assets {
      Id: 3402288870162705701
      Name: "Helper_ShooterInventoryItemPanel"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 3686956054674589503
          Objects {
            Id: 3686956054674589503
            Name: "Helper_ShooterInventoryItemPanel"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            ChildIds: 14739879799610992097
            ChildIds: 13195239993271327186
            ChildIds: 10109433933381915414
            ChildIds: 6852363808791064717
            ChildIds: 11342937521633669869
            ChildIds: 6226583716292660191
            UnregisteredParameters {
              Overrides {
                Name: "cs:Highlight"
                ObjectReference {
                  SubObjectId: 13195239993271327186
                }
              }
              Overrides {
                Name: "cs:ItemIcon"
                ObjectReference {
                  SubObjectId: 10109433933381915414
                }
              }
              Overrides {
                Name: "cs:ItemCount"
                ObjectReference {
                  SubObjectId: 11342937521633669869
                }
              }
              Overrides {
                Name: "cs:ItemName"
                ObjectReference {
                  SubObjectId: 6852363808791064717
                }
              }
              Overrides {
                Name: "cs:ItemBinding"
                ObjectReference {
                  SubObjectId: 6226583716292660191
                }
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            Control {
              Width: 100
              Height: 100
              RenderTransformPivot {
                Anchor {
                  Value: "mc:euianchor:middlecenter"
                }
              }
              Panel {
                Opacity: 1
                OpacityMaskBrush {
                }
              }
              AnchorLayout {
                SelfAnchor {
                  Anchor {
                    Value: "mc:euianchor:topleft"
                  }
                }
                TargetAnchor {
                  Anchor {
                    Value: "mc:euianchor:topleft"
                  }
                }
              }
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 14739879799610992097
            Name: "Background"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 3686956054674589503
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            Control {
              Width: 200
              Height: 200
              RenderTransformPivot {
                Anchor {
                  Value: "mc:euianchor:middlecenter"
                }
              }
              UseParentWidth: true
              UseParentHeight: true
              Image {
                Brush {
                  Id: 7442837171748145830
                }
                Color {
                  A: 0.8
                }
                TeamSettings {
                }
                ShadowColor {
                  A: 1
                }
                ShadowOffset {
                }
                ScreenshotIndex: 1
              }
              AnchorLayout {
                SelfAnchor {
                  Anchor {
                    Value: "mc:euianchor:middlecenter"
                  }
                }
                TargetAnchor {
                  Anchor {
                    Value: "mc:euianchor:middlecenter"
                  }
                }
              }
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 13195239993271327186
            Name: "Highlight"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 3686956054674589503
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            Control {
              Width: 200
              Height: 200
              RenderTransformPivot {
                Anchor {
                  Value: "mc:euianchor:middlecenter"
                }
              }
              UseParentWidth: true
              UseParentHeight: true
              Image {
                Brush {
                  Id: 8072763642593573838
                }
                Color {
                  R: 1
                  G: 0.903576195
                  B: 0.0899999738
                  A: 0.8
                }
                TeamSettings {
                }
                ShadowColor {
                  A: 1
                }
                ShadowOffset {
                }
                ScreenshotIndex: 1
              }
              AnchorLayout {
                SelfAnchor {
                  Anchor {
                    Value: "mc:euianchor:middlecenter"
                  }
                }
                TargetAnchor {
                  Anchor {
                    Value: "mc:euianchor:middlecenter"
                  }
                }
              }
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 10109433933381915414
            Name: "Item Icon"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 3686956054674589503
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            Control {
              Width: -15
              Height: -15
              RenderTransformPivot {
                Anchor {
                  Value: "mc:euianchor:middlecenter"
                }
              }
              AddSizeToParentIfUsingParentSize: true
              UseParentWidth: true
              UseParentHeight: true
              Image {
                Brush {
                  Id: 17524094064623687357
                }
                Color {
                  R: 1
                  G: 1
                  B: 1
                  A: 1
                }
                TeamSettings {
                }
                ShadowColor {
                  A: 1
                }
                ShadowOffset {
                }
                ScreenshotIndex: 1
              }
              AnchorLayout {
                SelfAnchor {
                  Anchor {
                    Value: "mc:euianchor:middlecenter"
                  }
                }
                TargetAnchor {
                  Anchor {
                    Value: "mc:euianchor:middlecenter"
                  }
                }
              }
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 6852363808791064717
            Name: "Item Name"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 3686956054674589503
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            Control {
              Width: -10
              Height: 30
              RenderTransformPivot {
                Anchor {
                  Value: "mc:euianchor:middlecenter"
                }
              }
              AddSizeToParentIfUsingParentSize: true
              UseParentWidth: true
              Text {
                Label: "Item Name"
                Color {
                  R: 1
                  G: 1
                  B: 1
                  A: 1
                }
                Size: 15
                Justification {
                  Value: "mc:etextjustify:center"
                }
                AutoWrapText: true
                Font {
                  Id: 841534158063459245
                }
                VerticalJustification {
                  Value: "mc:everticaljustification:center"
                }
                ShadowColor {
                  A: 1
                }
                ShadowOffset {
                }
                ScaleToFit: true
                OutlineColor {
                  A: 1
                }
                OutlineSize: 1
              }
              AnchorLayout {
                SelfAnchor {
                  Anchor {
                    Value: "mc:euianchor:middlecenter"
                  }
                }
                TargetAnchor {
                  Anchor {
                    Value: "mc:euianchor:middlecenter"
                  }
                }
              }
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 11342937521633669869
            Name: "Item Count"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 3686956054674589503
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            Control {
              Width: 50
              Height: 50
              UIX: -10
              UIY: -5
              RenderTransformPivot {
                Anchor {
                  Value: "mc:euianchor:middlecenter"
                }
              }
              Text {
                Label: "00"
                Color {
                  R: 1
                  G: 1
                  B: 1
                  A: 1
                }
                Size: 15
                Justification {
                  Value: "mc:etextjustify:right"
                }
                AutoWrapText: true
                Font {
                  Id: 841534158063459245
                }
                VerticalJustification {
                  Value: "mc:everticaljustification:bottom"
                }
                ShadowColor {
                  A: 1
                }
                ShadowOffset {
                }
                OutlineColor {
                  A: 1
                }
                OutlineSize: 1
              }
              AnchorLayout {
                SelfAnchor {
                  Anchor {
                    Value: "mc:euianchor:bottomright"
                  }
                }
                TargetAnchor {
                  Anchor {
                    Value: "mc:euianchor:bottomright"
                  }
                }
              }
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 6226583716292660191
            Name: "Item Binding"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 3686956054674589503
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            Control {
              Width: 50
              Height: 40
              RenderTransformPivot {
                Anchor {
                  Value: "mc:euianchor:middlecenter"
                }
              }
              Text {
                Label: "1"
                Color {
                  R: 1
                  G: 1
                  B: 1
                  A: 1
                }
                Size: 15
                Justification {
                  Value: "mc:etextjustify:center"
                }
                AutoWrapText: true
                Font {
                  Id: 841534158063459245
                }
                VerticalJustification {
                  Value: "mc:everticaljustification:center"
                }
                ShadowColor {
                  A: 1
                }
                ShadowOffset {
                }
                OutlineColor {
                  A: 1
                }
                OutlineSize: 1
              }
              AnchorLayout {
                SelfAnchor {
                  Anchor {
                    Value: "mc:euianchor:topcenter"
                  }
                }
                TargetAnchor {
                  Anchor {
                    Value: "mc:euianchor:bottomcenter"
                  }
                }
              }
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
    }
    Assets {
      Id: 17524094064623687357
      Name: "Fantasy Wood 001"
      PlatformAssetType: 9
      PrimaryAsset {
        AssetType: "PlatformBrushAssetRef"
        AssetId: "UI_Fantasy_Equip_Wood_001"
      }
    }
    Assets {
      Id: 8072763642593573838
      Name: "Frame Outlined 002"
      PlatformAssetType: 9
      PrimaryAsset {
        AssetType: "PlatformBrushAssetRef"
        AssetId: "FrameSolid4px_019"
      }
    }
    Assets {
      Id: 7442837171748145830
      Name: "BG Flat 002"
      PlatformAssetType: 9
      PrimaryAsset {
        AssetType: "PlatformBrushAssetRef"
        AssetId: "BackgroundNoOutline_019"
      }
    }
    Assets {
      Id: 14500583891837168340
      Name: "Starting Weapon Inventory"
      PlatformAssetType: 31
      VirtualFolderPath: "Weapon Switcher"
      DataTableAsset {
        Columns {
          Name: "Item"
          Type: 7
        }
        Rows {
          RawData: "E2EE5A9BCAF54F33"
        }
        Rows {
          RawData: "18174F20E33302FF"
        }
        Rows {
          RawData: "E73752D972DF3711"
        }
      }
    }
    Assets {
      Id: 16660876440369051409
      Name: "Grenade"
      PlatformAssetType: 33
      VirtualFolderPath: "Weapon Switcher"
      ItemAsset {
        CustomName: "Grenade"
        MaximumStackCount: 1
        ItemTemplateAssetId: 11840076694154351930
        CustomParameters {
          Overrides {
            Name: "cs:Slot"
            Int: 3
          }
          Overrides {
            Name: "cs:Icon"
            AssetReference {
              Id: 5947119066835658584
            }
          }
          Overrides {
            Name: "cs:Ammo"
            Int: 5
          }
          Overrides {
            Name: "cs:Ammo:isrep"
            Bool: true
          }
          Overrides {
            Name: "cs:Slot:tooltip"
            String: "Slot that this item can only exist in the inventory. If set to 0 then it can go to any available slot."
          }
          Overrides {
            Name: "cs:Icon:tooltip"
            String: "Reference the icon related to this item. Setting nothing will show the name of the item in the slot."
          }
          Overrides {
            Name: "cs:Ammo:tooltip"
            String: "Dynamic property to reference the status of the weapon\'s ammo. By default, you should set the weapon\'s starting ammo."
          }
          Overrides {
            Name: "cs:Ammo:category"
            String: "Custom"
          }
          Overrides {
            Name: "cs:Ammo:subcategory"
            String: "Dynamic"
          }
        }
      }
    }
    Assets {
      Id: 11840076694154351930
      Name: "Basic Grenade"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 10995544877558915165
          Objects {
            Id: 10995544877558915165
            Name: "Basic Grenade"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            ChildIds: 4148289698436847122
            ChildIds: 9602005995167140668
            ChildIds: 520438572048192294
            ChildIds: 10002155825824731598
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Equipment {
              SocketName: "right_prop"
              PickupTrigger {
                SubObjectId: 520438572048192294
              }
              Weapon {
                ProjectileAssetRef {
                  Id: 9270236968685246877
                }
                MuzzleFlashAssetRef {
                  Id: 841534158063459245
                }
                TrailAssetRef {
                  Id: 9791663148394559353
                }
                ImpactAssetRef {
                  Id: 841534158063459245
                }
                UseReticle: true
                Muzzle {
                  Location {
                  }
                }
                AnimationSet: "unarmed_stance"
                OutOfAmmoSfxAssetRef {
                  Id: 2185484604682618257
                }
                ReloadSfxAssetRef {
                  Id: 16788617737712185088
                }
                ShootAnimation: "2hand_rifle_shoot"
                ImpactProjectileAssetRef {
                  Id: 1108689888157251110
                }
                BeamAssetRef {
                  Id: 841534158063459245
                }
                BurstCount: 1
                BurstDuration: 1
                AttackCooldown: 0.25
                Range: 100000
                ImpactPlayerAssetRef {
                  Id: 7436194052653179954
                }
                ReticleType {
                  Value: "mc:ereticletype:crosshair"
                }
                AttackSfxAssetRef {
                  Id: 6460910652340078702
                }
                MaxAmmo: 5
                AmmoType: "rounds"
                MultiShot: 1
                ProjectileSpeed: 2000
                ProjectileLifeSpan: 2
                ProjectileGravity: 1.9
                ProjectileLength: 12
                ProjectileRadius: 12
                DefaultAbility {
                  SubObjectId: 4148289698436847122
                }
                ReloadAbility {
                  SubObjectId: 9602005995167140668
                }
                Damage: 60
                WeaponTrajectoryMode {
                  Value: "mc:eweapontrajectorymode:muzzletolooktarget"
                }
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 4148289698436847122
            Name: "Throw"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 10995544877558915165
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Ability {
              IsEnabled: true
              CastPhaseSettings {
                Duration: 0.1
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:aim"
                }
              }
              ExecutePhaseSettings {
                Duration: 0.1
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                IsTargetDataUpdated: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:aim"
                }
              }
              RecoveryPhaseSettings {
                Duration: 0.01
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:none"
                }
              }
              CooldownPhaseSettings {
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:none"
                }
              }
              Animation: "unarmed_throw"
              KeyBinding_v2 {
                Value: "mc:egameaction:invalid"
              }
              KeyBinding_v3: "Shoot"
              Version: 3
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 9602005995167140668
            Name: "Reload"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 10995544877558915165
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Ability {
              IsEnabled: true
              CastPhaseSettings {
                Duration: 0.3
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:aim"
                }
              }
              ExecutePhaseSettings {
                Duration: 0.1
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:aim"
                }
              }
              RecoveryPhaseSettings {
                CanMove: true
                CanJump: true
                CanRotate: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:none"
                }
              }
              CooldownPhaseSettings {
                CanMove: true
                CanJump: true
                CanRotate: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:none"
                }
              }
              Animation: "unarmed_pickup"
              KeyBinding_v2 {
                Value: "mc:egameaction:invalid"
              }
              KeyBinding_v3: "Reload"
              Version: 3
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 520438572048192294
            Name: "PickupTrigger"
            Transform {
              Location {
                X: 15
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 10995544877558915165
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:alwaysvisible"
            }
            Trigger {
              Interactable: true
              InteractionLabel: "Equip Basic Grenade"
              TeamSettings {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              TriggerShape_v2 {
                Value: "mc:etriggershape:box"
              }
              InteractionTemplate {
              }
              BreadcrumbTemplate {
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 10002155825824731598
            Name: "Client Art"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 10995544877558915165
            ChildIds: 18088815223060512347
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            NetworkContext {
              MinDetailLevel {
                Value: "mc:edetaillevel:low"
              }
              MaxDetailLevel {
                Value: "mc:edetaillevel:ultra"
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 18088815223060512347
            Name: "Geo"
            Transform {
              Location {
                Z: -15
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 10002155825824731598
            ChildIds: 10971540752399803835
            ChildIds: 6766940754836731342
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Folder {
              IsGroup: true
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 10971540752399803835
            Name: "Grenade Canister 04"
            Transform {
              Location {
                Y: 4.57763672e-05
                Z: 5.64148712
              }
              Rotation {
                Yaw: 134.999969
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 18088815223060512347
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 6855348992067761797
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 6766940754836731342
            Name: "Grenade Handle 01"
            Transform {
              Location {
                Y: 4.57763672e-05
                Z: 20
              }
              Rotation {
                Yaw: 134.999969
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 18088815223060512347
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 5544820850613172301
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
      VirtualFolderPath: "Weapons"
      VirtualFolderPath: "Projectile"
    }
    Assets {
      Id: 5544820850613172301
      Name: "Modern Weapon - Grenade Handle 01"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_weapons_grenade_handle_001"
      }
    }
    Assets {
      Id: 6855348992067761797
      Name: "Modern Weapon - Grenade Canister 04"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_weapons_grenade_sphere_001"
      }
    }
    Assets {
      Id: 6460910652340078702
      Name: "Grenade Attack Sound"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 14400253843638661859
          Objects {
            Id: 14400253843638661859
            Name: "Grenade Muzzle Flash"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            ChildIds: 5153500133894071777
            ChildIds: 18059806954620662536
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            NetworkContext {
              MinDetailLevel {
                Value: "mc:edetaillevel:low"
              }
              MaxDetailLevel {
                Value: "mc:edetaillevel:ultra"
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 5153500133894071777
            Name: "Grenade Object Toss Throw Gear Shuffle 01 SFX"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 14400253843638661859
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            AudioInstance {
              AudioAsset {
                Id: 9052054768173682124
              }
              AutoPlay: true
              Volume: 1
              Falloff: 1400
              Radius: 400
              EnableOcclusion: true
              IsSpatializationEnabled: true
              IsAttenuationEnabled: true
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 18059806954620662536
            Name: "Grenade Pin Pull Activate Cook 01 SFX"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 14400253843638661859
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            AudioInstance {
              AudioAsset {
                Id: 15936785812690386016
              }
              AutoPlay: true
              Volume: 1.5
              Falloff: 3600
              Radius: 400
              EnableOcclusion: true
              IsSpatializationEnabled: true
              IsAttenuationEnabled: true
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
      VirtualFolderPath: "Weapons"
      VirtualFolderPath: "Projectile"
      VirtualFolderPath: "Dependecies"
    }
    Assets {
      Id: 15936785812690386016
      Name: "Grenade Pin Pull Activate Cook 01 SFX"
      PlatformAssetType: 7
      PrimaryAsset {
        AssetType: "AudioAssetRef"
        AssetId: "sfx_grenade_pin_pull_cook_01a_Cue_ref"
      }
    }
    Assets {
      Id: 9052054768173682124
      Name: "Grenade Object Toss Throw Gear Shuffle 01 SFX"
      PlatformAssetType: 7
      PrimaryAsset {
        AssetType: "AudioAssetRef"
        AssetId: "sfx_grenade_object_toss_throw_gear_shuffle_01_Cue_ref"
      }
    }
    Assets {
      Id: 7436194052653179954
      Name: "Generic Impact Player Effect"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 11352976760511440785
          Objects {
            Id: 11352976760511440785
            Name: "Generic Impact Player Effect"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            ChildIds: 12801116442223059089
            ChildIds: 15368370472108963347
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            NetworkContext {
              MinDetailLevel {
                Value: "mc:edetaillevel:low"
              }
              MaxDetailLevel {
                Value: "mc:edetaillevel:ultra"
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 12801116442223059089
            Name: "Generic Player Impact VFX"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 11352976760511440785
            UnregisteredParameters {
              Overrides {
                Name: "bp:color"
                Color {
                  R: 0.950000048
                  A: 1
                }
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Blueprint {
              BlueprintAsset {
                Id: 7628097165165581423
              }
              Vfx {
                AutoPlay: true
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 15368370472108963347
            Name: "Bullet Body Impact SFX"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 11352976760511440785
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            AudioInstance {
              AudioAsset {
                Id: 7866413056776856701
              }
              AutoPlay: true
              Volume: 1
              Falloff: 3600
              Radius: 400
              IsSpatializationEnabled: true
              IsAttenuationEnabled: true
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
      VirtualFolderPath: "Weapons"
    }
    Assets {
      Id: 7866413056776856701
      Name: "Bullet Body Impact SFX"
      PlatformAssetType: 7
      PrimaryAsset {
        AssetType: "AudioAssetRef"
        AssetId: "sfx_bullet_impact_body"
      }
    }
    Assets {
      Id: 7628097165165581423
      Name: "Generic Player Impact VFX"
      PlatformAssetType: 8
      PrimaryAsset {
        AssetType: "VfxBlueprintAssetRef"
        AssetId: "fxbp_player_impact"
      }
    }
    Assets {
      Id: 1108689888157251110
      Name: "Grenade Explosion Projectile Impact"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 3631816468235174342
          Objects {
            Id: 3631816468235174342
            Name: "Grenade Explosion Projectile Impact"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            ChildIds: 8294218620204688349
            ChildIds: 15578947255402770909
            ChildIds: 6403277457468986457
            UnregisteredParameters {
            }
            Lifespan: 6
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            NetworkContext {
              MinDetailLevel {
                Value: "mc:edetaillevel:low"
              }
              MaxDetailLevel {
                Value: "mc:edetaillevel:ultra"
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 8294218620204688349
            Name: "Smoke Puff VFX"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 3631816468235174342
            UnregisteredParameters {
              Overrides {
                Name: "bp:color"
                Color {
                  R: 1
                  G: 1
                  B: 1
                  A: 1
                }
              }
              Overrides {
                Name: "bp:Particle Scale Multiplier"
                Float: 1.5
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Blueprint {
              BlueprintAsset {
                Id: 17772147750865925804
              }
              TeamSettings {
              }
              Vfx {
                AutoPlay: true
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 15578947255402770909
            Name: "Basic Explosion VFX"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1.5
                Y: 1.5
                Z: 1.5
              }
            }
            ParentId: 3631816468235174342
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Blueprint {
              BlueprintAsset {
                Id: 17069761961690292468
              }
              TeamSettings {
              }
              Vfx {
                AutoPlay: true
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 6403277457468986457
            Name: "Explosion Creation & Construction Kit 01 SFX"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 3631816468235174342
            UnregisteredParameters {
              Overrides {
                Name: "bp:Explosion Type 1"
                Enum {
                  Value: "mc:esfx_explosions:13"
                }
              }
              Overrides {
                Name: "bp:Explosion Type 2"
                Enum {
                  Value: "mc:esfx_explosions:16"
                }
              }
              Overrides {
                Name: "bp:Sweetener Impact Type 1"
                Enum {
                  Value: "mc:esfx_explosions_sw_impact:18"
                }
              }
              Overrides {
                Name: "bp:Sweetener Impact Type 2"
                Enum {
                  Value: "mc:esfx_explosions_sw_impact:15"
                }
              }
              Overrides {
                Name: "bp:Sweetener Sub Type"
                Enum {
                  Value: "mc:esfx_explosions_sw_sub:12"
                }
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Blueprint {
              BlueprintAsset {
                Id: 6970563607933101105
              }
              AudioBP {
                AutoPlay: true
                Volume: 1
                Falloff: 15000
                Radius: 400
                EnableOcclusion: true
                IsSpatializationEnabled: true
                IsAttenuationEnabled: true
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
      VirtualFolderPath: "Weapons"
      VirtualFolderPath: "Projectile"
      VirtualFolderPath: "Dependecies"
    }
    Assets {
      Id: 6970563607933101105
      Name: "Explosion Creation & Construction Kit 01 SFX"
      PlatformAssetType: 10
      PrimaryAsset {
        AssetType: "AudioBlueprintAssetRef"
        AssetId: "sfxabp_explosion_construction_kit_ref"
      }
    }
    Assets {
      Id: 17069761961690292468
      Name: "Basic Explosion VFX"
      PlatformAssetType: 8
      PrimaryAsset {
        AssetType: "VfxBlueprintAssetRef"
        AssetId: "fxbp_explosion"
      }
    }
    Assets {
      Id: 17772147750865925804
      Name: "Smoke Puff VFX"
      PlatformAssetType: 8
      PrimaryAsset {
        AssetType: "VfxBlueprintAssetRef"
        AssetId: "fxbp_smoke_puff"
      }
    }
    Assets {
      Id: 16788617737712185088
      Name: "Generic Sound Reload"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 902047587094345629
          Objects {
            Id: 902047587094345629
            Name: "Generic Sound Reload"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            ChildIds: 4272344084064824150
            UnregisteredParameters {
            }
            Lifespan: 1
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            NetworkContext {
              MinDetailLevel {
                Value: "mc:edetaillevel:low"
              }
              MaxDetailLevel {
                Value: "mc:edetaillevel:ultra"
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 4272344084064824150
            Name: "Gun Weapon Reload Set 01 SFX"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 902047587094345629
            UnregisteredParameters {
              Overrides {
                Name: "bp:Type"
                Enum {
                  Value: "mc:esfx_gunreloads:50"
                }
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Blueprint {
              BlueprintAsset {
                Id: 11279392096978883335
              }
              AudioBP {
                AutoPlay: true
                Volume: 1
                Falloff: 1000
                Radius: 100
                EnableOcclusion: true
                IsSpatializationEnabled: true
                IsAttenuationEnabled: true
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
      VirtualFolderPath: "Weapons"
      VirtualFolderPath: "Projectile"
      VirtualFolderPath: "Dependecies"
    }
    Assets {
      Id: 11279392096978883335
      Name: "Gun Weapon Reload Set 01 SFX"
      PlatformAssetType: 10
      PrimaryAsset {
        AssetType: "AudioBlueprintAssetRef"
        AssetId: "sfxabp_reloads_ref"
      }
    }
    Assets {
      Id: 2185484604682618257
      Name: "Generic Sound Out Of Ammo"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 17487107411025673192
          Objects {
            Id: 17487107411025673192
            Name: "Generic Sound Out Of Ammo"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            ChildIds: 14374793592845219494
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            NetworkContext {
              MinDetailLevel {
                Value: "mc:edetaillevel:low"
              }
              MaxDetailLevel {
                Value: "mc:edetaillevel:ultra"
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 14374793592845219494
            Name: "Dry Fire Click Generic Clicky 01 SFX"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 17487107411025673192
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            AudioInstance {
              AudioAsset {
                Id: 3358730465653412221
              }
              AutoPlay: true
              Volume: 1
              Falloff: 1200
              Radius: 400
              IsSpatializationEnabled: true
              IsAttenuationEnabled: true
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
      VirtualFolderPath: "Weapons"
      VirtualFolderPath: "Projectile"
      VirtualFolderPath: "Dependecies"
    }
    Assets {
      Id: 3358730465653412221
      Name: "Dry Fire Click Generic Clicky 01 SFX"
      PlatformAssetType: 7
      PrimaryAsset {
        AssetType: "AudioAssetRef"
        AssetId: "sfx_clicky_dryfire_01_Cue_ref"
      }
    }
    Assets {
      Id: 9791663148394559353
      Name: "Generic Trail"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 11388592286874595498
          Objects {
            Id: 11388592286874595498
            Name: "Generic Trail"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            ChildIds: 7928271528055639521
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            NetworkContext {
              MinDetailLevel {
                Value: "mc:edetaillevel:low"
              }
              MaxDetailLevel {
                Value: "mc:edetaillevel:ultra"
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 7928271528055639521
            Name: "Basic Projectile Trail VFX"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 11388592286874595498
            UnregisteredParameters {
              Overrides {
                Name: "bp:colorB"
                Color {
                  R: 1
                  G: 1
                  B: 1
                  A: 1
                }
              }
              Overrides {
                Name: "bp:Particle Scale Multiplier"
                Float: 0.4
              }
              Overrides {
                Name: "bp:Life"
                Float: 0.22
              }
              Overrides {
                Name: "bp:Emissive Boost"
                Float: 2
              }
              Overrides {
                Name: "bp:Color"
                Color {
                  R: 0.97
                  G: 0.366159
                  A: 1
                }
              }
              Overrides {
                Name: "bp:ColorB"
                Color {
                  R: 1
                  G: 0.73827821
                  B: 0.24000001
                  A: 1
                }
              }
              Overrides {
                Name: "bp:ColorC"
                Color {
                  R: 1
                  G: 1
                  B: 1
                  A: 1
                }
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Blueprint {
              BlueprintAsset {
                Id: 17977280587505271142
              }
              Vfx {
                AutoPlay: true
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
      VirtualFolderPath: "Weapons"
      VirtualFolderPath: "Projectile"
      VirtualFolderPath: "Dependecies"
    }
    Assets {
      Id: 17977280587505271142
      Name: "Basic Projectile Trail VFX"
      PlatformAssetType: 8
      PrimaryAsset {
        AssetType: "VfxBlueprintAssetRef"
        AssetId: "fxbp_basic_projectile_trail"
      }
    }
    Assets {
      Id: 9270236968685246877
      Name: "Grenade Projectile"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 6637820697500110737
          Objects {
            Id: 6637820697500110737
            Name: "Grenade Projectile"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            ChildIds: 2231629422558954152
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            NetworkContext {
              MinDetailLevel {
                Value: "mc:edetaillevel:low"
              }
              MaxDetailLevel {
                Value: "mc:edetaillevel:ultra"
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 2231629422558954152
            Name: "Modern Weapon - Grenade 02 (Prop)"
            Transform {
              Location {
                Z: -10
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 6637820697500110737
            ChildIds: 13493774454738326224
            ChildIds: 12438069925643964341
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Folder {
              IsGroup: true
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 13493774454738326224
            Name: "Grenade Canister 04"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 2231629422558954152
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 6855348992067761797
              }
              Teams {
              }
              DisableReceiveDecals: true
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 12438069925643964341
            Name: "Grenade Handle 01"
            Transform {
              Location {
                Z: 14.3585129
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 2231629422558954152
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 5544820850613172301
              }
              Teams {
              }
              DisableReceiveDecals: true
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
      VirtualFolderPath: "Weapons"
      VirtualFolderPath: "Projectile"
      VirtualFolderPath: "Dependecies"
    }
    Assets {
      Id: 5947119066835658584
      Name: "Weapon Grenade 001"
      PlatformAssetType: 9
      PrimaryAsset {
        AssetType: "PlatformBrushAssetRef"
        AssetId: "UI_Military_Weapon_Grenade_001"
      }
    }
    Assets {
      Id: 1735943184043934463
      Name: "Pistol"
      PlatformAssetType: 33
      VirtualFolderPath: "Weapon Switcher"
      ItemAsset {
        CustomName: "Pistol"
        MaximumStackCount: 1
        ItemTemplateAssetId: 13526530623171806134
        CustomParameters {
          Overrides {
            Name: "cs:Slot"
            Int: 2
          }
          Overrides {
            Name: "cs:Icon"
            AssetReference {
              Id: 3687930860452606934
            }
          }
          Overrides {
            Name: "cs:Ammo"
            Int: 16
          }
          Overrides {
            Name: "cs:Ammo:isrep"
            Bool: true
          }
          Overrides {
            Name: "cs:Ammo:category"
            String: "Custom"
          }
          Overrides {
            Name: "cs:Ammo:subcategory"
            String: "Dynamic"
          }
          Overrides {
            Name: "cs:Slot:tooltip"
            String: "Slot that this item can only exist in the inventory. If set to 0 then it can go to any available slot."
          }
          Overrides {
            Name: "cs:Icon:tooltip"
            String: "Reference the icon related to this item. Setting nothing will show the name of the item in the slot."
          }
          Overrides {
            Name: "cs:Ammo:tooltip"
            String: "Dynamic property to reference the status of the weapon\'s ammo. By default, you should set the weapon\'s starting ammo."
          }
        }
      }
    }
    Assets {
      Id: 13526530623171806134
      Name: "Basic Pistol"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 14156651541393010698
          Objects {
            Id: 14156651541393010698
            Name: "Basic Pistol"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            ChildIds: 5047134629311476418
            ChildIds: 17873086566573210660
            ChildIds: 5970618703958104407
            ChildIds: 1362060855448717416
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Equipment {
              SocketName: "right_prop"
              PickupTrigger {
                SubObjectId: 5970618703958104407
              }
              Weapon {
                ProjectileAssetRef {
                  Id: 13686915018416948746
                }
                MuzzleFlashAssetRef {
                  Id: 5441335048714837920
                }
                TrailAssetRef {
                  Id: 9791663148394559353
                }
                ImpactAssetRef {
                  Id: 17438692118890248845
                }
                UseReticle: true
                Muzzle {
                  Location {
                    X: 33
                    Z: 15
                  }
                }
                AnimationSet: "1hand_pistol_stance"
                OutOfAmmoSfxAssetRef {
                  Id: 2185484604682618257
                }
                ReloadSfxAssetRef {
                  Id: 16788617737712185088
                }
                ShootAnimation: "2hand_rifle_shoot"
                ImpactProjectileAssetRef {
                  Id: 841534158063459245
                }
                BeamAssetRef {
                  Id: 841534158063459245
                }
                BurstCount: 1
                BurstDuration: 1
                AttackCooldown: 0.25
                Range: 70000
                ImpactPlayerAssetRef {
                  Id: 7436194052653179954
                }
                ReticleType {
                  Value: "mc:ereticletype:crosshair"
                }
                AttackSfxAssetRef {
                  Id: 17085390824819963184
                }
                MaxAmmo: 16
                AmmoType: "rounds"
                MultiShot: 1
                ProjectileSpeed: 25000
                ProjectileLifeSpan: 10
                ProjectileLength: 50
                ProjectileRadius: 2
                SpreadMax: 2
                SpreadDecreaseSpeed: 8
                SpreadIncreasePerShot: 1
                SpreadPenaltyPerShot: 0.5
                DefaultAbility {
                  SubObjectId: 5047134629311476418
                }
                ReloadAbility {
                  SubObjectId: 17873086566573210660
                }
                Damage: 25
                WeaponTrajectoryMode {
                  Value: "mc:eweapontrajectorymode:muzzletolooktarget"
                }
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 5047134629311476418
            Name: "Shoot"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 14156651541393010698
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Ability {
              IsEnabled: true
              CastPhaseSettings {
                Duration: 0.03
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:aim"
                }
              }
              ExecutePhaseSettings {
                Duration: 0.1
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                IsTargetDataUpdated: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:aim"
                }
              }
              RecoveryPhaseSettings {
                Duration: 0.01
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:none"
                }
              }
              CooldownPhaseSettings {
                Duration: 0.1
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:none"
                }
              }
              Animation: "1hand_pistol_shoot"
              KeyBinding_v2 {
                Value: "mc:egameaction:invalid"
              }
              KeyBinding_v3: "Shoot"
              Version: 3
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 17873086566573210660
            Name: "Reload"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 14156651541393010698
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Ability {
              IsEnabled: true
              CastPhaseSettings {
                Duration: 1.3
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:aim"
                }
              }
              ExecutePhaseSettings {
                Duration: 0.1
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:aim"
                }
              }
              RecoveryPhaseSettings {
                CanMove: true
                CanJump: true
                CanRotate: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:none"
                }
              }
              CooldownPhaseSettings {
                CanMove: true
                CanJump: true
                CanRotate: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:none"
                }
              }
              Animation: "1hand_pistol_reload_magazine"
              KeyBinding_v2 {
                Value: "mc:egameaction:invalid"
              }
              KeyBinding_v3: "Reload"
              Version: 3
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 5970618703958104407
            Name: "PickupTrigger"
            Transform {
              Location {
                X: 15
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 14156651541393010698
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:alwaysvisible"
            }
            Trigger {
              Interactable: true
              InteractionLabel: "Equip Basic Pistol"
              TeamSettings {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              TriggerShape_v2 {
                Value: "mc:etriggershape:box"
              }
              InteractionTemplate {
              }
              BreadcrumbTemplate {
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 1362060855448717416
            Name: "Client Art"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 14156651541393010698
            ChildIds: 6112954265110768632
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            NetworkContext {
              MinDetailLevel {
                Value: "mc:edetaillevel:low"
              }
              MaxDetailLevel {
                Value: "mc:edetaillevel:ultra"
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 6112954265110768632
            Name: "Geo"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 1362060855448717416
            ChildIds: 16142181337060486089
            ChildIds: 227202885866204189
            ChildIds: 17661404483695676331
            ChildIds: 13325591224137657058
            ChildIds: 15826693310415172956
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Folder {
              IsGroup: true
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 16142181337060486089
            Name: "Modern Weapon - Slide 01"
            Transform {
              Location {
                X: -9.3879385
                Z: 15.6609459
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 6112954265110768632
            UnregisteredParameters {
              Overrides {
                Name: "ma:Shared_BaseMaterial:color"
                Color {
                  R: 0.205078766
                  G: 0.205078766
                  B: 0.205078766
                  A: 1
                }
              }
              Overrides {
                Name: "ma:Shared_Detail1:id"
                AssetReference {
                  Id: 3702191406046426907
                }
              }
              Overrides {
                Name: "ma:Shared_Detail1:color"
                Color {
                  R: 0.0423114114
                  G: 0.258182913
                  B: 0.644479871
                  A: 1
                }
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 697347799158381382
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 227202885866204189
            Name: "Trigger - Rear"
            Transform {
              Location {
                X: 2.68535042
                Z: 6.59273911
              }
              Rotation {
                Yaw: 89.9999542
              }
              Scale {
                X: 0.0216475781
                Y: 0.0397833697
                Z: 0.0606815
              }
            }
            ParentId: 6112954265110768632
            UnregisteredParameters {
              Overrides {
                Name: "ma:Shared_BaseMaterial:id"
                AssetReference {
                  Id: 132672053610873933
                }
              }
              Overrides {
                Name: "ma:Shared_BaseMaterial:color"
                Color {
                  R: 0.149
                  G: 0.149
                  B: 0.149
                  A: 1
                }
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 16965777294932964901
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 17661404483695676331
            Name: "Modern Weapon - Grip 04"
            Transform {
              Location {
                X: -0.222086906
                Y: -0.110616684
                Z: 8.6464119
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 6112954265110768632
            UnregisteredParameters {
              Overrides {
                Name: "ma:Shared_BaseMaterial:color"
                Color {
                  R: 0.205078766
                  G: 0.205078766
                  B: 0.205078766
                  A: 1
                }
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 15552769917126078605
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 13325591224137657058
            Name: "Modern Weapon - Sight Forward 01"
            Transform {
              Location {
                X: 27.5106201
                Z: 19.9975243
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 6112954265110768632
            UnregisteredParameters {
              Overrides {
                Name: "ma:Shared_Detail1:id"
                AssetReference {
                  Id: 3702191406046426907
                }
              }
              Overrides {
                Name: "ma:Shared_Detail1:color"
                Color {
                  R: 0.0423114114
                  G: 0.258182913
                  B: 0.644479871
                  A: 1
                }
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 7395101924488058849
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 15826693310415172956
            Name: "Modern Weapon - Sight Rear 01"
            Transform {
              Location {
                X: -7.69331264
                Z: 19.2971725
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 6112954265110768632
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 9117384065423546074
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
      VirtualFolderPath: "Weapons"
      VirtualFolderPath: "Projectile"
    }
    Assets {
      Id: 9117384065423546074
      Name: "Modern Weapon - Sight Rear 02"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_weap_modern_sight_rear_002"
      }
    }
    Assets {
      Id: 7395101924488058849
      Name: "Modern Weapon - Sight Forward 01"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_weap_modern_sight_forw_001"
      }
    }
    Assets {
      Id: 15552769917126078605
      Name: "Modern Weapon - Grip 04"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_weap_modern_grip_004"
      }
    }
    Assets {
      Id: 132672053610873933
      Name: "Plastic Matte"
      PlatformAssetType: 2
      PrimaryAsset {
        AssetType: "MaterialAssetRef"
        AssetId: "plastic_matte_001"
      }
    }
    Assets {
      Id: 16965777294932964901
      Name: "Cube - Chamfered Large Polished"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_cube_hq_002"
      }
    }
    Assets {
      Id: 3702191406046426907
      Name: "Emissive Glow Transparent"
      PlatformAssetType: 2
      PrimaryAsset {
        AssetType: "MaterialAssetRef"
        AssetId: "mi_basic_emissive_001"
      }
    }
    Assets {
      Id: 697347799158381382
      Name: "Modern Weapon - Slide 01"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_weap_modern_slide_001"
      }
    }
    Assets {
      Id: 17085390824819963184
      Name: "Pistol Attack Sound"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 5015312009504924698
          Objects {
            Id: 5015312009504924698
            Name: "Pistol Muzzle Flash"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            ChildIds: 12252926853189696465
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            NetworkContext {
              MinDetailLevel {
                Value: "mc:edetaillevel:low"
              }
              MaxDetailLevel {
                Value: "mc:edetaillevel:ultra"
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 12252926853189696465
            Name: "Gunshot Pistol & Revolver Set 01 SFX"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 5015312009504924698
            UnregisteredParameters {
              Overrides {
                Name: "bp:Gunshot Type"
                Enum {
                  Value: "mc:esfx_gunshot_pistol_revolver:4"
                }
              }
              Overrides {
                Name: "bp:Ricochet Type"
                Enum {
                  Value: "mc:esfx_gunshot_ricochets:0"
                }
              }
              Overrides {
                Name: "bp:Enable Dynamic Distant Sound"
                Bool: true
              }
              Overrides {
                Name: "bp:Ricochet Volume"
                Float: 0
              }
              Overrides {
                Name: "bp:Type"
                Enum {
                  Value: "mc:esfx_gunshot_pistol_revolver:5"
                }
              }
              Overrides {
                Name: "bp:Main Sound Mix Medium Distance Type"
                Enum {
                  Value: "mc:esfx_gunshot_pistol_revolver:5"
                }
              }
              Overrides {
                Name: "bp:Main Sound Mix Far Distance Type"
                Enum {
                  Value: "mc:esfx_gunshot_pistol_revolver:6"
                }
              }
              Overrides {
                Name: "bp:Far Distant Sound Type Pitch"
                Float: 58.1020508
              }
              Overrides {
                Name: "bp:Medium Sound Cutoff Distance"
                Float: 2500
              }
              Overrides {
                Name: "bp:Far Sound Cutoff Distance"
                Float: 3500
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Blueprint {
              BlueprintAsset {
                Id: 11671637230280120648
              }
              AudioBP {
                AutoPlay: true
                Volume: 1
                Falloff: 5500
                Radius: 400
                IsSpatializationEnabled: true
                IsAttenuationEnabled: true
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
      VirtualFolderPath: "Weapons"
      VirtualFolderPath: "Projectile"
      VirtualFolderPath: "Dependecies"
    }
    Assets {
      Id: 11671637230280120648
      Name: "Gunshot Pistol & Revolver Set 01 SFX"
      PlatformAssetType: 10
      PrimaryAsset {
        AssetType: "AudioBlueprintAssetRef"
        AssetId: "sfxabp_gunshot_revolver_ref"
      }
    }
    Assets {
      Id: 17438692118890248845
      Name: "Generic Impact Surface Aligned"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 6246242700242467092
          Objects {
            Id: 6246242700242467092
            Name: "Generic Impact Surface Aligned"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            ChildIds: 15676067918659116593
            UnregisteredParameters {
            }
            Lifespan: 6
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            NetworkContext {
              MinDetailLevel {
                Value: "mc:edetaillevel:low"
              }
              MaxDetailLevel {
                Value: "mc:edetaillevel:ultra"
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 15676067918659116593
            Name: "Impact Geo"
            Transform {
              Location {
              }
              Rotation {
                Pitch: -90
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 6246242700242467092
            ChildIds: 11244076573502085025
            ChildIds: 6983234237468868165
            ChildIds: 8007739458989036561
            ChildIds: 9519357983113725241
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Folder {
              IsGroup: true
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 11244076573502085025
            Name: "Impact Ground Dirt 01 SFX"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 15676067918659116593
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            AudioInstance {
              AudioAsset {
                Id: 3307794794401153799
              }
              AutoPlay: true
              Volume: 1
              Falloff: 3600
              Radius: 400
              EnableOcclusion: true
              IsSpatializationEnabled: true
              IsAttenuationEnabled: true
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 6983234237468868165
            Name: "Gun Impact Small VFX"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 15676067918659116593
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Blueprint {
              BlueprintAsset {
                Id: 17144409617272687275
              }
              Vfx {
                AutoPlay: true
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 8007739458989036561
            Name: "Impact Sparks VFX"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 0.4
                Y: 0.4
                Z: 0.4
              }
            }
            ParentId: 15676067918659116593
            UnregisteredParameters {
              Overrides {
                Name: "bp:Density"
                Float: 0.3
              }
              Overrides {
                Name: "bp:Particle Scale Multiplier"
                Float: 2
              }
              Overrides {
                Name: "bp:Spark Line Scale Multiplier"
                Float: 1
              }
              Overrides {
                Name: "bp:Enable Hotspot"
                Bool: true
              }
              Overrides {
                Name: "bp:Enable Flash"
                Bool: true
              }
              Overrides {
                Name: "bp:Enable Spark Lines"
                Bool: true
              }
              Overrides {
                Name: "bp:Enable Sparks"
                Bool: true
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Blueprint {
              BlueprintAsset {
                Id: 11887549032181544333
              }
              TeamSettings {
              }
              Vfx {
                AutoPlay: true
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 9519357983113725241
            Name: "Decal Bullet Damage Metal"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 0.1
                Y: 0.1
                Z: 0.1
              }
            }
            ParentId: 15676067918659116593
            UnregisteredParameters {
              Overrides {
                Name: "bp:Shape Index"
                Int: 0
              }
              Overrides {
                Name: "bp:Fade Delay"
                Float: 4
              }
              Overrides {
                Name: "bp:Fade Time"
                Float: 2
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Blueprint {
              BlueprintAsset {
                Id: 16471063547951275134
              }
              TeamSettings {
              }
              DecalBP {
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
      VirtualFolderPath: "Weapons"
      VirtualFolderPath: "Projectile"
      VirtualFolderPath: "Dependecies"
    }
    Assets {
      Id: 16471063547951275134
      Name: "Decal Bullet Damage Metal"
      PlatformAssetType: 14
      PrimaryAsset {
        AssetType: "DecalBlueprintAssetRef"
        AssetId: "bp_decal_bullet_metal_001"
      }
    }
    Assets {
      Id: 11887549032181544333
      Name: "Impact Sparks VFX"
      PlatformAssetType: 8
      PrimaryAsset {
        AssetType: "VfxBlueprintAssetRef"
        AssetId: "fxbp_impact_sparks"
      }
    }
    Assets {
      Id: 17144409617272687275
      Name: "Gun Impact Small VFX"
      PlatformAssetType: 8
      PrimaryAsset {
        AssetType: "VfxBlueprintAssetRef"
        AssetId: "fxbp_gun_impact_dirt_sm"
      }
    }
    Assets {
      Id: 3307794794401153799
      Name: "Impact Ground Dirt 01 SFX"
      PlatformAssetType: 7
      PrimaryAsset {
        AssetType: "AudioAssetRef"
        AssetId: "sfx_bullet_impact_ground_dirt_01_Cue_ref"
      }
    }
    Assets {
      Id: 5441335048714837920
      Name: "Generic Muzzle Flash"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 14475397580931583970
          Objects {
            Id: 14475397580931583970
            Name: "Generic Muzzle Flash"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            ChildIds: 4186545988497538470
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            NetworkContext {
              MinDetailLevel {
                Value: "mc:edetaillevel:low"
              }
              MaxDetailLevel {
                Value: "mc:edetaillevel:ultra"
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 4186545988497538470
            Name: "Generic Muzzleflash VFX"
            Transform {
              Location {
              }
              Rotation {
                Pitch: -90
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 14475397580931583970
            UnregisteredParameters {
              Overrides {
                Name: "bp:Particle Size Multiplier"
                Float: 1.2
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Blueprint {
              BlueprintAsset {
                Id: 16322635077100878811
              }
              Vfx {
                AutoPlay: true
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:high"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
      VirtualFolderPath: "Weapons"
      VirtualFolderPath: "Projectile"
      VirtualFolderPath: "Dependecies"
    }
    Assets {
      Id: 16322635077100878811
      Name: "Generic Muzzle Flash VFX"
      PlatformAssetType: 8
      PrimaryAsset {
        AssetType: "VfxBlueprintAssetRef"
        AssetId: "fxbp_generic_muzzleflash"
      }
    }
    Assets {
      Id: 13686915018416948746
      Name: "Generic Bullet"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 10801338030236837208
          Objects {
            Id: 10801338030236837208
            Name: "Generic Bullet"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            ChildIds: 12411949091338795968
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            NetworkContext {
              MinDetailLevel {
                Value: "mc:edetaillevel:low"
              }
              MaxDetailLevel {
                Value: "mc:edetaillevel:ultra"
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 12411949091338795968
            Name: "Bullet"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 10801338030236837208
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 9826710443425479508
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              DisableReceiveDecals: true
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
      VirtualFolderPath: "Weapons"
      VirtualFolderPath: "Projectile"
      VirtualFolderPath: "Dependecies"
    }
    Assets {
      Id: 9826710443425479508
      Name: "Modern Weapon Ammo - Bullet 01"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_weap_modern_ammo_bullet_tip_001"
      }
    }
    Assets {
      Id: 3687930860452606934
      Name: "Weapon Pistol 002"
      PlatformAssetType: 9
      PrimaryAsset {
        AssetType: "PlatformBrushAssetRef"
        AssetId: "UI_Military_Weapon_Pistol_002"
      }
    }
    Assets {
      Id: 16352106922200354611
      Name: "Rifle"
      PlatformAssetType: 33
      VirtualFolderPath: "Weapon Switcher"
      ItemAsset {
        CustomName: "Rifle"
        MaximumStackCount: 1
        ItemTemplateAssetId: 5873401194950168052
        CustomParameters {
          Overrides {
            Name: "cs:Slot"
            Int: 1
          }
          Overrides {
            Name: "cs:Icon"
            AssetReference {
              Id: 3029470344125914667
            }
          }
          Overrides {
            Name: "cs:Ammo"
            Int: 30
          }
          Overrides {
            Name: "cs:Ammo:isrep"
            Bool: true
          }
          Overrides {
            Name: "cs:Ammo:category"
            String: "Custom"
          }
          Overrides {
            Name: "cs:Ammo:subcategory"
            String: "Dynamic"
          }
          Overrides {
            Name: "cs:Slot:tooltip"
            String: "Slot that this item can only exist in the inventory. If set to 0 then it can go to any available slot."
          }
          Overrides {
            Name: "cs:Icon:tooltip"
            String: "Reference the icon related to this item. Setting nothing will show the name of the item in the slot."
          }
          Overrides {
            Name: "cs:Ammo:tooltip"
            String: "Dynamic property to reference the status of the weapon\'s ammo. By default, you should set the weapon\'s starting ammo."
          }
        }
      }
    }
    Assets {
      Id: 5873401194950168052
      Name: "Basic Assault Rifle"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 5545984700063622192
          Objects {
            Id: 5545984700063622192
            Name: "Basic Assault Rifle"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            ChildIds: 6091570635518507984
            ChildIds: 17342228179914680811
            ChildIds: 6668276427409425227
            ChildIds: 14554342770677881249
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Equipment {
              SocketName: "right_prop"
              PickupTrigger {
                SubObjectId: 6668276427409425227
              }
              Weapon {
                ProjectileAssetRef {
                  Id: 13686915018416948746
                }
                MuzzleFlashAssetRef {
                  Id: 5441335048714837920
                }
                TrailAssetRef {
                  Id: 9791663148394559353
                }
                ImpactAssetRef {
                  Id: 17438692118890248845
                }
                UseReticle: true
                Muzzle {
                  Location {
                    X: 75
                    Z: 14
                  }
                }
                AnimationSet: "2hand_rifle_stance"
                OutOfAmmoSfxAssetRef {
                  Id: 2185484604682618257
                }
                ReloadSfxAssetRef {
                  Id: 16788617737712185088
                }
                ShootAnimation: "2hand_rifle_shoot"
                ImpactProjectileAssetRef {
                  Id: 841534158063459245
                }
                BeamAssetRef {
                  Id: 841534158063459245
                }
                BurstCount: 30
                BurstDuration: 6.5
                BurstStopsWithRelease: true
                AttackCooldown: 0.25
                Range: 100000
                ImpactPlayerAssetRef {
                  Id: 7436194052653179954
                }
                ReticleType {
                  Value: "mc:ereticletype:crosshair"
                }
                AttackSfxAssetRef {
                  Id: 4087554182419681934
                }
                MaxAmmo: 30
                AmmoType: "rounds"
                MultiShot: 1
                ProjectileSpeed: 25000
                ProjectileLifeSpan: 10
                ProjectileLength: 50
                ProjectileRadius: 2
                SpreadMax: 3
                SpreadDecreaseSpeed: 5.5
                SpreadIncreasePerShot: 0.5
                SpreadPenaltyPerShot: 1
                DefaultAbility {
                  SubObjectId: 6091570635518507984
                }
                ReloadAbility {
                  SubObjectId: 17342228179914680811
                }
                Damage: 35
                WeaponTrajectoryMode {
                  Value: "mc:eweapontrajectorymode:muzzletolooktarget"
                }
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 6091570635518507984
            Name: "Shoot"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 5545984700063622192
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Ability {
              IsEnabled: true
              CastPhaseSettings {
                Duration: 0.03
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:aim"
                }
              }
              ExecutePhaseSettings {
                Duration: 0.05
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                IsTargetDataUpdated: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:aim"
                }
              }
              RecoveryPhaseSettings {
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:none"
                }
              }
              CooldownPhaseSettings {
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:none"
                }
              }
              Animation: "2hand_rifle_shoot"
              KeyBinding_v2 {
                Value: "mc:egameaction:invalid"
              }
              KeyBinding_v3: "Shoot"
              Version: 3
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 17342228179914680811
            Name: "Reload"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 5545984700063622192
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Ability {
              IsEnabled: true
              CastPhaseSettings {
                Duration: 2.3
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:aim"
                }
              }
              ExecutePhaseSettings {
                Duration: 0.1
                CanMove: true
                CanJump: true
                CanRotate: true
                PreventOtherAbilities: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:aim"
                }
              }
              RecoveryPhaseSettings {
                CanMove: true
                CanJump: true
                CanRotate: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:none"
                }
              }
              CooldownPhaseSettings {
                CanMove: true
                CanJump: true
                CanRotate: true
                Facing_V2 {
                  Value: "mc:eabilitysetfacing:none"
                }
              }
              Animation: "2hand_rifle_reload_magazine"
              KeyBinding_v2 {
                Value: "mc:egameaction:invalid"
              }
              KeyBinding_v3: "Reload"
              Version: 3
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 6668276427409425227
            Name: "PickupTrigger"
            Transform {
              Location {
                X: 36.1711121
              }
              Rotation {
              }
              Scale {
                X: 1.63968229
                Y: 1
                Z: 1
              }
            }
            ParentId: 5545984700063622192
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:alwaysvisible"
            }
            Trigger {
              Interactable: true
              InteractionLabel: "Equip Basic Assault Rifle"
              TeamSettings {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              TriggerShape_v2 {
                Value: "mc:etriggershape:box"
              }
              InteractionTemplate {
              }
              BreadcrumbTemplate {
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 14554342770677881249
            Name: "Client Art"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 5545984700063622192
            ChildIds: 16736873860049042069
            UnregisteredParameters {
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            NetworkContext {
              MinDetailLevel {
                Value: "mc:edetaillevel:low"
              }
              MaxDetailLevel {
                Value: "mc:edetaillevel:ultra"
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 16736873860049042069
            Name: "Geo"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 14554342770677881249
            ChildIds: 6391985750929905195
            ChildIds: 386011570158853906
            ChildIds: 10314890168954540014
            ChildIds: 6650241278264957551
            ChildIds: 9148359569688519204
            ChildIds: 15782437113296890346
            ChildIds: 8504565566456572736
            ChildIds: 15559417034723150746
            ChildIds: 1208037343488797634
            ChildIds: 14443026923989956536
            ChildIds: 9016971475337091938
            ChildIds: 464864758065346906
            ChildIds: 3190742588465447918
            ChildIds: 5642998436046435026
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Folder {
              IsGroup: true
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 6391985750929905195
            Name: "Modern Weapon - Sight Rear 01"
            Transform {
              Location {
                X: 1.5038271
                Y: -2.48977121e-05
                Z: 19.4978199
              }
              Rotation {
              }
              Scale {
                X: 1.14191353
                Y: 0.992392719
                Z: 1.20455921
              }
            }
            ParentId: 16736873860049042069
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 9117384065423546074
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              DisableReceiveDecals: true
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 386011570158853906
            Name: "Modern Weapon Accessory - Rail 02"
            Transform {
              Location {
                X: 53.3851547
                Y: -2.48977121e-05
                Z: 14.1252508
              }
              Rotation {
                Yaw: 179.999954
                Roll: 179.999954
              }
              Scale {
                X: 0.959740639
                Y: 0.782231212
                Z: 1
              }
            }
            ParentId: 16736873860049042069
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 12637801335342129827
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              DisableReceiveDecals: true
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 10314890168954540014
            Name: "Modern Weapon - Sight Forward 02"
            Transform {
              Location {
                X: 50.9217682
                Y: -2.48977121e-05
                Z: 19.4132023
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 16736873860049042069
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 6045540826292531006
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              DisableReceiveDecals: true
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 6650241278264957551
            Name: "Modern Weapon - Body 01"
            Transform {
              Location {
                X: 13.5848665
                Y: -2.48977121e-05
                Z: 13.7886019
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 16736873860049042069
            UnregisteredParameters {
              Overrides {
                Name: "ma:Shared_BaseMaterial:color"
                Color {
                  R: 0.205078766
                  G: 0.205078766
                  B: 0.205078766
                  A: 1
                }
              }
              Overrides {
                Name: "ma:Shared_Trim:color"
                Color {
                  R: 0.205078766
                  G: 0.205078766
                  B: 0.205078766
                  A: 1
                }
              }
              Overrides {
                Name: "ma:Shared_Detail1:id"
                AssetReference {
                  Id: 3702191406046426907
                }
              }
              Overrides {
                Name: "ma:Shared_Detail1:color"
                Color {
                  R: 0.0423114114
                  G: 0.258182913
                  B: 0.644479871
                  A: 1
                }
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 13077624968254610965
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              DisableReceiveDecals: true
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 9148359569688519204
            Name: "Modern Weapon - Barrel Tip 01"
            Transform {
              Location {
                X: 52.6301041
                Y: -2.48977121e-05
                Z: 13.7886019
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 16736873860049042069
            UnregisteredParameters {
              Overrides {
                Name: "ma:Shared_Trim:color"
                Color {
                  R: 0.09375
                  G: 0.09375
                  B: 0.09375
                  A: 1
                }
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 8307003537298922985
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              DisableReceiveDecals: true
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 15782437113296890346
            Name: "Modern Weapon - Gas Cylinder 01"
            Transform {
              Location {
                X: 27.3357468
                Y: -2.48977121e-05
                Z: 13.7886019
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 16736873860049042069
            UnregisteredParameters {
              Overrides {
                Name: "ma:Shared_BaseMaterial:color"
                Color {
                  R: 0.205078766
                  G: 0.205078766
                  B: 0.205078766
                  A: 1
                }
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 7024490427461832088
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              DisableReceiveDecals: true
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 8504565566456572736
            Name: "Modern Weapon Accessory - Rail 02"
            Transform {
              Location {
                X: 27.399662
                Y: -2.48977121e-05
                Z: 13.7886019
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 16736873860049042069
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 12637801335342129827
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              DisableReceiveDecals: true
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 15559417034723150746
            Name: "Modern Weapon Accessory - Rail 01"
            Transform {
              Location {
                X: 3.33459187
                Y: -2.48977121e-05
                Z: 19.5140018
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 0.89708668
                Z: 1
              }
            }
            ParentId: 16736873860049042069
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 13442965192408425307
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              DisableReceiveDecals: true
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 1208037343488797634
            Name: "Modern Weapon - Stock 01"
            Transform {
              Location {
                X: -2.22470856
                Y: -2.48977121e-05
                Z: 15.5089273
              }
              Rotation {
              }
              Scale {
                X: 1.13179314
                Y: 1
                Z: 1
              }
            }
            ParentId: 16736873860049042069
            UnregisteredParameters {
              Overrides {
                Name: "ma:Shared_BaseMaterial:color"
                Color {
                  R: 0.205078766
                  G: 0.205078766
                  B: 0.205078766
                  A: 1
                }
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 499697514733272876
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              DisableReceiveDecals: true
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 14443026923989956536
            Name: "Modern Weapon - Magazine 01"
            Transform {
              Location {
                X: 23.1359062
                Y: -1.72683176e-05
                Z: -4.01969242
              }
              Rotation {
                Pitch: 16.2499886
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 16736873860049042069
            UnregisteredParameters {
              Overrides {
                Name: "ma:Shared_Detail1:color"
                Color {
                  R: 0.0423114114
                  G: 0.258182913
                  B: 0.644479871
                  A: 1
                }
              }
              Overrides {
                Name: "ma:Shared_Detail1:id"
                AssetReference {
                  Id: 3702191406046426907
                }
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 6183130606669934264
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              DisableReceiveDecals: true
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 9016971475337091938
            Name: "Modern Weapon - Grip 01"
            Transform {
              Location {
                X: 2.79868603
                Y: -2.48977121e-05
                Z: 5.86524868
              }
              Rotation {
                Pitch: -19.9999943
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 16736873860049042069
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 13155471131385409602
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              DisableReceiveDecals: true
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 464864758065346906
            Name: "Modern Weapon Accessory - Rail 01"
            Transform {
              Location {
                X: 29.2020073
                Y: 5.64531612
                Z: 13.8066206
              }
              Rotation {
                Roll: 89.9999542
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 16736873860049042069
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 13442965192408425307
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              DisableReceiveDecals: true
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 3190742588465447918
            Name: "Modern Weapon Accessory - Rail 01"
            Transform {
              Location {
                X: 29.2020073
                Y: -5.64502478
                Z: 13.8066206
              }
              Rotation {
                Roll: -89.9999924
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 16736873860049042069
            UnregisteredParameters {
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 13442965192408425307
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              DisableReceiveDecals: true
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 5642998436046435026
            Name: "Trigger - Rear"
            Transform {
              Location {
                X: 9.52880859
                Y: -2.48977121e-05
                Z: 7.81673908
              }
              Rotation {
                Yaw: -90
                Roll: 10.0530453
              }
              Scale {
                X: 0.0110827358
                Y: 0.0295748301
                Z: 0.0530300215
              }
            }
            ParentId: 16736873860049042069
            UnregisteredParameters {
              Overrides {
                Name: "ma:Shared_BaseMaterial:id"
                AssetReference {
                  Id: 132672053610873933
                }
              }
              Overrides {
                Name: "ma:Shared_BaseMaterial:color"
                Color {
                  R: 0.149
                  G: 0.149
                  B: 0.149
                  A: 1
                }
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:forceoff"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:forceoff"
            }
            CoreMesh {
              MeshAsset {
                Id: 16965777294932964901
              }
              Teams {
                IsTeamCollisionEnabled: true
                IsEnemyCollisionEnabled: true
              }
              DisableReceiveDecals: true
              InteractWithTriggers: true
              StaticMesh {
                Physics {
                }
                BoundsScale: 1
              }
            }
            Relevance {
              Value: "mc:eproxyrelevance:critical"
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
      VirtualFolderPath: "Weapons"
      VirtualFolderPath: "Projectile"
    }
    Assets {
      Id: 13155471131385409602
      Name: "Modern Weapon - Grip 01"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_weap_modern_grip_001"
      }
    }
    Assets {
      Id: 6183130606669934264
      Name: "Modern Weapon - Magazine 01"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_weap_modern_mag_001"
      }
    }
    Assets {
      Id: 499697514733272876
      Name: "Modern Weapon - Stock 01"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_weap_modern_stock_001"
      }
    }
    Assets {
      Id: 13442965192408425307
      Name: "Modern Weapon Accessory - Rail 01"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_weap_modern_acc_rail_001"
      }
    }
    Assets {
      Id: 7024490427461832088
      Name: "Modern Weapon - Gas Cylinder 01"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_weap_modern_gas_cylinder_001"
      }
    }
    Assets {
      Id: 8307003537298922985
      Name: "Modern Weapon - Barrel Tip 01"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_weap_modern_barreltip_001"
      }
    }
    Assets {
      Id: 13077624968254610965
      Name: "Modern Weapon - Body 01"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_weap_modern_body_001"
      }
    }
    Assets {
      Id: 6045540826292531006
      Name: "Modern Weapon - Sight Forward 02"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_weap_modern_sight_forw_002"
      }
    }
    Assets {
      Id: 12637801335342129827
      Name: "Modern Weapon Accessory - Rail 02"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_weap_modern_acc_rail_002"
      }
    }
    Assets {
      Id: 4087554182419681934
      Name: "Rifle Attack Sound"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 11736491869790306490
          Objects {
            Id: 11736491869790306490
            Name: "Rifle Muzzle Flash"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            ChildIds: 14954116362281898619
            ChildIds: 10002870687909774377
            UnregisteredParameters {
            }
            Lifespan: 2.5
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            NetworkContext {
              MinDetailLevel {
                Value: "mc:edetaillevel:low"
              }
              MaxDetailLevel {
                Value: "mc:edetaillevel:ultra"
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 14954116362281898619
            Name: "Gunshot Assault Rifle Carbine Set 01 SFX"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 11736491869790306490
            UnregisteredParameters {
              Overrides {
                Name: "bp:Enable Dynamic Distant Sound"
                Bool: true
              }
              Overrides {
                Name: "bp:Type"
                Enum {
                  Value: "mc:esfx_gunshot_assaultrifle_carbine:3"
                }
              }
              Overrides {
                Name: "bp:Main Sound Mix Medium Distance Type"
                Enum {
                  Value: "mc:esfx_gunshot_assaultrifle_carbine:3"
                }
              }
              Overrides {
                Name: "bp:Medium Sound Cutoff Distance"
                Float: 2500
              }
              Overrides {
                Name: "bp:Far Sound Cutoff Distance"
                Float: 3500
              }
              Overrides {
                Name: "bp:Main Sound Mix Far Distance Type"
                Enum {
                  Value: "mc:esfx_gunshot_assaultrifle_carbine:17"
                }
              }
              Overrides {
                Name: "bp:Far Distant Sound Type"
                Enum {
                  Value: "mc:esfx_distant_gunshot_set:29"
                }
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Blueprint {
              BlueprintAsset {
                Id: 8182959108075168199
              }
              TeamSettings {
              }
              AudioBP {
                AutoPlay: true
                Pitch: 100
                Volume: 1
                Falloff: 5500
                Radius: 400
                EnableOcclusion: true
                IsSpatializationEnabled: true
                IsAttenuationEnabled: true
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
          Objects {
            Id: 10002870687909774377
            Name: "Gunshot Assault Rifle Carbine Set 01 SFX"
            Transform {
              Location {
              }
              Rotation {
              }
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 11736491869790306490
            UnregisteredParameters {
              Overrides {
                Name: "bp:Enable Dynamic Distant Sound"
                Bool: false
              }
              Overrides {
                Name: "bp:Type"
                Enum {
                  Value: "mc:esfx_gunshot_assaultrifle_carbine:20"
                }
              }
              Overrides {
                Name: "bp:Main Sound Mix Medium Distance Type"
                Enum {
                  Value: "mc:esfx_gunshot_assaultrifle_carbine:3"
                }
              }
              Overrides {
                Name: "bp:Medium Sound Cutoff Distance"
                Float: 2500
              }
              Overrides {
                Name: "bp:Far Sound Cutoff Distance"
                Float: 3500
              }
            }
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Blueprint {
              BlueprintAsset {
                Id: 8182959108075168199
              }
              TeamSettings {
              }
              AudioBP {
                AutoPlay: true
                Pitch: 100
                Volume: 0.9
                Falloff: 1200
                Radius: 800
                EnableOcclusion: true
                IsSpatializationEnabled: true
                IsAttenuationEnabled: true
              }
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
      VirtualFolderPath: "Weapons"
      VirtualFolderPath: "Projectile"
      VirtualFolderPath: "Dependecies"
    }
    Assets {
      Id: 8182959108075168199
      Name: "Gunshot Assault Rifle Carbine Set 01 SFX"
      PlatformAssetType: 10
      PrimaryAsset {
        AssetType: "AudioBlueprintAssetRef"
        AssetId: "sfxabp_gunshot_assaultrifle_carbine_ref"
      }
    }
    Assets {
      Id: 3029470344125914667
      Name: "Weapon Assault Rifle 010"
      PlatformAssetType: 9
      PrimaryAsset {
        AssetType: "PlatformBrushAssetRef"
        AssetId: "UI_Military_Weapon_AssaultRifle_010"
      }
    }
    Assets {
      Id: 16052791129926391597
      Name: "Weapon Inventory"
      PlatformAssetType: 5
      TemplateAsset {
        ObjectBlock {
          RootId: 17561304694505953885
          Objects {
            Id: 17561304694505953885
            Name: "Weapon Inventory"
            Transform {
              Scale {
                X: 1
                Y: 1
                Z: 1
              }
            }
            ParentId: 4781671109827199097
            UnregisteredParameters {
              Overrides {
                Name: "cs:ActiveSlot"
                Int: 1
              }
              Overrides {
                Name: "cs:ActiveSlot:isrep"
                Bool: true
              }
            }
            WantsNetworking: true
            Collidable_v2 {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            Visible_v2 {
              Value: "mc:evisibilitysetting:inheritfromparent"
            }
            CameraCollidable {
              Value: "mc:ecollisionsetting:inheritfromparent"
            }
            EditorIndicatorVisibility {
              Value: "mc:eindicatorvisibility:visiblewhenselected"
            }
            Inventory {
              InventoryNumSlots: 3
              PickupItemsOnStart: true
            }
            NetworkRelevanceDistance {
              Value: "mc:eproxyrelevance:critical"
            }
            IsReplicationEnabledByDefault: true
          }
        }
        PrimaryAssetId {
          AssetType: "None"
          AssetId: "None"
        }
      }
      VirtualFolderPath: "Weapon Switcher"
    }
    Assets {
      Id: 736360303936294653
      Name: "Default Bindings"
      PlatformAssetType: 29
      BindingSetAsset {
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:spacebar"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:a"
              }
            }
          }
          Action: "Jump"
          Description: "Make the character jump."
          CoreBehavior {
            Value: "mc:ecorebehavior:jump"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:leftcontrol"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:c"
              }
              Controller {
                Value: "mc:ebindinggamepad:b"
              }
            }
          }
          Action: "Crouch"
          Description: "Enter crouch mode."
          CoreBehavior {
            Value: "mc:ecorebehavior:crouch"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:g"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:dpadup"
              }
            }
          }
          Action: "Mount"
          Description: "Enter mount mode."
          CoreBehavior {
            Value: "mc:ecorebehavior:mount"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:f"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:x"
              }
            }
          }
          Action: "Interact"
          Description: "Interact with triggers."
          CoreBehavior {
            Value: "mc:ecorebehavior:interact"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:enter"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:none"
              }
            }
          }
          Action: "Chat"
          Description: "Opens chat dialog and social menu."
          CoreBehavior {
            Value: "mc:ecorebehavior:chat"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:tilde"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:middleclick"
              }
              Controller {
                Value: "mc:ebindinggamepad:view"
              }
            }
          }
          Action: "Slot Picker"
          Description: "Reopens last opened picker menu."
          CoreBehavior {
            Value: "mc:ecorebehavior:slotpicker"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:directional"
          }
          DirectionalBindingData {
            UpInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:w"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:leftstickup"
              }
            }
            LeftInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:a"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:leftstickleft"
              }
            }
            DownInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:s"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:leftstickdown"
              }
            }
            RightInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:d"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:leftstickright"
              }
            }
          }
          Action: "Move"
          Description: "Moves the character."
          CoreBehavior {
            Value: "mc:ecorebehavior:move"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:axis"
          }
          AxisBindingData {
            IncreaseInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:spacebar"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:a"
              }
            }
            DecreaseInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:leftcontrol"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:c"
              }
              Controller {
                Value: "mc:ebindinggamepad:b"
              }
            }
          }
          Action: "Move Vertically"
          Description: "Fly or swim vertically up and down."
          CoreBehavior {
            Value: "mc:ecorebehavior:movevertically"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:directional"
          }
          DirectionalBindingData {
            UpInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:mouseup"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:rightstickup"
              }
            }
            LeftInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:mouseleft"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:rightstickleft"
              }
            }
            DownInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:mousedown"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:rightstickdown"
              }
            }
            RightInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:mouseright"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:rightstickright"
              }
            }
          }
          Action: "Look"
          Description: "Controls the camera."
          CoreBehavior {
            Value: "mc:ecorebehavior:look"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:axis"
          }
          AxisBindingData {
            IncreaseInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:scrolldown"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:rightbumper"
              }
            }
            DecreaseInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:scrollup"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:leftbumper"
              }
            }
          }
          Action: "Zoom"
          Description: "Zoom in or out with the camera."
          CoreBehavior {
            Value: "mc:ecorebehavior:zoom"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:leftalt"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:none"
              }
            }
          }
          Action: "Push-to-Talk"
          Description: "Toggle voice chat mode."
          CoreBehavior {
            Value: "mc:ecorebehavior:pushtotalk"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:leftclick"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:righttrigger"
              }
            }
          }
          Action: "Shoot"
          Description: "Shoot ability of weapon or equipment."
          CoreBehavior {
            Value: "mc:ecorebehavior:weapon"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:rightclick"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:lefttrigger"
              }
            }
          }
          Action: "Aim"
          Description: "Weapon or equipment aiming."
          CoreBehavior {
            Value: "mc:ecorebehavior:weapon"
          }
          Networked: true
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:r"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:y"
              }
            }
          }
          Action: "Reload"
          Description: "Reload ability on weapons."
          CoreBehavior {
            Value: "mc:ecorebehavior:weapon"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:leftclick"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:x"
              }
            }
          }
          Action: "Attack"
          Description: "Attack ability for melee weapons or equipment."
          CoreBehavior {
            Value: "mc:ecorebehavior:equipment"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:w"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:righttrigger"
              }
            }
          }
          Action: "Vehicle Accelerate"
          Description: "When driving, accelerate forward."
          CoreBehavior {
            Value: "mc:ecorebehavior:vehicleaccelerate"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:s"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:lefttrigger"
              }
            }
          }
          Action: "Vehicle Reverse"
          Description: "When driving, stop the vehicle and reverse."
          CoreBehavior {
            Value: "mc:ecorebehavior:vehiclereverse"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:axis"
          }
          AxisBindingData {
            IncreaseInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:d"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:leftstickright"
              }
            }
            DecreaseInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:a"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:leftstickleft"
              }
            }
          }
          Action: "Vehicle Turn"
          Description: "When driving, turn the vehicle."
          CoreBehavior {
            Value: "mc:ecorebehavior:vehicleturn"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:spacebar"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:b"
              }
            }
          }
          Action: "Vehicle Handbrake"
          Description: "When driving, apply the handbrake."
          CoreBehavior {
            Value: "mc:ecorebehavior:vehiclehandbrake"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:leftclick"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:a"
              }
            }
          }
          Action: "Vehicle Shoot"
          Description: "Shoot ability on vehicle."
          CoreBehavior {
            Value: "mc:ecorebehavior:vehicle"
          }
          IsEnabledOnStart: true
        }
        Bindings {
          BindingType {
            Value: "mc:ebindingtype:basic"
          }
          BasicBindingData {
            BasicInputs {
              KeyboardPrimary {
                Value: "mc:ebindingkeyboard:f"
              }
              KeyboardSecondary {
                Value: "mc:ebindingkeyboard:none"
              }
              Controller {
                Value: "mc:ebindinggamepad:x"
              }
            }
          }
          Action: "Vehicle Exit"
          Description: "When driving, exit the vehicle."
          CoreBehavior {
            Value: "mc:ecorebehavior:vehicleexit"
          }
          IsEnabledOnStart: true
        }
      }
    }
    PrimaryAssetId {
      AssetType: "None"
      AssetId: "None"
    }
  }
  Marketplace {
    Id: "7d4c23a195d1445a9836e523ccc638e6"
    OwnerAccountId: "bd602d5201b04b3fbf7be10f59c8f974"
    OwnerName: "CoreAcademy"
  }
  SerializationVersion: 119
}
IncludesAllDependencies: true
