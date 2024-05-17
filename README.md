# qwz_hunting
Simple Hunting System

## !!!ATTENTION!!!

Its a simple script with simple shop to sell items you get from animals
By default anyone can kill and slaughter animals if he finds it.
You can enable or disable hunting zones in config section to use bait only in this zones.

##  !!!THERE IS NO IMAGES FOR ITEMS!!!!

## INSTALLATION
 - Download the latest realese
 - Just place `qwz_hunting` in your server scripts folder and ensure it!
 - Add to your `qb-core/shared/items.lua` items:
 ```lua
 	["huntingbait"] 		 			 = {["name"] = "huntingbait",       	    	["label"] = "Hunt Bait",	 ["weight"] = 150, 		["type"] = "item", 		["image"] = "huntingbait.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,   ["combinable"] = nil,   ["description"] = "Hunting Bait"},
 ```
 - Add some items like `meat` or `deerhorns` in the same way as you add `huntingbait`

## REQUIREMENTS
 - `qb-core`
 - `ox_lib`
 - `ox_target` or `qb-target`

## Config

In the config you can find all you need. This is example with some explanation

```lua
Config.MinSpawnDistance = 60 -- Here you can set minimum distance to spawn an animal
Config.MaxSpawnDistance = 100 -- Here you can set maximum distance to spawn an animal

Config.UsingBaitTimeount = 60 -- Time cooldown in seconds for using bait

Config.AnimalsFleeView = 30.0 -- Area from where animals will start to flee
Config.AnimalsFleeDistance = 50.0 -- Distance from where animals will start to flee
Config.AnimalsFleeTime = 5 -- Time in seconds how long animals will fleeing

Config.BaitPlacementSpeed = 6 -- Time in seconds for placing bait
Config.SlaughteringSpeed = 6 -- Time in seconds for slaughtering
```

Adding an animal to list

```lua
['a_c_boar'] = { -- Animal model name
    rewards = {
        {name = 'meat', chance = 100, min = 1, max = 5}, -- Item name, chance to get, min and max amount
    }
},
```

This part responsible for Shop data. You can add multiple shops

```lua
Config.MoneyItem = 'casinochips' -- Money item name
Config.ShopData = {
    ['shop1'] = { -- Shop name
        coords = vector4(2015.59, 3073.8, 47.07, 148.82), -- Shop coords
        pedModel = 'g_m_m_chicold_01', -- Ped model
        items = {
            {name = 'meat', price = 10}, -- Item name and sell price
            {name = 'meatdeer', price = 20},
        }
    }
}
```

You can add Hunting Zones with `Config.EnableHuntingZones = true`

```lua
Config.EnableHuntingZones = true -- Enable or disable Hunting Zones
Config.HuntingZones = {
    ['zone1'] = { -- Hunting zone unique name
        coords = vector3(1388.2, 2637.7, 46.18), -- Hunting zone coords
        radius = 250.0, -- Hunting zone radius
        showBlip = true, -- Show or hide Hunting zone blip
        name = 'Hunting Zone 1', -- Hunting zone name
        radiusBlip = true -- Show or hide Hunting zone radius blip
    },
}
```
