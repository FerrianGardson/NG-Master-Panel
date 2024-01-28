MasterPanel = LibStub("AceAddon-3.0"):NewAddon("MasterPanel", "AceHook-3.0", "AceTimer-3.0", "AceEvent-3.0")
-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                               Variables                                 ]]
-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
local EditboxStatement = nil
local EditboxText = nil
local SingleWord
local line
local BindingName
local ConvertedBind
local LastPossName
local MessageRadius = 1
local Chosen_colour = 1
local Chosen_GobDelRadius = 2
local colorCode = "|cffd3a3e3"
local booleanBattlePanel = true

-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                          MinimapIconButton                              ]]
-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
local MPA_LDB = LibStub("LibDataBroker-1.1"):NewDataObject("MPA_Minimap", {
    type = "data source",
    text = "MPA_Minimap",
    icon = "Interface\\Icons\\inv_misc_dice_01",
    OnClick = function()
        MasterPanel:MinMapButtonFunc()
    end,
    OnEnter = function()
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(LibDBIcon10_MPA_Minimap, "ANCHOR_TOP");
        GameTooltip:AddLine("MasterPanel Noblegarden")
        GameTooltip:AddLine("Нажмите для открытия меню")
        GameTooltip:Show()
    end
})

local MinimapIconButton = LibStub("LibDBIcon-1.0")
-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                            Scripts                                      ]]
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
local function BindingTextSplitter(BindingName)
    if BindingName:len() <= 4 then
        BindingName = BindingName
    else
        BindingName = string.sub(BindingName, 0, 4) .. "..."
    end

    return BindingName
end

local function ConvertToBinding(ConvertedBind)
    return BindingTextSplitter(GetBindingText(GetBindingKey(ConvertedBind), "KEY_", 1))
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
    else
        return 0
    end
end

local function isempty(text)
    return text == " " or text == nil or text == '' ---%s+  ???
end

local function ReturnNoSpace(text)
    new_text = string.gsub(text, "%s+", " ")
    return new_text
end

function isNPCtarget()
    return UnitIsPlayer("target") == nil and UnitExists("target") == 1
end

local function IsAllowedNotify(text)
    return isNPCtarget() and not isempty(text)
end

local function GameTooltipOnEnter(self)
    if self.Tooltip then
        GameTooltip:SetOwner(self, "ANCHOR_TOP");
        GameTooltip:AddLine(self.Tooltip);
        GameTooltip:AddLine(self.AddLine, 1, 1, 1, true);
        GameTooltip:Show();
    end
end
local function GameTooltipOnLeave(self)
    if GameTooltip:IsOwned(self) then
        GameTooltip:Hide();
    end
end

-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                           Message Splitter                              ]]
-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
local function NPCChatSender(text, state, radius, colour)
    if isempty(text) then
        return
    end
    if text:len() > 350 then
        return
    end
    NPCChatRetranslator(text, state, radius, colour)
end

local function MessageStringSplitter(line, state, radius, colour)
    local WordsTemp = "";
    local WordsTable = {}
    for SingleWord in line:gmatch("%S+") do
        table.insert(WordsTable, SingleWord);
    end
    -----
    if line:len() <= (350) then
        NPCChatSender(line, state, radius, colour)
    else
        for i = 1, table.getn(WordsTable) do
            WordsTemp = WordsTemp .. " " .. WordsTable[i];
            if i == table.getn(WordsTable) then
                NPCChatSender(WordsTemp, state, radius, colour)
                break
            end
            if (WordsTemp:len() + WordsTable[i + 1]:len()) > 349 then
                NPCChatSender(WordsTemp, state, radius, colour)
                WordsTemp = "";
            end
        end

    end
end

-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                             Addon Load                                  ]]
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
function MasterPanel:OnInitialize()
    ---// MinimapIconButton Initialize
    self.db = LibStub("AceDB-3.0"):New("MinMapDB", {
        profile = {
            minimap = {
                hide = false
            },
            settings = {
                NPCSayByEmote = false,
                NPCTalkAnimation = true,
                AddNameToEmote = true,
                SaveFocus = true,
                ChatRadius = 40,
                RollOneShot = 36,
                RollStatic = 45
            }
        }
    })
    MinimapIconButton:Register("MPA_Minimap", MPA_LDB, self.db.profile.minimap)
end

function MasterPanel:OnEnable()
    -- Called when the addon is enabled
    self:SecureHook("SendChatMessage", "CommandMessageHook")
    self:RegisterEvent("CHAT_MSG_SYSTEM", "SystemMessageHandler")
    self:RegisterEvent("UPDATE_BINDINGS", "SetBindings")

    MasterPanel:SetBindings()
    if self.db.profile.settings.NPCSayByEmote then
        SettingsFrame.NPCSay:SetChecked(true)
    else
        SettingsFrame.NPCSay:SetChecked(false)
    end
    if MasterPanel.db.profile.settings.AddNameToEmote then
        SettingsFrame.AddName:SetChecked(true)
    else
        SettingsFrame.AddName:SetChecked(false)
    end
    if MasterPanel.db.profile.settings.SaveFocus then
        SettingsFrame.SaveFocusEditbox:SetChecked(true)
    else
        SettingsFrame.SaveFocusEditbox:SetChecked(false)
    end

    SettingsFrame.RadiusSlider:SetValue(tonumber(MasterPanel.db.profile.settings.ChatRadius))
    if self.db.profile.settings.RollStatic then
        SettingsFrame.RollStateEditBox:SetNumber(tonumber(self.db.profile.settings.RollStatic))
    else
        SettingsFrame.RollStateEditBox:SetNumber(0)
    end
    if self.db.profile.settings.RollOneShot then
        SettingsFrame.RollOneShotEditBox:SetNumber(tonumber(self.db.profile.settings.RollOneShot))
    else
        SettingsFrame.RollOneShotEditBox:SetNumber(0)
    end
end

function MasterPanel:SetBindings()
    MPA_SearchAndDelPanel.DeleteNPC.Icon:SetText(ConvertToBinding("MPA_DELNPC"))
    MPA_SearchAndDelPanel.DeleteNearNPC.Icon:SetText(ConvertToBinding("MPA_DELNEARNPC"))
    MPA_SearchAndDelPanel.UndoGob.Icon:SetText(ConvertToBinding("MPA_UNDOGOBJECT"))
    MPA_SearchAndDelPanel.LoObjButton:SetText(ConvertToBinding("MPA_LOOKUPGOBJECT"))
    MPA_SearchAndDelPanel.LoCrButton:SetText(ConvertToBinding("MPA_LOOKUPCREATURE"))
    MPA_SearchAndDelPanel.GobDelByNameButton.Icon:SetText(ConvertToBinding("MPA_UNDOGOBNAME"))
    MPA_SearchAndDelPanel.GobDelRadiusButton.Icon:SetText(ConvertToBinding("MPA_UNDOGOBRADIUS"))

    MPA_NPCPanel.NPCSay_Button:SetText(ConvertToBinding("MPA_NPCSAY"))
    MPA_NPCPanel.NPCYell_Button:SetText(ConvertToBinding("MPA_NPCYELL"))
    MPA_NPCPanel.NPCEmote_Button:SetText(ConvertToBinding("MPA_NPCEMOTE"))
    MPA_NPCPanel.Colour_Button:SetText(ConvertToBinding("MPA_COLOURCHAT"))
    MPA_NPCPanel.TalkingHead_Button:SetText(ConvertToBinding("MPA_TALKINGHEADCHAT"))

    MPA_AurasAndStatesPanel.SetAura.Icon:SetText(ConvertToBinding("MPA_SETAURA"))
    MPA_AurasAndStatesPanel.ClearAura.Icon:SetText(ConvertToBinding("MPA_CLEARAURA"))
    MPA_AurasAndStatesPanel.SetScale.Icon:SetText(ConvertToBinding("MPA_SETSCALE"))
    MPA_AurasAndStatesPanel.Morph:SetText(ConvertToBinding("MPA_SETMORPH"))
    MPA_AurasAndStatesPanel.DeMorph:SetText(ConvertToBinding("MPA_DEMORPH"))
    MPA_AurasAndStatesPanel.Phase:SetText(ConvertToBinding("MPA_SETPHASE"))
    MPA_AurasAndStatesPanel.CastVisual.Icon:SetText(ConvertToBinding("MPA_SETVISUALSPELL"))
    MPA_AurasAndStatesPanel.StopCastVisual.Icon:SetText(ConvertToBinding("MPA_STOPVISUALSPELL"))
    MPA_AurasAndStatesPanel.SetTimeAndWeatherButton.Icon:SetText(ConvertToBinding("MPA_SETTIMEANDWEATHERBUTTON"))

    MPA_ControlPanel.Waypoint:SetText(ConvertToBinding("MPA_WAYPOINTS"))
    MPA_ControlPanel.PossUnposs:SetText(ConvertToBinding("MPA_POSS"))
    MPA_ControlPanel.RollButton:SetText(ConvertToBinding("MPA_BATTLEPANEL"))
    MPA_ControlPanel.Summon.Icon:SetText(ConvertToBinding("MPA_SUMMON"))
    MPA_ControlPanel.EmoteST.Icon:SetText(ConvertToBinding("MPA_NPCPLAYEMOTE"))
    MPA_ControlPanel.EmoteStatement.Icon:SetText(ConvertToBinding("MPA_NPCSTATEMENT"))
    MPA_ControlPanel.Army.Icon:SetText(ConvertToBinding("MPA_ARMYCONTROL"))
    MPA_ControlPanel.RaidSum.Icon:SetText(ConvertToBinding("MPA_RAIDSUM"))

    MPA_BattlePanel.GetTargetRoll.Icon:SetText(ConvertToBinding("MPA_ROLLTARGET"))
    MPA_BattlePanel.RollStr.Icon:SetText(ConvertToBinding("MPA_ROLLSRT"))
    MPA_BattlePanel.RollAgila.Icon:SetText(ConvertToBinding("MPA_ROLLAGIL"))
    MPA_BattlePanel.RollInt.Icon:SetText(ConvertToBinding("MPA_ROLLINT"))

    MPA_SetTimeAndWeatherPanel.EarlyMorning.Icon:SetText(ConvertToBinding("MPA_EARLYMORNING"))
    MPA_SetTimeAndWeatherPanel.Morning.Icon:SetText(ConvertToBinding("MPA_MORNING"))
    MPA_SetTimeAndWeatherPanel.Noon.Icon:SetText(ConvertToBinding("MPA_NOON"))
    MPA_SetTimeAndWeatherPanel.Evening.Icon:SetText(ConvertToBinding("MPA_EVENING"))
    MPA_SetTimeAndWeatherPanel.LateEvening.Icon:SetText(ConvertToBinding("MPA_LATEEVENING"))
    MPA_SetTimeAndWeatherPanel.Night.Icon:SetText(ConvertToBinding("MPA_NIGHT"))

    MPA_SetTimeAndWeatherPanel.Clear.Icon:SetText(ConvertToBinding("MPA_CLEAR"))
    MPA_SetTimeAndWeatherPanel.Rain.Icon:SetText(ConvertToBinding("MPA_RAIN"))
    MPA_SetTimeAndWeatherPanel.Snow.Icon:SetText(ConvertToBinding("MPA_SNOW"))
    MPA_SetTimeAndWeatherPanel.Storm.Icon:SetText(ConvertToBinding("MPA_STORM"))

    MPA_NPCPosPanel.Sit.Icon:SetText(ConvertToBinding("MPA_SIT"))
    MPA_NPCPosPanel.GetUp.Icon:SetText(ConvertToBinding("MPA_GETUP"))
    MPA_NPCPosPanel.SomeSleep.Icon:SetText(ConvertToBinding("MPA_SOMESLEEP"))
    MPA_NPCPosPanel.LSit.Icon:SetText(ConvertToBinding("MPA_LSIT"))
    MPA_NPCPosPanel.MSit.Icon:SetText(ConvertToBinding("MPA_MSIT"))
    MPA_NPCPosPanel.HSit.Icon:SetText(ConvertToBinding("MPA_HSIT"))
    MPA_NPCPosPanel.Death.Icon:SetText(ConvertToBinding("MPA_DEATH"))
    MPA_NPCPosPanel.Knee.Icon:SetText(ConvertToBinding("MPA_KNEE"))
    MPA_NPCPosPanel.Ground.Icon:SetText(ConvertToBinding("MPA_GROUND"))

    MPA_NPCPosPanel.TurnWeapon.Icon:SetText(ConvertToBinding("MPA_TURNWEAPON"))

    MPA_NPCPosPanel.SavePos.Icon:SetText(ConvertToBinding("MPA_SAVEPOS"))
end

-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                                 UI                                      ]]
-- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 

-----------------------------------------------------------------------------------------------------------------------------------------------------
--------/// MainPanel UI
-----------------------------------------------------------------------------------------------------------------------------------------------------

function CloseMasterPanel()
    MPA_MainPanel:Hide()
end

local MPA_MainPanel = CreateFrame("Frame", "MPA_MainPanel", UIParent)
MPA_MainPanel:SetClampedToScreen(true)
MPA_MainPanel:Hide()
MPA_MainPanel:SetFrameStrata("FULLSCREEN")
MPA_MainPanel:SetSize(318.94, 120.25)
MPA_MainPanel:SetPoint("CENTER", UIParent, "CENTER")
MPA_MainPanel:EnableMouse()
MPA_MainPanel:SetMovable(true)
--[[ MPA_MainPanel:SetScript("OnEscapePressed", CloseMasterPanel) ]]
MPA_MainPanel:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
MPA_MainPanel:SetScript("OnMouseDown", function(self)
    self:StartMoving()
end)
MPA_MainPanel:SetScript("OnMouseUp", function(self)
    self:StopMovingOrSizing()
    self:SetUserPlaced(true)
end)
MPA_MainPanel:RegisterForDrag("LeftButton", "RightButton")

MPA_MainPanel.Texture = MPA_MainPanel:CreateTexture("ARTWORK")
MPA_MainPanel.Texture:SetTexture("Interface\\AddOns\\MasterPanel\\IMG\\blank.blp")
MPA_MainPanel.Texture:SetAllPoints(MPA_MainPanel)
MPA_MainPanel.Texture:SetTexCoord(0, 0, 0, 0.634, 0.843, 0, 0.843, 0.634);

MPA_MainPanel.Title = MPA_MainPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
MPA_MainPanel.Title:SetPoint("CENTER", MPA_MainPanel, "CENTER", 0, 41)
MPA_MainPanel.Title:SetFont("Fonts\\MORPHEUS.TTF", 14, "OUTLINE")
MPA_MainPanel.Title:SetText("Главное меню")
MPA_MainPanel.Title:SetAlpha(0.85)
-----------------------------------------------------------------------------------------------------------------------------------------------------
--------/// Control Buttons UI
-----------------------------------------------------------------------------------------------------------------------------------------------------
MPA_MainPanel.CloseButton = CreateFrame("BUTTON", "MPA_MainPanel.CloseButton", MPA_MainPanel,
    "MasterPanel:CloseButtonTemplate");
MPA_MainPanel.CloseButton:SetSize(23, 23)
MPA_MainPanel.CloseButton:SetAlpha(.9)
MPA_MainPanel.CloseButton:SetPoint("CENTER", MPA_MainPanel, "CENTER", 142, 41)
MPA_MainPanel.CloseButton:RegisterForClicks("AnyUp")
MPA_MainPanel.CloseButton:SetScript("OnClick", function(self)
    MPA_MainPanel:Hide()
end)

MPA_MainPanel.RefreshButton = CreateFrame("BUTTON", "MPA_MainPanel.RefreshButton", MPA_MainPanel,
    "MasterPanel:RefreshButtonTemplate");
MPA_MainPanel.RefreshButton:SetSize(23, 23)
MPA_MainPanel.RefreshButton:SetAlpha(.9)
MPA_MainPanel.RefreshButton:SetPoint("CENTER", MPA_MainPanel, "CENTER", -142, 41)
MPA_MainPanel.RefreshButton:RegisterForClicks("AnyUp")
MPA_MainPanel.RefreshButton:SetScript("OnClick", function(self)
    MasterPanel:ReturnToMain()
end)
-----------------------------------------------------------------------------------------------------------------------------------------------------
--------/// Main EditBox UI
-----------------------------------------------------------------------------------------------------------------------------------------------------
local MPA_EditPanel = CreateFrame("Frame", "MPA_EditPanel", MPA_MainPanel)
MPA_EditPanel:SetSize(318.94, 120.25)
MPA_EditPanel:SetAllPoints(MPA_MainPanel)
MPA_EditPanel:Hide()

MPA_EditPanel.SetFocus = CreateFrame("BUTTON", "MPA_EditPanel.SetFocus", MPA_EditPanel, "SecureHandlerClickTemplate");
MPA_EditPanel.SetFocus:SetSize(275, 75)
MPA_EditPanel.SetFocus:SetPoint("CENTER", MPA_EditPanel, "CENTER", -11, -15)

MPA_EditPanel.SetFocus:SetScript("OnClick", function()
    if not MPA_EditPanel.EditBox:HasFocus() then
        MPA_EditPanel.EditBox:SetFocus()
    end
end) ------???

MPA_EditPanel.EditBox = CreateFrame('EditBox', 'MPA_MainEditBox', MPA_EditPanel)
MPA_EditPanel.EditBox:SetMultiLine(true)
MPA_EditPanel.EditBox:SetAutoFocus(false)
MPA_EditPanel.EditBox:EnableMouse(true)
MPA_EditPanel.EditBox:SetMaxLetters(2550)
MPA_EditPanel.EditBox:SetFontObject(GameFontHighlight)
MPA_EditPanel.EditBox:SetWidth(270)
MPA_EditPanel.EditBox:SetHeight(10)
MPA_EditPanel.EditBox:EnableMouseWheel(true)

MPA_EditPanel.EditBox:SetScript('OnTextChanged', function(self)
    ScrollingEdit_OnTextChanged(self, self:GetParent());
end)

MPA_EditPanel.EditBox:SetScript('OnCursorChanged', function(self, x, y, w, h)
    ScrollingEdit_OnCursorChanged(self, x, y, w, h);
end)

MPA_EditPanel.EditBox:SetScript('OnUpdate', function(self, elapsed)
    ScrollingEdit_OnUpdate(self, elapsed, self:GetParent());
end) -------------???

MPA_EditPanel.EditBox:SetScript('OnEditFocusLost', function(self, elapsed)
    MPA_EditPanel.SetFocus:Show()
end) ---------------???

MPA_EditPanel.EditBox:SetScript('OnEditFocusGained', function(self, elapsed)
    MPA_EditPanel.SetFocus:Hide()
end)

MPA_EditPanel.EditBox:SetScript('OnEscapePressed', function(self)
    MPA_EditPanel.EditBox:ClearFocus();
    -- MPA_EditPanel:Hide()
end)

MPA_EditPanel.EditBox:SetScript('OnEnterPressed', function(self)
    EditboxText = MPA_EditPanel.EditBox:GetText()
    if EditboxStatement == nil then
        print("Произошла ошибка ввода.")
    elseif EditboxStatement == "LOOKUPCREATURE" then
        if tostring(EditboxText) == "м1" then
            SendChatMessage(".npc add 28605", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
        elseif tostring(EditboxText) == "м2" then
            SendChatMessage(".npc add 11016974", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
        elseif tostring(EditboxText) == "м3" then
            SendChatMessage(".npc add 9928816", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
        elseif tostring(EditboxText) == "м4" then
            SendChatMessage(".npc add 987663", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
        elseif tostring(EditboxText) == "ф" then
            SendChatMessage(".npc add 11002715", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
        else
            SendChatMessage(".lo cr " .. tostring(EditboxText), "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
        end
    elseif EditboxStatement == "LOOKUPGAMEOBJECTS" then
        SendChatMessage(".lo ob " .. tostring(EditboxText), "WHISPER", GetDefaultLanguage("player"),
            GetUnitName("player"));
    elseif EditboxStatement == "NPCSAYSTATE" then
        if not isNPCtarget() then
            print("|cffff9716[ГМ-аддон]: Возьмите в цель NPC.|r")
            return
        elseif isempty(tostring(EditboxText)) then
            return
        else
            if not MasterPanel.db.profile.settings.NPCSayByEmote then
                MessageStringSplitter(tostring(EditboxText), 1, 0, 0)
            else
                local TargetName = GetUnitName("target")
                MessageStringSplitter(TargetName .. " говорит: " .. tostring(EditboxText), 2, 0, 0)
            end
            print("NPCTalkAnimation is now:", MasterPanel.db.profile.settings.NPCTalkAnimation)
            if MasterPanel.db.profile.settings.NPCTalkAnimation == true then
                SendChatMessage(".npc playemote 0", "SAY")
                MPA_MainPanel:Hide()
            end
        end
    elseif EditboxStatement == "NPCEMOTESTATE" then
        if not isNPCtarget() then
            print("|cffff9716[ГМ-аддон]: Возьмите в цель NPC.|r")
            return
        elseif isempty(tostring(EditboxText)) then
            return
        else
            if MasterPanel.db.profile.settings.AddNameToEmote == true then
                MessageStringSplitter(GetUnitName("target") .. " " .. tostring(EditboxText), 3, 0, 0)
            else
                MessageStringSplitter(tostring(EditboxText), 3, 0, 0)
            end
        end
    elseif EditboxStatement == "NPCYELLSTATE" then
        if not isNPCtarget() then
            print("|cffff9716[ГМ-аддон]: Возьмите в цель NPC.|r")
            return
        elseif isempty(tostring(EditboxText)) then
            return
        else
            MessageStringSplitter(tostring(EditboxText), 4, 0, 0)
        end
    elseif EditboxStatement == "CHATCOLORSTATE" then
        if isempty(tostring(EditboxText)) then
            return
        else
            if (not MasterPanel.db.profile.settings.ChatRadius) or MasterPanel.db.profile.settings.ChatRadius == nil or
                tonumber(MasterPanel.db.profile.settings.ChatRadius) == 0 then
                MessageStringSplitter(tostring(EditboxText), 5, 0, tonumber(Chosen_colour))
            else
                MessageStringSplitter(tostring(EditboxText), 5, tonumber(MasterPanel.db.profile.settings.ChatRadius),
                    tonumber(Chosen_colour))
            end
        end
    elseif EditboxStatement == "TALKINGHEADSTATE" then
        if not isNPCtarget() then
            print("|cffff9716[ГМ-аддон]: Возьмите в цель NPC.|r")
            return
        elseif isempty(tostring(EditboxText)) then
            return
        else
            if (not MasterPanel.db.profile.settings.ChatRadius) or MasterPanel.db.profile.settings.ChatRadius == nil or
                tonumber(MasterPanel.db.profile.settings.ChatRadius) == 0 then
                TalkingHeadRetranslator(tostring(EditboxText), GetUnitName("target"), GetUnitName("player"), 0)
            else
                TalkingHeadRetranslator(tostring(EditboxText), GetUnitName("target"), GetUnitName("player"),
                    tonumber(MasterPanel.db.profile.settings.ChatRadius))
            end
        end
    elseif EditboxStatement == "DELETEGOBNAMESTATE" then
        if ReturnNoSpace(tostring(EditboxText)):len() < 5 then
            print(
                "|cffff9716[ГМ-аддон]: Название должно быть длиннее 4 символов.|r")
            return
        else
            -- MasterPanel:UndoNameGobject(tostring(EditboxText), tonumber(Chosen_GobDelRadius))
            UndoPhaseNameGobjects(ReturnNoSpace(tostring(EditboxText)), ConvertRadius(tonumber(Chosen_GobDelRadius)))
        end
    elseif EditboxStatement == "PHASESTATEMENT" then
        if isempty(tostring(EditboxText)) then
            print("|cffff9716[ГМ-аддон]: Номер фазы не должен быть пустым.|r")
        elseif string.find(tostring(EditboxText), 1024) then
            print(
                "|cffff9716[ГМ-аддон]: Это фаза для ДМ-ведущих. Тебе туда нельзя.|r")
        elseif string.find(tostring(strlower(EditboxText)), "r") then
            local string
            nline = tostring(EditboxText):sub(1, -2);
            SendChatMessage(".raidphase " .. tonumber(nline), "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
        elseif tonumber(EditboxText) == 3 then
            SendChatMessage(".go 1055 -2120 0 13", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
        else
            SendChatMessage(".mod phase " .. tonumber(EditboxText), "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
        end
    elseif EditboxStatement == "MORPHSTATEMENT" then
        if isempty(tostring(EditboxText)) then
            return
        else
            SendChatMessage(".skin " .. tonumber(EditboxText), "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
        end
    elseif EditboxStatement == "SETAURASTATEMENT" then
        if not tonumber(EditboxText) or isempty(tostring(EditboxText)) then
            print("|cffff9716[ГМ-аддон]: Номер ауры должен состоять из цифр.|r")
        elseif tonumber(EditboxText) == 1 then
            SendChatMessage(".auraput 74836", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
        else
            SendChatMessage(".auraput " .. tonumber(EditboxText), "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
        end
    elseif EditboxStatement == "CLEARAURASTATEMENT" then
        if isempty(tostring(EditboxText)) then
            SendChatMessage(".cleartargetauras", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
        elseif not tonumber(EditboxText) then
            print("|cffff9716[ГМ-аддон]: Номер ауры должен состоять из цифр.|r")
        elseif tonumber(EditboxText) == 1 then
            SendChatMessage(".auradisp 74836", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
        else
            SendChatMessage(".auradisp " .. tonumber(EditboxText), "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
        end
    elseif EditboxStatement == "SETCLEARWEATHERSTATEMENT" then
        if not tonumber(EditboxText) or isempty(tostring(EditboxText)) then
            print(
                "|cffff9716[ГМ-аддон]: Номер интенсивности погоды должен быть целым числом в диапазоне 0 - 10.|r")
        elseif tonumber(EditboxText) > 10 or tonumber(EditboxText) < 0 then
            print(
                "|cffff9716[ГМ-аддон]: Номер интенсивности погоды должен быть целым числом в диапазоне 0 - 10.|r")
        else
            SendChatMessage(".weather 1 " .. tonumber(EditboxText), "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
            print("|cffff9716[ГМ-аддон]: Ясная погода установлена. (" ..
                      tonumber(EditboxText) .. ")|r");
        end
    elseif EditboxStatement == "SETRAINWEATHERSTATEMENT" then
        if not tonumber(EditboxText) or isempty(tostring(EditboxText)) then
            print(
                "|cffff9716[ГМ-аддон]: Номер интенсивности погоды должен быть целым числом в диапазоне 0 - 10.|r")
        elseif tonumber(EditboxText) > 10 or tonumber(EditboxText) < 0 then
            print(
                "|cffff9716[ГМ-аддон]: Номер интенсивности погоды должен быть целым числом в диапазоне 0 - 10.|r")
        else
            SendChatMessage(".weather 2 " .. tonumber(EditboxText), "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
            print("|cffff9716[ГМ-аддон]: Дождливая погода установлена. (" ..
                      tonumber(EditboxText) .. ")|r");
        end
    elseif EditboxStatement == "SETSNOWWEATHERSTATEMENT" then
        if not tonumber(EditboxText) or isempty(tostring(EditboxText)) then
            print(
                "|cffff9716[ГМ-аддон]: Номер интенсивности погоды должен быть целым числом в диапазоне 0 - 10.|r")
        elseif tonumber(EditboxText) > 10 or tonumber(EditboxText) < 0 then
            print(
                "|cffff9716[ГМ-аддон]: Номер интенсивности погоды должен быть целым числом в диапазоне 0 - 10.|r")
        else
            SendChatMessage(".weather 3 " .. tonumber(EditboxText), "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
            print("|cffff9716[ГМ-аддон]: Снежная погода установлена. (" ..
                      tonumber(EditboxText) .. ")|r");
        end
    elseif EditboxStatement == "SETSTORMWEATHERSTATEMENT" then
        if not tonumber(EditboxText) or isempty(tostring(EditboxText)) then
            print(
                "|cffff9716[ГМ-аддон]: Номер интенсивности погоды должен быть целым числом в диапазоне 0 - 10.|r")
        elseif tonumber(EditboxText) > 10 or tonumber(EditboxText) < 0 then
            print(
                "|cffff9716[ГМ-аддон]: Номер интенсивности погоды должен быть целым числом в диапазоне 0 - 10.|r")
        else
            SendChatMessage(".weather 4 " .. tonumber(EditboxText), "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
            print("|cffff9716[ГМ-аддон]: Буря установлена. (" .. tonumber(EditboxText) .. ")|r");
        end
    elseif EditboxStatement == "VISUALSPELLSSTATEMENT" then
        if not tonumber(EditboxText) or isempty(tostring(EditboxText)) then
            print(
                "|cffff9716[ГМ-аддон]: Номер визуального спелла должен быть числом.|r")
        else
            local numer = tonumber(EditboxText);
            if numer == 1 then
                numer = 550000
            elseif numer == 2 then
                numer = 550004
            elseif numer == 3 then
                numer = 550019
            elseif numer == 4 then
                numer = 550024
            elseif numer == 5 then
                numer = 550010
            elseif numer == 6 then
                numer = 550021
            elseif numer == 7 then
                numer = 550045
            elseif numer == 8 then
                numer = 550028
            elseif numer == 9 then
                numer = 550043
            elseif numer == 10 then
                numer = 550051
            elseif numer == 11 then
                numer = 550002
            elseif numer == 12 then
                numer = 550003
            elseif numer == 13 then
                numer = 5500049
            elseif numer == 14 then
                numer = 550005
            elseif numer == 15 then
                numer = 550007
            elseif numer == 16 then
                numer = 5500048
            elseif numer == 17 then
                numer = 550017
            elseif numer == 18 then
                numer = 550012
            elseif numer == 19 then
                numer = 550015
            elseif numer == 20 then
                numer = 550020
            elseif numer == 21 then
                numer = 550025
            elseif numer == 22 then
                numer = 550022
            elseif numer == 23 then
                numer = 550039
            elseif numer == 24 then
                numer = 550029
            elseif numer == 25 then
                numer = 550042
            elseif numer == 26 then
                numer = 550008
            end
            SendChatMessage(".npccastvisual " .. numer, "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
            print("|cffff9716[ГМ-аддон]: Визуальный эффект установлен на " ..
                      GetUnitName("target") .. ".|r");
        end
    elseif EditboxStatement == "TOPLAYERSTATEMENT" then
        if isempty(tostring(EditboxText)) or tonumber(EditboxText) then
            print("|cffff9716[ГМ-аддон]: Необходимо ввести ник игрока.|r")
        else
            SendChatMessage(".app " .. tostring(EditboxText), "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
        end
    elseif EditboxStatement == "NPCEQUIPMENTSTATEMENT" then
        if isempty(tostring(EditboxText)) then
            print(
                "|cffff9716[ГМ-аддон]: Необходимо ввести числа вооружения NPC. Пример: 123 456 789.|r")
        elseif (tonumber(EditboxText) == 0) then
            SendChatMessage(".changeweapon 0 0 0", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
        else
            SendChatMessage(".changeweapon " .. EditboxText, "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
        end
    elseif EditboxStatement == "SETSCALENPCSTATEMENT" then
        if not isNPCtarget() then
            print("|cffff9716[ГМ-аддон]: Возьмите в цель НПС.|r")
            return
        elseif not tonumber(EditboxText) or isempty(tostring(EditboxText)) then
            SendChatMessage(".changescale 1", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
        elseif tonumber(EditboxText) > 5 or tonumber(EditboxText) < 0.05 then
            print(
                "|cffff9716[ГМ-аддон]: Размер НПС должен быть в диапазоне 0.05 - 5|r")
        else
            SendChatMessage(".mod scale " .. tonumber(EditboxText), "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
        end
    elseif EditboxStatement == "NPCPLAYEMOTESTATEMENT" then
        if not isNPCtarget() then
            print("|cffff9716[ГМ-аддон]: Возьмите в цель NPC.|r")
            return
        elseif not tonumber(EditboxText) or isempty(tostring(EditboxText)) then
            print("|cffff9716[ГМ-аддон]: Эмоция должна быть числом.|r")
        else
            SendChatMessage(".npc playemote " .. tonumber(EditboxText), "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
        end
    elseif EditboxStatement == "NPCSTATESTATEMENT" then
        if not isNPCtarget() then
            print("|cffff9716[ГМ-аддон]: Возьмите в цель NPC.|r")
            return
        elseif not tonumber(EditboxText) or isempty(tostring(EditboxText)) then
            print(
                "|cffff9716[ГМ-аддон]: Статическая эмоция должна быть числом.|r")
        else
            SendChatMessage(".npcsetstate " .. tonumber(EditboxText), "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
        end
    elseif EditboxStatement == "SUMMONSTATEMENT" then
        if isempty(tostring(EditboxText)) then
            if GetUnitName("target") == GetUnitName("player") then
                print(
                    "|cffff9716[ГМ-аддон]: Вы не можете телепортировать самого себя.|r")
            elseif UnitIsPlayer("target") then
                SendChatMessage(".summon " .. GetUnitName("target"), "WHISPER", GetDefaultLanguage("player"),
                    GetUnitName("player"));
            elseif GetUnitName("target") == nil then
                print(
                    "|cffff9716[ГМ-аддон]: Необходимо ввести ник игрока или взять в цель (игрока или npc).|r")
            else
                SendChatMessage(".npc move", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
            end
        elseif tostring(EditboxText) == 1 or string.lower(tostring(EditboxText)) == "all" or
            string.lower(tostring(EditboxText)) == "рейд" then
            -----
            for Call_d = 1, GetNumRaidMembers() do
                Call_d_d = "raid" .. Call_d
                Call_name = UnitName(Call_d_d)
                SendChatMessage(".call " .. Call_name, "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
            end
            -----
        else
            SendChatMessage(".call " .. tostring(EditboxText), "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
        end
    elseif EditboxStatement == "SETDIFFSTATEMENT" then
        if not tonumber(EditboxText) or isempty(tostring(EditboxText)) then
            print("|cffff9716[ГМ-аддон]: Значение должно быть числом.|r")
        elseif not (UnitExists("target")) or not UnitIsPlayer("target") then
            print("|cffff9716[ГМ-аддон]: Возьмите в цель игрока.|r")
            return
        else
            SendChatMessage(".setdiff " .. tonumber(EditboxText), "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
        end
    elseif EditboxStatement == "RAIDSETDIFFSTATEMENT" then
        if not tonumber(EditboxText) or isempty(tostring(EditboxText)) then
            print("|cffff9716[ГМ-аддон]: Значение должно быть числом.|r")
        else
            SendChatMessage(".raidsetdiff " .. tonumber(EditboxText), "WHISPER", GetDefaultLanguage("player"),
                GetUnitName("player"));
        end
    end
    MasterPanel:EditBoxCollectGarbage()
end)

UNM_ScrollFrame = CreateFrame('ScrollFrame', 'UNM_ScrollFrame', MPA_EditPanel, 'UIPanelScrollFrameTemplate')
UNM_ScrollFrame:SetPoint('TOPLEFT', MPA_EditPanel, 'TOPLEFT', 10, -45)
UNM_ScrollFrame:SetPoint('BOTTOMRIGHT', MPA_EditPanel, 'BOTTOMRIGHT', -35, 10)
UNM_ScrollFrame:EnableMouseWheel(true)
UNM_ScrollFrame:SetScrollChild(MPA_EditPanel.EditBox)

function MasterPanel:EditBoxCollectGarbage()
    MPA_EditPanel.EditBox:SetText("");
    if not MasterPanel.db.profile.settings.SaveFocus then
        MPA_EditPanel.EditBox:ClearFocus();
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------
--------/// Select Panel UI
-----------------------------------------------------------------------------------------------------------------------------------------------------
local MPA_SelectPanel = CreateFrame("Frame", "MPA_SelectPanel", MPA_MainPanel)
MPA_SelectPanel:SetSize(318.94, 120.25)
MPA_SelectPanel:SetAllPoints(MPA_MainPanel)

MPA_SelectPanel.NPCButton = CreateFrame("Button", "MPA_SelectPanel.NPCButton", MPA_SelectPanel,
    "MasterPanel:IconButtonBG")
MPA_SelectPanel.NPCButton:SetPoint("CENTER", -120, -18)

MPA_SelectPanel.NPCButton.Icon = CreateFrame("BUTTON", nil, MPA_SelectPanel.NPCButton, "MasterPanel:IconButtonTemplate");
MPA_SelectPanel.NPCButton.Icon:SetNormalTexture("interface\\ICONS\\inv_misc_paperbundle03c")
MPA_SelectPanel.NPCButton.Icon:SetHighlightTexture("interface\\ICONS\\inv_misc_paperbundle03c")
MPA_SelectPanel.NPCButton.Icon:SetAlpha(0.85)
MPA_SelectPanel.NPCButton.Icon:SetScript("OnClick", function()
    MasterPanel:NPCPanel_ShowAll()
end)
MPA_SelectPanel.NPCButton.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SelectPanel.NPCButton.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SelectPanel.NPCButton.Icon.Tooltip = "Инструменты чата";
MPA_SelectPanel.NPCButton.Icon.AddLine = colorCode ..
                                             ".makeraid|r позволяет создать рейд тем, кто ниже 10-го уровня";
--- - - - - - - - - - - - -
--- - - - - - - - - - - - -
MPA_SelectPanel.SearchAndDel = CreateFrame("Button", "MPA_SelectPanel.SearchAndDel", MPA_SelectPanel,
    "MasterPanel:IconButtonBG") -- // First button
MPA_SelectPanel.SearchAndDel:SetPoint("CENTER", -60, -18)

MPA_SelectPanel.SearchAndDel.Icon = CreateFrame("BUTTON", nil, MPA_SelectPanel.SearchAndDel,
    "MasterPanel:IconButtonTemplate");
MPA_SelectPanel.SearchAndDel.Icon:SetNormalTexture("interface\\ICONS\\trade_archaeology")
MPA_SelectPanel.SearchAndDel.Icon:SetHighlightTexture("interface\\ICONS\\trade_archaeology")
MPA_SelectPanel.SearchAndDel.Icon:SetAlpha(0.85)
MPA_SelectPanel.SearchAndDel.Icon:SetScript("OnClick", function()
    MasterPanel:SearchAndDel_ShowAll()
end)
MPA_SelectPanel.SearchAndDel.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SelectPanel.SearchAndDel.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SelectPanel.SearchAndDel.Icon.Tooltip = "Поиск и удаление";

--- - - - - - - - - - - - -
--- - - - - - - - - - - - -
MPA_SelectPanel.AurasButton = CreateFrame("Button", "MPA_SelectPanel.AurasButton", MPA_SelectPanel,
    "MasterPanel:IconButtonBG") -- // First button
MPA_SelectPanel.AurasButton:SetPoint("CENTER", 0, -18)

MPA_SelectPanel.AurasButton.Icon = CreateFrame("BUTTON", nil, MPA_SelectPanel.AurasButton,
    "MasterPanel:IconButtonTemplate");
MPA_SelectPanel.AurasButton.Icon:SetNormalTexture("interface\\ICONS\\spell_arcane_blast")
MPA_SelectPanel.AurasButton.Icon:SetHighlightTexture("interface\\ICONS\\spell_arcane_blast")
MPA_SelectPanel.AurasButton.Icon:SetAlpha(0.85)
MPA_SelectPanel.AurasButton.Icon:SetScript("OnClick", function()
    MasterPanel:AurasAndStates_ShowAll()
end)
MPA_SelectPanel.AurasButton.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SelectPanel.AurasButton.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SelectPanel.AurasButton.Icon.Tooltip = "Ауры, морфы, фазы и погода";
--- - - - - - - - - - - - -
--- - - - - - - - - - - - -
MPA_SelectPanel.Dops = CreateFrame("Button", "MPA_SelectPanel.Dops", MPA_SelectPanel, "MasterPanel:IconButtonBG") -- // First button
MPA_SelectPanel.Dops:SetPoint("CENTER", 60, -18)

MPA_SelectPanel.Dops.Icon = CreateFrame("BUTTON", nil, MPA_SelectPanel.Dops, "MasterPanel:IconButtonTemplate");
MPA_SelectPanel.Dops.Icon:SetNormalTexture("interface\\ICONS\\spell_shadow_twistedfaith")
MPA_SelectPanel.Dops.Icon:SetHighlightTexture("interface\\ICONS\\spell_shadow_twistedfaith")
MPA_SelectPanel.Dops.Icon:SetAlpha(0.85)
MPA_SelectPanel.Dops.Icon:SetScript("OnClick", function()
    MasterPanel:ControlPanel_ShowAll()
end)
MPA_SelectPanel.Dops.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SelectPanel.Dops.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SelectPanel.Dops.Icon.Tooltip = "Контроль NPC";
MPA_SelectPanel.Dops.Icon.AddLine = colorCode ..
                                        ".npcsave|r позволяет сохранить позицию и анимацию выбранного NPC;|n" ..
                                        colorCode .. ".setmount |r садит NPC на маунта;|n" .. colorCode ..
                                        ".roam [радиус 0-10]|r заставляет выбранного NPC бродить в указанном радиусе (работает только пока NPC прогружен игроками, потом сбрасывается, а " ..
                                        colorCode .. ".unroam|r или " .. colorCode ..
                                        ".stoproam|r отменяет это;|n" .. colorCode ..
                                        ".follow [Ник]|r заставляет выбранного NPC следовать за игроком, а " ..
                                        colorCode .. ".unfollow|r отменяет это;|n" .. colorCode ..
                                        ".follow [ник] [дистанция] [угол]|r - дополнительно указывает расстояние на котором держится NPC, а также угол, с какой стороны игрока стоит и идёт NPC. Можно указать r для рандомного числа.";
--- - - - - - - - - - - - -
--- - - - - - - - - - - - -
MPA_SelectPanel.Options = CreateFrame("Button", "MPA_SelectPanel.Options", MPA_SelectPanel, "MasterPanel:IconButtonBG") -- // First button
MPA_SelectPanel.Options:SetPoint("CENTER", 120, -18)

MPA_SelectPanel.Options.Icon = CreateFrame("BUTTON", nil, MPA_SelectPanel.Options, "MasterPanel:IconButtonTemplate");
MPA_SelectPanel.Options.Icon:SetNormalTexture("interface\\ICONS\\icon_petfamily_mechanical")
MPA_SelectPanel.Options.Icon:SetHighlightTexture("interface\\ICONS\\icon_petfamily_mechanical")
MPA_SelectPanel.Options.Icon:SetAlpha(0.85)
MPA_SelectPanel.Options.Icon:SetScript("OnClick", function()
    MasterPanel:SettingsFrameOnOff()
end)
MPA_SelectPanel.Options.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SelectPanel.Options.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SelectPanel.Options.Icon.Tooltip = "Настройки";
MPA_SelectPanel.Options.Icon.AddLine = colorCode ..
                                           ".reskin|r позволяет изменить расу и ник персонажа;|n" ..
                                           colorCode ..
                                           ".gps|r показывает координаты места, в котором находится персонаж;|n" ..
                                           colorCode ..
                                           ".charcust|r показывает параметры внешности персонажа;|n" ..
                                           colorCode ..
                                           ".tele gm|r перемещает на локацию где можна тестировать ГОшки и NPC;|n" ..
                                           colorCode ..
                                           ".tele ShowCase|r перемещает в локацию с различными NPC на выбор;|n" ..
                                           colorCode ..
                                           ".createtargetdisp [название]|r создает Display ID персонажа в таргете;|n" ..
                                           colorCode .. ".reloadoutfits|r перезагружает Display ID.";

-----------------------------------------------------------------------------------------------------------------------------------------------------
--------/// Select Panel UI
-----------------------------------------------------------------------------------------------------------------------------------------------------

local MPA_NPCPanel = CreateFrame("Frame", "MPA_NPCPanel", MPA_MainPanel)
MPA_NPCPanel:SetSize(318.94, 120.25)
MPA_NPCPanel:SetAllPoints(MPA_MainPanel)
MPA_NPCPanel:Hide()

MPA_NPCPanel.NPCSay_Button = CreateFrame("BUTTON", "MPA_MainPanel.NPCSay_Button", MPA_NPCPanel,
    "MasterPanel:NPCSAYButton");
MPA_NPCPanel.NPCSay_Button:SetPoint("CENTER", MPA_MainPanel, "CENTER", -100, 0)
MPA_NPCPanel.NPCSay_Button.Tooltip = "Отпись за NPC";
MPA_NPCPanel.NPCSay_Button:SetScript("OnEnter", GameTooltipOnEnter);
MPA_NPCPanel.NPCSay_Button:SetScript("OnLeave", GameTooltipOnLeave);
MPA_NPCPanel.NPCSay_Button:SetScript("OnClick", function(self)
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "NPCSAYSTATE";
    MPA_MainPanel.Title:SetText("Отпись за NPC")
    MasterPanel:OpenMainEditbox();
    print("NPCTalkAnimation is now:", MasterPanel.db.profile.settings.NPCTalkAnimation)
    if MasterPanel.db.profile.settings.NPCTalkAnimation == true then
        SendChatMessage(".npc playemote 1", "SAY")
    end
end)

MPA_NPCPanel.NPCEmote_Button = CreateFrame("BUTTON", "MPA_MainPanel.NPCEmote_Button", MPA_NPCPanel,
    "MasterPanel:NPCEmoteButton");
MPA_NPCPanel.NPCEmote_Button:SetPoint("CENTER", MPA_MainPanel, "CENTER", 0, 0)
MPA_NPCPanel.NPCEmote_Button.Tooltip = "Эмоции за NPC";
MPA_NPCPanel.NPCEmote_Button:SetScript("OnEnter", GameTooltipOnEnter);
MPA_NPCPanel.NPCEmote_Button:SetScript("OnLeave", GameTooltipOnLeave);
MPA_NPCPanel.NPCEmote_Button:SetScript("OnClick", function(self)
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "NPCEMOTESTATE";
    MPA_MainPanel.Title:SetText("Эмоции за NPC")
    MasterPanel:OpenMainEditbox();
end)

MPA_NPCPanel.Colour_Button = CreateFrame("BUTTON", "MPA_MainPanel.Colour_Button", MPA_NPCPanel,
    "MasterPanel:NPCColourButton");
MPA_NPCPanel.Colour_Button:SetPoint("CENTER", MPA_MainPanel, "CENTER", 100, 0)
MPA_NPCPanel.Colour_Button.Tooltip = "Цветная отпись";
MPA_NPCPanel.Colour_Button:SetScript("OnEnter", GameTooltipOnEnter);
MPA_NPCPanel.Colour_Button:SetScript("OnLeave", GameTooltipOnLeave);
MPA_NPCPanel.Colour_Button:SetScript("OnClick", function(self)
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "CHATCOLORSTATE";
    MPA_MainPanel.Title:SetText("Цветная отпись")
    MasterPanel:OpenMainEditbox();
end)

MPA_NPCPanel.NPCYell_Button = CreateFrame("BUTTON", "MPA_MainPanel.NPCYell_Button", MPA_NPCPanel,
    "MasterPanel:NPCYellButton");
MPA_NPCPanel.NPCYell_Button:SetPoint("CENTER", MPA_MainPanel, "CENTER", -100, -35)
MPA_NPCPanel.NPCYell_Button.Tooltip = "Крик за NPC";
MPA_NPCPanel.NPCYell_Button:SetScript("OnEnter", GameTooltipOnEnter);
MPA_NPCPanel.NPCYell_Button:SetScript("OnLeave", GameTooltipOnLeave);
MPA_NPCPanel.NPCYell_Button:SetScript("OnClick", function(self)
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "NPCYELLSTATE";
    MPA_MainPanel.Title:SetText("Крик за NPC")
    MasterPanel:OpenMainEditbox();
end)

MPA_NPCPanel.TalkingHead_Button = CreateFrame("BUTTON", "MPA_MainPanel.TalkingHead_Button", MPA_NPCPanel,
    "MasterPanel:NPCTalkingHeadButton");
MPA_NPCPanel.TalkingHead_Button:SetPoint("CENTER", MPA_MainPanel, "CENTER", 0, -35)
MPA_NPCPanel.TalkingHead_Button.Tooltip = "Интерактивный фрейм";
MPA_NPCPanel.TalkingHead_Button:SetScript("OnEnter", GameTooltipOnEnter);
MPA_NPCPanel.TalkingHead_Button:SetScript("OnLeave", GameTooltipOnLeave);
MPA_NPCPanel.TalkingHead_Button:SetScript("OnClick", function(self)
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "TALKINGHEADSTATE";
    MPA_MainPanel.Title:SetText("Интерактивный фрейм")
    MasterPanel:OpenMainEditbox();
end)

MPA_NPCPanel.ColourDropDown = CreateFrame("Button", "MPA_NPCPanel.ColourDropDown", MPA_NPCPanel,
    "UIDropDownMenuTemplate")
MPA_NPCPanel.ColourDropDown:SetPoint("CENTER", MPA_MainPanel, "CENTER", 100, -35)

local Colour_items = {"|cffbbbbbbСерый|r", "|cffff0000Красный", "|cff00ccffСиний",
                      "|cff93c57fЗеленый", "|cffFF6EB4Розовый", "|cffec9c22Оранжевый",
                      "|cffc169d2Фиолетовый"}

local function OnClick(self)
    UIDropDownMenu_SetSelectedID(MPA_NPCPanel.ColourDropDown, self:GetID())
    Chosen_colour = self:GetID()
end

local function initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    for k, v in pairs(Colour_items) do
        info = UIDropDownMenu_CreateInfo()
        info.text = v
        info.value = v
        info.func = OnClick
        UIDropDownMenu_AddButton(info, level)
    end
end

UIDropDownMenu_Initialize(MPA_NPCPanel.ColourDropDown, initialize)
UIDropDownMenu_SetWidth(MPA_NPCPanel.ColourDropDown, 70);
UIDropDownMenu_SetButtonWidth(MPA_NPCPanel.ColourDropDown, 80)
UIDropDownMenu_SetSelectedID(MPA_NPCPanel.ColourDropDown, 1)
UIDropDownMenu_SetText(MPA_NPCPanel.ColourDropDown, "Цвет")
UIDropDownMenu_JustifyText(MPA_NPCPanel.ColourDropDown, "LEFT")

-----------------------------------------------------------------------------------------------------------------------------------------------------
--------/// SearchAndDel UI
-----------------------------------------------------------------------------------------------------------------------------------------------------

local MPA_SearchAndDelPanel = CreateFrame("Frame", "MPA_SearchAndDelPanel", MPA_MainPanel)
MPA_SearchAndDelPanel:SetSize(318.94, 120.25)
MPA_SearchAndDelPanel:SetAllPoints(MPA_MainPanel)
MPA_SearchAndDelPanel:Hide()

MPA_SearchAndDelPanel.LoCrButton = CreateFrame("BUTTON", "MPA_SearchAndDelPanel.LoCrButton", MPA_SearchAndDelPanel,
    "MasterPanel:LoCrButtonTemplate");
MPA_SearchAndDelPanel.LoCrButton:SetPoint("CENTER", MPA_MainPanel, "CENTER", -100, -35)
MPA_SearchAndDelPanel.LoCrButton.Tooltip = "Поиск NPC";
MPA_SearchAndDelPanel.LoCrButton.AddLine =
    "Чтобы создать маунта для морфа введите: " .. colorCode ..
        "м1|r (обычный), " .. colorCode .. "м2|r (быстрый) или " .. colorCode ..
        "м3|r (летающий);|n Чтобы создать летающего NPC введите находясь в воздухе: " ..
        colorCode .. "ф|r.";
MPA_SearchAndDelPanel.LoCrButton:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SearchAndDelPanel.LoCrButton:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SearchAndDelPanel.LoCrButton:SetScript("OnClick", function(self)
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "LOOKUPCREATURE";
    MPA_MainPanel.Title:SetText("Поиск NPC")
    MasterPanel:OpenMainEditbox();
end)

MPA_SearchAndDelPanel.LoObjButton = CreateFrame("BUTTON", "MPA_SearchAndDelPanel.LoObjButton", MPA_SearchAndDelPanel,
    "MasterPanel:LoObjButtonTemplate");
MPA_SearchAndDelPanel.LoObjButton:SetPoint("CENTER", MPA_MainPanel, "CENTER", 0, -35)
MPA_SearchAndDelPanel.LoObjButton.Tooltip = "Поиск объектов";
MPA_SearchAndDelPanel.LoObjButton.AddLine = colorCode ..
                                                ".movego|r позволяет выделить близжайшую гошку, наклонить и изменить её размер;|n" ..
                                                colorCode ..
                                                ".gobcopy [радиус] [фаза]|r — копирует (не переносит) объекты в указанном радиусе в указанную фазу;|n" ..
                                                colorCode ..
                                                ".neardis|r показывает Dysplay ID ближайших ГО;|n" ..
                                                colorCode ..
                                                ".targetdis|r показывает Dysplay ID ближайшей ГО;|n" ..
                                                colorCode .. ".gobnear [guid]|r - гуид объектов;|n" ..
                                                colorCode .. ".gobsize [guid] [size]|r - размер объекта;|n" ..
                                                colorCode .. ".gob act [guid]|r - действие объекта;|n" ..
                                                colorCode ..
                                                ".gobtele [guid]|r - перемещает обьект к вам;|n" ..
                                                colorCode ..
                                                ".gobinfo|r показывает GUID, персонажа, дату установки ближайшей ГО.";
MPA_SearchAndDelPanel.LoObjButton:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SearchAndDelPanel.LoObjButton:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SearchAndDelPanel.LoObjButton:SetScript("OnClick", function(self)
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "LOOKUPGAMEOBJECTS";
    MPA_MainPanel.Title:SetText("Поиск объектов")
    MasterPanel:OpenMainEditbox();
end)

MPA_SearchAndDelPanel.DeleteNPC = CreateFrame("Button", "MPA_SearchAndDelPanel.DeleteNPC", MPA_SearchAndDelPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_SearchAndDelPanel.DeleteNPC:SetPoint("CENTER", -90, 0)

MPA_SearchAndDelPanel.DeleteNPC.Icon = CreateFrame("BUTTON", nil, MPA_SearchAndDelPanel.DeleteNPC,
    "MasterPanel:MiniIconButtonTemplate");
MPA_SearchAndDelPanel.DeleteNPC.Icon:SetNormalTexture("interface\\ICONS\\inv_jewelry_trinket_04")
MPA_SearchAndDelPanel.DeleteNPC.Icon:SetHighlightTexture("interface\\ICONS\\inv_jewelry_trinket_04")
MPA_SearchAndDelPanel.DeleteNPC.Icon:SetAlpha(0.8)
MPA_SearchAndDelPanel.DeleteNPC.Icon:SetScript("OnClick", function()
    MasterPanel:TargetDeleteNPC()
end)
MPA_SearchAndDelPanel.DeleteNPC.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SearchAndDelPanel.DeleteNPC.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SearchAndDelPanel.DeleteNPC.Icon.Tooltip = "Удалить NPC.";
MPA_SearchAndDelPanel.DeleteNPC.Icon.AddLine = colorCode ..
                                                   ".guiddelnpc [GUID]|r позволяет удалить NPC по его GUID;|n" ..
                                                   colorCode ..
                                                   ".npc info|r позволяет узнать GUID выбранного NPC. Также вы можете узнать это на сайте в модерке.";

MPA_SearchAndDelPanel.DeleteNearNPC = CreateFrame("Button", "MPA_SearchAndDelPanel.DeleteNPC", MPA_SearchAndDelPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_SearchAndDelPanel.DeleteNearNPC:SetPoint("CENTER", -50, 0)

MPA_SearchAndDelPanel.DeleteNearNPC.Icon = CreateFrame("BUTTON", nil, MPA_SearchAndDelPanel.DeleteNearNPC,
    "MasterPanel:MiniIconButtonTemplate");
MPA_SearchAndDelPanel.DeleteNearNPC.Icon:SetNormalTexture("interface\\ICONS\\warrior_skullbanner")
MPA_SearchAndDelPanel.DeleteNearNPC.Icon:SetHighlightTexture("interface\\ICONS\\warrior_skullbanner")
MPA_SearchAndDelPanel.DeleteNearNPC.Icon:SetAlpha(0.8)
MPA_SearchAndDelPanel.DeleteNearNPC.Icon:SetScript("OnClick", function()
    SendChatMessage(".delnearnpc", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
end)
MPA_SearchAndDelPanel.DeleteNearNPC.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SearchAndDelPanel.DeleteNearNPC.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SearchAndDelPanel.DeleteNearNPC.Icon.Tooltip = "Удаление ближайшего NPC.";

local UndoGob_block = false;
local UndoGob_Cooldown = CreateFrame("Frame")
local UndoGob_Cooldown_AnimationGroup = UndoGob_Cooldown:CreateAnimationGroup()
local UndoGob_CooldownAnimation = UndoGob_Cooldown_AnimationGroup:CreateAnimation("Alpha")
UndoGob_CooldownAnimation:SetDuration(1)
UndoGob_Cooldown_AnimationGroup:SetScript("OnFinished", function(self)
    UndoGob_block = false;
end)

MPA_SearchAndDelPanel.UndoGob = CreateFrame("Button", "MPA_SearchAndDelPanel.UndoGob", MPA_SearchAndDelPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_SearchAndDelPanel.UndoGob:SetPoint("CENTER", -10, 0)

MPA_SearchAndDelPanel.UndoGob.Icon = CreateFrame("BUTTON", nil, MPA_SearchAndDelPanel.UndoGob,
    "MasterPanel:MiniIconButtonTemplate");
MPA_SearchAndDelPanel.UndoGob.Icon:SetNormalTexture("interface\\ICONS\\spell_holy_borrowedtime")
MPA_SearchAndDelPanel.UndoGob.Icon:SetHighlightTexture("interface\\ICONS\\spell_holy_borrowedtime")
MPA_SearchAndDelPanel.UndoGob.Icon:SetAlpha(0.8)
MPA_SearchAndDelPanel.UndoGob.Icon:SetScript("OnClick", function()
    if UndoGob_block == true then
        return
    end
    UndoGob_block = true;
    MasterPanel:UndoGobject()
    UndoGob_CooldownAnimation:Play()
    MPA_SearchAndDelPanel.UndoGob.Icon.Cooldown:SetCooldown(GetTime(), 1)
end)
MPA_SearchAndDelPanel.UndoGob.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SearchAndDelPanel.UndoGob.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SearchAndDelPanel.UndoGob.Icon.Tooltip = "Откат предыдущей ГО.";

MPA_SearchAndDelPanel.UndoGob.Icon.Cooldown = CreateFrame("Cooldown", "MPA_SearchAndDelPanel.UndoGob.Icon.Cooldown",
    MPA_SearchAndDelPanel.UndoGob.Icon, "CooldownFrameTemplate")
MPA_SearchAndDelPanel.UndoGob.Icon.Cooldown:SetAllPoints()
MPA_SearchAndDelPanel.UndoGob.Icon.Cooldown:SetCooldown(0, 0)

MPA_SearchAndDelPanel.GobDelRadiusButton = CreateFrame("Button", "MPA_SearchAndDelPanel.GobDelRadiusButton",
    MPA_SearchAndDelPanel, "MasterPanel:MiniIconButtonBG") -- // First button
MPA_SearchAndDelPanel.GobDelRadiusButton:SetPoint("CENTER", 120, 0)

MPA_SearchAndDelPanel.GobDelRadiusButton.Icon = CreateFrame("BUTTON", nil, MPA_SearchAndDelPanel.GobDelRadiusButton,
    "MasterPanel:MiniIconButtonTemplate");
MPA_SearchAndDelPanel.GobDelRadiusButton.Icon:SetNormalTexture("interface\\ICONS\\inv_misc_bomb_05")
MPA_SearchAndDelPanel.GobDelRadiusButton.Icon:SetHighlightTexture("interface\\ICONS\\inv_misc_bomb_05")
MPA_SearchAndDelPanel.GobDelRadiusButton.Icon:SetAlpha(0.8)
MPA_SearchAndDelPanel.GobDelRadiusButton.Icon:SetScript("OnClick", function()
    MasterPanel:WarningFrameShow(Chosen_GobDelRadius)
end)
MPA_SearchAndDelPanel.GobDelRadiusButton.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SearchAndDelPanel.GobDelRadiusButton.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SearchAndDelPanel.GobDelRadiusButton.Icon.Tooltip =
    "Удаление всех ГО вокруг.\nУдаляются даже чужие ГО.";
MPA_SearchAndDelPanel.GobDelRadiusButton.Icon.AddLine = colorCode ..
                                                            ".gob del GUID|r удаляет обьект по его guid.";

MPA_SearchAndDelPanel.GobDelByNameButton = CreateFrame("Button", "MPA_SearchAndDelPanel.GobDelByNameButton",
    MPA_SearchAndDelPanel, "MasterPanel:MiniIconButtonBG") -- // First button
MPA_SearchAndDelPanel.GobDelByNameButton:SetPoint("CENTER", 80, 0)

MPA_SearchAndDelPanel.GobDelByNameButton.Icon = CreateFrame("BUTTON", nil, MPA_SearchAndDelPanel.GobDelByNameButton,
    "MasterPanel:MiniIconButtonTemplate");
MPA_SearchAndDelPanel.GobDelByNameButton.Icon:SetNormalTexture("interface\\ICONS\\garrison_building_workshop")
MPA_SearchAndDelPanel.GobDelByNameButton.Icon:SetHighlightTexture("interface\\ICONS\\garrison_building_workshop")
MPA_SearchAndDelPanel.GobDelByNameButton.Icon:SetAlpha(0.8)
MPA_SearchAndDelPanel.GobDelByNameButton.Icon:SetScript("OnClick", function()
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "DELETEGOBNAMESTATE";
    MPA_MainPanel.Title:SetText("Удаление ГО по названию")
    MasterPanel:OpenMainEditbox();
    MPA_EditPanel.EditBox:SetTextColor(1, 0, 0, 1);
end)
MPA_SearchAndDelPanel.GobDelByNameButton.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SearchAndDelPanel.GobDelByNameButton.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SearchAndDelPanel.GobDelByNameButton.Icon.Tooltip =
    "Удаление всех ГО по названию.\nУдаляются даже чужие ГО.";
MPA_SearchAndDelPanel.GobDelByNameButton.Icon.AddLine = colorCode ..
                                                            ".gob del GUID|r удаляет обьект по его guid.";

MPA_SearchAndDelPanel.GobDeleteDropDown = CreateFrame("Button", "MPA_SearchAndDelPanel.GobDeleteDropDown",
    MPA_SearchAndDelPanel, "UIDropDownMenuTemplate")
MPA_SearchAndDelPanel.GobDeleteDropDown:SetPoint("CENTER", MPA_MainPanel, "CENTER", 100, -35)

local GobDelete_radius = {"2 ярда", "5 ярдов", "10 ярдов", "15 ярдов"}

local function OnClick(self)
    UIDropDownMenu_SetSelectedID(MPA_SearchAndDelPanel.GobDeleteDropDown, self:GetID())
    Chosen_GobDelRadius = self:GetID()
end

local function initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    for k, v in pairs(GobDelete_radius) do
        info = UIDropDownMenu_CreateInfo()
        info.text = v
        info.value = v
        info.func = OnClick
        UIDropDownMenu_AddButton(info, level)
    end
end

UIDropDownMenu_Initialize(MPA_SearchAndDelPanel.GobDeleteDropDown, initialize)
UIDropDownMenu_SetWidth(MPA_SearchAndDelPanel.GobDeleteDropDown, 70);
UIDropDownMenu_SetButtonWidth(MPA_SearchAndDelPanel.GobDeleteDropDown, 70)
UIDropDownMenu_SetSelectedID(MPA_SearchAndDelPanel.GobDeleteDropDown, 2)
UIDropDownMenu_SetText(MPA_SearchAndDelPanel.GobDeleteDropDown, "Радиус:")
UIDropDownMenu_JustifyText(MPA_SearchAndDelPanel.GobDeleteDropDown, "LEFT")

-----------------------------------------------------------------------------------------------------------------------------------------------------
--------/// SearchAndDel UI
-----------------------------------------------------------------------------------------------------------------------------------------------------

local MPA_AurasAndStatesPanel = CreateFrame("Frame", "MPA_AurasAndStatesPanel", MPA_MainPanel)
MPA_AurasAndStatesPanel:SetSize(318.94, 120.25)
MPA_AurasAndStatesPanel:SetAllPoints(MPA_MainPanel)
MPA_AurasAndStatesPanel:Hide()

MPA_AurasAndStatesPanel.Morph = CreateFrame("BUTTON", "MPA_AurasAndStatesPanel.Morph", MPA_AurasAndStatesPanel,
    "MasterPanel:MorphButtonTemplate");
MPA_AurasAndStatesPanel.Morph:SetPoint("CENTER", MPA_MainPanel, "CENTER", -100, -35)
MPA_AurasAndStatesPanel.Morph.Tooltip = "Смена облика";
MPA_AurasAndStatesPanel.Morph:SetScript("OnEnter", GameTooltipOnEnter);
MPA_AurasAndStatesPanel.Morph:SetScript("OnLeave", GameTooltipOnLeave);
MPA_AurasAndStatesPanel.Morph:SetScript("OnClick", function(self)
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "MORPHSTATEMENT";
    MPA_MainPanel.Title:SetText("Смена облика")
    MasterPanel:OpenMainEditbox();
end)

MPA_AurasAndStatesPanel.DeMorph = CreateFrame("BUTTON", "MPA_AurasAndStatesPanel.DeMorph", MPA_AurasAndStatesPanel,
    "MasterPanel:DeMorphButtonTemplate");
MPA_AurasAndStatesPanel.DeMorph:SetPoint("CENTER", MPA_MainPanel, "CENTER", 0, -35)
MPA_AurasAndStatesPanel.DeMorph.Tooltip = "Снять облик";
MPA_AurasAndStatesPanel.DeMorph:SetScript("OnEnter", GameTooltipOnEnter);
MPA_AurasAndStatesPanel.DeMorph:SetScript("OnLeave", GameTooltipOnLeave);
MPA_AurasAndStatesPanel.DeMorph:SetScript("OnClick", function(self)
    SendChatMessage(".deskin", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
end)

MPA_AurasAndStatesPanel.Phase = CreateFrame("BUTTON", "MPA_AurasAndStatesPanel.Phase", MPA_AurasAndStatesPanel,
    "MasterPanel:PhaseButtonTemplate");
MPA_AurasAndStatesPanel.Phase:SetPoint("CENTER", MPA_MainPanel, "CENTER", 100, 0)
MPA_AurasAndStatesPanel.Phase.Tooltip = "Смена фазы";
MPA_AurasAndStatesPanel.Phase.AddLine =
    "Основная фаза: 1;|nДругие фазы: 2, 4, 8, 16, 32, 64;|nДобавьте к номеру фазы малую или большую английскую букву " ..
        colorCode ..
        "R|r чтобы переместить в нужную фазу всю группу или рейд;|n" ..
        colorCode .. "3|r - личный телепорт на карту с NPC.|n";
MPA_AurasAndStatesPanel.Phase:SetScript("OnEnter", GameTooltipOnEnter);
MPA_AurasAndStatesPanel.Phase:SetScript("OnLeave", GameTooltipOnLeave);
MPA_AurasAndStatesPanel.Phase:SetScript("OnClick", function(self)
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "PHASESTATEMENT";
    MPA_MainPanel.Title:SetText("Смена фазы")
    MasterPanel:OpenMainEditbox();
end)

MPA_AurasAndStatesPanel.CastVisual = CreateFrame("Button", "MPA_AurasAndStatesPanel.CastVisual",
    MPA_AurasAndStatesPanel, "MasterPanel:MiniIconButtonBG") -- // First button
MPA_AurasAndStatesPanel.CastVisual:SetPoint("CENTER", 80, -35)

MPA_AurasAndStatesPanel.CastVisual.Icon = CreateFrame("BUTTON", nil, MPA_AurasAndStatesPanel.CastVisual,
    "MasterPanel:MiniIconButtonTemplate");
MPA_AurasAndStatesPanel.CastVisual.Icon:SetNormalTexture("interface\\ICONS\\spell_arcane_massdispel")
MPA_AurasAndStatesPanel.CastVisual.Icon:SetHighlightTexture("interface\\ICONS\\spell_arcane_massdispel")
MPA_AurasAndStatesPanel.CastVisual.Icon:SetAlpha(0.8)
MPA_AurasAndStatesPanel.CastVisual.Icon:SetScript("OnClick", function()
    if not IsAddOnLoaded("Noble_UI") then
        print(
            "|cffff9716[ГМ-аддон]: Для использования функции включите модификацию '[N] Интерфейс'.|r")
    else
        MasterPanel:EditBoxCollectGarbage();
        EditboxStatement = "VISUALSPELLSSTATEMENT";
        MPA_MainPanel.Title:SetText("Введите ID эффекта")
        MasterPanel:OpenMainEditbox();
    end
end)
MPA_AurasAndStatesPanel.CastVisual.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_AurasAndStatesPanel.CastVisual.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_AurasAndStatesPanel.CastVisual.Icon.Tooltip = "Визуальные эффекты";
MPA_AurasAndStatesPanel.CastVisual.Icon.AddLine = colorCode .. "1|r лед;|n" .. colorCode .. "2|r огонь;|n" ..
                                                      colorCode .. "3|r вода;|n" .. colorCode ..
                                                      "4|r молния;|n" .. colorCode ..
                                                      "5|r тайная магия;|n" .. colorCode ..
                                                      "6|r природа;|n" .. colorCode .. "7|r свет;|n" ..
                                                      colorCode .. "8|r тьма;|n" .. colorCode ..
                                                      "9|r скверна;|n" .. colorCode ..
                                                      "10|r теневая преграда;|n" .. colorCode .. "11|r, " ..
                                                      colorCode .. "12|r, " .. colorCode ..
                                                      "13|r заклинание льда;|n" .. colorCode .. "14|r, " ..
                                                      colorCode .. "15|r, " .. colorCode ..
                                                      "16|r заклинание огня;|n" .. colorCode .. "17|r, " ..
                                                      colorCode .. "18|r, " .. colorCode ..
                                                      "19|r заклинание арканы;|n" .. colorCode ..
                                                      "20|r заклинание природы;|n" .. colorCode ..
                                                      "21|r заклинание молнии;|n" .. colorCode ..
                                                      "22|r, " .. colorCode .. "23|r заклинание света;|n" ..
                                                      colorCode .. "24|r заклинание тьмы;|n" .. colorCode ..
                                                      "25|r заклинание скверны;|n" .. colorCode ..
                                                      "26|r ритуал тьмы.";

MPA_AurasAndStatesPanel.StopCastVisual = CreateFrame("Button", "MPA_AurasAndStatesPanel.StopCastVisual",
    MPA_AurasAndStatesPanel, "MasterPanel:MiniIconButtonBG") -- // First button
MPA_AurasAndStatesPanel.StopCastVisual:SetPoint("CENTER", 120, -35)

MPA_AurasAndStatesPanel.StopCastVisual.Icon = CreateFrame("BUTTON", nil, MPA_AurasAndStatesPanel.StopCastVisual,
    "MasterPanel:MiniIconButtonTemplate");
MPA_AurasAndStatesPanel.StopCastVisual.Icon:SetNormalTexture("interface\\ICONS\\spell_shadow_dispersion")
MPA_AurasAndStatesPanel.StopCastVisual.Icon:SetHighlightTexture("interface\\ICONS\\spell_shadow_dispersion")
MPA_AurasAndStatesPanel.StopCastVisual.Icon:SetAlpha(0.8)
MPA_AurasAndStatesPanel.StopCastVisual.Icon:SetScript("OnClick", function()
    SendChatMessage(".stopspell", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
end)
MPA_AurasAndStatesPanel.StopCastVisual.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_AurasAndStatesPanel.StopCastVisual.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_AurasAndStatesPanel.StopCastVisual.Icon.Tooltip = "Отменить визуальное\nзаклинание";

MPA_AurasAndStatesPanel.SetAura = CreateFrame("Button", "MPA_AurasAndStatesPanel.SetAura", MPA_AurasAndStatesPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_AurasAndStatesPanel.SetAura:SetPoint("CENTER", -120, 0)

MPA_AurasAndStatesPanel.SetAura.Icon = CreateFrame("BUTTON", nil, MPA_AurasAndStatesPanel.SetAura,
    "MasterPanel:MiniIconButtonTemplate");
MPA_AurasAndStatesPanel.SetAura.Icon:SetNormalTexture("interface\\ICONS\\spell_arcane_studentofmagic")
MPA_AurasAndStatesPanel.SetAura.Icon:SetHighlightTexture("interface\\ICONS\\spell_arcane_studentofmagic")
MPA_AurasAndStatesPanel.SetAura.Icon:SetAlpha(0.8)
MPA_AurasAndStatesPanel.SetAura.Icon:SetScript("OnClick", function()
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "SETAURASTATEMENT";
    MPA_MainPanel.Title:SetText("Добавить ауру")
    MasterPanel:OpenMainEditbox();
end)
MPA_AurasAndStatesPanel.SetAura.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_AurasAndStatesPanel.SetAura.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_AurasAndStatesPanel.SetAura.Icon.Tooltip = "Добавить ауру";
MPA_AurasAndStatesPanel.SetAura.Icon.AddLine =
    "Небольшой список полезных аур:|n" .. colorCode .. "1|r - невидимость;";

MPA_AurasAndStatesPanel.ClearAura = CreateFrame("Button", "MPA_AurasAndStatesPanel.ClearAura", MPA_AurasAndStatesPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_AurasAndStatesPanel.ClearAura:SetPoint("CENTER", -80, 0)

MPA_AurasAndStatesPanel.ClearAura.Icon = CreateFrame("BUTTON", nil, MPA_AurasAndStatesPanel.ClearAura,
    "MasterPanel:MiniIconButtonTemplate");
MPA_AurasAndStatesPanel.ClearAura.Icon:SetNormalTexture("interface\\ICONS\\spell_holy_dispelmagic")
MPA_AurasAndStatesPanel.ClearAura.Icon:SetHighlightTexture("interface\\ICONS\\spell_holy_dispelmagic")
MPA_AurasAndStatesPanel.ClearAura.Icon:SetAlpha(0.8)
MPA_AurasAndStatesPanel.ClearAura.Icon:SetScript("OnClick", function(self, click_button)
    if click_button == "RightButton" then
        SendChatMessage(".cleartargetauras", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
    else
        MasterPanel:EditBoxCollectGarbage();
        EditboxStatement = "CLEARAURASTATEMENT";
        MPA_MainPanel.Title:SetText("Убрать ауру")
        MasterPanel:OpenMainEditbox();
    end
end)
MPA_AurasAndStatesPanel.ClearAura.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_AurasAndStatesPanel.ClearAura.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_AurasAndStatesPanel.ClearAura.Icon.Tooltip = "Убрать ауру";
MPA_AurasAndStatesPanel.ClearAura.Icon.AddLine = "Выберите цель и нажмите " .. colorCode ..
                                                     "ПКМ|r или оставьте поле пустым и нажмите Enter, чтобы убрать все ауры. Вы можете убрать определенную ауру по id.";

MPA_AurasAndStatesPanel.SetScale = CreateFrame("Button", "MPA_AurasAndStatesPanel.SetScale", MPA_AurasAndStatesPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_AurasAndStatesPanel.SetScale:SetPoint("CENTER", 25, 0)

MPA_AurasAndStatesPanel.SetScale.Icon = CreateFrame("BUTTON", nil, MPA_AurasAndStatesPanel.SetScale,
    "MasterPanel:MiniIconButtonTemplate");
MPA_AurasAndStatesPanel.SetScale.Icon:SetNormalTexture("interface\\ICONS\\spell_shaman_improvedreincarnation")
MPA_AurasAndStatesPanel.SetScale.Icon:SetHighlightTexture("interface\\ICONS\\spell_shaman_improvedreincarnation")
MPA_AurasAndStatesPanel.SetScale.Icon:SetAlpha(0.8)
MPA_AurasAndStatesPanel.SetScale.Icon:SetScript("OnClick", function(self, click_button)
    if click_button == "RightButton" then
        if not isNPCtarget() then
            print("|cffff9716[ГМ-аддон]: Возьмите в цель НПС.|r")
            return
        else
            SendChatMessage(".changescale 1", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
        end
    else
        MasterPanel:EditBoxCollectGarbage();
        EditboxStatement = "SETSCALENPCSTATEMENT";
        MPA_MainPanel.Title:SetText("Изменить размер NPC/игрока")
        MasterPanel:OpenMainEditbox();
    end
end)
MPA_AurasAndStatesPanel.SetScale.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_AurasAndStatesPanel.SetScale.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_AurasAndStatesPanel.SetScale.Icon.Tooltip = "Изменить размер NPC/игрока";
MPA_AurasAndStatesPanel.SetScale.Icon.AddLine = "Выберите цель и нажмите " .. colorCode ..
                                                    "ПКМ|r или оставьте поле пустым и нажмите Enter, чтобы получить стандартный размер.";

-- Время и погода

MPA_AurasAndStatesPanel.SetTimeAndWeatherButton = CreateFrame("Button",
    "MPA_AurasAndStatesPanel.SetTimeAndWeatherButton", MPA_AurasAndStatesPanel, "MasterPanel:MiniIconButtonBG") -- // First button
MPA_AurasAndStatesPanel.SetTimeAndWeatherButton:SetPoint("CENTER", -25, 0)

MPA_AurasAndStatesPanel.SetTimeAndWeatherButton.Icon = CreateFrame("BUTTON", nil,
    MPA_AurasAndStatesPanel.SetTimeAndWeatherButton, "MasterPanel:MiniIconButtonTemplate");
MPA_AurasAndStatesPanel.SetTimeAndWeatherButton.Icon:SetNormalTexture("interface\\ICONS\\spell_nature_timestop")
MPA_AurasAndStatesPanel.SetTimeAndWeatherButton.Icon:SetHighlightTexture("interface\\ICONS\\spell_nature_timestop")
MPA_AurasAndStatesPanel.SetTimeAndWeatherButton.Icon:SetAlpha(0.8)
MPA_AurasAndStatesPanel.SetTimeAndWeatherButton.Icon:SetScript("OnClick", function()
    MasterPanel:SetTimeAndWeather_ShowAll()
end)
MPA_AurasAndStatesPanel.SetTimeAndWeatherButton.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_AurasAndStatesPanel.SetTimeAndWeatherButton.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_AurasAndStatesPanel.SetTimeAndWeatherButton.Icon.Tooltip = "Изменить время и погоду";

-- Время и погода end

-----------------------------------------------------------------------------------------------------------------------------------------------------
--------/// SetTimeAndWeatherPanel
-----------------------------------------------------------------------------------------------------------------------------------------------------
local MPA_SetTimeAndWeatherPanel = CreateFrame("Frame", "MPA_SetTimeAndWeatherPanel", MPA_MainPanel)
MPA_SetTimeAndWeatherPanel:SetSize(318.94, 120.25)
MPA_SetTimeAndWeatherPanel:SetAllPoints(MPA_MainPanel)
MPA_SetTimeAndWeatherPanel:Hide()

MPA_SetTimeAndWeatherPanel.EarlyMorning = CreateFrame("Button", "MPA_SetTimeAndWeatherPanel.EarlyMorning",
    MPA_SetTimeAndWeatherPanel, "MasterPanel:MiniIconButtonBG") -- // First button
MPA_SetTimeAndWeatherPanel.EarlyMorning:SetPoint("CENTER", -130, 5)

MPA_SetTimeAndWeatherPanel.EarlyMorning.Icon = CreateFrame("BUTTON", nil, MPA_SetTimeAndWeatherPanel.EarlyMorning,
    "MasterPanel:MiniIconButtonTemplate");
MPA_SetTimeAndWeatherPanel.EarlyMorning.Icon:SetNormalTexture("interface\\ICONS\\inv_jewelcrafting_shadowspirit_02")
MPA_SetTimeAndWeatherPanel.EarlyMorning.Icon:SetHighlightTexture("interface\\ICONS\\inv_jewelcrafting_shadowspirit_02")
MPA_SetTimeAndWeatherPanel.EarlyMorning.Icon:SetAlpha(0.8)
MPA_SetTimeAndWeatherPanel.EarlyMorning.Icon:SetScript("OnClick", function()
    SendChatMessage(".setgrouptime 1");
    print("|cffff9716[ГМ-аддон]: Раннее утро выставлено.|r");
end)
MPA_SetTimeAndWeatherPanel.EarlyMorning.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SetTimeAndWeatherPanel.EarlyMorning.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SetTimeAndWeatherPanel.EarlyMorning.Icon.Tooltip = "Раннее утро";

MPA_SetTimeAndWeatherPanel.Morning = CreateFrame("Button", "MPA_SetTimeAndWeatherPanel.Morning",
    MPA_SetTimeAndWeatherPanel, "MasterPanel:MiniIconButtonBG") -- // First button
MPA_SetTimeAndWeatherPanel.Morning:SetPoint("CENTER", -90, 5)

MPA_SetTimeAndWeatherPanel.Morning.Icon = CreateFrame("BUTTON", nil, MPA_SetTimeAndWeatherPanel.Morning,
    "MasterPanel:MiniIconButtonTemplate");
MPA_SetTimeAndWeatherPanel.Morning.Icon:SetNormalTexture("interface\\ICONS\\spell_holy_holysmite")
MPA_SetTimeAndWeatherPanel.Morning.Icon:SetHighlightTexture("interface\\ICONS\\spell_holy_holysmite")
MPA_SetTimeAndWeatherPanel.Morning.Icon:SetAlpha(0.8)
MPA_SetTimeAndWeatherPanel.Morning.Icon:SetScript("OnClick", function()
    SendChatMessage(".setgrouptime 2");
    print("|cffff9716[ГМ-аддон]: Утро выставлено.|r");
end)
MPA_SetTimeAndWeatherPanel.Morning.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SetTimeAndWeatherPanel.Morning.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SetTimeAndWeatherPanel.Morning.Icon.Tooltip = "Утро";

MPA_SetTimeAndWeatherPanel.Noon = CreateFrame("Button", "MPA_SetTimeAndWeatherPanel.Noon", MPA_SetTimeAndWeatherPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_SetTimeAndWeatherPanel.Noon:SetPoint("CENTER", -50, 5)

MPA_SetTimeAndWeatherPanel.Noon.Icon = CreateFrame("BUTTON", nil, MPA_SetTimeAndWeatherPanel.Noon,
    "MasterPanel:MiniIconButtonTemplate");
MPA_SetTimeAndWeatherPanel.Noon.Icon:SetNormalTexture("interface\\ICONS\\spell_holy_powerwordbarrier")
MPA_SetTimeAndWeatherPanel.Noon.Icon:SetHighlightTexture("interface\\ICONS\\spell_holy_powerwordbarrier")
MPA_SetTimeAndWeatherPanel.Noon.Icon:SetAlpha(0.8)
MPA_SetTimeAndWeatherPanel.Noon.Icon:SetScript("OnClick", function()
    SendChatMessage(".setgrouptime 3");
    print("|cffff9716[ГМ-аддон]: Полдень выставлен.|r");
end)
MPA_SetTimeAndWeatherPanel.Noon.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SetTimeAndWeatherPanel.Noon.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SetTimeAndWeatherPanel.Noon.Icon.Tooltip = "Полдень";

MPA_SetTimeAndWeatherPanel.Evening = CreateFrame("Button", "MPA_SetTimeAndWeatherPanel.Evening",
    MPA_SetTimeAndWeatherPanel, "MasterPanel:MiniIconButtonBG") -- // First button
MPA_SetTimeAndWeatherPanel.Evening:SetPoint("CENTER", -10, 5)

MPA_SetTimeAndWeatherPanel.Evening.Icon = CreateFrame("BUTTON", nil, MPA_SetTimeAndWeatherPanel.Evening,
    "MasterPanel:MiniIconButtonTemplate");
MPA_SetTimeAndWeatherPanel.Evening.Icon:SetNormalTexture("interface\\ICONS\\spell_nature_starfall")
MPA_SetTimeAndWeatherPanel.Evening.Icon:SetHighlightTexture("interface\\ICONS\\spell_nature_starfall")
MPA_SetTimeAndWeatherPanel.Evening.Icon:SetAlpha(0.8)
MPA_SetTimeAndWeatherPanel.Evening.Icon:SetScript("OnClick", function()
    SendChatMessage(".setgrouptime 4");
    print("|cffff9716[ГМ-аддон]: Вечер выставлен.|r");
end)
MPA_SetTimeAndWeatherPanel.Evening.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SetTimeAndWeatherPanel.Evening.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SetTimeAndWeatherPanel.Evening.Icon.Tooltip = "Вечер";

MPA_SetTimeAndWeatherPanel.LateEvening = CreateFrame("Button", "MPA_SetTimeAndWeatherPanel.LateEvening",
    MPA_SetTimeAndWeatherPanel, "MasterPanel:MiniIconButtonBG") -- // First button
MPA_SetTimeAndWeatherPanel.LateEvening:SetPoint("CENTER", 30, 5)

MPA_SetTimeAndWeatherPanel.LateEvening.Icon = CreateFrame("BUTTON", nil, MPA_SetTimeAndWeatherPanel.LateEvening,
    "MasterPanel:MiniIconButtonTemplate");
MPA_SetTimeAndWeatherPanel.LateEvening.Icon:SetNormalTexture("interface\\ICONS\\ability_racial_shadowmeld")
MPA_SetTimeAndWeatherPanel.LateEvening.Icon:SetHighlightTexture("interface\\ICONS\\ability_racial_shadowmeld")
MPA_SetTimeAndWeatherPanel.LateEvening.Icon:SetAlpha(0.8)
MPA_SetTimeAndWeatherPanel.LateEvening.Icon:SetScript("OnClick", function()
    SendChatMessage(".setgrouptime 5");
    print("|cffff9716[ГМ-аддон]: Поздний вечер выставлен.|r");
end)
MPA_SetTimeAndWeatherPanel.LateEvening.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SetTimeAndWeatherPanel.LateEvening.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SetTimeAndWeatherPanel.LateEvening.Icon.Tooltip = "Поздний вечер";

MPA_SetTimeAndWeatherPanel.Night = CreateFrame("Button", "MPA_SetTimeAndWeatherPanel.Night", MPA_SetTimeAndWeatherPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_SetTimeAndWeatherPanel.Night:SetPoint("CENTER", 70, 5)

MPA_SetTimeAndWeatherPanel.Night.Icon = CreateFrame("BUTTON", nil, MPA_SetTimeAndWeatherPanel.Night,
    "MasterPanel:MiniIconButtonTemplate");
MPA_SetTimeAndWeatherPanel.Night.Icon:SetNormalTexture("interface\\ICONS\\spell_holy_elunesgrace")
MPA_SetTimeAndWeatherPanel.Night.Icon:SetHighlightTexture("interface\\ICONS\\spell_holy_elunesgrace")
MPA_SetTimeAndWeatherPanel.Night.Icon:SetAlpha(0.8)
MPA_SetTimeAndWeatherPanel.Night.Icon:SetScript("OnClick", function()
    SendChatMessage(".setgrouptime 6");
    print("|cffff9716[ГМ-аддон]: Ночь выставлена.|r");
end)
MPA_SetTimeAndWeatherPanel.Night.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SetTimeAndWeatherPanel.Night.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SetTimeAndWeatherPanel.Night.Icon.Tooltip = "Ночь";

MPA_SetTimeAndWeatherPanel.Clear = CreateFrame("Button", "MPA_SetTimeAndWeatherPanel.Clear", MPA_SetTimeAndWeatherPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_SetTimeAndWeatherPanel.Clear:SetPoint("CENTER", -130, -35)

MPA_SetTimeAndWeatherPanel.Clear.Icon = CreateFrame("BUTTON", nil, MPA_SetTimeAndWeatherPanel.Clear,
    "MasterPanel:MiniIconButtonTemplate");
MPA_SetTimeAndWeatherPanel.Clear.Icon:SetNormalTexture("interface\\ICONS\\inv_enchant_essenceastralsmall")
MPA_SetTimeAndWeatherPanel.Clear.Icon:SetHighlightTexture("interface\\ICONS\\inv_enchant_essenceastralsmall")
MPA_SetTimeAndWeatherPanel.Clear.Icon:SetAlpha(0.8)
MPA_SetTimeAndWeatherPanel.Clear.Icon:SetScript("OnClick", function()
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "SETCLEARWEATHERSTATEMENT";
    MPA_MainPanel.Title:SetText("Введите интенсивность погоды")
    MasterPanel:OpenMainEditbox();
end)
MPA_SetTimeAndWeatherPanel.Clear.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SetTimeAndWeatherPanel.Clear.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SetTimeAndWeatherPanel.Clear.Icon.Tooltip = "Ясная погода";
MPA_SetTimeAndWeatherPanel.Clear.Icon.AddLine =
    "Применяется к текущей цели или ко всем в группе/рейде, если цель не выбрана.";

MPA_SetTimeAndWeatherPanel.Rain = CreateFrame("Button", "MPA_SetTimeAndWeatherPanel.Rain", MPA_SetTimeAndWeatherPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_SetTimeAndWeatherPanel.Rain:SetPoint("CENTER", -90, -35)

MPA_SetTimeAndWeatherPanel.Rain.Icon = CreateFrame("BUTTON", nil, MPA_SetTimeAndWeatherPanel.Rain,
    "MasterPanel:MiniIconButtonTemplate");
MPA_SetTimeAndWeatherPanel.Rain.Icon:SetNormalTexture("interface\\ICONS\\spell_fire_bluerainoffire")
MPA_SetTimeAndWeatherPanel.Rain.Icon:SetHighlightTexture("interface\\ICONS\\spell_fire_bluerainoffire")
MPA_SetTimeAndWeatherPanel.Rain.Icon:SetAlpha(0.8)
MPA_SetTimeAndWeatherPanel.Rain.Icon:SetScript("OnClick", function()
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "SETRAINWEATHERSTATEMENT";
    MPA_MainPanel.Title:SetText("Введите интенсивность погоды")
    MasterPanel:OpenMainEditbox();
end)
MPA_SetTimeAndWeatherPanel.Rain.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SetTimeAndWeatherPanel.Rain.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SetTimeAndWeatherPanel.Rain.Icon.Tooltip = "Дождь";
MPA_SetTimeAndWeatherPanel.Rain.Icon.AddLine =
    "Применяется к текущей цели или ко всем в группе/рейде, если цель не выбрана.";

MPA_SetTimeAndWeatherPanel.Snow = CreateFrame("Button", "MPA_SetTimeAndWeatherPanel.Snow", MPA_SetTimeAndWeatherPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_SetTimeAndWeatherPanel.Snow:SetPoint("CENTER", -50, -35)

MPA_SetTimeAndWeatherPanel.Snow.Icon = CreateFrame("BUTTON", nil, MPA_SetTimeAndWeatherPanel.Snow,
    "MasterPanel:MiniIconButtonTemplate");
MPA_SetTimeAndWeatherPanel.Snow.Icon:SetNormalTexture("interface\\ICONS\\inv_ammo_snowball")
MPA_SetTimeAndWeatherPanel.Snow.Icon:SetHighlightTexture("interface\\ICONS\\inv_ammo_snowball")
MPA_SetTimeAndWeatherPanel.Snow.Icon:SetAlpha(0.8)
MPA_SetTimeAndWeatherPanel.Snow.Icon:SetScript("OnClick", function()
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "SETSNOWWEATHERSTATEMENT";
    MPA_MainPanel.Title:SetText("Введите интенсивность погоды")
    MasterPanel:OpenMainEditbox();
end)
MPA_SetTimeAndWeatherPanel.Snow.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SetTimeAndWeatherPanel.Snow.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SetTimeAndWeatherPanel.Snow.Icon.Tooltip = "Снег";
MPA_SetTimeAndWeatherPanel.Snow.Icon.AddLine =
    "Применяется к текущей цели или ко всем в группе/рейде, если цель не выбрана.";

MPA_SetTimeAndWeatherPanel.Storm = CreateFrame("Button", "MPA_SetTimeAndWeatherPanel.Storm", MPA_SetTimeAndWeatherPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_SetTimeAndWeatherPanel.Storm:SetPoint("CENTER", -10, -35)

MPA_SetTimeAndWeatherPanel.Storm.Icon = CreateFrame("BUTTON", nil, MPA_SetTimeAndWeatherPanel.Storm,
    "MasterPanel:MiniIconButtonTemplate");
MPA_SetTimeAndWeatherPanel.Storm.Icon:SetNormalTexture("interface\\ICONS\\spell_frost_icestorm")
MPA_SetTimeAndWeatherPanel.Storm.Icon:SetHighlightTexture("interface\\ICONS\\spell_frost_icestorm")
MPA_SetTimeAndWeatherPanel.Storm.Icon:SetAlpha(0.8)
MPA_SetTimeAndWeatherPanel.Storm.Icon:SetScript("OnClick", function()
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "SETSTORMWEATHERSTATEMENT";
    MPA_MainPanel.Title:SetText("Введите интенсивность погоды")
    MasterPanel:OpenMainEditbox();
end)
MPA_SetTimeAndWeatherPanel.Storm.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_SetTimeAndWeatherPanel.Storm.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_SetTimeAndWeatherPanel.Storm.Icon.Tooltip = "Буря";
MPA_SetTimeAndWeatherPanel.Storm.Icon.AddLine =
    "Применяется к текущей цели или ко всем в группе/рейде, если цель не выбрана.";

-----------------------------------------------------------------------------------------------------------------------------------------------------
--------/// SetTimeAndWeatherPanel END
-----------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------
--------/// NPCPosPanel 
-----------------------------------------------------------------------------------------------------------------------------------------------------

local MPA_NPCPosPanel = CreateFrame("Frame", "MPA_NPCPosPanel", MPA_MainPanel)
MPA_NPCPosPanel:SetSize(318.94, 120.25)
MPA_NPCPosPanel:SetAllPoints(MPA_MainPanel)
MPA_NPCPosPanel:Hide()

MPA_NPCPosPanel.Sit = CreateFrame("Button", "MPA_NPCPosPanel.Sit", MPA_NPCPosPanel, "MasterPanel:MiniIconButtonBG") -- // First button
MPA_NPCPosPanel.Sit:SetPoint("CENTER", -130, 5)

MPA_NPCPosPanel.Sit.Icon = CreateFrame("BUTTON", nil, MPA_NPCPosPanel.Sit, "MasterPanel:MiniIconButtonTemplate");
MPA_NPCPosPanel.Sit.Icon:SetNormalTexture("interface\\ICONS\\inv_fishingchair")
MPA_NPCPosPanel.Sit.Icon:SetHighlightTexture("interface\\ICONS\\inv_fishingchair")
MPA_NPCPosPanel.Sit.Icon:SetAlpha(0.8)
MPA_NPCPosPanel.Sit.Icon:SetScript("OnClick", function()
    SendChatMessage(".npcsetstate 1");
end)
MPA_NPCPosPanel.Sit.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_NPCPosPanel.Sit.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_NPCPosPanel.Sit.Icon.Tooltip = "Сесть";

MPA_NPCPosPanel.GetUp = CreateFrame("Button", "MPA_NPCPosPanel.GetUp", MPA_NPCPosPanel, "MasterPanel:MiniIconButtonBG") -- // First button
MPA_NPCPosPanel.GetUp:SetPoint("CENTER", -90, 5)

MPA_NPCPosPanel.GetUp.Icon = CreateFrame("BUTTON", nil, MPA_NPCPosPanel.GetUp, "MasterPanel:MiniIconButtonTemplate");
MPA_NPCPosPanel.GetUp.Icon:SetNormalTexture("interface\\ICONS\\ability_warrior_charge")
MPA_NPCPosPanel.GetUp.Icon:SetHighlightTexture("interface\\ICONS\\ability_warrior_charge")
MPA_NPCPosPanel.GetUp.Icon:SetAlpha(0.8)
MPA_NPCPosPanel.GetUp.Icon:SetScript("OnClick", function()
    SendChatMessage(".npcsetstate 2");
end)
MPA_NPCPosPanel.GetUp.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_NPCPosPanel.GetUp.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_NPCPosPanel.GetUp.Icon.Tooltip = "Встать";

MPA_NPCPosPanel.SomeSleep = CreateFrame("Button", "MPA_NPCPosPanel.SomeSleep", MPA_NPCPosPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_NPCPosPanel.SomeSleep:SetPoint("CENTER", -50, 5)

MPA_NPCPosPanel.SomeSleep.Icon = CreateFrame("BUTTON", nil, MPA_NPCPosPanel.SomeSleep,
    "MasterPanel:MiniIconButtonTemplate");
MPA_NPCPosPanel.SomeSleep.Icon:SetNormalTexture("interface\\ICONS\\spell_nature_sleep")
MPA_NPCPosPanel.SomeSleep.Icon:SetHighlightTexture("interface\\ICONS\\spell_nature_sleep")
MPA_NPCPosPanel.SomeSleep.Icon:SetAlpha(0.8)
MPA_NPCPosPanel.SomeSleep.Icon:SetScript("OnClick", function()
    SendChatMessage(".npcsetstate 3");
end)
MPA_NPCPosPanel.SomeSleep.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_NPCPosPanel.SomeSleep.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_NPCPosPanel.SomeSleep.Icon.Tooltip = "Спать";

MPA_NPCPosPanel.LSit = CreateFrame("Button", "MPA_NPCPosPanel.LSit", MPA_NPCPosPanel, "MasterPanel:MiniIconButtonBG") -- // First button
MPA_NPCPosPanel.LSit:SetPoint("CENTER", -10, 5)

MPA_NPCPosPanel.LSit.Icon = CreateFrame("BUTTON", nil, MPA_NPCPosPanel.LSit, "MasterPanel:MiniIconButtonTemplate");
MPA_NPCPosPanel.LSit.Icon:SetNormalTexture("interface\\ICONS\\inv_bijou_yellow")
MPA_NPCPosPanel.LSit.Icon:SetHighlightTexture("interface\\ICONS\\inv_bijou_yellow")
MPA_NPCPosPanel.LSit.Icon:SetAlpha(0.8)
MPA_NPCPosPanel.LSit.Icon:SetScript("OnClick", function()
    SendChatMessage(".npcsetstate 4");
end)
MPA_NPCPosPanel.LSit.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_NPCPosPanel.LSit.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_NPCPosPanel.LSit.Icon.Tooltip = "Низкий стул";

MPA_NPCPosPanel.MSit = CreateFrame("Button", "MPA_NPCPosPanel.MSit", MPA_NPCPosPanel, "MasterPanel:MiniIconButtonBG") -- // First button
MPA_NPCPosPanel.MSit:SetPoint("CENTER", 30, 5)

MPA_NPCPosPanel.MSit.Icon = CreateFrame("BUTTON", nil, MPA_NPCPosPanel.MSit, "MasterPanel:MiniIconButtonTemplate");
MPA_NPCPosPanel.MSit.Icon:SetNormalTexture("interface\\ICONS\\inv_bijou_green")
MPA_NPCPosPanel.MSit.Icon:SetHighlightTexture("interface\\ICONS\\inv_bijou_green")
MPA_NPCPosPanel.MSit.Icon:SetAlpha(0.8)
MPA_NPCPosPanel.MSit.Icon:SetScript("OnClick", function()
    SendChatMessage(".npcsetstate 5");
end)
MPA_NPCPosPanel.MSit.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_NPCPosPanel.MSit.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_NPCPosPanel.MSit.Icon.Tooltip = "Средний стул";

MPA_NPCPosPanel.HSit = CreateFrame("Button", "MPA_NPCPosPanel.HSit", MPA_NPCPosPanel, "MasterPanel:MiniIconButtonBG") -- // First button
MPA_NPCPosPanel.HSit:SetPoint("CENTER", 70, 5)

MPA_NPCPosPanel.HSit.Icon = CreateFrame("BUTTON", nil, MPA_NPCPosPanel.HSit, "MasterPanel:MiniIconButtonTemplate");
MPA_NPCPosPanel.HSit.Icon:SetNormalTexture("interface\\ICONS\\inv_bijou_red")
MPA_NPCPosPanel.HSit.Icon:SetHighlightTexture("interface\\ICONS\\inv_bijou_red")
MPA_NPCPosPanel.HSit.Icon:SetAlpha(0.8)
MPA_NPCPosPanel.HSit.Icon:SetScript("OnClick", function()
    SendChatMessage(".npcsetstate 6");
end)
MPA_NPCPosPanel.HSit.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_NPCPosPanel.HSit.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_NPCPosPanel.HSit.Icon.Tooltip = "Высокий стул";

MPA_NPCPosPanel.Death = CreateFrame("Button", "MPA_NPCPosPanel.Death", MPA_NPCPosPanel, "MasterPanel:MiniIconButtonBG") -- // First button
MPA_NPCPosPanel.Death:SetPoint("CENTER", 110, 5)

MPA_NPCPosPanel.Death.Icon = CreateFrame("BUTTON", nil, MPA_NPCPosPanel.Death, "MasterPanel:MiniIconButtonTemplate");
MPA_NPCPosPanel.Death.Icon:SetNormalTexture("interface\\ICONS\\ability_rogue_feigndeath")
MPA_NPCPosPanel.Death.Icon:SetHighlightTexture("interface\\ICONS\\ability_rogue_feigndeath")
MPA_NPCPosPanel.Death.Icon:SetAlpha(0.8)
MPA_NPCPosPanel.Death.Icon:SetScript("OnClick", function()
    SendChatMessage(".npcsetstate 7");
end)
MPA_NPCPosPanel.Death.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_NPCPosPanel.Death.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_NPCPosPanel.Death.Icon.Tooltip = "Смерть";

MPA_NPCPosPanel.Knee = CreateFrame("Button", "MPA_NPCPosPanel.Knee", MPA_NPCPosPanel, "MasterPanel:MiniIconButtonBG") -- // First button
MPA_NPCPosPanel.Knee:SetPoint("CENTER", 110, -35)

MPA_NPCPosPanel.Knee.Icon = CreateFrame("BUTTON", nil, MPA_NPCPosPanel.Knee, "MasterPanel:MiniIconButtonTemplate");
MPA_NPCPosPanel.Knee.Icon:SetNormalTexture("interface\\ICONS\\inv_essenceofwintergrasp")
MPA_NPCPosPanel.Knee.Icon:SetHighlightTexture("interface\\ICONS\\inv_essenceofwintergrasp")
MPA_NPCPosPanel.Knee.Icon:SetAlpha(0.8)
MPA_NPCPosPanel.Knee.Icon:SetScript("OnClick", function()
    SendChatMessage(".npcsetstate 8");
end)
MPA_NPCPosPanel.Knee.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_NPCPosPanel.Knee.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_NPCPosPanel.Knee.Icon.Tooltip = "Колени";

MPA_NPCPosPanel.TurnWeapon = CreateFrame("Button", "MPA_NPCPosPanel.TurnWeapon", MPA_NPCPosPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_NPCPosPanel.TurnWeapon:SetPoint("CENTER", -130, -35)

MPA_NPCPosPanel.TurnWeapon.Icon = CreateFrame("BUTTON", nil, MPA_NPCPosPanel.TurnWeapon,
    "MasterPanel:MiniIconButtonTemplate");
MPA_NPCPosPanel.TurnWeapon.Icon:SetNormalTexture("interface\\ICONS\\inv_sword_24")
MPA_NPCPosPanel.TurnWeapon.Icon:SetHighlightTexture("interface\\ICONS\\inv_sword_24")
MPA_NPCPosPanel.TurnWeapon.Icon:SetAlpha(0.8)
MPA_NPCPosPanel.TurnWeapon.Icon:SetScript("OnClick", function()
    if WeaponOn == true then
        SendChatMessage(".weapon 0");
        WeaponOn = false;
    else
        SendChatMessage(".weapon 1");
        WeaponOn = true;
    end
end)
MPA_NPCPosPanel.TurnWeapon.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_NPCPosPanel.TurnWeapon.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_NPCPosPanel.TurnWeapon.Icon.Tooltip = "Оружие в руках/нет";

MPA_NPCPosPanel.SavePos = CreateFrame("Button", "MPA_NPCPosPanel.SavePos", MPA_NPCPosPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_NPCPosPanel.SavePos:SetPoint("CENTER", -90, -35)

MPA_NPCPosPanel.SavePos.Icon = CreateFrame("BUTTON", nil, MPA_NPCPosPanel.SavePos, "MasterPanel:MiniIconButtonTemplate");
MPA_NPCPosPanel.SavePos.Icon:SetNormalTexture("interface\\ICONS\\inv_misc_rune_01")
MPA_NPCPosPanel.SavePos.Icon:SetHighlightTexture("interface\\ICONS\\inv_misc_rune_01")
MPA_NPCPosPanel.SavePos.Icon:SetAlpha(0.8)
MPA_NPCPosPanel.SavePos.Icon:SetScript("OnClick", function()
    SendChatMessage(".npcsave");
end)
MPA_NPCPosPanel.SavePos.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_NPCPosPanel.SavePos.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_NPCPosPanel.SavePos.Icon.Tooltip = "Сохранить анимацию";

MPA_NPCPosPanel.Ground =
    CreateFrame("Button", "MPA_NPCPosPanel.Ground", MPA_NPCPosPanel, "MasterPanel:MiniIconButtonBG") -- // First button
MPA_NPCPosPanel.Ground:SetPoint("CENTER", 70, -35)

MPA_NPCPosPanel.Ground.Icon = CreateFrame("BUTTON", nil, MPA_NPCPosPanel.Ground, "MasterPanel:MiniIconButtonTemplate");
MPA_NPCPosPanel.Ground.Icon:SetNormalTexture("interface\\ICONS\\spell_holy_harmundeadaura")
MPA_NPCPosPanel.Ground.Icon:SetHighlightTexture("interface\\ICONS\\spell_holy_harmundeadaura")
MPA_NPCPosPanel.Ground.Icon:SetAlpha(0.8)
MPA_NPCPosPanel.Ground.Icon:SetScript("OnClick", function()
    SendChatMessage(".npcsetstate 9");
end)
MPA_NPCPosPanel.Ground.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_NPCPosPanel.Ground.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_NPCPosPanel.Ground.Icon.Tooltip = "Под землю (вурдалаки/нерубы)";

-----------------------------------------------------------------------------------------------------------------------------------------------------
--------/// NPCPosPanel END
-----------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------
--------/// Control Panel
-----------------------------------------------------------------------------------------------------------------------------------------------------

local MPA_ControlPanel = CreateFrame("Frame", "MPA_ControlPanel", MPA_MainPanel)
MPA_ControlPanel:SetSize(318.94, 120.25)
MPA_ControlPanel:SetAllPoints(MPA_MainPanel)
MPA_ControlPanel:Hide()

MPA_ControlPanel.EmoteST = CreateFrame("Button", "MPA_ControlPanel.EmoteST", MPA_ControlPanel,
    "MasterPanel:MiniIconButtonBG")
MPA_ControlPanel.EmoteST:SetPoint("CENTER", 80, 5)

MPA_ControlPanel.EmoteST.Icon = CreateFrame("BUTTON", nil, MPA_ControlPanel.EmoteST,
    "MasterPanel:MiniIconButtonTemplate");
MPA_ControlPanel.EmoteST.Icon:SetNormalTexture("interface\\ICONS\\achievement_bg_tophealer_ab")
MPA_ControlPanel.EmoteST.Icon:SetHighlightTexture("interface\\ICONS\\achievement_bg_tophealer_ab")
MPA_ControlPanel.EmoteST.Icon:SetAlpha(0.8)
MPA_ControlPanel.EmoteST.Icon:SetScript("OnClick", function()
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "NPCPLAYEMOTESTATEMENT";
    MPA_MainPanel.Title:SetText("Проиграть эмоцию NPC")
    MasterPanel:OpenMainEditbox();
end)
MPA_ControlPanel.EmoteST.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_ControlPanel.EmoteST.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_ControlPanel.EmoteST.Icon.Tooltip = "Проиграть эмоцию NPC";

MPA_ControlPanel.EmoteStatement = CreateFrame("Button", "MPA_ControlPanel.EmoteStatement", MPA_ControlPanel,
    "MasterPanel:MiniIconButtonBG")
MPA_ControlPanel.EmoteStatement:SetPoint("CENTER", 120, 5)

MPA_ControlPanel.EmoteStatement.Icon = CreateFrame("BUTTON", nil, MPA_ControlPanel.EmoteStatement,
    "MasterPanel:MiniIconButtonTemplate");
MPA_ControlPanel.EmoteStatement.Icon:SetNormalTexture("interface\\ICONS\\spell_arcane_mindmastery")
MPA_ControlPanel.EmoteStatement.Icon:SetHighlightTexture("interface\\ICONS\\spell_arcane_mindmastery")
MPA_ControlPanel.EmoteStatement.Icon:SetAlpha(0.8)
MPA_ControlPanel.EmoteStatement.Icon:SetScript("OnClick", function()
    MasterPanel:NPCPos_ShowAll()
end)
MPA_ControlPanel.EmoteStatement.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_ControlPanel.EmoteStatement.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_ControlPanel.EmoteStatement.Icon.Tooltip = "Позиция NPC";

MPA_ControlPanel.Army = CreateFrame("Button", "MPA_ControlPanel.Army", MPA_ControlPanel, "MasterPanel:MiniIconButtonBG")
MPA_ControlPanel.Army:SetPoint("CENTER", 120, -35)

MPA_ControlPanel.Army.Icon = CreateFrame("BUTTON", nil, MPA_ControlPanel.Army, "MasterPanel:MiniIconButtonTemplate");
MPA_ControlPanel.Army.Icon:SetNormalTexture("interface\\ICONS\\achievement_guildperk_everybodysfriend")
MPA_ControlPanel.Army.Icon:SetHighlightTexture("interface\\ICONS\\achievement_guildperk_everybodysfriend")
MPA_ControlPanel.Army.Icon:SetAlpha(0.8)
MPA_ControlPanel.Army.Icon:SetScript("OnClick", function()
    if not UnitAura("player", "Режим управления NPC") then
        SendChatMessage(".npccontrol", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
    else
        CancelUnitBuff("player", "Режим управления NPC")
    end
end)
MPA_ControlPanel.Army.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_ControlPanel.Army.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_ControlPanel.Army.Icon.Tooltip = "Контроль армией";

MPA_ControlPanel.RollButton = CreateFrame("BUTTON", "MPA_ControlPanel.RollButton", MPA_ControlPanel,
    "MasterPanel:BattleButtonTemplate");
MPA_ControlPanel.RollButton:SetPoint("CENTER", MPA_MainPanel, "CENTER", 5, 0)
MPA_ControlPanel.RollButton.Tooltip = "Панель боёвки";
MPA_ControlPanel.RollButton.AddLine = "Клавиша " .. colorCode ..
                                          "ЛКМ|r чтобы открыть/закрыть окно боевки;|nКлавиша " ..
                                          colorCode ..
                                          "ПКМ|r чтобы открыть/закрыть окно баффов и дебаффов;|nНажмите " ..
                                          colorCode ..
                                          "СКМ|r чтобы заблокировать/разблокировать передвижение панели боевки. При блокировании, панель автоматически переместится к окну аддона.";
MPA_ControlPanel.RollButton:SetScript("OnEnter", GameTooltipOnEnter);
MPA_ControlPanel.RollButton:SetScript("OnLeave", GameTooltipOnLeave);
MPA_ControlPanel.RollButton:SetScript("OnClick", function(self, click_button)
    MPA_BattlePanel:SetScale(0.85);
    StateFrame:SetScale(0.85);
    if click_button == "MiddleButton" then
        FramePosses()
    elseif click_button == "RightButton" then
        if StateFrame:IsVisible() then
            StateFrame:Hide()
        else
            StateFrame:Show()
        end
    else
        if MPA_BattlePanel:IsVisible() then
            MPA_BattlePanel:Hide()
        else
            MPA_BattlePanel:Show()
        end
    end
end)

MPA_ControlPanel.Summon = CreateFrame("Button", "MPA_ControlPanel.Summon", MPA_ControlPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_ControlPanel.Summon:SetPoint("CENTER", -30, -35)

MPA_ControlPanel.Summon.Icon = CreateFrame("BUTTON", nil, MPA_ControlPanel.Summon, "MasterPanel:MiniIconButtonTemplate");
MPA_ControlPanel.Summon.Icon:SetNormalTexture("interface\\ICONS\\spell_arcane_portalstormwind")
MPA_ControlPanel.Summon.Icon:SetHighlightTexture("interface\\ICONS\\spell_arcane_portalstormwind")
MPA_ControlPanel.Summon.Icon:SetAlpha(0.8)
MPA_ControlPanel.Summon.Icon:SetScript("OnClick", function()
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "SUMMONSTATEMENT";
    MPA_MainPanel.Title:SetText("Суммон игрока")
    MasterPanel:OpenMainEditbox();
end)
MPA_ControlPanel.Summon.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_ControlPanel.Summon.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_ControlPanel.Summon.Icon.Tooltip = "Суммон игрока или NPC";
MPA_ControlPanel.Summon.Icon.AddLine =
    "Суммон выбранной цели (игрока или npc). Если таргета нет - суммон по нику.|nЕсли ввести цифру " ..
        colorCode .. "1|r или слова " .. colorCode .. "рейд|r, " .. colorCode ..
        "all|r - будет суммон ко всему рейду.";

-- Raid summon

MPA_ControlPanel.RaidSum = CreateFrame("Button", "MPA_ControlPanel.RaidSum", MPA_ControlPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_ControlPanel.RaidSum:SetPoint("CENTER", 5, -35)

MPA_ControlPanel.RaidSum.Icon = CreateFrame("BUTTON", nil, MPA_ControlPanel.RaidSum,
    "MasterPanel:MiniIconButtonTemplate");
MPA_ControlPanel.RaidSum.Icon:SetNormalTexture("interface\\ICONS\\ability_seal")
MPA_ControlPanel.RaidSum.Icon:SetHighlightTexture("interface\\ICONS\\ability_seal")
MPA_ControlPanel.RaidSum.Icon:SetAlpha(0.8)
MPA_ControlPanel.RaidSum.Icon:SetScript("OnClick", function()
    MasterPanel:RaidSumm();
end)
MPA_ControlPanel.RaidSum.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_ControlPanel.RaidSum.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_ControlPanel.RaidSum.Icon.Tooltip = "Суммон рейда";

-- Raid summon end

-- To Player

MPA_ControlPanel.ToPlayer = CreateFrame("Button", "MPA_ControlPanel.ToPlayer", MPA_ControlPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_ControlPanel.ToPlayer:SetPoint("CENTER", 40, -35)

MPA_ControlPanel.ToPlayer.Icon = CreateFrame("BUTTON", nil, MPA_ControlPanel.ToPlayer,
    "MasterPanel:MiniIconButtonTemplate");
MPA_ControlPanel.ToPlayer.Icon:SetNormalTexture("interface\\ICONS\\ability_mount_rocketmount")
MPA_ControlPanel.ToPlayer.Icon:SetHighlightTexture("interface\\ICONS\\ability_mount_rocketmount")
MPA_ControlPanel.ToPlayer.Icon:SetAlpha(0.8)
MPA_ControlPanel.ToPlayer.Icon:SetScript("OnClick", function()
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "TOPLAYERSTATEMENT";
    MPA_MainPanel.Title:SetText("Введите ник игрока")
    MasterPanel:OpenMainEditbox();
end)
MPA_ControlPanel.ToPlayer.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_ControlPanel.ToPlayer.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_ControlPanel.ToPlayer.Icon.Tooltip = "Телепорт к игроку";

-- To Player end

-- NPCEquipment

MPA_ControlPanel.NPCEquipment = CreateFrame("Button", "MPA_ControlPanel.NPCEquipment", MPA_ControlPanel,
    "MasterPanel:MiniIconButtonBG") -- // First button
MPA_ControlPanel.NPCEquipment:SetPoint("CENTER", 80, -35)

MPA_ControlPanel.NPCEquipment.Icon = CreateFrame("BUTTON", nil, MPA_ControlPanel.NPCEquipment,
    "MasterPanel:MiniIconButtonTemplate");
MPA_ControlPanel.NPCEquipment.Icon:SetNormalTexture("interface\\ICONS\\inv_sword_draenei_05")
MPA_ControlPanel.NPCEquipment.Icon:SetHighlightTexture("interface\\ICONS\\inv_sword_draenei_05")
MPA_ControlPanel.NPCEquipment.Icon:SetAlpha(0.8)
MPA_ControlPanel.NPCEquipment.Icon:SetScript("OnClick", function()
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "NPCEQUIPMENTSTATEMENT";
    MPA_MainPanel.Title:SetText("Введите оружие NPC: a b c")
    MasterPanel:OpenMainEditbox();
end)
MPA_ControlPanel.NPCEquipment.Icon:SetScript("OnEnter", GameTooltipOnEnter);
MPA_ControlPanel.NPCEquipment.Icon:SetScript("OnLeave", GameTooltipOnLeave);
MPA_ControlPanel.NPCEquipment.Icon.Tooltip = "Вооружение NPC";

-- NPCEquipment end

MPA_ControlPanel.PossUnposs = CreateFrame("BUTTON", "MPA_ControlPanel.PossUnposs", MPA_ControlPanel,
    "MasterPanel:PossUnpossButton");
MPA_ControlPanel.PossUnposs:SetPoint("CENTER", MPA_MainPanel, "CENTER", -100, -35)
MPA_ControlPanel.PossUnposs.Tooltip = "Poss / Unposs";
MPA_ControlPanel.PossUnposs:SetScript("OnEnter", GameTooltipOnEnter);
MPA_ControlPanel.PossUnposs:SetScript("OnLeave", GameTooltipOnLeave);
MPA_ControlPanel.PossUnposs:SetScript("OnClick", function(self)
    if UnitExists("pet") and not isNPCtarget() then
        PetAbandon();
    elseif GetUnitName("target") == LastPossName then
        PetAbandon();
        LastPossName = nil
        return
    else
        if isNPCtarget() then
            PetAbandon();
            LastPossName = GetUnitName("target")
            SendChatMessage(".pos", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
        else
            print("|cffff9716[ГМ-аддон]: Возьмите в цель NPC.|r")
        end
    end
end)

MPA_ControlPanel.Waypoint = CreateFrame("BUTTON", "MPA_ControlPanel.Waypoint", MPA_ControlPanel,
    "MasterPanel:WaypointButtonTemplate");
MPA_ControlPanel.Waypoint:SetPoint("CENTER", MPA_MainPanel, "CENTER", -100, 0)
MPA_ControlPanel.Waypoint.Tooltip = "Waypoints";
MPA_ControlPanel.Waypoint.AddLine = "Позволяет настраивать маршруты для NPC.|n" ..
                                        colorCode .. ".taxi create|r - новый полет;|n" .. colorCode ..
                                        ".taxi add ID|r - добавить точку полета;|n" .. colorCode ..
                                        ".taxi save ID IdNpc|r - сохранить полет на NPC;|n" .. colorCode ..
                                        ".taxi go|r - отправить игрока в полет (он должен быть рядом с начальной точкой).";
MPA_ControlPanel.Waypoint:SetScript("OnEnter", GameTooltipOnEnter);
MPA_ControlPanel.Waypoint:SetScript("OnLeave", GameTooltipOnLeave);
MPA_ControlPanel.Waypoint:SetScript("OnClick", function(self)
    if MPA_WaypointPanel:IsVisible() then
        MPA_WaypointPanel:Hide()
    else
        MPA_WaypointPanel:Show()
    end
end)
-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                            Settings Frame                               ]]
-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
local SettingsFrame = CreateFrame("Frame", "SettingsFrame", MPA_MainPanel)
SettingsFrame:Hide()
SettingsFrame:SetWidth(300)
SettingsFrame:SetHeight(250)
SettingsFrame:SetPoint("BOTTOM", MPA_MainPanel, "TOP", 0, 10)
SettingsFrame:EnableMouse()
SettingsFrame:SetFrameStrata("FULLSCREEN")

SettingsFrame.Texture = SettingsFrame:CreateTexture("ARTWORK")
SettingsFrame.Texture:SetTexture("Interface\\AddOns\\MasterPanel\\IMG\\DopPanels.blp")
SettingsFrame.Texture:SetAllPoints(SettingsFrame)
SettingsFrame.Texture:SetTexCoord(0, 0, 0, 0.553, 0.782, 0, 0.782, 0.553);

SettingsFrame.CloseButton = CreateFrame("BUTTON", "SettingsFrame.CloseButton", SettingsFrame,
    "MasterPanel:CloseButtonTemplate");
SettingsFrame.CloseButton:SetSize(23, 23)
SettingsFrame.CloseButton:SetAlpha(.9)
SettingsFrame.CloseButton:SetPoint("TOPRIGHT", SettingsFrame, "TOPRIGHT", 0, 0)
SettingsFrame.CloseButton:RegisterForClicks("AnyUp")
SettingsFrame.CloseButton:SetScript("OnClick", function(self)
    SettingsFrame:Hide()
end)

SettingsFrame.Title = SettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
SettingsFrame.Title:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 25, -25)
SettingsFrame.Title:SetText("Настройки")

SettingsFrame.NPCSay =
    CreateFrame("CheckButton", "SettingsFrame_NPCSay", SettingsFrame, "ChatConfigCheckButtonTemplate");
SettingsFrame.NPCSay:SetPoint("TOPLEFT", SettingsFrame.Title, "BOTTOMLEFT", 0, -10);
SettingsFrame_NPCSayText:SetText("Альтернативный NPC SAY");
SettingsFrame.NPCSay.tooltip = "Переключение в режим NPC SAY одной строки.";
SettingsFrame.NPCSay:SetScript("OnClick", function()
    MasterPanel.db.profile.settings.NPCSayByEmote = not MasterPanel.db.profile.settings.NPCSayByEmote
    if MasterPanel.db.profile.settings.NPCSayByEmote then
        SettingsFrame.NPCSay:SetChecked(true)
    else
        SettingsFrame.NPCSay:SetChecked(false)
    end
end);

SettingsFrame.AddName = CreateFrame("CheckButton", "SettingsFrame_AddName", SettingsFrame,
    "ChatConfigCheckButtonTemplate");
SettingsFrame.AddName:SetPoint("TOPLEFT", SettingsFrame.NPCSay, "BOTTOMLEFT", 0, 0);
SettingsFrame_AddNameText:SetText("Авто-добавление имени NPC");
SettingsFrame.AddName.tooltip = "Авто-добавление имени NPC к эмоции.";
SettingsFrame.AddName:SetScript("OnClick", function()
    MasterPanel.db.profile.settings.AddNameToEmote = not MasterPanel.db.profile.settings.AddNameToEmote
    if MasterPanel.db.profile.settings.AddNameToEmote then
        SettingsFrame.AddName:SetChecked(true)
    else
        SettingsFrame.AddName:SetChecked(false)
    end
end);

SettingsFrame.SaveFocusEditbox = CreateFrame("CheckButton", "SettingsFrame_SaveFocusEditbox", SettingsFrame,
    "ChatConfigCheckButtonTemplate");
SettingsFrame.SaveFocusEditbox:SetPoint("TOPLEFT", SettingsFrame.AddName, "BOTTOMLEFT", 0, 0);
SettingsFrame_SaveFocusEditboxText:SetText("Сохранение окна ввода");
SettingsFrame.SaveFocusEditbox.tooltip =
    "Сохранять фокус в окне редактирования после ввода.";
SettingsFrame.SaveFocusEditbox:SetScript("OnClick", function()
    MasterPanel.db.profile.settings.SaveFocus = not MasterPanel.db.profile.settings.SaveFocus
    if MasterPanel.db.profile.settings.SaveFocus then
        SettingsFrame.SaveFocusEditbox:SetChecked(true)
    else
        SettingsFrame.SaveFocusEditbox:SetChecked(false)
    end
end);

SettingsFrame.NPCTalkAnimation = CreateFrame("CheckButton", "SettingsFrame_NPCSay", SettingsFrame.SaveFocusEditbox,
    "ChatConfigCheckButtonTemplate");
SettingsFrame.NPCTalkAnimation:SetPoint("TOPLEFT", SettingsFrame.SaveFocusEditbox, "BOTTOMLEFT", 0, 0);
SettingsFrame.NPCTalkAnimation.tooltip = "Переключение в режим NPC SAY одной строки.";
SettingsFrame.NPCTalkAnimation:SetScript("OnClick", function()
    MasterPanel.db.profile.settings.NPCTalkAnimation = not MasterPanel.db.profile.settings.NPCTalkAnimation
    print("NPCTalkAnimation is now:", MasterPanel.db.profile.settings.NPCTalkAnimation)
    if MasterPanel.db.profile.settings.NPCTalkAnimation == true then
        SettingsFrame.NPCTalkAnimation:SetChecked(true)
    else
        SettingsFrame.NPCTalkAnimation:SetChecked(false)
    end
end);
SettingsFrame.NPCTalkAnimation.label = SettingsFrame.NPCTalkAnimation:CreateFontString(nil, "ARTWORK",
    "GameFontHighlight")
SettingsFrame.NPCTalkAnimation.label:SetPoint("LEFT", SettingsFrame.NPCTalkAnimation, "RIGHT", 0, 0)
SettingsFrame.NPCTalkAnimation.label:SetText("Включить NPC Talk Animation")



SettingsFrame.RollStateEditBox = CreateFrame("EditBox", "SettingsFrame.RollStateEditBox", SettingsFrame, "InputBoxTemplate")
SettingsFrame.RollStateEditBox:SetPoint("TOPLEFT", SettingsFrame.NPCTalkAnimation, "BOTTOMLEFT", 5, -20)
SettingsFrame.RollStateEditBox:SetSize(32, 16)
SettingsFrame.RollStateEditBox:SetAltArrowKeyMode(false)
SettingsFrame.RollStateEditBox:SetAutoFocus(false)
SettingsFrame.RollStateEditBox:SetFontObject(GameFontHighlight)
SettingsFrame.RollStateEditBox:SetMaxLetters(3)
SettingsFrame.RollStateEditBox:SetNumeric(true)
-- SettingsFrame.RollStateEditBox:SetNumber(0)
SettingsFrame.RollStateEditBox:SetScript('OnEnterPressed', function(self)
    self:ClearFocus()
    MasterPanel.db.profile.settings.RollStatic = tonumber(self:GetText())
end)
SettingsFrame.RollStateEditBox:SetScript('OnEditFocusLost', function(self, elapsed)
    self:ClearFocus()
    MasterPanel.db.profile.settings.RollStatic = tonumber(self:GetText())
end)

SettingsFrame.RollOneShotEditBox = CreateFrame("EditBox", "SettingsFrame.RollOneShotEditBox",
    SettingsFrame.RollStateEditBox, "InputBoxTemplate")
SettingsFrame.RollOneShotEditBox:SetPoint("LEFT", SettingsFrame.RollStateEditBox, "RIGHT", 10, 0)
SettingsFrame.RollOneShotEditBox:SetSize(32, 16)
SettingsFrame.RollOneShotEditBox:SetAltArrowKeyMode(false)
SettingsFrame.RollOneShotEditBox:SetAutoFocus(false)
SettingsFrame.RollOneShotEditBox:SetFontObject(GameFontHighlight)
SettingsFrame.RollOneShotEditBox:SetMaxLetters(3)
SettingsFrame.RollOneShotEditBox:SetNumeric(true)
-- SettingsFrame.RollOneShotEditBox:SetNumber(0)
SettingsFrame.RollOneShotEditBox:SetScript('OnEnterPressed', function(self)
    self:ClearFocus()
    MasterPanel.db.profile.settings.RollOneShot = tonumber(self:GetText())
end)
SettingsFrame.RollOneShotEditBox:SetScript('OnEditFocusLost', function(self, elapsed)
    self:ClearFocus()
    MasterPanel.db.profile.settings.RollOneShot = tonumber(self:GetText())
end)

SettingsFrame.RollStateEditBox.Text = SettingsFrame.RollStateEditBox:CreateFontString(nil, "OVERLAY",
    "GameFontHighlight")
SettingsFrame.RollStateEditBox.Text:SetPoint("LEFT", SettingsFrame.RollOneShotEditBox, "RIGHT", 5, 0)
SettingsFrame.RollStateEditBox.Text:SetFontObject(GameFontHighlight)
SettingsFrame.RollStateEditBox.Text:SetText("Эмоции NPC-Roll")

SettingsFrame.RollStateEditBox.Static = SettingsFrame.RollStateEditBox:CreateFontString(nil, "OVERLAY",
    "GameFontHighlight")
SettingsFrame.RollStateEditBox.Static:SetPoint("CENTER", SettingsFrame.RollStateEditBox, "CENTER", -4, 15)
SettingsFrame.RollStateEditBox.Static:SetFontObject(GameFontHighlightSmall)
SettingsFrame.RollStateEditBox.Static:SetText("Static")

SettingsFrame.RollOneShotEditBox.OneShot = SettingsFrame.RollOneShotEditBox:CreateFontString(nil, "OVERLAY",
    "GameFontHighlight")
SettingsFrame.RollOneShotEditBox.OneShot:SetPoint("CENTER", SettingsFrame.RollOneShotEditBox, "CENTER", -2, 15)
SettingsFrame.RollOneShotEditBox.OneShot:SetFontObject(GameFontHighlightSmall)
SettingsFrame.RollOneShotEditBox.OneShot:SetText("OneShot")

SettingsFrame.RadiusSlider = CreateFrame("Slider", "MPA_RadiusSlider", SettingsFrame.RollStateEditBox, "OptionsSliderTemplate")
SettingsFrame.RadiusSlider:ClearAllPoints()
SettingsFrame.RadiusSlider:SetPoint("TOPLEFT", SettingsFrame.RollStateEditBox, "TOPLEFT", 0, -35)
SettingsFrame.RadiusSlider:SetWidth(150)
SettingsFrame.RadiusSlider.tooltipText = "Регулирует радиус вещания ColorChat и TalkingHead."
SettingsFrame.RadiusSlider:SetMinMaxValues(0, 89)
SettingsFrame.RadiusSlider:SetValueStep(10)
getglobal(SettingsFrame.RadiusSlider:GetName() .. 'Low'):SetText('Группа');
getglobal(SettingsFrame.RadiusSlider:GetName() .. 'High'):SetText('89');
getglobal(SettingsFrame.RadiusSlider:GetName() .. 'Text'):SetText(SettingsFrame.RadiusSlider:GetValue());
SettingsFrame.RadiusSlider:SetScript("OnValueChanged", function(self)
    local SliderValue = self:GetValue()
    if SliderValue == 0 then
        getglobal(SettingsFrame.RadiusSlider:GetName() .. 'Text'):SetText("Группа / рейд");
    else
        getglobal(SettingsFrame.RadiusSlider:GetName() .. 'Text'):SetText(
            SettingsFrame.RadiusSlider:GetValue() .. " ярдов от Вас.");
    end
    MasterPanel.db.profile.settings.ChatRadius = tonumber(SliderValue)
end)


-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                            Frames closer                                ]]
-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
function MasterPanel:HideAllFrames()
    MPA_EditPanel.EditBox:SetTextColor(1, 1, 1, 1.0);

    MPA_NPCPanel:Hide()
    MPA_EditPanel:Hide()
    MPA_SelectPanel:Hide()
    MPA_SearchAndDelPanel:Hide()
    MPA_AurasAndStatesPanel:Hide()
    MPA_ControlPanel:Hide()
    MPA_SetTimeAndWeatherPanel:Hide()
    MPA_NPCPosPanel:Hide()
end

function MasterPanel:OpenMainEditbox()
    MasterPanel:HideAllFrames()
    MPA_EditPanel:Show()
    MPA_EditPanel.EditBox:SetFocus()
end

function MasterPanel:ReturnToMain()
    MasterPanel:HideAllFrames()
    MPA_MainPanel.Title:SetText("Главное меню")
    MPA_SelectPanel:Show()
end

function MasterPanel:NPCPanel_ShowAll()
    MasterPanel:HideAllFrames()
    MPA_MainPanel.Title:SetText("Инструменты чата")
    MPA_NPCPanel:Show()
end

function MasterPanel:SearchAndDel_ShowAll()
    MasterPanel:HideAllFrames()
    MPA_MainPanel.Title:SetText("Поиск и удаление")
    MPA_SearchAndDelPanel:Show()
end

function MasterPanel:AurasAndStates_ShowAll()
    MasterPanel:HideAllFrames()
    MPA_MainPanel.Title:SetText("Ауры и состояния")
    MPA_AurasAndStatesPanel:Show()
end

function MasterPanel:ControlPanel_ShowAll()
    if booleanBattlePanel then
        FramePosses()
        booleanBattlePanel = false;
    end
    MasterPanel:HideAllFrames()
    MPA_MainPanel.Title:SetText("Контроль NPC")
    MPA_ControlPanel:Show()
end

function MasterPanel:SetTimeAndWeather_ShowAll()
    MasterPanel:HideAllFrames()
    MPA_MainPanel.Title:SetText("Время и погода")
    MPA_SetTimeAndWeatherPanel:Show()
end

function MasterPanel:NPCPos_ShowAll()
    MasterPanel:HideAllFrames()
    MPA_MainPanel.Title:SetText("Позиция NPC")
    MPA_NPCPosPanel:Show()
end
-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                            Binding Funcs                                ]]
-- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

function MasterPanel:ClearAllAuraBind()
    if (UnitExists("target")) then
        SendChatMessage(".cleartargetauras", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
    else
        print("|cffff9716[ГМ-аддон]: У Вас нет цели.|r")
    end
end

function MasterPanel:SettingsFrameOnOff()
    if SettingsFrame:IsVisible() then
        SettingsFrame:Hide()
    else
        SettingsFrame:Show()
    end
end

function MasterPanel:MinMapButtonFunc()
    if MPA_MainPanel:IsVisible() then
        MPA_MainPanel:Hide()
    else
        MPA_MainPanel:Show()
    end
end

function MasterPanel:ClearEditboxFunc()
    MPA_EditPanel.EditBox:SetText("")
end

function MasterPanel:AuraDeathFunc()
    if (UnitExists("target")) then
        SendChatMessage(".auraput 88053", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
    else
        print("|cffff9716[ГМ-аддон]: У Вас нет цели.|r")
    end
end

function MasterPanel:AuraLayFunc()
    if (UnitExists("target")) then
        SendChatMessage(".auraput 64393", "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
    else
        print("|cffff9716[ГМ-аддон]: У Вас нет цели.|r")
    end
end

function MasterPanel:SetDiffFunc()
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "SETDIFFSTATEMENT";
    MPA_MainPanel.Title:SetText("Модификатор SetDiff")
    MasterPanel:OpenMainEditbox();
end

function MasterPanel:SetDiffRaidFunc()
    MasterPanel:EditBoxCollectGarbage();
    EditboxStatement = "RAIDSETDIFFSTATEMENT";
    MPA_MainPanel.Title:SetText("Модификатор RaidSetDiff")
    MasterPanel:OpenMainEditbox();
end

function MasterPanel:RaidSumm()
    for Sum_d = 1, GetNumRaidMembers() do
        Sum_d_d = "raid" .. Sum_d
        Sum_name = UnitName(Sum_d_d)
        SendChatMessage(".sum " .. Sum_name, "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"));
    end
end
