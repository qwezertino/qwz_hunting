--[[ Default Config Settings ]]
                                --
Config  = {}

Config.Debug = false

Config.UseQBTarget = true
Config.BaitItem = 'huntingbait'

Config.MinSpawnDistance = 60
Config.MaxSpawnDistance = 100

Config.UsingBaitTimeount = 60 -- in seconds

Config.AnimalsFleeView = 30.0
Config.AnimalsFleeDistance = 50.0
Config.AnimalsFleeTime = 5 -- in seconds

Config.BaitPlacementSpeed = 6 -- in seconds
Config.SlaughteringSpeed = 6 -- in seconds

Config.Animations = {
    ['slughter'] = {
        animDict = 'anim@gangops@facility@servers@bodysearch@',
        animName = 'player_search',
    },
    ['bait'] = {
        animDict = 'anim@gangops@facility@servers@bodysearch@',
        animName = 'player_search',
    }
}

Config.AnimalsData = {
    ['a_c_boar'] = {
        rewards = {
            {name = 'meat', chance = 100, min = 1, max = 5},
        }
    },
    ['a_c_deer'] = {
        rewards = {
            {name = 'meat', chance = 100, min = 1, max = 5},
            {name = 'meatdeer', chance = 100, min = 1, max = 5},
        }
    }
}

Config.MoneyItem = 'casinochips'
Config.ShopData = {
    ['shop1'] = {
        coords = vector4(2015.59, 3073.8, 47.07, 148.82),
        pedModel = 'g_m_m_chicold_01',
        items = {
            {name = 'meat', price = 10},
            {name = 'meatdeer', price = 20},
        }
    }
}

Config.EnableHuntingZones = true
Config.HuntingZones = {
    ['zone1'] = {
        coords = vector3(1388.2, 2637.7, 46.18),
        radius = 250.0,
        showBlip = true,
        name = 'Hunting Zone 1',
        radiusBlip = true
    },
}

-- Config.AnimalModelsList = {
--     [`a_c_boar`] = true,
--     [`a_c_cat_01`] = true,
--     [`a_c_chickenhawk`] = true,
--     [`a_c_chimp`] = true,
--     [`a_c_chop`] = true,
--     [`a_c_cormorant`] = true,
--     [`a_c_cow`] = true,
--     [`a_c_coyote`] = true,
--     [`a_c_crow`] = true,
--     [`a_c_deer`] = true,
--     [3630914197] = true, --another deer
--     [`a_c_dolphin`] = true,
--     [`a_c_fish`] = true,
--     [`a_c_hen`] = true,
--     [`a_c_humpback`] = true,
--     [`a_c_husky`] = true,
--     [`a_c_killerwhale`] = true,
--     [`a_c_mtlion`] = true,
--     [`a_c_pig`] = true,
--     [`a_c_pigeon`] = true,
--     [`a_c_poodle`] = true,
--     [`a_c_pug`] = true,
--     [`a_c_rabbit_01`] = true,
--     [`a_c_rat`] = true,
--     [`a_c_retriever`] = true,
--     [`a_c_rhesus`] = true,
--     [`a_c_rottweiler`] = true,
--     [`a_c_seagull`] = true,
--     [`a_c_sharkhammer`] = true,
--     [`a_c_sharktiger`] = true,
--     [`a_c_shepherd`] = true,
--     [`a_c_stingray`] = true,
--     [`a_c_westy`] = true,
-- }