<div align="center">

# Weapon Switcher

[![Build Status](https://github.com/ManticoreGamesInc/CC-Weapon-Switcher/workflows/CI/badge.svg)](https://github.com/ManticoreGamesInc/CC-Weapon-Switcher/actions/workflows/ci.yml?query=workflow%3ACI%29)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/ManticoreGamesInc/CC-Weapon-Switcher?style=plastic)

![Preview](/Screenshots/weaponswitcher.png)

</div>


## Finding the Component

This component can be found under the **CoreAcademy** account on Community Content.

## Overview

Weapon Switcher is a template that allows players to switch between multiple weapons.

The template uses the inventory and item components, as well as data tables. The player will be assigned a new inventory and be given weapons at the start of the game. A UI will be created to display the current weapons the player has in their inventory. The template also includes a binding set of actions for switching weapons.

This template works with the Weapon Spawner template.

## Note

If the Dependent folders are empty in Project Content under Imported Content for this component, save and reload the project to fix it.

## Setup

Drag and drop the Weapon Switcher template into the Hierarchy.

Preview the project and use "Q", "E", "1", "2", or "3" to switch weapons.

## How to use this Template

### Custom Properties

The root object of the template has 3 custom properties.

- Weapon Inventory

A template of an inventory that each player will be assigned to hold the weapon slots.

- Starting Inventory Table

A data table of weapon items that each player will be assigned at the start of the game.

- Spacing

The distance each UI weapon slot will be spaced from each other.

### Creating a Weapon Item

1. Create a new template for the weapon equipment.

2. In Project Content window, create a new item asset.

3. Assign it a name and select the item asset to see its Properties.

4. Drag and drop the weapon equipment template into the Item Template property.

5. Add 3 custom properties to the Item Asset.

--- 5a. Name: "Slot", Type: Int, The slot number that this weapon will occupy when equipped.

--- 5b. Name: "Icon", Type: Asset Reference, The 2d icon that will display on the UI

--- 5c. Name: "Ammo", Type: Int, A reference for the amount of ammo which should equal the starting ammo amount. Do not add if ammo is not required (sword for example).

6. Right click the Ammo custom property, and select the Enable Dynamic Property option.

7. Open the Starting Weapon Inventory data table and drag the Item Asset into one of the rows.

### Change Inventory Slots

To change the amount of inventory slots, the Weapon Inventory template needs to be updated.

1. From Project Content, drag and drop the Weapon Inventory template into the Hierarchy.

2. Select the Weapon Inventory object and open the Properties window.

3. Set the Slot Count property to the desired amount.

4. Right click the Weapon Inventory object and Update Template From Object.

5. Delete the Weapon Inventory object from the Hierarchy.

### Events

The server script is connected to an event for the player to equip a new weapon
and add the item to the inventory. The syntax is as follows:

`Events.Broadcast("AddInventoryWeapon", weapon, item)`
