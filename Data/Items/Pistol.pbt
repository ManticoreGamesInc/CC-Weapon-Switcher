Assets {
  Id: 1735943184043934463
  Name: "Pistol"
  PlatformAssetType: 33
  SerializationVersion: 119
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
    Assets {
      Id: 3687930860452606934
      Name: "Weapon Pistol 002"
      PlatformAssetType: 9
      PrimaryAsset {
        AssetType: "PlatformBrushAssetRef"
        AssetId: "UI_Military_Weapon_Pistol_002"
      }
    }
  }
}
