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
    { key = "rfc",    name = "Ragefire Chasm",            expansion = "Classic", minLevel = 13, maxLevel = 18, zone = "Orgrimmar",            quests = {} },
    { key = "wc",     name = "Wailing Caverns",           expansion = "Classic", minLevel = 17, maxLevel = 24, zone = "The Barrens",         quests = {} },
    { key = "dm",     name = "The Deadmines",             expansion = "Classic", minLevel = 17, maxLevel = 26, zone = "Westfall",            quests = {} },
    { key = "sfk",    name = "Shadowfang Keep",           expansion = "Classic", minLevel = 22, maxLevel = 30, zone = "Silverpine Forest",   quests = {} },
    { key = "bfd",    name = "Blackfathom Deeps",         expansion = "Classic", minLevel = 24, maxLevel = 32, zone = "Ashenvale",           quests = {} },
    { key = "stocks", name = "The Stockade",              expansion = "Classic", minLevel = 24, maxLevel = 32, zone = "Stormwind City",      quests = {} },
    { key = "gnomer", name = "Gnomeregan",                expansion = "Classic", minLevel = 29, maxLevel = 38, zone = "Dun Morogh",          quests = {} },
    { key = "rfk",    name = "Razorfen Kraul",            expansion = "Classic", minLevel = 29, maxLevel = 38, zone = "The Barrens",         quests = {} },
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
    { key = "rfd",    name = "Razorfen Downs",            expansion = "Classic", minLevel = 37, maxLevel = 46, zone = "The Barrens",         quests = {} },
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
    { key = "zf",     name = "Zul'Farrak",                expansion = "Classic", minLevel = 42, maxLevel = 54, zone = "Tanaris",             quests = {} },
    { key = "mara",   name = "Maraudon",                  expansion = "Classic", minLevel = 46, maxLevel = 55, zone = "Desolace",            quests = {} },
    { key = "st",     name = "Temple of Atal'Hakkar",     expansion = "Classic", minLevel = 50, maxLevel = 60, zone = "Swamp of Sorrows",    quests = {} },
    { key = "brd",    name = "Blackrock Depths",          expansion = "Classic", minLevel = 52, maxLevel = 60, zone = "Blackrock Mountain",  quests = {} },
    { key = "lbrs",   name = "Lower Blackrock Spire",     expansion = "Classic", minLevel = 55, maxLevel = 60, zone = "Blackrock Mountain",  quests = {} },
    { key = "ubrs",   name = "Upper Blackrock Spire",     expansion = "Classic", minLevel = 57, maxLevel = 60, zone = "Blackrock Mountain",  quests = {} },
    { key = "dme",    name = "Dire Maul",                 expansion = "Classic", minLevel = 55, maxLevel = 60, zone = "Feralas",             quests = {} },
    { key = "strat",  name = "Stratholme",                expansion = "Classic", minLevel = 58, maxLevel = 60, zone = "Eastern Plaguelands", quests = {} },
    { key = "scholo", name = "Scholomance",               expansion = "Classic", minLevel = 58, maxLevel = 60, zone = "Western Plaguelands", quests = {} },

    --------------------------------------------------------------------
    -- THE BURNING CRUSADE
    --------------------------------------------------------------------
    { key = "hr",     name = "Hellfire Ramparts",         expansion = "TBC", minLevel = 60, maxLevel = 63, zone = "Hellfire Peninsula", quests = {} },
    { key = "bf",     name = "The Blood Furnace",         expansion = "TBC", minLevel = 61, maxLevel = 64, zone = "Hellfire Peninsula", quests = {} },
    { key = "sp",     name = "The Slave Pens",            expansion = "TBC", minLevel = 62, maxLevel = 65, zone = "Zangarmarsh",        quests = {} },
    { key = "ub",     name = "The Underbog",              expansion = "TBC", minLevel = 63, maxLevel = 66, zone = "Zangarmarsh",        quests = {} },
    { key = "mt",     name = "Mana-Tombs",                expansion = "TBC", minLevel = 64, maxLevel = 67, zone = "Terokkar Forest",    quests = {} },
    { key = "ac",     name = "Auchenai Crypts",           expansion = "TBC", minLevel = 65, maxLevel = 68, zone = "Terokkar Forest",    quests = {} },
    { key = "ohf",    name = "Old Hillsbrad Foothills",   expansion = "TBC", minLevel = 66, maxLevel = 69, zone = "Caverns of Time",    quests = {} },
    { key = "sh",     name = "Sethekk Halls",             expansion = "TBC", minLevel = 67, maxLevel = 70, zone = "Terokkar Forest",    quests = {} },
    { key = "sv",     name = "The Steamvault",            expansion = "TBC", minLevel = 68, maxLevel = 70, zone = "Zangarmarsh",        quests = {} },
    { key = "shh",    name = "The Shattered Halls",        expansion = "TBC", minLevel = 69, maxLevel = 70, zone = "Hellfire Peninsula", quests = {} },
    { key = "slabs",  name = "Shadow Labyrinth",          expansion = "TBC", minLevel = 70, maxLevel = 70, zone = "Terokkar Forest",    quests = {} },
    { key = "bm",     name = "The Black Morass",          expansion = "TBC", minLevel = 70, maxLevel = 70, zone = "Caverns of Time",    quests = {} },
    { key = "mech",   name = "The Mechanar",              expansion = "TBC", minLevel = 70, maxLevel = 70, zone = "Tempest Keep",       quests = {} },
    { key = "bot",    name = "The Botanica",              expansion = "TBC", minLevel = 70, maxLevel = 70, zone = "Tempest Keep",       quests = {} },
    { key = "arc",    name = "The Arcatraz",              expansion = "TBC", minLevel = 70, maxLevel = 70, zone = "Tempest Keep",       quests = {} },
    { key = "mgt",    name = "Magisters' Terrace",        expansion = "TBC", minLevel = 70, maxLevel = 70, zone = "Isle of Quel'Danas", quests = {} },
}
