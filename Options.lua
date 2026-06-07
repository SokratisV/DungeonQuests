local ADDON, ns = ...

-- Standalone settings panel, registered in the Blizzard Interface/AddOns options
-- (Esc -> Options -> AddOns -> Dungeon Quests, or the in-window "Settings" button).

local panel = CreateFrame("Frame")
panel.name = "Dungeon Quests"
ns.optionsPanel = panel

local refreshers = {}   -- functions that re-sync each control from ns.db

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Dungeon Quests")

local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
subtitle:SetPoint("RIGHT", panel, "RIGHT", -32, 0)
subtitle:SetJustifyH("LEFT")
subtitle:SetText("Filtering and display options for the dungeon-quest browser (/dq).")

--------------------------------------------------------------------------
-- Checkboxes (each bound to a key in ns.db.filters)
--------------------------------------------------------------------------
local function addCheck(label, key, tooltip, y)
    local cb = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    cb:SetSize(26, 26)
    cb:SetPoint("TOPLEFT", 18, y)
    local txt = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    txt:SetPoint("LEFT", cb, "RIGHT", 2, 0)
    txt:SetText(label)
    cb:SetScript("OnClick", function(self)
        ns.db.filters[key] = self:GetChecked() and true or false
        if ns.RefreshUI then ns.RefreshUI() end
    end)
    if tooltip then
        cb:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(label, 1, 1, 1)
            GameTooltip:AddLine(tooltip, 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end)
        cb:SetScript("OnLeave", GameTooltip_Hide or function() GameTooltip:Hide() end)
    end
    refreshers[#refreshers + 1] = function() cb:SetChecked(ns.db.filters[key]) end
    return cb
end

local y = -70
addCheck("Show only my faction's quests", "playerFactionOnly",
    "Hide quests for the opposite faction.", y); y = y - 30
addCheck("Hide completed quests", "hideCompleted",
    "Hide quests you've already finished.", y); y = y - 30
addCheck("Hide unavailable quests", "hideUnavailable",
    "Hide quests your class/race can't take.", y); y = y - 30
addCheck("Show breadcrumb quests", "showBreadcrumbs",
    "List the breadcrumb quests that lead to a quest, above it.", y); y = y - 30
addCheck("Show completion counts in the list", "showCounts",
    "Show each dungeon's done/total and colour its name green when complete.", y); y = y - 30
addCheck("Count breadcrumbs toward completion", "breadcrumbsInCompletion",
    "Include breadcrumb quests in the done/total counts.", y); y = y - 40

--------------------------------------------------------------------------
-- Opacity slider
--------------------------------------------------------------------------
local slider = CreateFrame("Slider", "DungeonQuestsOpacitySlider", panel, "OptionsSliderTemplate")
slider:SetWidth(280)
slider:SetPoint("TOPLEFT", 20, y)
-- Explicit groove: the template's track backdrop is invisible on a dark panel.
local groove = slider:CreateTexture(nil, "BACKGROUND")
groove:SetColorTexture(0.55, 0.55, 0.55, 0.6)
groove:SetHeight(3)
groove:SetPoint("LEFT", slider, "LEFT", 5, 0)
groove:SetPoint("RIGHT", slider, "RIGHT", -5, 0)
slider:SetMinMaxValues(0.3, 1.0)
slider:SetValueStep(0.05)
if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
_G[slider:GetName() .. "Low"]:SetText("30%")
_G[slider:GetName() .. "High"]:SetText("100%")
local sliderLabel = _G[slider:GetName() .. "Text"]
sliderLabel:SetText("Window opacity")
slider:SetScript("OnValueChanged", function(self, value)
    ns.db.opacity = value
    if ns.SetWindowOpacity then ns.SetWindowOpacity(value) end
    sliderLabel:SetText(string.format("Window opacity: %d%%", math.floor(value * 100 + 0.5)))
end)
refreshers[#refreshers + 1] = function() slider:SetValue(ns.db.opacity or 1) end

--------------------------------------------------------------------------
-- Sync controls whenever the panel is shown.
--------------------------------------------------------------------------
panel.refresh = function()
    if not ns.db then return end
    for _, fn in ipairs(refreshers) do fn() end
end
panel:SetScript("OnShow", panel.refresh)

--------------------------------------------------------------------------
-- Register with the options UI (new Settings API or legacy InterfaceOptions).
--------------------------------------------------------------------------
local category
if Settings and Settings.RegisterCanvasLayoutCategory then
    category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    category.ID = panel.name
    Settings.RegisterAddOnCategory(category)
elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel)
end

function ns.OpenOptions()
    if Settings and Settings.OpenToCategory and category then
        Settings.OpenToCategory(category:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)   -- twice: legacy open-to-category quirk
    end
end
