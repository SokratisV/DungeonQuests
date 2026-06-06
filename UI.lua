local ADDON, ns = ...

local UI               -- main frame (lazy-built)
local dungeonRows = {} -- reusable left-pane rows
local questRows   = {} -- reusable right-pane rows
local selectedKey      -- currently selected dungeon key
local searchText = ""

local FONT = "GameFontNormal"
local BREAD = "|TInterface\\Icons\\INV_Misc_Food_06:14:14:0:0|t"   -- breadcrumb marker, for fun

--------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------
local function fmtCoords(g)
    if g.fromObject then return "Found on an object inside the dungeon" end
    if g.fromItem   then return "Drops from an enemy inside the dungeon" end
    local where = g.zone or "Unknown"
    if g.x and g.y then
        return string.format("%s  (%.1f, %.1f)", where, g.x, g.y)
    end
    return where
end

local function pickupLine(info)
    local g = info.givers and info.givers[1]
    if not g then return "Pickup: unknown" end
    if g.fromObject or g.fromItem then return fmtCoords(g) end
    local line = (g.name or "?") .. " — " .. fmtCoords(g)
    if #info.givers > 1 then line = line .. string.format("  (+%d more)", #info.givers - 1) end
    return line
end

--------------------------------------------------------------------------
-- Wowhead link popup (a selectable text box; Ctrl+C to copy).
--------------------------------------------------------------------------
local linkURL = ""
StaticPopupDialogs["DUNGEONQUESTS_LINK"] = {
    text = "Wowhead link — press Ctrl+C to copy:",
    button1 = OKAY,
    hasEditBox = true,
    editBoxWidth = 350,
    OnShow = function(self)
        local eb = self.editBox or self.EditBox
        if eb then eb:SetText(linkURL); eb:HighlightText(); eb:SetFocus(); eb:SetCursorPosition(0) end
    end,
    EditBoxOnTextChanged = function(self)            -- keep it effectively read-only
        if self:GetText() ~= linkURL then self:SetText(linkURL); self:HighlightText() end
    end,
    EditBoxOnEnterPressed  = function(self) self:GetParent():Hide() end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
    timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
}

function ns.ShowQuestLink(questId)
    linkURL = "https://www.wowhead.com/tbc/quest=" .. questId
    StaticPopup_Show("DUNGEONQUESTS_LINK")
end

-- A dungeon's quests, filtered to what the player wants to see, each annotated
-- with live status and chain position. Returns the row list + a done/total tally.
--
-- Chains are detected from Questie's prerequisite / next-in-chain links: any two
-- visible quests linked that way are grouped, ordered by chain depth, and tagged
-- with chainStep / chainTotal so same-named steps read as a sequence rather than
-- looking like duplicates. Chains are then ordered by their most-actionable step.
local function buildQuestList(dungeon)
    local f = ns.db.filters
    local rows = {}
    for idx, q in ipairs(dungeon.quests) do
        local info = ns.GetQuestInfo(q.id) or { missing = true, name = q.name }
        if not info.name then info.name = q.name end
        local status, reason = ns.GetQuestStatus(q.id, info)

        local show = true
        if f.playerFactionOnly and info.faction and info.faction ~= "Both"
            and info.faction ~= ns.player.faction then show = false end
        if f.hideCompleted   and status == "done"        then show = false end
        if f.hideUnavailable  and status == "unavailable" then show = false end

        if show then
            rows[#rows + 1] = { q = q, info = info, status = status, reason = reason, idx = idx }
        end
    end

    -- Index visible rows by quest id; only links within this set form a chain.
    local byId = {}
    for _, r in ipairs(rows) do byId[r.q.id] = r end

    -- Union-find to group linked quests into chains.
    local uf = {}
    local function find(x)
        local root = x
        while uf[root] do root = uf[root] end
        return root
    end
    local function union(a, b)
        local ra, rb = find(a), find(b)
        if ra ~= rb then uf[ra] = rb end
    end
    for _, r in ipairs(rows) do
        local function link(list)
            if not list then return end
            for _, pid in ipairs(list) do if byId[pid] then union(r.q.id, pid) end end
        end
        link(r.info.preGroup)
        link(r.info.preSingle)
        if r.info.nextInChain and r.info.nextInChain ~= 0 and byId[r.info.nextInChain] then
            union(r.q.id, r.info.nextInChain)
        end
    end

    -- Chain depth = longest prerequisite path within the visible set.
    local function depthOf(id, guard)
        local r = byId[id]
        if not r or not r.info or guard[id] then return 0 end
        guard[id] = true
        local d = 0
        local function consider(list)
            if not list then return end
            for _, pid in ipairs(list) do
                if byId[pid] then
                    local pd = depthOf(pid, guard) + 1
                    if pd > d then d = pd end
                end
            end
        end
        consider(r.info.preGroup)
        consider(r.info.preSingle)
        guard[id] = false
        return d
    end
    for _, r in ipairs(rows) do r.depth = depthOf(r.q.id, {}) end

    -- Bucket rows into chains.
    local chains = {}
    for _, r in ipairs(rows) do
        local root = find(r.q.id)
        local c = chains[root]
        if not c then c = { rows = {}, minOrder = 999, minIdx = 999 }; chains[root] = c end
        c.rows[#c.rows + 1] = r
        local o = ns.STATUS[r.status].order
        if o < c.minOrder then c.minOrder = o end
        if r.idx < c.minIdx then c.minIdx = r.idx end
    end

    local chainList = {}
    for _, c in pairs(chains) do chainList[#chainList + 1] = c end
    table.sort(chainList, function(a, b)
        if a.minOrder ~= b.minOrder then return a.minOrder < b.minOrder end
        return a.minIdx < b.minIdx
    end)

    -- Flatten: chains in actionable order, steps within a chain in chain order.
    local out, done, total = {}, 0, 0
    for _, c in ipairs(chainList) do
        table.sort(c.rows, function(a, b)
            if a.depth ~= b.depth then return a.depth < b.depth end
            return a.idx < b.idx
        end)
        local n = #c.rows
        for i, r in ipairs(c.rows) do
            r.chainStep, r.chainTotal = i, n
            out[#out + 1] = r
            total = total + 1
            if r.status == "done" then done = done + 1 end
        end
    end

    -- Optionally weave in breadcrumb quests (the ones that lead TO a quest),
    -- each placed right above its target. Breadcrumbs don't count toward the
    -- done/total tally -- they're context, not dungeon quests.
    if f.showBreadcrumbs then
        local withBc, seen = {}, {}
        for _, r in ipairs(out) do
            local bcs = r.info and r.info.breadcrumbs
            if bcs then
                for _, bcId in ipairs(bcs) do
                    if not byId[bcId] and not seen[bcId] then
                        seen[bcId] = true
                        local bi = ns.GetQuestInfo(bcId) or { missing = true, name = "Quest " .. bcId }
                        local bstatus, breason = ns.GetQuestStatus(bcId, bi)
                        local show = true
                        if f.playerFactionOnly and bi.faction and bi.faction ~= "Both" and bi.faction ~= ns.player.faction then show = false end
                        if f.hideCompleted   and bstatus == "done"        then show = false end
                        if f.hideUnavailable and bstatus == "unavailable" then show = false end
                        if show then
                            withBc[#withBc + 1] = {
                                q = { id = bcId, name = bi.name }, info = bi,
                                status = bstatus, reason = breason,
                                isBreadcrumb = true, breadcrumbFor = (r.info.name or r.q.name),
                            }
                        end
                    end
                end
            end
            withBc[#withBc + 1] = r
        end
        out = withBc
    end

    return out, done, total
end

--------------------------------------------------------------------------
-- Right pane (quest list)
--------------------------------------------------------------------------
local function questRowTooltip(row)
    local data = row.data
    if not data then return end
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:AddLine(data.info.name or data.q.name, 1, 1, 1)
    local st = ns.STATUS[data.status]
    GameTooltip:AddLine(st.label, st.color[1], st.color[2], st.color[3])
    if data.status == "active" then
        GameTooltip:AddLine("Currently in your quest log", 0.8, 0.8, 0.6)
    end
    if data.reason then GameTooltip:AddLine(data.reason, 0.9, 0.7, 0.5, true) end
    if data.chainTotal and data.chainTotal > 1 then
        GameTooltip:AddLine(string.format("Chain: step %d of %d", data.chainStep, data.chainTotal), 0.7, 0.7, 1)
    end
    if data.isBreadcrumb then
        GameTooltip:AddLine(BREAD .. " Breadcrumb leading to: " .. (data.breadcrumbFor or "?"), 0.85, 0.75, 0.45, true)
    elseif data.info.breadcrumbs and #data.info.breadcrumbs > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(BREAD .. " Breadcrumbs leading here:", 0.85, 0.75, 0.45)
        for _, bcId in ipairs(data.info.breadcrumbs) do
            local bi = ns.GetQuestInfo(bcId)
            if bi and not bi.missing then
                local bs = ns.GetQuestStatus(bcId, bi)
                local sc = ns.STATUS[bs].color
                GameTooltip:AddLine("  " .. (bi.name or ("Quest " .. bcId)) .. " |cff808080[" .. ns.STATUS[bs].label .. "]|r",
                    sc[1], sc[2], sc[3])
            end
        end
    end
    if data.info.questLevel and data.info.questLevel > 0 then
        GameTooltip:AddLine("Quest level " .. data.info.questLevel
            .. (data.info.reqLevel and data.info.reqLevel > 0 and ("  (req " .. data.info.reqLevel .. ")") or ""),
            0.8, 0.8, 0.8)
    end
    if data.info.faction and data.info.faction ~= "Both" then
        GameTooltip:AddLine("Faction: " .. data.info.faction, 0.8, 0.8, 0.8)
    end
    if data.info.givers and #data.info.givers > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Pick up from:", 0.6, 0.8, 1)
        for _, g in ipairs(data.info.givers) do
            if g.name then
                GameTooltip:AddLine("  " .. g.name .. " — " .. fmtCoords(g), 1, 1, 1)
            else
                GameTooltip:AddLine("  " .. fmtCoords(g), 1, 1, 1)
            end
        end
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Quest ID " .. data.q.id, 0.5, 0.5, 0.5)
    GameTooltip:AddLine("Left-click: copy Wowhead link", 0.5, 0.8, 0.5)
    GameTooltip:AddLine(ns.db.seen[data.q.id] and "Right-click: unmark as seen" or "Right-click: mark as seen", 0.5, 0.8, 0.5)
    GameTooltip:Show()
end

local function getQuestRow(i, parent)
    local row = questRows[i]
    if row then return row end
    row = CreateFrame("Button", nil, parent)
    row:SetHeight(36)
    row.dot = row:CreateTexture(nil, "ARTWORK")
    row.dot:SetTexture("Interface\\COMMON\\Indicator-Gray")
    row.dot:SetSize(16, 16)
    row.dot:SetPoint("TOPLEFT", 4, -4)

    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.name:SetPoint("TOPLEFT", row.dot, "TOPRIGHT", 6, 1)
    row.name:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    row.name:SetJustifyH("LEFT")

    row.meta = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.meta:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -2)
    row.meta:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    row.meta:SetJustifyH("LEFT")

    -- Strikethrough line for "seen" quests, sized to the name text at render time.
    row.strike = row:CreateTexture(nil, "OVERLAY")
    row.strike:SetColorTexture(0.7, 0.7, 0.7, 0.9)
    row.strike:SetHeight(1)
    row.strike:Hide()

    row.hl = row:CreateTexture(nil, "BACKGROUND")
    row.hl:SetAllPoints()
    row.hl:SetColorTexture(1, 1, 1, 0.06)
    row.hl:Hide()
    row:SetScript("OnEnter", function(self) self.hl:Show(); questRowTooltip(self) end)
    row:SetScript("OnLeave", function(self) self.hl:Hide(); GameTooltip:Hide() end)
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row:SetScript("OnClick", function(self, button)
        if not self.data then return end
        if button == "RightButton" then
            local id = self.data.q.id
            ns.db.seen[id] = (not ns.db.seen[id]) or nil
            ns.RefreshUI()
            questRowTooltip(self)   -- refresh the hint text immediately
        else
            ns.ShowQuestLink(self.data.q.id)
        end
    end)
    questRows[i] = row
    return row
end

local function renderQuests()
    local child = UI.questScroll.child
    local w = UI.questScroll:GetWidth(); if w and w > 1 then child:SetWidth(w) end
    local dungeon
    for _, d in ipairs(ns.dungeons) do if d.key == selectedKey then dungeon = d break end end

    -- Hide all rows first.
    for _, r in ipairs(questRows) do r:Hide() end

    if not dungeon then
        UI.header:SetText("Select a dungeon")
        UI.empty:SetText("")
        return
    end

    UI.header:SetText(dungeon.name .. "  |cff999999(" .. dungeon.zone .. ", lvl " .. dungeon.minLevel .. "-" .. dungeon.maxLevel .. ")|r")

    if not ns.QuestieReady then
        UI.empty:SetText(ns.questieMissing
            and "This addon requires |cff66ccffQuestie|r to be installed and enabled."
            or "Loading Questie data…")
        return
    end
    if #dungeon.quests == 0 then
        UI.empty:SetText("No quests catalogued for this dungeon yet.")
        return
    end

    local rows, done, total = buildQuestList(dungeon)
    if total == 0 then
        UI.empty:SetText("No quests match your filters.")
    else
        UI.empty:SetText("")
    end
    UI.header:SetText(UI.header:GetText() .. string.format("   |cffffffff%d/%d done|r", done, total))

    local y = -2
    for i, data in ipairs(rows) do
        local row = getQuestRow(i, child)
        row:SetParent(child)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", child, "TOPLEFT", 0, y)
        row:SetPoint("RIGHT", child, "RIGHT", 0, 0)
        row.data = data

        local st = ns.STATUS[data.status]
        -- Indent chain steps after the first (and breadcrumb rows) so they read
        -- as belonging under their quest.
        local isChainChild = data.chainTotal and data.chainTotal > 1 and data.chainStep > 1
        local indent = isChainChild and 16 or 0   -- breadcrumbs sit above their quest, not indented under it
        row.dot:ClearAllPoints()
        row.dot:SetPoint("TOPLEFT", 4 + indent, -4)
        row.dot:SetVertexColor(st.color[1], st.color[2], st.color[3])
        local prefix = string.format("|cff%02x%02x%02x[%s]|r ",
            math.floor(st.color[1] * 255), math.floor(st.color[2] * 255), math.floor(st.color[3] * 255), st.label)
        local lvl = (data.info.questLevel and data.info.questLevel > 0) and (" |cff999999(" .. data.info.questLevel .. ")|r") or ""
        local fac = ""
        if data.info.faction == "Alliance" then fac = " |cff6699ff[A]|r"
        elseif data.info.faction == "Horde" then fac = " |cffcc4444[H]|r" end
        local chainTag = ""
        if data.chainTotal and data.chainTotal > 1 then
            chainTag = string.format(" |cff7f7f7f(%d/%d)|r", data.chainStep, data.chainTotal)
        end
        local connector = isChainChild and "|cff7f7f7f\194\187|r " or ""   -- "» " (U+21B3 ↳ isn't in the game font)
        local bread = data.isBreadcrumb and (BREAD .. " ") or ""
        local bcTag = data.isBreadcrumb and " |cff9d9d9d(breadcrumb)|r" or ""
        row.name:SetText(prefix .. connector .. bread .. (data.info.name or data.q.name) .. lvl .. fac .. chainTag .. bcTag)

        local seen = ns.db.seen[data.q.id]
        local alpha = 1
        if seen then alpha = 0.4
        elseif data.status == "unavailable" or data.status == "done" then alpha = 0.55 end
        row.name:SetAlpha(alpha); row.meta:SetAlpha(alpha); row.dot:SetAlpha(alpha)

        -- Strike through "seen" quests (line sized to the rendered name width).
        if seen then
            local avail = (row:GetWidth() or 400) - indent - 32
            local w = row.name:GetStringWidth()
            if avail > 0 and w > avail then w = avail end
            row.strike:ClearAllPoints()
            row.strike:SetPoint("LEFT", row.name, "LEFT", 0, 0)
            row.strike:SetWidth(math.max(1, w))
            row.strike:Show()
        else
            row.strike:Hide()
        end
        if data.isBreadcrumb and data.breadcrumbFor then
            row.meta:SetText(pickupLine(data.info) .. "   |cff7f9f7fleads to " .. data.breadcrumbFor .. "|r")
        else
            row.meta:SetText(pickupLine(data.info))
        end
        row:Show()
        y = y - 36
    end
    child:SetHeight(math.max(1, -y))
end

--------------------------------------------------------------------------
-- Left pane (dungeon list)
--------------------------------------------------------------------------
local function buildLeftItems()
    local items = {}
    local lastExp
    for _, d in ipairs(ns.dungeons) do
        if searchText == "" or d.name:lower():find(searchText, 1, true) then
            if d.expansion ~= lastExp then
                items[#items + 1] = { header = d.expansion }
                lastExp = d.expansion
            end
            items[#items + 1] = { dungeon = d }
        end
    end
    return items
end

local function getDungeonRow(i, parent)
    local row = dungeonRows[i]
    if row then return row end
    row = CreateFrame("Button", nil, parent)
    row:SetHeight(30)
    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.name:SetPoint("TOPLEFT", 8, -3)
    row.name:SetPoint("RIGHT", -4, 0)
    row.name:SetJustifyH("LEFT")
    row.sub = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.sub:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -1)
    row.sub:SetJustifyH("LEFT")
    row.hl = row:CreateTexture(nil, "BACKGROUND")
    row.hl:SetAllPoints(); row.hl:SetColorTexture(0.3, 0.5, 0.8, 0.25); row.hl:Hide()
    row.sel = row:CreateTexture(nil, "BACKGROUND")
    row.sel:SetAllPoints(); row.sel:SetColorTexture(0.25, 0.45, 0.75, 0.45); row.sel:Hide()
    row:SetScript("OnEnter", function(self) if self.key then self.hl:Show() end end)
    row:SetScript("OnLeave", function(self) self.hl:Hide() end)
    row:SetScript("OnClick", function(self)
        if not self.key then return end
        selectedKey = self.key
        ns.db.selected = self.key
        ns.RefreshUI()
    end)
    dungeonRows[i] = row
    return row
end

local function renderDungeons()
    local child = UI.dungeonScroll.child
    local w = UI.dungeonScroll:GetWidth(); if w and w > 1 then child:SetWidth(w) end
    for _, r in ipairs(dungeonRows) do r:Hide() end
    local items = buildLeftItems()
    local y = -2
    for i, item in ipairs(items) do
        local row = getDungeonRow(i, child)
        row:SetParent(child)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", child, "TOPLEFT", 0, y)
        row:SetPoint("RIGHT", child, "RIGHT", 0, 0)
        if item.header then
            row.key = nil
            row:SetHeight(22)
            row.name:SetText("|cffffd100" .. item.header .. "|r")
            row.sub:SetText("")
            row.sel:Hide(); row.hl:Hide()
            row:EnableMouse(false)
            y = y - 24
        else
            local d = item.dungeon
            row.key = d.key
            row:SetHeight(30)
            row.name:SetText(d.name)
            row.sub:SetText("lvl " .. d.minLevel .. "-" .. d.maxLevel .. "  •  " .. d.zone)
            row.sel:SetShown(d.key == selectedKey)
            row.hl:Hide()
            row:EnableMouse(true)
            y = y - 32
        end
        row:Show()
    end
    child:SetHeight(math.max(1, -y))
end

--------------------------------------------------------------------------
-- Public refresh
--------------------------------------------------------------------------
function ns.RefreshUI()
    if not UI or not UI:IsShown() then return end
    renderDungeons()
    renderQuests()
end

--------------------------------------------------------------------------
-- Build
--------------------------------------------------------------------------
local BACKDROP = {
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
}

local function makeScroll(parent, name)
    local scroll = CreateFrame("ScrollFrame", name, parent, "UIPanelScrollFrameTemplate")
    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(10, 10)
    scroll:SetScrollChild(child)
    scroll.child = child
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local sb = self.ScrollBar or _G[name .. "ScrollBar"]
        if sb then sb:SetValue(sb:GetValue() - delta * 32) end
    end)
    -- keep child width synced to the visible area
    scroll:SetScript("OnSizeChanged", function(self, w) child:SetWidth(w) end)
    return scroll
end

local function makeCheck(parent, label, key)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetSize(22, 22)
    local txt = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    txt:SetPoint("LEFT", cb, "RIGHT", 1, 0)
    txt:SetText(label)
    cb:SetScript("OnShow", function(self) self:SetChecked(ns.db.filters[key]) end)
    cb:SetScript("OnClick", function(self)
        ns.db.filters[key] = self:GetChecked() and true or false
        ns.RefreshUI()
    end)
    cb.label = txt
    return cb
end

local function buildUI()
    if UI then return end
    UI = CreateFrame("Frame", "DungeonQuestsFrame", UIParent, "BackdropTemplate")
    UI:SetSize(800, 520)
    UI:SetFrameStrata("HIGH")
    UI:SetBackdrop(BACKDROP)
    UI:SetClampedToScreen(true)
    UI:SetMovable(true)
    UI:EnableMouse(true)
    UI:RegisterForDrag("LeftButton")
    UI:SetScript("OnDragStart", UI.StartMoving)
    UI:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, rp, x, y = self:GetPoint()
        ns.db.window.point = { p, rp, math.floor(x + 0.5), math.floor(y + 0.5) }
    end)
    tinsert(UISpecialFrames, "DungeonQuestsFrame")   -- close with Escape

    -- position
    local pt = ns.db.window.point
    if pt then UI:SetPoint(pt[1], UIParent, pt[2], pt[3], pt[4]) else UI:SetPoint("CENTER") end

    -- title + close
    local title = UI:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText("|cff66ccffDungeon Quests|r")
    local close = CreateFrame("Button", nil, UI, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -8, -8)

    -- search box
    local search = CreateFrame("EditBox", "DungeonQuestsSearch", UI, "InputBoxTemplate")
    search:SetSize(220, 22)
    search:SetPoint("TOPLEFT", 22, -46)
    search:SetAutoFocus(false)
    search:SetScript("OnTextChanged", function(self)
        searchText = self:GetText():lower():gsub("^%s+", ""):gsub("%s+$", "")
        renderDungeons()
    end)
    search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    local sLabel = UI:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    sLabel:SetPoint("BOTTOMLEFT", search, "TOPLEFT", -2, 2)
    sLabel:SetText("Search dungeons")

    -- filters (top-right row)
    local c1 = makeCheck(UI, "My faction only", "playerFactionOnly")
    c1:SetPoint("TOPLEFT", search, "TOPRIGHT", 16, 2)
    local c2 = makeCheck(UI, "Hide completed", "hideCompleted")
    c2:SetPoint("LEFT", c1.label, "RIGHT", 14, 0)
    local c3 = makeCheck(UI, "Hide unavailable", "hideUnavailable")
    c3:SetPoint("LEFT", c2.label, "RIGHT", 14, 0)
    local c4 = makeCheck(UI, "Breadcrumbs", "showBreadcrumbs")
    c4:SetPoint("LEFT", c3.label, "RIGHT", 14, 0)
    c4.label:SetText("Breadcrumbs " .. BREAD)

    -- divider line under the controls
    local sep = UI:CreateTexture(nil, "ARTWORK")
    sep:SetColorTexture(1, 1, 1, 0.12)
    sep:SetPoint("TOPLEFT", 16, -78)
    sep:SetPoint("TOPRIGHT", -16, -78)
    sep:SetHeight(1)

    -- left pane
    local leftBG = CreateFrame("Frame", nil, UI, "BackdropTemplate")
    leftBG:SetPoint("TOPLEFT", 16, -86)
    leftBG:SetPoint("BOTTOMLEFT", 16, 16)
    leftBG:SetWidth(244)
    leftBG:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    leftBG:SetBackdropColor(0, 0, 0, 0.25)
    leftBG:SetBackdropBorderColor(1, 1, 1, 0.12)
    UI.dungeonScroll = makeScroll(leftBG, "DungeonQuestsDungeonScroll")
    UI.dungeonScroll:SetPoint("TOPLEFT", 6, -6)
    UI.dungeonScroll:SetPoint("BOTTOMRIGHT", -26, 6)

    -- right pane
    UI.header = UI:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    UI.header:SetPoint("TOPLEFT", leftBG, "TOPRIGHT", 16, -2)
    UI.header:SetPoint("RIGHT", UI, "RIGHT", -20, 0)
    UI.header:SetJustifyH("LEFT")
    UI.header:SetText("Select a dungeon")

    local rightBG = CreateFrame("Frame", nil, UI, "BackdropTemplate")
    rightBG:SetPoint("TOPLEFT", leftBG, "TOPRIGHT", 16, -26)
    rightBG:SetPoint("BOTTOMRIGHT", -16, 16)
    rightBG:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    rightBG:SetBackdropColor(0, 0, 0, 0.25)
    rightBG:SetBackdropBorderColor(1, 1, 1, 0.12)
    UI.questScroll = makeScroll(rightBG, "DungeonQuestsQuestScroll")
    UI.questScroll:SetPoint("TOPLEFT", 6, -6)
    UI.questScroll:SetPoint("BOTTOMRIGHT", -26, 6)

    UI.empty = UI.questScroll.child:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    UI.empty:SetPoint("TOP", UI.questScroll, "TOP", 0, -20)
    UI.empty:SetText("")

    UI:Hide()
end

--------------------------------------------------------------------------
-- Toggle + live refresh events
--------------------------------------------------------------------------
function ns.Toggle()
    buildUI()
    if UI:IsShown() then
        UI:Hide()
    else
        selectedKey = selectedKey or ns.db.selected
        UI:Show()
        ns.RefreshUI()
    end
end

local pending
local function throttledRefresh()
    if pending or not UI or not UI:IsShown() then return end
    pending = true
    C_Timer.After(0.3, function() pending = nil; ns.RefreshUI() end)
end
ns.On("QUEST_TURNED_IN",  throttledRefresh)
ns.On("QUEST_ACCEPTED",   throttledRefresh)
ns.On("QUEST_REMOVED",    throttledRefresh)
ns.On("QUEST_LOG_UPDATE", throttledRefresh)

--------------------------------------------------------------------------
-- /dq validate : check every curated quest ID against Questie's live names.
--------------------------------------------------------------------------
-- /dq bc : report which catalogued quests actually have breadcrumb data in
-- Questie (settles "bug vs. no data" for the Breadcrumbs option).
function ns.BreadcrumbDebug()
    if not ns.QuestieReady then
        print("|cff66ccffDungeon Quests|r: Questie not ready yet.")
        return
    end
    local withBc, total = 0, 0
    for _, d in ipairs(ns.dungeons) do
        for _, q in ipairs(d.quests) do
            total = total + 1
            local info = ns.GetQuestInfo(q.id)
            local bcs = info and info.breadcrumbs
            if bcs and #bcs > 0 then
                withBc = withBc + 1
                local names = {}
                for _, bcId in ipairs(bcs) do
                    local bi = ns.GetQuestInfo(bcId)
                    names[#names + 1] = (bi and bi.name) or tostring(bcId)
                end
                print(string.format("|cff66ccff%s|r — %s (%d): %s",
                    d.name, info.name or q.name, q.id, table.concat(names, ", ")))
            end
        end
    end
    print(string.format("|cff66ccffDungeon Quests|r: %d of %d catalogued quests have breadcrumb data in Questie.", withBc, total))
end

function ns.ValidateData()
    if not ns.QuestieReady then
        print("|cff66ccffDungeon Quests|r: Questie not ready yet" ..
            (ns.questieMissing and " (Questie not installed)." or " — try again in a moment."))
        return
    end
    local bad, checked = 0, 0
    for _, d in ipairs(ns.dungeons) do
        for _, q in ipairs(d.quests) do
            checked = checked + 1
            local real = ns.GetQuestieName(q.id)
            if not real then
                bad = bad + 1
                print(string.format("|cffff5555[%s] id %d (%s): NOT FOUND in Questie|r", d.name, q.id, q.name))
            elseif q.name and real ~= q.name then
                bad = bad + 1
                print(string.format("|cffffd100[%s] id %d: expected '%s' but Questie says '%s'|r", d.name, q.id, q.name, real))
            end
        end
    end
    print(string.format("|cff66ccffDungeon Quests|r: validated %d quests, %d mismatches.", checked, bad))
end
