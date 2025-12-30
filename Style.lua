-- Add initialization function
function InitializeSavedVariables()
    if not FAF then
        FAF = {}
    end
    if FAF.isLocked == nil then
        FAF.isLocked = false
    end
end

function SetupFrame()
    -- Create the main frame
    frame = CreateFrame("Frame", "FixArcaneFamiliarFrame", UIParent, "BackdropTemplate")
    frame:SetSize(50, 50)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        if not FAF.isLocked then
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

    frame:RegisterEvent("PLAYER_LOGIN")
    frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("UNIT_AURA")

end

function SetupIcon()
    -- Create icon texture
    local icon = frame:CreateTexture(nil, "ARTWORK")
    icon:SetSize(42, 42)
    icon:SetPoint("CENTER", frame, "CENTER")
    icon:SetTexture(1041232)
    icon:SetDesaturated(true)

    -- Create red X overlay to indicate missing buff
    local missingOverlay = frame:CreateTexture(nil, "OVERLAY")
    missingOverlay:SetSize(42, 42)
    missingOverlay:SetPoint("CENTER", frame, "CENTER")
    missingOverlay:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady")
end




function SetupTooltip()
    -- Add tooltip
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Arcane Familiar Missing!", 1, 0, 0)
        GameTooltip:AddLine("Your Arcane Familiar buff is not active.", 1, 1, 1, true)
        if FAF.isLocked then
            GameTooltip:AddLine("Position locked. Use /faf unlock to move.", 0.7, 0.7, 0.7)
        else
            GameTooltip:AddLine("Click and drag to move. Use /faf lock to lock.", 0.7, 0.7, 0.7)
        end
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

