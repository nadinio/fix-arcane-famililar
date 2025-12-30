InitializeSavedVariables()

SetupFrame()

SetupIcon()

SetupTooltip()

-- Function to check if player has the Arcane Familiar buff
local function HasArcaneFamiliarBuff()
    local auraData = C_UnitAuras.GetAuraDataBySpellName("player", "Arcane Familiar", "HELPFUL")
    return auraData ~= nil
end

-- Function to check if player is an Arcane Mage
local function IsArcaneMage()
    local ARCANE_MAGE_SPEC_ID = 62;

    local currentSpecID = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())

    return currentSpecID == ARCANE_MAGE_SPEC_ID
end

-- Function to update the frame visibility
local function UpdateBuffStatus()
    if not IsArcaneMage() or InCombatLockdown() or HasArcaneFamiliarBuff() then
        frame:Hide()
        return
    end

    frame:Show()
end

-- Event Handling
frame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_REGEN_DISABLED" then
        -- Entering combat, hide frame
        frame:Hide()
    else
        UpdateBuffStatus()
    end
end)



local PREFIX_TEXT = "|cff8B00FFFix Arcane Familiar:|r "

-- Slash command to toggle or reset position
SLASH_FIXARCANEFAMILIAR1 = "/faf"
SLASH_FIXARCANEFAMILIAR2 = "/fixarcanefamiliar"
SlashCmdList["FIXARCANEFAMILIAR"] = function(msg)
    if msg == "reset" then
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
        print(PREFIX_TEXT .. "Frame position reset.")
    elseif msg == "test" then
        if frame:IsShown() then
            frame:Hide()
            print(PREFIX_TEXT .. "Test mode off.")
        else
            frame:Show()
            print(PREFIX_TEXT .. "Test mode on - showing frame.")
        end
    elseif msg == "lock" then
        FAF.isLocked = true
        print(PREFIX_TEXT .. "Frame locked.")
    elseif msg == "unlock" then
        FAF.isLocked = false
        print(PREFIX_TEXT .. "Frame unlocked.")
    else
        print(PREFIX_TEXT .. "commands:")
        print("  /faf reset - Reset frame to center of screen")
        print("  /faf test - Toggle frame visibility for testing")
        print("  /faf lock - Lock frame position")
        print("  /faf unlock - Unlock frame position")
    end
end
