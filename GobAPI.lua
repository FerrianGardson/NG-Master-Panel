local name
local radius
local GobjectDeleteRad = 1
local UndoRadius = false
local UndoNameRadius = false
local SaveGobToDB = false
local UndoGobTable = {
}

local function SystemHookIsBlocked()
    return UndoRadius == false and UndoNameRadius == false and SaveGobToDB == false
end

function MasterPanel:CommandMessageHook(msg)
  if msg:find("^.gob add") or msg:find("^.gobject add") then SaveGobToDB = true end
end

local function ConvertRadius(radius)
    if tonumber(radius) == 1 then
        return 2
    elseif tonumber(radius) == 2 then
        return 5
    elseif tonumber(radius) == 3 then
       return 10
    elseif tonumber(radius) == 4 then
        return 15
    else return 0 end
end


local Undo_Cooldown = CreateFrame("Frame")
local Undo_Cooldown_AnimationGroup = Undo_Cooldown:CreateAnimationGroup()
local Undo_CooldownAnimation = Undo_Cooldown_AnimationGroup:CreateAnimation("Alpha")
Undo_CooldownAnimation:SetDuration(1.5)
Undo_Cooldown_AnimationGroup:SetScript("OnFinished", function(self)
    UndoRadius = false
    UndoNameRadius = false
            end)


function MasterPanel:SystemMessageHandler(eventName, arg1)
    if SystemHookIsBlocked() then return end

    --[[if arg1:find("^(%d+)%s%(Entry") and (UndoRadius == true) then
        SendChatMessage(".gob del "..tonumber(string.match(arg1, "^(%d+)")),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
    end
    
    if arg1:find("^(%d+)%s%(Entry") and (UndoNameRadius == true) then
        if string.lower(arg1):find(string.lower(UndoGobName)) then
            SendChatMessage(".gob del "..tonumber(string.match(arg1, "^(%d+)")),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
        end
    end]]
    
    if arg1:find("^>> Add Game Object") then
        table.insert(UndoGobTable, tonumber(string.match(arg1, "%(GUID: (%d+)%)")))
        SaveGobToDB = false
    end
end

--"%(GUID: (.+))"

function MasterPanel:UndoGobject()
    if table.getn(UndoGobTable) == 0 then
        print("Нет сохраненных GUID.")
    else
        SendChatMessage(".gob del "..UndoGobTable[table.getn(UndoGobTable)],"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
        table.remove(UndoGobTable)
    end
end


function MasterPanel:UndoRadiusGobject(radius)
    if tonumber(radius) > 4 then return end
    UndoRadius = true
    SendChatMessage(".gob near "..ConvertRadius(tonumber(radius)),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
    Undo_CooldownAnimation:Play()
end

function MasterPanel:UndoNameGobject(name, radius)
    if tonumber(radius) > 4 then return end
    UndoGobName = tostring(name)
    UndoNameRadius = true    
    SendChatMessage(".gob near "..ConvertRadius(tonumber(radius)),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
    Undo_CooldownAnimation:Play()
end



local WarningFrame = CreateFrame("Frame", "WarningFrame", UIParent)
WarningFrame:Hide()
WarningFrame:SetWidth(290)
WarningFrame:SetHeight(140)
WarningFrame:SetPoint("CENTER", UIParent, "CENTER")
WarningFrame:EnableMouse()
WarningFrame:SetFrameStrata("FULLSCREEN_DIALOG")
WarningFrame:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 8, right = 8, top = 8, bottom = 8 },
})
WarningFrame:SetBackdropColor(0, 0, 0, 1)

WarningFrame.Title = WarningFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
WarningFrame.Title:SetPoint("CENTER", WarningFrame, "TOP", 0, -50)
WarningFrame.Title:SetText("Удалить ВСЕ ГОшки\nрядом с персонажем?\n(Даже ГОшки за серебро)\n(Радиус 5 ярдов)")

WarningFrame.ButtonOK = CreateFrame("Button", nil, WarningFrame, "UIPanelButtonTemplate")
WarningFrame.ButtonOK:SetPoint("BOTTOM", WarningFrame, "BOTTOM", -70, 13)
WarningFrame.ButtonOK:SetSize(100, 25)
WarningFrame.ButtonOK:SetText("Удалить")
WarningFrame.ButtonOK:SetScript("OnClick", function()
    UndoPhaseGobjects(ConvertRadius(GobjectDeleteRad))
    WarningFrame:Hide()
end)

WarningFrame.ButtonEsc = CreateFrame("Button", nil, WarningFrame, "UIPanelButtonTemplate")
WarningFrame.ButtonEsc:SetPoint("BOTTOM", WarningFrame, "BOTTOM", 70, 13)
WarningFrame.ButtonEsc:SetSize(100, 25)
WarningFrame.ButtonEsc:SetText("Отмена")
WarningFrame.ButtonEsc:SetScript("OnClick", function()
    WarningFrame:Hide()
    GobjectDeleteRad = 1
end)

WarningFrame.ButtonEsc = CreateFrame("Button", nil, WarningFrame, "UIPanelCloseButton")
WarningFrame.ButtonEsc:SetPoint("TOP", WarningFrame, "TOPRIGHT", -20, -5)
WarningFrame.ButtonEsc:SetSize(30, 30)
WarningFrame.ButtonEsc:SetScript("OnClick", function()
    WarningFrame:Hide()
    GobjectDeleteRad = 1
end)

function MasterPanel:WarningFrameShow(radius)
    if radius == 1 then
        WarningFrame.Title:SetText("Удалить ВСЕ ГОшки\nрядом с персонажем?\n(Даже ГОшки за серебро)\n(Радиус "..ConvertRadius(tonumber(radius)).." ярда)")
    else
        WarningFrame.Title:SetText("Удалить ВСЕ ГОшки\nрядом с персонажем?\n(Даже ГОшки за серебро)\n(Радиус "..ConvertRadius(tonumber(radius)).." ярдов)")
    end
        GobjectDeleteRad = tonumber(radius)
        WarningFrame:Show()
end