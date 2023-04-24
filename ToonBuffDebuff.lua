local debuffFrame = createFrame(160, 32)
local buffFrame = createFrame(350, 32)
InitializePosition(buffFrame)
InitializePosition(debuffFrame)

-- Create the buff and debuff icons
local BUFF_ICON_SIZE = 32
local NUM_BUFFS = 20
for i = 1, NUM_BUFFS do
    local buffIcon = CreateSpellIcon(buffFrame, "")
    buffIcon:SetPoint("TOPLEFT", buffFrame, "TOPLEFT", (i-1)*BUFF_ICON_SIZE, 0)
end

local DEBUFF_ICON_SIZE = 32
local NUM_DEBUFFS = 20
for i = 1, NUM_DEBUFFS do
    local debuffIcon = CreateSpellIcon(debuffFrame, "")
    debuffIcon:SetPoint("TOPLEFT", debuffFrame, "TOPLEFT", (i-1)*DEBUFF_ICON_SIZE, 0)
end

local existingBuffIDs = {}

local function UpdateBuffDisplay()
    -- Get the buff data with spell icons
    local buffsData, _ = buffsDebuffs()

    -- Handle buffs
    local buffIndex = 1
    for _, buffData in pairs(buffsData) do
        local buffIcon = existingBuffIDs[buffData.spellId]
        if not buffIcon then
            -- Create a new buff icon frame
            buffIcon = CreateSpellIcon(buffFrame, buffData.texture)
            existingBuffIDs[buffData.spellId] = buffIcon
        end

        local buffText = ''
        local buffExpirationTime = buffData.expirationTime - GetTime()
        if buffExpirationTime <= 0 or buffExpirationTime >= 90 then
            ResetInactiveBuffIcon(buffIcon) -- Call the new function to reset and hide inactive buff icons
            existingBuffIDs[buffData.spellId] = nil
        else
            if buffData.modifiesSpellPower then
                buffText = string.format("%.1f\n%d", buffExpirationTime, buffData.buffAmount)
            else
                buffText = string.format("%.1f", buffExpirationTime)
            end
            buffIcon:SetAlpha(1.0)
            buffIcon.text:SetText(buffText)
            buffIcon:Show() -- Make sure the buff icon is shown

            -- Set the position of the spell icon based on its index
            buffIcon:ClearAllPoints()
            buffIcon:SetPoint("TOPLEFT", buffFrame, "TOPLEFT", (buffIndex-1)*(BUFF_ICON_SIZE + 4), 0)

            buffIndex = buffIndex + 1
        end
    end

    -- Hide any inactive buffs that are still in the existingBuffIDs table
    for spellId, spellIcon in pairs(existingBuffIDs) do
        if not buffDataContainsSpellId(buffsData, spellId) then
            ResetInactiveBuffIcon(spellIcon)
            existingBuffIDs[spellId] = nil
        end
    end
end

local existingDebuffIDs = {}

local function UpdateDebuffDisplay()
    -- Get the debuff data with spell icons
    local _, debuffsData = buffsDebuffs()

    -- Handle debuffs
    local debuffIndex = 1
    for _, debuffData in pairs(debuffsData) do
        local debuffIcon = existingDebuffIDs[debuffData.spellId]
        if not debuffIcon then
            -- Create a new debuff icon frame
            debuffIcon = CreateSpellIcon(debuffFrame, debuffData.texture)
            existingDebuffIDs[debuffData.spellId] = debuffIcon
        end

        local expirationTime = debuffData.expirationTime - GetTime()
        if buffExpirationTime <= 0 or buffExpirationTime >= 90 then
            ResetInactiveBuffIcon(debuffIcon)
            existingDebuffIDs[debuffData.spellId] = nil
        else
            debuffIcon:SetAlpha(1.0)
            debuffIcon.text:SetText(format("%.1f", expirationTime))
            debuffIcon:Show()

            -- Set the position of the spell icon based on its index
            debuffIcon:ClearAllPoints()
            debuffIcon:SetPoint("TOPLEFT", debuffFrame, "TOPLEFT", (debuffIndex-1)*DEBUFF_ICON_SIZE, 0)

            debuffIndex = debuffIndex + 1
        end
    end

    -- Hide any inactive debuffs that are still in the existingDebuffIDs table
    for spellId, spellIcon in pairs(existingDebuffIDs) do
        if not buffDataContainsSpellId(debuffsData, spellId) then
            ResetInactiveBuffIcon(spellIcon)
            existingDebuffIDs[spellId] = nil
        end
    end
end

-- Define a function to handle the UNIT_AURA event
local function OnUnitAuraChanged(self, event, unit)
    if unit ~= "target" then
        return
    end

    -- Update the buff display
    UpdateBuffDisplay()

    -- Update the rotation display
    UpdateDebuffDisplay()
end

-- Register for the UNIT_AURA event to update the buff and rotation displays when the target's auras change
buffFrame:RegisterEvent("UNIT_AURA")
buffFrame:SetScript("OnEvent", OnUnitAuraChanged)

debuffFrame:RegisterUnitEvent("UNIT_AURA", "target")
debuffFrame:SetScript("OnEvent", OnUnitAuraChanged)

-- Create a frame for updating the buffs
local buffFrameUpdate = CreateFrame("Frame")
buffFrameUpdate:SetScript("OnUpdate", function(self, elapsed)
    UpdateBuffDisplay()
end)
-- Create a frame for updating the debuffs
local debuffFrameUpdate = CreateFrame("Frame")
debuffFrameUpdate:SetScript("OnUpdate", function(self, elapsed)
    UpdateDebuffDisplay()
end)

-- Event Handling
buffFrame:RegisterEvent("ADDON_LOADED")
buffFrame:RegisterEvent("PLAYER_LOGOUT")
buffFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "ToonBuffDebuff" then
        InitializePosition(buffFrame)
    elseif event == "PLAYER_LOGOUT" then
        SavePosition(buffFrame)
    end
end)