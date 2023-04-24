function createFrame(width, height)
    local frame = CreateFrame("Frame", "frame", UIParent)
    frame:SetSize(width, height)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        --SavePosition()
    end)
    
    -- Set a background texture
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.5)
    
    return frame
end

function SavePosition(frame)
    local point, _, _, x, y = frame:GetPoint()
    FrameDB = {point, x, y}
end

function InitializePosition(frame)
    local point, x, y
    if FrameDB then
        point, x, y = unpack(FrameDB)
    else
        point, x, y = "CENTER", 0, 0
    end
    frame:SetPoint(point, x, y)
end

function OnPlayerLogout()
    SavePosition()
end

function ResetInactiveBuffIcon(frameIcon)
    frameIcon:SetAlpha(0.1)
    frameIcon.text:SetText("")
    frameIcon:Hide()
end

function buffDataContainsSpellId(data, spellId)
    for _, data in pairs(data) do
        if data.spellId == spellId then
            return true
        end
    end
    return false
end


function CreateSpellIcon(parent, texture)
    local iconFrame = CreateFrame("Frame", nil, parent)
    iconFrame:SetSize(32, 32)

    local iconTexture = iconFrame:CreateTexture(nil, "ARTWORK")
    iconTexture:SetTexture(texture)
    iconTexture:SetAllPoints(iconFrame)
    iconFrame.texture = iconTexture

    local cooldownText = iconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cooldownText:SetPoint("BOTTOM", iconFrame, "TOP", 0, -2)
    cooldownText:SetFont(GameFontNormal:GetFont(), 14)
    cooldownText:SetTextColor(1, 1, 1)
    iconFrame.text = cooldownText

    return iconFrame
end

function buffsDebuffs()
    local buffsData, debuffsData = {}, {}
    for i = 1, 40 do -- assuming you want to check all 40 buff/debuff slots
        local debuffName, _, debuffIcon, _, debuffDuration, debuffExpirationTime, debuffCaster, _, _, debuffSpellId = UnitAura("target", i, "HARMFUL|PLAYER")
        local buffName, _, buffIcon, _, buffDuration, buffExpirationTime, buffCaster, _, _, buffSpellId = UnitAura("player", i, "HELPFUL|PLAYER")
        local petBuffName, _, petBuffIcon, _, petBuffDuration, petBuffExpirationTime, petBuffCaster, _, _, petBuffSpellId, _, _,_,_,_,_, buffAmount  = UnitAura("pet", i, "HELPFUL|PLAYER")
        if debuffName and debuffCaster == "player" then -- if there is a debuff present and it's applied by the player
            local debuff = {
                name = debuffName, 
                icon = debuffIcon, 
                duration = debuffDuration, 
                expirationTime = debuffExpirationTime, 
                texture = GetSpellTexture(debuffSpellId), 
                spellId = debuffSpellId, 
                isDebuff = true,
                modifiesSpellPower = false
            }
            table.insert(debuffsData, debuff)
        end
        if buffName and buffCaster == "player" then -- if there is a buff present and it's applied by the player
            local buff = {
                name = buffName, 
                icon = buffIcon, 
                duration = buffDuration, 
                expirationTime = buffExpirationTime, 
                texture = GetSpellTexture(buffSpellId), 
                spellId = buffSpellId, 
                isDebuff = false,
                modifiesSpellPower = false
            }
            table.insert(buffsData, buff)
        end
        if petBuffName and petBuffCaster == "pet" and petBuffName == "Demonic Pact" then
            local buff = {
                name = petBuffName,
                icon = petBuffIcon,
                duration = petBuffDuration,
                expirationTime = petBuffExpirationTime,
                texture = GetSpellTexture(petBuffSpellId),
                spellId = petBuffSpellId,
                isDebuff = false,
                modifiesSpellPower = true,
                bonus = bonus,
                buffAmount = buffAmount
            }
            table.insert(buffsData, buff)
        end
    end
    return buffsData, debuffsData
end