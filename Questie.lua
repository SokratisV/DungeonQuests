local ADDON, ns = ...

-- Data bridge to the Questie addon. Questie ships the full Classic + TBC quest
-- and NPC database and exposes it at runtime; we read quest metadata (name,
-- level, faction/class/race restrictions, prerequisites, quest-givers + their
-- spawn coordinates) from it rather than shipping our own copy.

local QuestieDB, ZoneDB
ns.QuestieReady   = false   -- true once Questie's DB is loaded
ns.questieMissing = false   -- true if Questie isn't installed/enabled

local readyQueue = {}
function ns.OnQuestieReady(fn)
    if ns.QuestieReady then
        fn()
    else
        readyQueue[#readyQueue + 1] = fn
    end
end

--------------------------------------------------------------------------
-- Faction / class / race bitmasks (standard WoW masks; Questie uses these too).
--------------------------------------------------------------------------
local RACE_BIT = {
    Human = 1, Orc = 2, Dwarf = 4, NightElf = 8, Scourge = 16,
    Tauren = 32, Gnome = 64, Troll = 128, BloodElf = 512, Draenei = 1024,
}
local ALLIANCE_RACES = RACE_BIT.Human + RACE_BIT.Dwarf + RACE_BIT.NightElf + RACE_BIT.Gnome + RACE_BIT.Draenei   -- 1101
local HORDE_RACES    = RACE_BIT.Orc + RACE_BIT.Scourge + RACE_BIT.Tauren + RACE_BIT.Troll + RACE_BIT.BloodElf     -- 690

local CLASS_BIT = {
    WARRIOR = 1, PALADIN = 2, HUNTER = 4, ROGUE = 8, PRIEST = 16,
    SHAMAN = 64, MAGE = 128, WARLOCK = 256, DRUID = 1024,
}

-- Player identity, cached at login.
ns.player = {}
local function cachePlayer()
    ns.player.faction  = UnitFactionGroup("player")              -- "Alliance" / "Horde"
    ns.player.level    = UnitLevel("player")
    local _, classFile = UnitClass("player")
    local _, raceFile  = UnitRace("player")
    ns.player.classBit = CLASS_BIT[classFile] or 0
    ns.player.raceBit  = RACE_BIT[raceFile] or 0
end

-- Derive a quest's faction from its requiredRaces bitmask.
local function factionFromRaceMask(mask)
    if not mask or mask == 0 then return "Both" end
    local a = bit.band(mask, ALLIANCE_RACES) ~= 0
    local h = bit.band(mask, HORDE_RACES) ~= 0
    if a and h then return "Both" end
    if a then return "Alliance" end
    if h then return "Horde" end
    return "Both"
end
ns.ALLIANCE_RACES = ALLIANCE_RACES
ns.HORDE_RACES = HORDE_RACES

--------------------------------------------------------------------------
-- Quest-giver pickup info (NPC name + zone + coords).
--------------------------------------------------------------------------
local function firstSpawn(npcId)
    local npc = QuestieDB:GetNPC(npcId)   -- GetNPC is a colon-method (takes self)
    if not npc then return nil end
    local zoneName, x, y
    if npc.spawns then
        for areaId, coords in pairs(npc.spawns) do
            zoneName = (C_Map and C_Map.GetAreaInfo and C_Map.GetAreaInfo(areaId)) or nil
            local c = coords and coords[1]
            if c then x, y = c[1], c[2] end
            break   -- first known spawn is good enough for a pickup hint
        end
    end
    -- friendlyToFaction is "A" / "H" / "AH" / nil -- used to refine quest faction
    -- when the quest itself carries no race restriction.
    return { name = npc.name, zone = zoneName, x = x, y = y, faction = npc.friendlyToFaction }
end

local function buildGivers(quest)
    local givers = {}
    local startedBy = quest.startedBy
    local npcList = startedBy and startedBy[1]
    if npcList then
        for _, npcId in ipairs(npcList) do
            local g = firstSpawn(npcId)
            if g and g.name then givers[#givers + 1] = g end
        end
    end
    if #givers == 0 then
        -- No NPC giver -> started by a world object or an item drop (common for
        -- "found in the dungeon" starters like discs/relics).
        if startedBy and startedBy[2] then
            givers[#givers + 1] = { fromObject = true }
        elseif startedBy and startedBy[3] then
            givers[#givers + 1] = { fromItem = true }
        end
    end
    return givers
end

--------------------------------------------------------------------------
-- Normalized quest info, memoized per questID.
--------------------------------------------------------------------------
local cache = {}
function ns.GetQuestInfo(questId)
    if cache[questId] then return cache[questId] end
    if not ns.QuestieReady or not QuestieDB then return nil end

    local q = QuestieDB.GetQuest(questId)
    if not q then
        local info = { missing = true }
        cache[questId] = info
        return info
    end

    local givers = buildGivers(q)

    -- Faction: prefer the quest's race restriction; if it carries none (common
    -- for quests gated only by their quest-giver's faction), fall back to the
    -- faction of the first quest-giver NPC. This is what stops opposite-faction
    -- versions of a quest showing up as "duplicates".
    local faction = factionFromRaceMask(q.requiredRaces)
    if faction == "Both" then
        local gf = givers[1] and givers[1].faction
        if gf == "A" then faction = "Alliance"
        elseif gf == "H" then faction = "Horde" end
    end

    -- Breadcrumbs (quests that lead TO this one). Questie itself reads this via
    -- QueryQuestSingle, so use the same path as a fallback. Note: this field is
    -- only populated for a minority of quests in Questie's DB.
    local breadcrumbs = q.breadcrumbs
    if not breadcrumbs and QuestieDB.QueryQuestSingle then
        breadcrumbs = QuestieDB.QueryQuestSingle(questId, "breadcrumbs")
    end

    local info = {
        id          = questId,
        name        = q.name,
        reqLevel    = q.requiredLevel or 0,
        questLevel  = q.questLevel or 0,
        raceMask    = q.requiredRaces or 0,
        classMask   = q.requiredClasses or 0,
        faction     = faction,
        preSingle   = q.preQuestSingle,
        preGroup    = q.preQuestGroup,
        exclusiveTo = q.exclusiveTo,
        nextInChain = q.nextQuestInChain,
        breadcrumbs = breadcrumbs,
        givers      = givers,
    }
    cache[questId] = info
    return info
end

-- Lightweight name lookup used by "/dq validate" (bypasses the giver build).
function ns.GetQuestieName(questId)
    if not QuestieDB then return nil end
    local q = QuestieDB.GetQuest(questId)
    return q and q.name or nil
end

--------------------------------------------------------------------------
-- Initialization: hook Questie's "data ready" signal.
--------------------------------------------------------------------------
local function initQuestie()
    if ns._questieInit then return end
    ns._questieInit = true
    cachePlayer()

    if _G.Questie and _G.QuestieLoader and Questie.API and Questie.API.RegisterOnReady then
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        ZoneDB    = QuestieLoader:ImportModule("ZoneDB")
        Questie.API.RegisterOnReady(function()
            ns.QuestieReady = true
            local pending = readyQueue
            readyQueue = {}
            for _, fn in ipairs(pending) do pcall(fn) end
            if ns.RefreshUI then ns.RefreshUI() end
        end)
    else
        ns.questieMissing = true
        if ns.RefreshUI then ns.RefreshUI() end
    end
end

ns.On("PLAYER_LOGIN", initQuestie)
