local addonName, addon = ...

-- Arcane Familiar buff name and icon
local ARCANE_FAMILIAR_BUFF_NAME = "Arcane Familiar"
local ARCANE_FAMILIAR_ICON = 1041232 -- Interface icon for Arcane Familiar

-- Lock state
local isLocked = false

-- Create the main frame
local frame = CreateFrame("Frame", "FixArcaneFamiliarFrame", UIParent, "BackdropTemplate")
frame:SetSize(50, 50)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self)
    if not isLocked then
        self:StartMoving()
    end
end)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetClampedToScreen(true)
frame:Hide()

-- Add backdrop
frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0, 0, 0, 0.8)
frame:SetBackdropBorderColor(1, 0, 0, 1)

-- Create icon texture
local icon = frame:CreateTexture(nil, "ARTWORK")
icon:SetSize(42, 42)
icon:SetPoint("CENTER", frame, "CENTER")
icon:SetTexture(ARCANE_FAMILIAR_ICON)
icon:SetDesaturated(true)

-- Create red X overlay to indicate missing buff
local missingOverlay = frame:CreateTexture(nil, "OVERLAY")
missingOverlay:SetSize(42, 42)
missingOverlay:SetPoint("CENTER", frame, "CENTER")
missingOverlay:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady")

-- Add tooltip
frame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Arcane Familiar Missing!", 1, 0, 0)
    GameTooltip:AddLine("Your Arcane Familiar buff is not active.", 1, 1, 1, true)
    if isLocked then
        GameTooltip:AddLine("Position locked. Use /faf unlock to move.", 0.7, 0.7, 0.7)
    else
        GameTooltip:AddLine("Click and drag to move. Use /faf lock to lock.", 0.7, 0.7, 0.7)
    end
    GameTooltip:Show()
end)
frame:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Function to check if player has the Arcane Familiar buff
local function HasArcaneFamiliarBuff()
    -- Iterate through player buffs to find Arcane Familiar by name
    for i = 1, 40 do
        local auraData = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
        if not auraData then
            break
        end
        if auraData.name == ARCANE_FAMILIAR_BUFF_NAME then
            return true
        end
    end
    return false
end

-- Function to check if player is an Arcane Mage
local function IsArcaneMage()
    local _, class = UnitClass("player")
    if class ~= "MAGE" then
        return false
    end
    local specIndex = GetSpecialization()
    if specIndex then
        local specID = GetSpecializationInfo(specIndex)
        return specID == 62 -- Arcane Mage spec ID
    end
    return false
end

-- Function to update the frame visibility
local function UpdateBuffStatus()
    if not IsArcaneMage() then
        frame:Hide()
        return
    end

    -- Don't show during combat
    if InCombatLockdown() then
        frame:Hide()
        return
    end

    if HasArcaneFamiliarBuff() then
        frame:Hide()
    else
        frame:Show()
    end
end

-- Event handling
local eventFrame = CreateFrame("Frame")
local isActive = false

local function EnableAddon()
    if not isActive then
        eventFrame:RegisterEvent("UNIT_AURA")
        eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        isActive = true
    end
    UpdateBuffStatus()
end

local function DisableAddon()
    if isActive then
        eventFrame:UnregisterEvent("UNIT_AURA")
        eventFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
        eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        isActive = false
    end
    frame:Hide()
end

local function CheckSpecAndToggle()
    if IsArcaneMage() then
        EnableAddon()
    else
        DisableAddon()
    end
end

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            UpdateBuffStatus()
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Entering combat, hide frame
        frame:Hide()
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Leaving combat, check buff status
        UpdateBuffStatus()
    else
        CheckSpecAndToggle()
    end
end)

-- Slash command to toggle or reset position
SLASH_FIXARCANEFAMILIAR1 = "/faf"
SLASH_FIXARCANEFAMILIAR2 = "/fixarcanefamiliar"
SlashCmdList["FIXARCANEFAMILIAR"] = function(msg)
    if msg == "reset" then
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
        print("|cff00ff00Fix Arcane Familiar:|r Frame position reset.")
    elseif msg == "test" then
        if frame:IsShown() then
            frame:Hide()
            print("|cff00ff00Fix Arcane Familiar:|r Test mode off.")
        else
            frame:Show()
            print("|cff00ff00Fix Arcane Familiar:|r Test mode on - showing frame.")
        end
    elseif msg == "lock" then
        isLocked = true
        print("|cff00ff00Fix Arcane Familiar:|r Frame locked.")
    elseif msg == "unlock" then
        isLocked = false
        print("|cff00ff00Fix Arcane Familiar:|r Frame unlocked.")
    else
        print("|cff00ff00Fix Arcane Familiar|r commands:")
        print("  /faf reset - Reset frame to center of screen")
        print("  /faf test - Toggle frame visibility for testing")
        print("  /faf lock - Lock frame position")
        print("  /faf unlock - Unlock frame position")
    end
end
