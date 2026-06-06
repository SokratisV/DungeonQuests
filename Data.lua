local ADDON, ns = ...

-- The curated dungeon catalog. This is the ONLY hand-maintained data in the
-- addon: which quests "belong" to which dungeon. Everything else (quest names,
-- levels, factions, quest-givers, prerequisites, pickup coordinates) is read
-- live from Questie at runtime -- see Questie.lua.
--
-- Each quest is { id = <questID>, name = "<expected name>" }. The expected name
-- is only used as a fallback label and by "/dq validate" to flag any ID whose
-- Questie name doesn't match (i.e. a wrong ID). Questie's name is authoritative
-- when present.
--
-- To add a dungeon: append an entry below and fill in its `quests` list.

ns.dungeons = {
    --------------------------------------------------------------------
    -- CLASSIC
    --------------------------------------------------------------------
    { key = "rfc",    name = "Ragefire Chasm",            expansion = "Classic", minLevel = 13, maxLevel = 18, zone = "Orgrimmar",            quests = {
        { id = 5722, name = "Searching for the Lost Satchel" },
        { id = 5723, name = "Testing an Enemy's Strength" },
        { id = 5724, name = "Returning the Lost Satchel" },
        { id = 5725, name = "The Power to Destroy..." },
        { id = 5761, name = "Slaying the Beast" },
        { id = 5726, name = "Hidden Enemies" },
        { id = 5727, name = "Hidden Enemies" },
        { id = 5728, name = "Hidden Enemies" },
        { id = 5729, name = "Hidden Enemies" },
        { id = 5730, name = "Hidden Enemies" },
    } },
    { key = "wc",     name = "Wailing Caverns",           expansion = "Classic", minLevel = 17, maxLevel = 24, zone = "The Barrens",         quests = {
        { id = 865,  name = "Raptor Horns" },
        { id = 959,  name = "Trouble at the Docks" },
        { id = 1486, name = "Deviate Hides" },
        { id = 1487, name = "Deviate Eradication" },
        { id = 1491, name = "Smart Drinks" },
        { id = 6981, name = "The Glowing Shard" },
        { id = 962,  name = "Serpentbloom" },
        { id = 3369, name = "In Nightmares" },               -- Horde
        { id = 3370, name = "In Nightmares" },               -- Alliance
        { id = 886,  name = "The Barrens Oases" },
        { id = 870,  name = "The Forgotten Pools" },
        { id = 877,  name = "The Stagnant Oasis" },
        { id = 880,  name = "Altered Beings" },
        { id = 1489, name = "Hamuul Runetotem" },
        { id = 1490, name = "Nara Wildmane" },
        { id = 914,  name = "Leaders of the Fang" },
    } },
    { key = "dm",     name = "The Deadmines",             expansion = "Classic", minLevel = 17, maxLevel = 26, zone = "Westfall",            quests = {
        { id = 168,  name = "Collecting Memories" },
        { id = 167,  name = "Oh Brother. . ." },
        { id = 214,  name = "Red Silk Bandanas" },
        { id = 2040, name = "Underground Assault" },
        { id = 373,  name = "The Unsent Letter" },
        -- The Defias Brotherhood chain (Alliance)
        { id = 65,   name = "The Defias Brotherhood" },
        { id = 132,  name = "The Defias Brotherhood" },
        { id = 135,  name = "The Defias Brotherhood" },
        { id = 141,  name = "The Defias Brotherhood" },
        { id = 142,  name = "The Defias Brotherhood" },
        { id = 155,  name = "The Defias Brotherhood" },
        { id = 166,  name = "The Defias Brotherhood" },
    } },
    { key = "sfk",    name = "Shadowfang Keep",           expansion = "Classic", minLevel = 22, maxLevel = 30, zone = "Silverpine Forest",   quests = {
        { id = 1013, name = "The Book of Ur" },              -- Horde
        { id = 1014, name = "Arugal Must Die" },             -- Horde
        { id = 1098, name = "Deathstalkers in Shadowfang" }, -- Horde
    } },
    { key = "bfd",    name = "Blackfathom Deeps",         expansion = "Classic", minLevel = 24, maxLevel = 32, zone = "Ashenvale",           quests = {
        { id = 971,  name = "Knowledge in the Deeps" },
        { id = 1740, name = "The Orb of Soran'ruk" },        -- Warlock
        { id = 1442, name = "Seeking the Kor Gem" },         -- Paladin
        -- Alliance (Argent Dawn / Explorers' League)
        { id = 1198, name = "In Search of Thaelrid" },
        { id = 1199, name = "Twilight Falls" },
        { id = 1200, name = "Blackfathom Villainy" },
        { id = 1275, name = "Researching the Corruption" },
        { id = 3765, name = "The Corruption Abroad" },
        -- Horde
        { id = 6561, name = "Blackfathom Villainy" },
        { id = 6563, name = "The Essence of Aku'Mai" },
        { id = 6564, name = "Allegiance to the Old Gods" },
        { id = 6565, name = "Allegiance to the Old Gods" },
        { id = 6921, name = "Amongst the Ruins" },
        { id = 6922, name = "Baron Aquanis" },
    } },
    { key = "stocks", name = "The Stockade",              expansion = "Classic", minLevel = 24, maxLevel = 32, zone = "Stormwind City",      quests = {
        { id = 391,  name = "The Stockade Riots" },          -- Alliance
        { id = 377,  name = "Crime and Punishment" },
        { id = 387,  name = "Quell The Uprising" },
        { id = 388,  name = "The Color of Blood" },
        { id = 378,  name = "The Fury Runs Deep" },
        { id = 386,  name = "What Comes Around..." },
    } },
    { key = "gnomer", name = "Gnomeregan",                expansion = "Classic", minLevel = 29, maxLevel = 38, zone = "Dun Morogh",          quests = {
        { id = 2904, name = "A Fine Mess" },
        { id = 2962, name = "The Only Cure is More Green Glow" },
        { id = 2928, name = "Gyrodrillmatic Excavationators" },
        { id = 2922, name = "Save Techbot's Brain!" },
        { id = 2924, name = "Essential Artificials" },
        { id = 2930, name = "Data Rescue" },
        { id = 2929, name = "The Grand Betrayal" },
        { id = 2843, name = "Gnomer-gooooone!" },
        { id = 2841, name = "Rig Wars" },
        -- Grime-Encrusted Ring chain
        { id = 2945, name = "Grime-Encrusted Ring" },
        { id = 2927, name = "The Day After" },
        { id = 2926, name = "Gnogaine" },
        { id = 2947, name = "Return of the Ring" },          -- Alliance
        { id = 2948, name = "Gnome Improvement" },           -- Alliance
        { id = 2949, name = "Return of the Ring" },          -- Horde
        { id = 2950, name = "Nogg's Ring Redo" },            -- Horde
    } },
    { key = "rfk",    name = "Razorfen Kraul",            expansion = "Classic", minLevel = 29, maxLevel = 38, zone = "The Barrens",         quests = {
        { id = 1144, name = "Willix the Importer" },
        { id = 1221, name = "Blueleaf Tubers" },
        { id = 1701, name = "Fire Hardened Mail" },          -- Alliance
        { id = 1838, name = "Brutal Armor" },                -- Horde
        { id = 1142, name = "Mortality Wanes" },             -- Alliance
        { id = 1101, name = "The Crone of the Kraul" },      -- Alliance
        { id = 1100, name = "Lonebrow's Journal" },          -- Alliance
        { id = 1102, name = "A Vengeful Fate" },             -- Horde
        { id = 1109, name = "Going, Going, Guano!" },        -- Horde
        { id = 6521, name = "An Unholy Alliance" },          -- Horde
        { id = 6522, name = "An Unholy Alliance" },          -- Horde
    } },
    { key = "sm",     name = "Scarlet Monastery",         expansion = "Classic", minLevel = 28, maxLevel = 45, zone = "Tirisfal Glades",     quests = {
        -- Graveyard
        { id = 1051, name = "Vorrel's Revenge" },
        { id = 1113, name = "Hearts of Zeal" },
        -- Library
        { id = 1050, name = "Mythology of the Titans" },
        { id = 1049, name = "Compendium of the Fallen" },
        { id = 1160, name = "Test of Lore" },
        { id = 1951, name = "Rituals of Power" },              -- Mage
        -- Cathedral / multi-wing
        { id = 261,  name = "Down the Scarlet Path" },         -- Alliance; has breadcrumb Brother Anton (6141)
        { id = 1052, name = "Down the Scarlet Path" },         -- Alliance, gates 1053
        { id = 1053, name = "In the Name of the Light" },      -- Alliance
        { id = 1048, name = "Into the Scarlet Monastery" },    -- Horde
    } },
    { key = "rfd",    name = "Razorfen Downs",            expansion = "Classic", minLevel = 37, maxLevel = 46, zone = "The Barrens",         quests = {
        { id = 3636, name = "Bring the Light" },             -- Alliance
        { id = 3341, name = "Bring the End" },               -- Horde
        { id = 6626, name = "A Host of Evil" },
        { id = 3525, name = "Extinguishing the Idol" },
        { id = 3523, name = "Scourge of the Downs" },
    } },
    { key = "uld",    name = "Uldaman",                   expansion = "Classic", minLevel = 35, maxLevel = 45, zone = "Badlands",            quests = {
        -- Neutral
        { id = 2418, name = "Power Stones" },
        { id = 709,  name = "Solution to Doom" },
        { id = 1956, name = "Power in Uldaman" },                -- Mage only
        -- Alliance: Prospector Stormpike / Agmond's Fate chain
        { id = 707,  name = "Ironband Wants You!" },
        { id = 738,  name = "Find Agmond" },
        { id = 739,  name = "Murdaloc" },
        { id = 704,  name = "Agmond's Fate" },
        -- Alliance: A Sign of Hope / Tablets of Will chain
        { id = 720,  name = "A Sign of Hope" },
        { id = 721,  name = "A Sign of Hope" },
        { id = 722,  name = "Amulet of Secrets" },
        { id = 723,  name = "Prospect of Faith" },
        { id = 724,  name = "Prospect of Faith" },
        { id = 1139, name = "The Lost Tablets of Will" },
        -- Alliance: The Lost Dwarves chain
        { id = 2398, name = "The Lost Dwarves" },
        { id = 2240, name = "The Hidden Chamber" },
        -- Alliance: The Shattered Necklace chain
        { id = 2198, name = "The Shattered Necklace" },
        { id = 2199, name = "Lore for a Price" },
        { id = 2200, name = "Back to Uldaman" },
        { id = 2201, name = "Find the Gems" },
        { id = 2361, name = "Restoring the Necklace" },
        -- Alliance: misc
        { id = 1360, name = "Reclaimed Treasures" },
        { id = 17,   name = "Uldaman Reagent Run" },
        -- Alliance: The Platinum Discs
        { id = 2279, name = "The Platinum Discs" },
        { id = 2439, name = "The Platinum Discs" },
        -- Horde: Necklace Recovery chain
        { id = 2283, name = "Necklace Recovery" },
        { id = 2284, name = "Necklace Recovery, Take 2" },
        { id = 2318, name = "Translating the Journal" },
        { id = 2338, name = "Translating the Journal" },
        { id = 2339, name = "Find the Gems and Power Source" },
        -- Horde: misc
        { id = 2342, name = "Reclaimed Treasures" },
        { id = 2202, name = "Uldaman Reagent Run" },
        -- Horde: The Platinum Discs
        { id = 2280, name = "The Platinum Discs" },
        { id = 2440, name = "The Platinum Discs" },
    } },
    { key = "zf",     name = "Zul'Farrak",                expansion = "Classic", minLevel = 42, maxLevel = 54, zone = "Tanaris",             quests = {
        { id = 2768, name = "Divino-matic Rod" },
        { id = 2770, name = "Gahz'rilla" },
        { id = 2846, name = "Tiara of the Deep" },
        { id = 2865, name = "Scarab Shells" },
        { id = 3042, name = "Troll Temper" },
        { id = 2936, name = "The Spider God" },              -- Horde
        { id = 2991, name = "Nekrum's Medallion" },          -- Alliance
        { id = 3527, name = "The Prophecy of Mosh'aru" },    -- leads to Sunken Temple
    } },
    { key = "mara",   name = "Maraudon",                  expansion = "Classic", minLevel = 46, maxLevel = 55, zone = "Desolace",            quests = {
        { id = 7067, name = "The Pariah's Instructions" },
        { id = 7044, name = "Legends of Maraudon" },
        { id = 7028, name = "Twisted Evils" },
        { id = 7066, name = "Seed of Life" },
        { id = 7068, name = "Shadowshard Fragments" },       -- Horde
        { id = 7070, name = "Shadowshard Fragments" },       -- Alliance
        { id = 7029, name = "Vyletongue Corruption" },       -- Horde
        { id = 7041, name = "Vyletongue Corruption" },       -- Alliance
        { id = 7064, name = "Corruption of Earth and Seed" },-- Horde
        { id = 7065, name = "Corruption of Earth and Seed" },-- Alliance
    } },
    { key = "st",     name = "Temple of Atal'Hakkar",     expansion = "Classic", minLevel = 50, maxLevel = 60, zone = "Swamp of Sorrows",    quests = {
        { id = 1446, name = "Jammal'an the Prophet" },
        { id = 1475, name = "Into The Temple of Atal'Hakkar" }, -- Alliance
        { id = 1445, name = "The Temple of Atal'Hakkar" },      -- Horde
        { id = 3446, name = "Into the Depths" },
        { id = 3447, name = "Secret of the Circle" },
        { id = 4143, name = "Haze of Evil" },                   -- Alliance
        { id = 4146, name = "Zapper Fuel" },                    -- Horde
        { id = 3373, name = "The Essence of Eranikus" },
        { id = 3374, name = "The Essence of Eranikus" },
        { id = 4787, name = "The Ancient Egg" },                -- Hakkar chain (from Zul'Farrak)
        { id = 3528, name = "The God Hakkar" },                 -- Hakkar chain
    } },
    { key = "brd",    name = "Blackrock Depths",          expansion = "Classic", minLevel = 48, maxLevel = 60, zone = "Blackrock Mountain",  quests = {
        -- Neutral / both
        { id = 3801, name = "Dark Iron Legacy" },
        { id = 3802, name = "Dark Iron Legacy" },
        { id = 4123, name = "The Heart of the Mountain" },
        { id = 4022, name = "A Taste of Flame" },
        { id = 4023, name = "A Taste of Flame" },
        { id = 4024, name = "A Taste of Flame" },
        { id = 4136, name = "Ribbly Screwspigot" },
        { id = 4324, name = "Yuka Screwspigot" },
        { id = 4201, name = "The Love Potion" },
        { id = 7848, name = "Attunement to the Core" },
        -- Alliance
        { id = 4262, name = "Overmaster Pyron" },
        { id = 4263, name = "Incendius!" },
        { id = 4182, name = "Dragonkin Menace" },
        { id = 4183, name = "The True Masters" },
        { id = 4184, name = "The True Masters" },
        { id = 4185, name = "The True Masters" },
        { id = 4186, name = "The True Masters" },
        { id = 4223, name = "The True Masters" },
        { id = 4224, name = "The True Masters" },
        { id = 4241, name = "Marshal Windsor" },
        { id = 4286, name = "The Good Stuff" },
        { id = 3701, name = "The Smoldering Ruins of Thaurissan" },
        { id = 3702, name = "The Smoldering Ruins of Thaurissan" },
        { id = 4341, name = "Kharan Mighthammer" },
        { id = 4342, name = "Kharan's Tale" },
        { id = 4361, name = "The Bearer of Bad News" },
        { id = 4362, name = "The Fate of the Kingdom" },
        { id = 4126, name = "Hurley Blackbreath" },
        { id = 4128, name = "Ragnar Thunderbrew" },
        -- Horde
        { id = 3906, name = "Disharmony of Flame" },
        { id = 3907, name = "Disharmony of Fire" },
        { id = 4081, name = "KILL ON SIGHT: Dark Iron Dwarves" },
        { id = 4082, name = "KILL ON SIGHT: High Ranking Dark Iron Officials" },
        { id = 7201, name = "The Last Element" },
        { id = 3981, name = "Commander Gor'shak" },
        { id = 3982, name = "What Is Going On?" },
        { id = 4001, name = "What Is Going On?" },
        { id = 4003, name = "The Royal Rescue" },
        { id = 4133, name = "Vivian Lagrave" },
        { id = 4134, name = "Lost Thunderbrew Recipe" },
        { id = 4121, name = "Precarious Predicament" },
        { id = 4122, name = "Grark Lorkrub" },
        { id = 4132, name = "Operation: Death to Angerforge" },
        { id = 4061, name = "The Rise of the Machines" },
        { id = 4062, name = "The Rise of the Machines" },
        { id = 4063, name = "The Rise of the Machines" },
    } },
    { key = "lbrs",   name = "Lower Blackrock Spire",     expansion = "Classic", minLevel = 55, maxLevel = 60, zone = "Blackrock Mountain",  quests = {
        { id = 4742, name = "Seal of Ascension" },
        { id = 4743, name = "Seal of Ascension" },
        { id = 4729, name = "Kibler's Exotic Pets" },
        { id = 4862, name = "En-Ay-Es-Tee-Why" },
        { id = 5065, name = "The Lost Tablets of Mosh'aru" },
        { id = 4788, name = "The Final Tablets" },
        { id = 4701, name = "Put Her Down" },                -- Alliance
        { id = 4724, name = "The Pack Mistress" },           -- Horde
        { id = 4903, name = "Warlord's Command" },           -- Horde
        -- Bijou / Maxwell (Alliance), Operative Bijou (Horde)
        { id = 4981, name = "Operative Bijou" },             -- Horde
        { id = 4982, name = "Bijou's Belongings" },          -- Horde
        { id = 5001, name = "Bijou's Belongings" },          -- Alliance
        { id = 5002, name = "Message to Maxwell" },          -- Alliance
        { id = 5081, name = "Maxwell's Mission" },           -- Alliance
        { id = 5089, name = "General Drakkisath's Command" },-- Alliance
    } },
    { key = "ubrs",   name = "Upper Blackrock Spire",     expansion = "Classic", minLevel = 57, maxLevel = 60, zone = "Blackrock Mountain",  quests = {
        { id = 5102, name = "General Drakkisath's Demise" }, -- Alliance
        { id = 4974, name = "For The Horde!" },              -- Horde
        { id = 4764, name = "Doomrigger's Clasp" },          -- Alliance
        { id = 4766, name = "Mayara Brightwing" },           -- Alliance
        { id = 4768, name = "The Darkstone Tablet" },        -- Horde
        { id = 5126, name = "Lorax's Tale" },
        { id = 5127, name = "The Demon Forge" },
        { id = 5160, name = "The Matron Protectorate" },
        { id = 6804, name = "Poisoned Water" },
        { id = 6805, name = "Stormers and Rumblers" },
        { id = 6821, name = "Eye of the Emberseer" },
        { id = 7761, name = "Blackhand's Command" },
    } },
    { key = "dme",    name = "Dire Maul",                 expansion = "Classic", minLevel = 55, maxLevel = 60, zone = "Feralas",             quests = {
        { id = 5518, name = "The Gordok Ogre Suit" },
        { id = 5525, name = "Free Knot!" },
        { id = 7703, name = "Unfinished Gordok Business" },
        { id = 7441, name = "Pusillin and the Elder Azj'Tordin" },
        { id = 5526, name = "Shards of the Felvine" },
        { id = 7461, name = "The Madness Within" },
        { id = 7462, name = "The Treasure of the Shen'dralar" },  -- Alliance
        { id = 7877, name = "The Treasure of the Shen'dralar" },  -- Horde
        { id = 7488, name = "Lethtendris's Web" },           -- Alliance
        { id = 7489, name = "Lethtendris's Web" },           -- Horde
        { id = 7503, name = "The Greatest Race of Hunters" },-- Hunter
        { id = 7631, name = "Dreadsteed of Xoroth" },        -- Warlock
        -- Quel'Serrar (Elven Legends -> A Reliquary of Purity)
        { id = 7481, name = "Elven Legends" },               -- Horde
        { id = 7482, name = "Elven Legends" },               -- Alliance
        { id = 5527, name = "A Reliquary of Purity" },
    } },
    { key = "strat",  name = "Stratholme",                expansion = "Classic", minLevel = 58, maxLevel = 60, zone = "Eastern Plaguelands", quests = {
        { id = 4941, name = "Eitrigg's Wisdom" },            -- Horde (entry)
        { id = 5122, name = "The Medallion of Faith" },
        { id = 5125, name = "Aurius' Reckoning" },
        { id = 5212, name = "The Flesh Does Not Lie" },
        { id = 5213, name = "The Active Agent" },
        { id = 5214, name = "The Great Fras Siabi" },
        { id = 5243, name = "Houses of the Holy" },
        { id = 5251, name = "The Archivist" },
        { id = 5262, name = "The Truth Comes Crashing Down" },
        { id = 5263, name = "Above and Beyond" },
        { id = 5281, name = "The Restless Souls" },
        { id = 5282, name = "The Restless Souls" },
        { id = 5542, name = "Demon Dogs" },
        { id = 5845, name = "Of Lost Honor" },
    } },
    { key = "scholo", name = "Scholomance",               expansion = "Classic", minLevel = 58, maxLevel = 60, zone = "Western Plaguelands", quests = {
        { id = 5505, name = "The Key to Scholomance" },      -- Alliance
        { id = 5511, name = "The Key to Scholomance" },      -- Horde
        { id = 5382, name = "Doctor Theolen Krastinov, the Butcher" },
        { id = 5384, name = "Kirtonos the Herald" },
        { id = 5466, name = "The Lich, Ras Frostwhisper" },
        { id = 5341, name = "Barov Family Fortune" },        -- Horde
        { id = 5343, name = "Barov Family Fortune" },        -- Alliance
        { id = 4771, name = "Dawn's Gambit" },
        { id = 8258, name = "The Darkreaver Menace" },       -- Shaman (Horde)
    } },

    --------------------------------------------------------------------
    -- THE BURNING CRUSADE
    --------------------------------------------------------------------
    { key = "hr",     name = "Hellfire Ramparts",         expansion = "TBC", minLevel = 60, maxLevel = 63, zone = "Hellfire Peninsula", quests = {
        { id = 9575, name = "Weaken the Ramparts" },         -- Alliance
        { id = 9572, name = "Weaken the Ramparts" },         -- Horde
        { id = 9587, name = "Dark Tidings" },                -- Alliance
        { id = 9588, name = "Dark Tidings" },                -- Horde
        { id = 11354, name = "Wanted: Nazan's Riding Crop" },-- Heroic
    } },
    { key = "bf",     name = "The Blood Furnace",         expansion = "TBC", minLevel = 61, maxLevel = 64, zone = "Hellfire Peninsula", quests = {
        { id = 9589, name = "The Blood is Life" },           -- Alliance
        { id = 9590, name = "The Blood is Life" },           -- Horde
        { id = 9607, name = "Heart of Rage" },               -- Alliance
        { id = 9608, name = "Heart of Rage" },               -- Horde
        { id = 11362, name = "Wanted: Keli'dan's Feathered Stave" }, -- Heroic
    } },
    { key = "sp",     name = "The Slave Pens",            expansion = "TBC", minLevel = 62, maxLevel = 65, zone = "Zangarmarsh",        quests = {
        { id = 9738, name = "Lost in Action" },
        { id = 10901, name = "The Cudgel of Kar'desh" },
        { id = 11368, name = "Wanted: The Heart of Quagmirran" }, -- Heroic
    } },
    { key = "ub",     name = "The Underbog",              expansion = "TBC", minLevel = 63, maxLevel = 66, zone = "Zangarmarsh",        quests = {
        { id = 9717, name = "Oh, It's On!" },
        { id = 9719, name = "Stalk the Stalker" },
        { id = 9715, name = "Bring Me A Shrubbery!" },
        { id = 11369, name = "Wanted: A Black Stalker Egg" }, -- Heroic
    } },
    { key = "mt",     name = "Mana-Tombs",                expansion = "TBC", minLevel = 64, maxLevel = 67, zone = "Terokkar Forest",    quests = {
        { id = 10216, name = "Safety Is Job One" },
        { id = 10165, name = "Undercutting the Competition" },
        { id = 10218, name = "Someone Else's Hard Work Pays Off" },
        { id = 10977, name = "Stasis Chambers of the Mana-Tombs" },
        { id = 10981, name = "Nexus-Prince Shaffar's Personal Chamber" },
        { id = 11373, name = "Wanted: Shaffar's Wondrous Pendant" }, -- Heroic
        -- Consortium / Ethereum (Seek Out Ameer chain)
        { id = 10969, name = "Seek Out Ameer" },
        { id = 10970, name = "A Mission of Mercy" },
        { id = 10971, name = "Ethereum Secrets" },
        { id = 10972, name = "Ethereum Prisoner I.D. Catalogue" },
    } },
    { key = "ac",     name = "Auchenai Crypts",           expansion = "TBC", minLevel = 65, maxLevel = 68, zone = "Terokkar Forest",    quests = {
        { id = 10164, name = "Everything Will Be Alright" },
        { id = 10950, name = "Auchindoun and the Ring of Observance" }, -- Alliance
        { id = 10167, name = "Auchindoun..." },              -- Horde
        { id = 11374, name = "Wanted: The Exarch's Soul Gem" }, -- Heroic
    } },
    { key = "ohf",    name = "Old Hillsbrad Foothills",   expansion = "TBC", minLevel = 66, maxLevel = 69, zone = "Caverns of Time",    quests = {
        { id = 10277, name = "The Caverns of Time" },
        { id = 10279, name = "To The Master's Lair" },
        { id = 10282, name = "Old Hillsbrad" },
        { id = 10283, name = "Taretha's Diversion" },
        { id = 10284, name = "Escape from Durnholde" },
        { id = 10285, name = "Return to Andormu" },
        { id = 12513, name = "Nice Hat..." },
        { id = 11378, name = "Wanted: The Epoch Hunter's Head" }, -- Heroic
    } },
    { key = "sh",     name = "Sethekk Halls",             expansion = "TBC", minLevel = 67, maxLevel = 70, zone = "Terokkar Forest",    quests = {
        { id = 10097, name = "Brother Against Brother" },
        { id = 10098, name = "Terokk's Legacy" },
        { id = 9637,  name = "Kalynna's Request" },
        { id = 11372, name = "Wanted: The Headfeathers of Ikiss" }, -- Heroic
        { id = 11001, name = "Vanquish the Raven God" },     -- Druid (Heroic)
    } },
    { key = "sv",     name = "The Steamvault",            expansion = "TBC", minLevel = 68, maxLevel = 70, zone = "Zangarmarsh",        quests = {
        { id = 9763, name = "The Warlord's Hideout" },
        { id = 9764, name = "Orders from Lady Vashj" },
        { id = 10667, name = "Underworld Loam" },
        { id = 10885, name = "Trial of the Naaru: Strength" },
        { id = 11371, name = "Wanted: Coilfang Myrmidons" },  -- Heroic
        { id = 11370, name = "Wanted: The Warlord's Treatise" }, -- Heroic
    } },
    { key = "shh",    name = "The Shattered Halls",        expansion = "TBC", minLevel = 69, maxLevel = 70, zone = "Hellfire Peninsula", quests = {
        { id = 9494, name = "Fel Embers" },                  -- Alliance
        { id = 9492, name = "Turning the Tide" },            -- Alliance
        { id = 9493, name = "Pride of the Fel Horde" },      -- Alliance
        { id = 9496, name = "Pride of the Fel Horde" },      -- Horde
        { id = 9495, name = "The Will of the Warchief" },    -- Horde
        { id = 9524, name = "Imprisoned in the Citadel" },   -- Alliance
        { id = 9525, name = "Imprisoned in the Citadel" },   -- Horde
        { id = 10884, name = "Trial of the Naaru: Mercy" },
        { id = 11364, name = "Wanted: Shattered Hand Centurions" }, -- Heroic
        { id = 11363, name = "Wanted: Bladefist's Seal" },   -- Heroic
    } },
    { key = "slabs",  name = "Shadow Labyrinth",          expansion = "TBC", minLevel = 70, maxLevel = 70, zone = "Terokkar Forest",    quests = {
        { id = 10177, name = "Trouble at Auchindoun" },
        { id = 10094, name = "The Codex of Blood" },
        { id = 10095, name = "Into the Heart of the Labyrinth" },
        { id = 10178, name = "Find Spy To'gun" },
        { id = 10649, name = "The Book of Fel Names" },      -- Karazhan attunement
        { id = 11376, name = "Wanted: Malicious Instructors" }, -- Heroic
        { id = 11375, name = "Wanted: Murmur's Whisper" },   -- Heroic
    } },
    { key = "bm",     name = "The Black Morass",          expansion = "TBC", minLevel = 70, maxLevel = 70, zone = "Caverns of Time",    quests = {
        { id = 9836,  name = "The Master's Touch" },
        { id = 10297, name = "The Opening of the Dark Portal" },
    } },
    { key = "mech",   name = "The Mechanar",              expansion = "TBC", minLevel = 70, maxLevel = 70, zone = "Tempest Keep",       quests = {
        { id = 10665, name = "Fresh From the Mechanar" },
        { id = 11387, name = "Wanted: Tempest-Forge Destroyers" }, -- Heroic
        { id = 11386, name = "Wanted: Pathaleon's Projector" },    -- Heroic
    } },
    { key = "bot",    name = "The Botanica",              expansion = "TBC", minLevel = 70, maxLevel = 70, zone = "Tempest Keep",       quests = {
        { id = 10257, name = "Capturing the Keystone" },
        { id = 10897, name = "Master of Potions" },
        { id = 11385, name = "Wanted: Sunseeker Channelers" },     -- Heroic
    } },
    { key = "arc",    name = "The Arcatraz",              expansion = "TBC", minLevel = 70, maxLevel = 70, zone = "Tempest Keep",       quests = {
        { id = 10704, name = "How to Break Into the Arcatraz" },
        { id = 10705, name = "Seer Udalo" },
        { id = 10706, name = "A Mysterious Portent" },
        { id = 10882, name = "Harbinger of Doom" },
        { id = 9832,  name = "The Second and Third Fragments" },
        { id = 10886, name = "Trial of the Naaru: Tenacity" },
        { id = 11389, name = "Wanted: Arcatraz Sentinels" },       -- Heroic
        { id = 11388, name = "Wanted: The Scroll of Skyriss" },    -- Heroic
    } },
    { key = "mgt",    name = "Magisters' Terrace",        expansion = "TBC", minLevel = 70, maxLevel = 70, zone = "Isle of Quel'Danas", quests = {
        { id = 11488, name = "Magisters' Terrace" },
        { id = 11492, name = "Hard to Kill" },
    } },
}
