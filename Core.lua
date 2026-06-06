local ADDON, ns = ...

-- Expose for console poking: /run DungeonQuests.Toggle()
_G.DungeonQuests = ns

--------------------------------------------------------------------------
-- Defaults (filled into SavedVariables, non-destructively).
--------------------------------------------------------------------------
ns.defaults = {
    filters = {
        playerFactionOnly = true,   -- hide opposite-faction quests
        hideCompleted     = false,  -- hide quests already done
        hideUnavailable   = false,  -- hide quests not doable by this class/race
        showBreadcrumbs   = false,  -- show breadcrumb quests that lead to each quest
    },
    window   = { point = nil },     -- { point, relPoint, x, y }
    selected = nil,                 -- last selected dungeon key
}

--------------------------------------------------------------------------
-- Fill missing values from a defaults table (recursive, non-destructive).
--------------------------------------------------------------------------
local function CopyDefaults(src, dst)
    if type(dst) ~= "table" then dst = {} end
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
    return dst
end
ns.CopyDefaults = CopyDefaults

--------------------------------------------------------------------------
-- Single event dispatcher. ns.On(event, fn) registers a handler.
--------------------------------------------------------------------------
local dispatcher = CreateFrame("Frame")
local handlers = {}
function ns.On(event, fn)
    if not handlers[event] then
        -- RegisterEvent throws on events that don't exist on this client version;
        -- skip those safely so one bad name can't abort a file's whole load.
        if not pcall(dispatcher.RegisterEvent, dispatcher, event) then return end
        handlers[event] = {}
    end
    table.insert(handlers[event], fn)
end
dispatcher:SetScript("OnEvent", function(_, event, ...)
    local list = handlers[event]
    if not list then return end
    for _, fn in ipairs(list) do
        fn(event, ...)
    end
end)

--------------------------------------------------------------------------
-- Lifecycle.
--------------------------------------------------------------------------
ns.On("ADDON_LOADED", function(_, name)
    if name ~= ADDON then return end
    DungeonQuestsDB = CopyDefaults(ns.defaults, DungeonQuestsDB)
    ns.db = DungeonQuestsDB
end)

--------------------------------------------------------------------------
-- Slash command.
--------------------------------------------------------------------------
SLASH_DUNGEONQUESTS1 = "/dq"
SLASH_DUNGEONQUESTS2 = "/dungeonquests"
SlashCmdList.DUNGEONQUESTS = function(msg)
    msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if msg == "validate" then
        if ns.ValidateData then ns.ValidateData() end
    elseif msg == "bc" then
        if ns.BreadcrumbDebug then ns.BreadcrumbDebug() end
    elseif msg == "reset" then
        DungeonQuestsDB = CopyDefaults(ns.defaults, {})
        ns.db = DungeonQuestsDB
        print("|cff66ccffDungeon Quests|r: settings reset.")
        if ns.RefreshUI then ns.RefreshUI() end
    else
        if ns.Toggle then ns.Toggle() end
    end
end
