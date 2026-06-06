local ADDON, ns = ...

-- Per-quest status for the current character, overlaid on the live quest log.
--
--   done        -> already completed (green)
--   active      -> currently in your quest log (yellow)
--   eligible    -> can be picked up right now (blue)
--   locked      -> right faction/class, but a prereq or level gate isn't met (grey)
--   unavailable -> wrong faction / class / race for this character (red, dimmed)
--   unknown     -> Questie has no data for this id

local IsCompleted = (C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted) or IsQuestFlaggedCompleted
local function isCompleted(id) return IsCompleted and IsCompleted(id) or false end

local function isActive(id)
    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        return C_QuestLog.GetLogIndexForQuestID(id) ~= nil
    end
    return false
end
ns.IsQuestCompleted = isCompleted
ns.IsQuestActive    = isActive

-- Does this character's faction/class/race satisfy the quest's restrictions?
function ns.MatchesPlayer(info)
    local p = ns.player
    if info.faction == "Alliance" and p.faction ~= "Alliance" then return false end
    if info.faction == "Horde"    and p.faction ~= "Horde"    then return false end
    if info.classMask and info.classMask > 0 and p.classBit > 0 then
        if bit.band(info.classMask, p.classBit) == 0 then return false end
    end
    if info.raceMask and info.raceMask > 0 and p.raceBit > 0 then
        if bit.band(info.raceMask, p.raceBit) == 0 then return false end
    end
    return true
end

-- Returns status, reason. `reason` is a short string for locked/unavailable.
function ns.GetQuestStatus(questId, info)
    info = info or ns.GetQuestInfo(questId)
    if not info or info.missing then return "unknown" end

    if isCompleted(questId) then return "done" end
    if isActive(questId)    then return "active" end

    if not ns.MatchesPlayer(info) then
        return "unavailable", "Not available to your faction/class/race"
    end

    -- All prerequisites in a group must be completed.
    if info.preGroup then
        for _, id in ipairs(info.preGroup) do
            if not isCompleted(id) then
                local pre = ns.GetQuestInfo(id)
                return "locked", "Requires: " .. ((pre and pre.name) or ("quest " .. id))
            end
        end
    end

    -- At least one of the "single" prerequisites must be completed.
    if info.preSingle and #info.preSingle > 0 then
        local any = false
        for _, id in ipairs(info.preSingle) do
            if isCompleted(id) then any = true break end
        end
        if not any then
            local pre = ns.GetQuestInfo(info.preSingle[1])
            return "locked", "Requires: " .. ((pre and pre.name) or ("quest " .. info.preSingle[1]))
        end
    end

    -- A mutually-exclusive quest already taken/done closes this one off.
    if info.exclusiveTo then
        for _, id in ipairs(info.exclusiveTo) do
            if isCompleted(id) or isActive(id) then
                return "unavailable", "You took a mutually-exclusive quest"
            end
        end
    end

    if info.reqLevel and info.reqLevel > 0 and (ns.player.level or 0) < info.reqLevel then
        return "locked", "Requires level " .. info.reqLevel
    end

    return "eligible"
end

-- Display metadata per status.
ns.STATUS = {
    done        = { label = "Done",        color = {0.40, 0.85, 0.40}, order = 4 },
    active      = { label = "In Progress", color = {0.95, 0.82, 0.25}, order = 1 },
    eligible    = { label = "Eligible",    color = {0.45, 0.70, 1.00}, order = 0 },
    locked      = { label = "Locked",      color = {0.60, 0.60, 0.60}, order = 2 },
    unavailable = { label = "Unavailable", color = {0.80, 0.35, 0.35}, order = 5 },
    unknown     = { label = "No data",     color = {0.55, 0.45, 0.55}, order = 6 },
}
