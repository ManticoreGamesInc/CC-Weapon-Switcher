--[[
 __          __                             _____         _ _       _               
 \ \        / /                            / ____|       (_) |     | |              
  \ \  /\  / /__  __ _ _ __   ___  _ __   | (_____      ___| |_ ___| |__   ___ _ __ 
   \ \/  \/ / _ \/ _` | '_ \ / _ \| '_ \   \___ \ \ /\ / / | __/ __| '_ \ / _ \ '__|
    \  /\  /  __/ (_| | |_) | (_) | | | |  ____) \ V  V /| | || (__| | | |  __/ |   
     \/  \/ \___|\__,_| .__/ \___/|_| |_| |_____/ \_/\_/ |_|\__\___|_| |_|\___|_|   
                      | |                                                           
                      |_|                                                           

Weapon Switcher is a template that allows players to switch between multiple weapons.

The template uses the inventory and item components, as well as data tables. The player
will be assigned a new inventory and be given weapons at the start of the game. A UI
will be created to display the current weapons the player has in their inventory.
The template also includes a binding set of actions for switching weapons.

This template works with the Weapon Spawner template.

=====
Setup
=====

Drag and drop the Weapon Switcher template into the Hierarchy.

Preview the project and use "Q", "E", "1", "2", or "3" to switch weapons.

==========
How to Use
==========

=================
Custom Properties
=================

The root object of the template has 3 custom properties.

- Weapon Inventory

A template of an inventory that each player will be assigned to hold the weapon slots.

- Starting Inventory Table

A data table of weapon items that each player will be assigned at the start of the game.

- Spacing

The distance each UI weapon slot will be spaced from each other.

======================
Creating a Weapon Item
======================

1. Add a new networked weapon template to the Project Content.

2. Find the Weapon Switcher items in the Project Content.

3. Duplicate one of the items and rename to the new weapon name.

4. Select the new item and open the Properties window.

5. Change the item's properties (Item Template, Slot, Icon, Ammo).

6. Open the Starting Weapon Inventory data table and add the new item.

======================
Change Inventory Slots
======================

To change the amount of inventory slots, the Weapon Inventory template needs to be updated.

1. From Project Content, drag and drop the Weapon Inventory template into the Hierarchy.

2. Select the Weapon Inventory object and open the Properties window.

3. Set the Slot Count property to the desired amount.

4. Right click the Weapon Inventory object and Update Template From Object.

5. Delete the Weapon Inventory object from the Hierarchy.

======
Events
======

The server script is connected to an event for the player to equip a new weapon
and add the item to the inventory. The syntax is as follows:

`Events.Broadcast("AddInventoryWeapon", weapon, item)`

]]--