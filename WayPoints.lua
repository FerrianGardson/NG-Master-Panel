local function isNPCtarget()
  return UnitIsPlayer("target") == nil and UnitExists("target") == 1
end

local function GameTooltipOnEnter(self)
        if self.Tooltip then
            GameTooltip:SetOwner(self,"ANCHOR_TOP");
            GameTooltip:AddLine(self.Tooltip);
            GameTooltip:Show();
        end
end
    local function GameTooltipOnLeave(self) if GameTooltip:IsOwned(self) then GameTooltip:Hide(); end end



--------------------
local MPA_WaypointPanel = CreateFrame("Frame", "MPA_WaypointPanel", UIParent)
MPA_WaypointPanel:Hide()
MPA_WaypointPanel:SetClampedToScreen(true)
MPA_WaypointPanel:SetFrameStrata("HIGH")
MPA_WaypointPanel:SetSize(318.94, 120.25)
MPA_WaypointPanel:SetPoint("CENTER", MPA_MainPanel, "CENTER", 0, 125)
MPA_WaypointPanel:EnableMouse()
MPA_WaypointPanel:SetMovable(true)
MPA_WaypointPanel:SetScript("OnDragStart", function(self) self:StartMoving() end)
MPA_WaypointPanel:SetScript("OnMouseDown", function(self) self:StartMoving() end)
MPA_WaypointPanel:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() self:SetUserPlaced(true) end)
MPA_WaypointPanel:RegisterForDrag("LeftButton","RightButton")

MPA_WaypointPanel.Texture = MPA_WaypointPanel:CreateTexture("ARTWORK")
MPA_WaypointPanel.Texture:SetTexture("Interface\\AddOns\\MasterPanel\\IMG\\DopPanels.blp")
MPA_WaypointPanel.Texture:SetAllPoints(MPA_WaypointPanel)
MPA_WaypointPanel.Texture:SetTexCoord(0, 0, 0, 0.553, 0.782, 0, 0.782, 0.553);


MPA_WaypointPanel.CloseButton = CreateFrame("BUTTON", "MPA_WaypointPanel.CloseButton", MPA_WaypointPanel, "MasterPanel:CloseButtonTemplate");
MPA_WaypointPanel.CloseButton:SetSize(23,23)
MPA_WaypointPanel.CloseButton:SetAlpha(.9)
MPA_WaypointPanel.CloseButton:SetPoint("CENTER", MPA_WaypointPanel, "CENTER", 150, 50)
MPA_WaypointPanel.CloseButton:RegisterForClicks("AnyUp")
MPA_WaypointPanel.CloseButton:SetScript("OnClick", function(self)
    MPA_WaypointPanel:Hide()
end)

--[[
-100
0
100
]]
--------------

--[[MPA_WaypointPanel.WpClear = CreateFrame("BUTTON", "MPA_WaypointPanel.WpClear", MPA_WaypointPanel, "MasterPanel:WPClearButtonTemplate");
MPA_WaypointPanel.WpClear:SetPoint("CENTER", MPA_WaypointPanel, "CENTER", -50, -35)
MPA_WaypointPanel.WpClear.Tooltip="Очистить точки";
MPA_WaypointPanel.WpClear:SetScript("OnEnter", GameTooltipOnEnter);
MPA_WaypointPanel.WpClear:SetScript("OnLeave",GameTooltipOnLeave);
MPA_WaypointPanel.WpClear:SetScript("OnClick", function(self)
    if not isNPCtarget() then
        print("|cffff9716[ГМ-аддон]: Возьмите в цель НПС.|r")
        return
    else
        SendChatMessage(".wpclear" ,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
    end
end)

MPA_WaypointPanel.WpGo = CreateFrame("BUTTON", "MPA_WaypointPanel.WpGo", MPA_WaypointPanel, "MasterPanel:WPGOButtonTemplate");
MPA_WaypointPanel.WpGo:SetPoint("CENTER", MPA_WaypointPanel, "CENTER", 50, -35)
MPA_WaypointPanel.WpGo.Tooltip="Включить путь";
MPA_WaypointPanel.WpGo:SetScript("OnEnter", GameTooltipOnEnter);
MPA_WaypointPanel.WpGo:SetScript("OnLeave",GameTooltipOnLeave);
MPA_WaypointPanel.WpGo:SetScript("OnClick", function(self)
    if not isNPCtarget() then
        print("|cffff9716[ГМ-аддон]: Возьмите в цель НПС.|r")
        return
    else
        SendChatMessage(".wpgo" ,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
    end
end)


MPA_WaypointPanel.WpMove = CreateFrame("BUTTON", "MPA_WaypointPanel.WpMove", MPA_WaypointPanel, "MasterPanel:WPMoveButtonTemplate");
MPA_WaypointPanel.WpMove:SetPoint("CENTER", MPA_WaypointPanel, "CENTER", -100, 35)
MPA_WaypointPanel.WpMove.Tooltip="Обычный шаг";
MPA_WaypointPanel.WpMove:SetScript("OnEnter", GameTooltipOnEnter);
MPA_WaypointPanel.WpMove:SetScript("OnLeave",GameTooltipOnLeave);
MPA_WaypointPanel.WpMove:SetScript("OnClick", function(self)
    if not isNPCtarget() then
        print("|cffff9716[ГМ-аддон]: Возьмите в цель НПС.|r")
        return
    else
        SendChatMessage(".wpmove" ,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
    end
end)

MPA_WaypointPanel.WpWalk = CreateFrame("BUTTON", "MPA_WaypointPanel.WpWalk", MPA_WaypointPanel, "MasterPanel:WPWalkButtonTemplate");
MPA_WaypointPanel.WpWalk:SetPoint("CENTER", MPA_WaypointPanel, "CENTER", -100, 0)
MPA_WaypointPanel.WpWalk.Tooltip="Ходьба";
MPA_WaypointPanel.WpWalk:SetScript("OnEnter", GameTooltipOnEnter);
MPA_WaypointPanel.WpWalk:SetScript("OnLeave",GameTooltipOnLeave);
MPA_WaypointPanel.WpWalk:SetScript("OnClick", function(self)
    if not isNPCtarget() then
        print("|cffff9716[ГМ-аддон]: Возьмите в цель НПС.|r")
        return
    else
        SendChatMessage(".wpwalk" ,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
    end
end)]]




MPA_WaypointPanel.WpClear = CreateFrame("Button", "MPA_WaypointPanel.WpClear", MPA_WaypointPanel, "UIPanelButtonTemplate")
MPA_WaypointPanel.WpClear:SetPoint("CENTER", MPA_WaypointPanel, "CENTER", -50, -37)
MPA_WaypointPanel.WpClear:SetHeight(25)
MPA_WaypointPanel.WpClear:SetWidth(90)
MPA_WaypointPanel.WpClear:SetText("WpClear")
MPA_WaypointPanel.WpClear:SetScript("OnClick", function(self)
    if not isNPCtarget() then
        print("|cffff9716[ГМ-аддон]: Возьмите в цель НПС.|r")
        return
    else
        SendChatMessage(".wpclear" ,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
    end
end)

MPA_WaypointPanel.WpGo = CreateFrame("Button", "MPA_WaypointPanel.WpGo", MPA_WaypointPanel, "UIPanelButtonTemplate")
MPA_WaypointPanel.WpGo:SetPoint("CENTER", MPA_WaypointPanel, "CENTER", 50, -37)
MPA_WaypointPanel.WpGo:SetHeight(25)
MPA_WaypointPanel.WpGo:SetWidth(90)
MPA_WaypointPanel.WpGo:SetText("WpGo")
MPA_WaypointPanel.WpGo:SetScript("OnClick", function(self)
    if not isNPCtarget() then
        print("|cffff9716[ГМ-аддон]: Возьмите в цель НПС.|r")
        return
    else
        SendChatMessage(".wpgo" ,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
    end
end)

MPA_WaypointPanel.WpMove = CreateFrame("Button", "MPA_WaypointPanel.WpMove", MPA_WaypointPanel, "UIPanelButtonTemplate")
MPA_WaypointPanel.WpMove:SetPoint("CENTER", MPA_WaypointPanel, "CENTER", -100, 35)
MPA_WaypointPanel.WpMove:SetHeight(25)
MPA_WaypointPanel.WpMove:SetWidth(90)
MPA_WaypointPanel.WpMove:SetText("WpMove")
MPA_WaypointPanel.WpMove:SetScript("OnClick", function(self)
    if not isNPCtarget() then
        print("|cffff9716[ГМ-аддон]: Возьмите в цель НПС.|r")
        return
    else
        SendChatMessage(".wpmove" ,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
    end
end)

MPA_WaypointPanel.WpWalk = CreateFrame("Button", "MPA_WaypointPanel.WpWalk", MPA_WaypointPanel, "UIPanelButtonTemplate")
MPA_WaypointPanel.WpWalk:SetPoint("CENTER", MPA_WaypointPanel, "CENTER", -100, 2)
MPA_WaypointPanel.WpWalk:SetHeight(25)
MPA_WaypointPanel.WpWalk:SetWidth(90)
MPA_WaypointPanel.WpWalk:SetText("WpWalk")
MPA_WaypointPanel.WpWalk:SetScript("OnClick", function(self)
    if not isNPCtarget() then
        print("|cffff9716[ГМ-аддон]: Возьмите в цель НПС.|r")
        return
    else
        SendChatMessage(".wpwalk" ,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
    end
end)

MPA_WaypointPanel.WpWait = CreateFrame("Button", "MPA_WaypointPanel.WpWait", MPA_WaypointPanel, "UIPanelButtonTemplate")
MPA_WaypointPanel.WpWait:SetPoint("CENTER", MPA_WaypointPanel, "CENTER", 0, 35)
MPA_WaypointPanel.WpWait:SetHeight(25)
MPA_WaypointPanel.WpWait:SetWidth(90)
MPA_WaypointPanel.WpWait:SetText("WpWait")
MPA_WaypointPanel.WpWait:SetScript("OnClick", function(self)
    if not isNPCtarget() then
        print("|cffff9716[ГМ-аддон]: Возьмите в цель НПС.|r")
        return
    else
        if tonumber(MPA_WaypointPanel.WpWait.EditBox:GetText()) then
        SendChatMessage(".wpwait " .. tonumber(MPA_WaypointPanel.WpWait.EditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
        else
            print("|cffff9716[ГМ-аддон]: Время ожидания должно быть числом.|r")
        end
    end
end)

MPA_WaypointPanel.WpWait.EditBox = CreateFrame("EditBox", "MPA_WaypointPanel.WpWait.EditBox", MPA_WaypointPanel, "InputBoxTemplate")
MPA_WaypointPanel.WpWait.EditBox:SetPoint("CENTER", MPA_WaypointPanel, "CENTER", 70, 35)
MPA_WaypointPanel.WpWait.EditBox:SetSize(30, 16)
MPA_WaypointPanel.WpWait.EditBox:SetAltArrowKeyMode(false)
MPA_WaypointPanel.WpWait.EditBox:SetHistoryLines(5)
MPA_WaypointPanel.WpWait.EditBox:SetAutoFocus(false)
MPA_WaypointPanel.WpWait.EditBox:SetFontObject(GameFontHighlight)
MPA_WaypointPanel.WpWait.EditBox:SetMaxLetters(3)
--MPA_WaypointPanel.WpWait.EditBox:SetNumeric(true)
MPA_WaypointPanel.WpWait.EditBox:SetNumber(1)
MPA_WaypointPanel.WpWait.EditBox:SetScript('OnEnterPressed', function(self)
    self:ClearFocus()
    self:AddHistoryLine(tonumber(self:GetText()));
end)

MPA_WaypointPanel.WpEmote = CreateFrame("Button", "MPA_WaypointPanel.WpEmote", MPA_WaypointPanel, "UIPanelButtonTemplate")
MPA_WaypointPanel.WpEmote:SetPoint("CENTER", MPA_WaypointPanel, "CENTER", 0, 2)
MPA_WaypointPanel.WpEmote:SetHeight(25)
MPA_WaypointPanel.WpEmote:SetWidth(90)
MPA_WaypointPanel.WpEmote:SetText("WpEmote")
MPA_WaypointPanel.WpEmote:SetScript("OnClick", function(self)
    if not isNPCtarget() then
        print("|cffff9716[ГМ-аддон]: Возьмите в цель НПС.|r")
        return
    else
        if tonumber(MPA_WaypointPanel.WpEmote.EditBox:GetText()) and tonumber(MPA_WaypointPanel.WpEmote.EditBox2:GetText()) then
            SendChatMessage(".wpemote " .. tonumber(MPA_WaypointPanel.WpEmote.EditBox:GetText()) .. " " .. tonumber(MPA_WaypointPanel.WpEmote.EditBox2:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
        else
            print("|cffff9716[ГМ-аддон]: Время ожидания и номер анимации должны быть числом.|r")
        end
    end
end)

MPA_WaypointPanel.WpEmote.EditBox = CreateFrame("EditBox", "MPA_WaypointPanel.WpEmote.EditBox", MPA_WaypointPanel, "InputBoxTemplate")
MPA_WaypointPanel.WpEmote.EditBox:SetPoint("CENTER", MPA_WaypointPanel, "CENTER", 70, 2)
MPA_WaypointPanel.WpEmote.EditBox:SetSize(30, 16)
MPA_WaypointPanel.WpEmote.EditBox:SetAltArrowKeyMode(false)
MPA_WaypointPanel.WpEmote.EditBox:SetHistoryLines(5)
MPA_WaypointPanel.WpEmote.EditBox:SetAutoFocus(false)
MPA_WaypointPanel.WpEmote.EditBox:SetFontObject(GameFontHighlight)
MPA_WaypointPanel.WpEmote.EditBox:SetMaxLetters(3)
--MPA_WaypointPanel.WpEmote.EditBox:SetNumeric(true)
MPA_WaypointPanel.WpEmote.EditBox:SetNumber(0)
MPA_WaypointPanel.WpEmote.EditBox:SetScript('OnEnterPressed', function(self)
    self:ClearFocus()
    self:AddHistoryLine(tonumber(self:GetText()));
end)

MPA_WaypointPanel.WpEmote.EditBox2 = CreateFrame("EditBox", "MPA_WaypointPanel.WpEmote.EditBox2", MPA_WaypointPanel, "InputBoxTemplate")
MPA_WaypointPanel.WpEmote.EditBox2:SetPoint("CENTER", MPA_WaypointPanel, "CENTER", 105, 2)
MPA_WaypointPanel.WpEmote.EditBox2:SetSize(20, 16)
MPA_WaypointPanel.WpEmote.EditBox2:SetAltArrowKeyMode(false)
MPA_WaypointPanel.WpEmote.EditBox2:SetHistoryLines(5)
MPA_WaypointPanel.WpEmote.EditBox2:SetAutoFocus(false)
MPA_WaypointPanel.WpEmote.EditBox2:SetFontObject(GameFontHighlight)
MPA_WaypointPanel.WpEmote.EditBox2:SetMaxLetters(2)
MPA_WaypointPanel.WpEmote.EditBox2:SetNumber(1)
MPA_WaypointPanel.WpEmote.EditBox2:SetScript('OnEnterPressed', function(self)
    self:ClearFocus()
    self:AddHistoryLine(tonumber(self:GetText()));
end)