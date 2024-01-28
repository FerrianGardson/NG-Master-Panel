--[[ 

 @    @@        @@@      &@     @@      @@  @@@@@@&        /@#    @@      @@   @
 @    @(@      @@@@     @@ @     %@    @@   @@     @@     /@ @/    ,@*   @@    @
 @    @ *@    @@ @@    @@   @      @@#@     @@      @&   ,@   @/     @@ @.     @
 @    @. .@  @@  @@   #@%%%%%@      @@      @@      @*   @%%%%%@*     @@       @
 @    @.   @@@   @@  (@      ,@     @@      @@    @@*  .@       @.    @@       @
 
--]]

local booleanPanelsIsBlock = false;

-- Тогглер главного окна
function BattlePanelToggle()
	if MPA_BattlePanel:IsShown() then
		MPA_BattlePanel:Hide()
	else
		MPA_BattlePanel:Show()
	end
end

-- Выставление стандартных значений
function DefaultValues()
	SetHPEditBox:SetText("3")
	DamHPEditBox:SetText("1")
	AddHPEditBox:SetText("1")
	SetWoundEditBox:SetText("1")

	SetAPEditBox:SetText("1")
	DamAPEditBox:SetText("1")
	AddAPEditBox:SetText("1")

	SetStrEditBox:SetText("0")
	SetAgilEditBox:SetText("0")
	SetIntEditBox:SetText("0")
	SetPhysResEditBox:SetText("0")
	SetMagResEditBox:SetText("0")

    SetFocusEditBox:SetText("100")
    DamFocusEditBox:SetText("1")
    AddFocusEditBox:SetText("1")

    SetEnergyEditBox:SetText("3")
    DamEnergyEditBox:SetText("1")
    AddEnergyEditBox:SetText("1")

    NDEditBox:SetText("1")
    BuffEditBox:SetText("1")
    DefaultEditBox:SetText("1")
    DebuffEditBox:SetText("1")
    WoundsEditBox:SetText("1")
    ActionsEditBox:SetText("1")
end

-- Закрытие основного окна
function CloseMainFrameBtn_OnMouseDown()
	MPA_BattlePanel:Hide()
end

-- Закрытие окна состояний
function CloseStateFrameBtn_OnMouseDown()
	StateFrame:Hide()
end

-- Тогглер окна дайсов
function OpenDiceFrameBtn_OnMouseDown()
	if DiceFrame:IsShown() then
        DiceFrame:Hide()
    else
        DiceFrame:Show()
    end
end

-- Тогглер окна состояний
function OpenStatesFrameBtn_OnMouseDown()
    if StateFrame:IsShown() then
        StateFrame:Hide()
    else
        StateFrame:Show()
    end
end

-- Проверка цели
local function isNPCtarget()
  return UnitIsPlayer("target") == nil and UnitExists("target") == 1
end

-- Переменная цели
local TargetNameToRoll = nil

-- Фокус
function LostFocus(self)
	self:ClearFocus()
end

-- [ОЗ/броня] --


-- Выставить ОЗ
function SetHPBtn_OnClick()
	if tonumber(SetHPEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".sethp " .. tonumber(SetHPEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Снять ОЗ
function DamHPBtn_OnClick()
	if tonumber(DamHPEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".damhp " .. tonumber(DamHPEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Добавить ОЗ
function AddHPBtn_OnClick()
	if tonumber(AddHPEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".addhp " .. tonumber(AddHPEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Добавить рану
function SetWoundBtn_OnClick()
	if tonumber(SetWoundEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".setwound " .. tonumber(SetWoundEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Выставить броню
function SetAPBtn_OnClick()
	if tonumber(SetAPEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".setarmor " .. tonumber(SetAPEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Снять броню
function DamAPBtn_OnClick()
	if tonumber(DamAPEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".removearmor " .. tonumber(DamAPEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Добавить броню
function AddAPBtn_OnClick()
	if tonumber(AddAPEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".addarmor " .. tonumber(AddAPEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Убрать ОЗ
function WakeUpBtn_OnClick()
	SendChatMessage(".wakeup" ,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end


-- [Основные характеристики] --


-- Сила
function SetStrBtn_OnClick()
	if tonumber(SetStrEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".npcsetstat 1 " .. tonumber(SetStrEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Ловкость
function SetAgilBtn_OnClick()
	if tonumber(SetAgilEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".npcsetstat 2 " .. tonumber(SetAgilEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Интеллект
function SetIntBtn_OnClick()
	if tonumber(SetIntEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".npcsetstat 3 " .. tonumber(SetIntEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Физическая защита
function SetPhysResBtn_OnClick()
	if tonumber(SetPhysResEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".npcsetstat 5 " .. tonumber(SetPhysResEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Магическая защита
function SetMagResBtn_OnClick()
	if tonumber(SetMagResEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".npcsetstat 6 " .. tonumber(SetMagResEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end


-- [Второстепенные кнопки] --


-- Проверить
function CheckStatsBtn_OnClick()
	SendChatMessage(".checknpcstat ","WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Применить
function ApplyStatsBtn_OnClick()
	local strength = tonumber(SetStrEditBox:GetText()); if strength == nil then strength = 0 end
    local agility = tonumber(SetAgilEditBox:GetText()); if agility == nil then strength = 0 end
    local intellect = tonumber(SetIntEditBox:GetText()); if intellect == nil then strength = 0 end
    local physres = tonumber(SetPhysResEditBox:GetText()); if physres == nil then strength = 0 end
    local magres = tonumber(SetMagResEditBox:GetText()); if magres == nil then strength = 0 end
    local hpval = tonumber(SetHPEditBox:GetText()); if hpval == nil then hpval = 0 end
    local apval = tonumber(SetAPEditBox:GetText()); if apval == nil then hpval = 0 end

    SendChatMessage(".npcsetstat 1 " .. strength,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
    SendChatMessage(".npcsetstat 2 " .. agility,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
    SendChatMessage(".npcsetstat 3 " .. intellect,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
    SendChatMessage(".npcsetstat 5 " .. physres,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
    SendChatMessage(".npcsetstat 6 " .. magres,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
    SendChatMessage(".sethp " .. hpval,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
    SendChatMessage(".setarmor  " .. apval,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Применить в радиусе
function ApplyStatsByRadiusBtn_OnClick()
	local strength = tonumber(SetStrEditBox:GetText()); if strength == nil then strength = 0 end
    local agility = tonumber(SetAgilEditBox:GetText()); if agility == nil then strength = 0 end
    local intellect = tonumber(SetIntEditBox:GetText()); if intellect == nil then strength = 0 end
    local physres = tonumber(SetPhysResEditBox:GetText()); if physres == nil then strength = 0 end
    local magres = tonumber(SetMagResEditBox:GetText()); if magres == nil then strength = 0 end
    local hpval = tonumber(SetHPEditBox:GetText()); if hpval == nil then hpval = 0 end
    local apval = tonumber(SetAPEditBox:GetText()); if apval == nil then hpval = 0 end

    SendChatMessage(".npcsetstatradius " .. strength .. " " .. agility .. " " .. intellect .. " ".. 0  .." " .. physres .. " " .. magres .. " " .. hpval .. " " .. apval .. " ","WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end


-- [Дайсы] --


-- Бросить дайс силы
function StrDiceBtn_OnMouseDown()
	if isNPCtarget() then
        if TargetNameToRoll ~= nil then
            SendChatMessage(".npcroll " .. tostring(TargetNameToRoll) .. " 1" ,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
            NPCRollPlusEmote()
        else
            print("|cffff9716[ГМ-аддон]: Необходимо выбрать игрока для броска.|r")
        end
    else
        print("|cffff9716[ГМ-аддон]: Необходимо взять в цель НПС.|r")
    end
end

-- Бросить дайс ловкости
function AgilDiceBtn_OnMouseDown()
	if isNPCtarget() then
        if TargetNameToRoll ~= nil then
            SendChatMessage(".npcroll " .. tostring(TargetNameToRoll) .. " 2" ,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
            NPCRollPlusEmote()
        else
            print("|cffff9716[ГМ-аддон]: Необходимо выбрать игрока для броска.|r")
        end
    else
        print("|cffff9716[ГМ-аддон]: Необходимо взять в цель НПС.|r")
    end
end

-- Бросить дайс интеллекта
function IntDiceBtn_OnMouseDown()
	if isNPCtarget() then
        if TargetNameToRoll ~= nil then
            SendChatMessage(".npcroll " .. tostring(TargetNameToRoll) .. " 3" ,"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
            NPCRollPlusEmote()
        else
            print("|cffff9716[ГМ-аддон]: Необходимо выбрать игрока для броска.|r")
        end
    else
        print("|cffff9716[ГМ-аддон]: Необходимо взять в цель НПС.|r")
    end
end

-- Выбрать цель
function TargetDiceBtn_OnMouseDown()
    if isNPCtarget() then
        print("|cffff9716[ГМ-аддон]: Целью бросков должен быть игрок.|r")
    elseif not UnitExists("target") then
        print("|cffff9716[ГМ-аддон]: Целью бросков должен быть игрок.|r")
    else
        TargetNameToRoll = tostring(GetUnitName("target"))
        TargetNameLabel:SetText("Цель : " .. tostring(GetUnitName("target")))
        print("|cffff9716[ГМ-аддон]: Цель бросков - " .. tostring(GetUnitName("target")) .. ".|r")
    end
end


-- [Состояния персонажей] --


-- Выставить фокус
function SetFocusBtn_OnClick()
	if tonumber(SetFocusEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".setfocus " .. tonumber(SetFocusEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Снять фокус
function DamFocusBtn_OnClick()
	if tonumber(DamFocusEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".removefocus " .. tonumber(DamFocusEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Добавить фокус
function AddFocusBtn_OnClick()
	if tonumber(AddFocusEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".addfocus " .. tonumber(AddFocusEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Иные характеристики

NDDropDownMenu.items = {
    {text = "Физическая сила", value = "1"},
    {text = "Мастерство", value = "2"},
    {text = "Учёность", value = "3"},
    {text = "Мудрость", value = "4"},
    {text = "Атака", value = "5"},
    {text = "Защита", value = "6"},
    {text = "Дальний бой", value = "7"},
    {text = "Магия", value = "8"},
    {text = "Живучесть", value = "9"},
    {text = "Мана", value = "10"},
    {text = "Мощь", value = "11"},
    {text = "Незаметность", value = "12"},
    {text = "Удача", value = "13"},
}

function NDDropDownMenu_OnClick(self)
    UIDropDownMenu_SetSelectedID(NDDropDownMenu, self:GetID())
    NDDropDownMenu.selectedValue = self.value

    for i = 1, #NDDropDownMenu.items do
        local item = NDDropDownMenu.items[i]
        if item ~= self then
            item.checked = false
        end
    end
    NDDropDownMenu_OnDropDownClick(self.value)
end


    UIDropDownMenu_Initialize(NDDropDownMenu, function()
        for i, item in ipairs(NDDropDownMenu.items) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = item.text
            info.value = item.value
            info.func = NDDropDownMenu_OnClick
            UIDropDownMenu_AddButton(info)
        end
    end)

UIDropDownMenu_SetWidth(NDDropDownMenu, 110)
UIDropDownMenu_SetButtonWidth(NDDropDownMenu, 110)
UIDropDownMenu_JustifyText(NDDropDownMenu, "LEFT")
UIDropDownMenu_SetSelectedID(NDDropDownMenu, 0)

function NDApplyBtn_OnClick()
    local selectedValue = NDDropDownMenu.selectedValue
    if (NDEditBox:GetText() == "") then
	    print("|cffff9716[ГМ-аддон]: Значение не должно равняться нулю или быть пустым.|r")
    else
        SendChatMessage(".setaurastats " .. selectedValue .. " " .. tonumber(NDEditBox:GetText()), "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"))
	end
end

-- Усиления

BuffDropDownMenu.items = {
    {text = "Скорость", value = "1"},
    {text = "Атака", value = "2"},
    {text = "Защита", value = "3"},
    {text = "Дальний бой", value = "4"},
    {text = "Точность", value = "5"},
    {text = "Абсолютная неуязвимость", value = "6"},
    {text = "Неуязвимость (магия)", value = "7"},
    {text = "Неуязвимость (физич.)", value = "8"},
    {text = "Исступление", value = "9"},
}

function BuffDropDownMenu_OnClick(self)
    UIDropDownMenu_SetSelectedID(BuffDropDownMenu, self:GetID())
    BuffDropDownMenu.selectedValue = self.value

    for i = 1, #BuffDropDownMenu.items do
        local item = BuffDropDownMenu.items[i]
        if item ~= self then
            item.checked = false
        end
    end
    BuffDropDownMenu_OnDropDownClick(self.value)
end


UIDropDownMenu_Initialize(BuffDropDownMenu, function()
    for i, item in ipairs(BuffDropDownMenu.items) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = item.text
        info.value = item.value
        info.func = BuffDropDownMenu_OnClick
        UIDropDownMenu_AddButton(info)
    end
end)

UIDropDownMenu_SetWidth(BuffDropDownMenu, 110)
UIDropDownMenu_SetButtonWidth(BuffDropDownMenu, 110)
UIDropDownMenu_JustifyText(BuffDropDownMenu, "LEFT")
UIDropDownMenu_SetSelectedID(BuffDropDownMenu, 0)

function BuffApplyBtn_OnClick()
    local selectedValue = BuffDropDownMenu.selectedValue
    if (BuffEditBox:GetText() == "") then
	    print("|cffff9716[ГМ-аддон]: Значение не должно равняться нулю или быть пустым.|r")
    else
        SendChatMessage(".setbuff " .. selectedValue .. " " .. tonumber(BuffEditBox:GetText()), "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"))
	end
end

-- Действия

ActionsDropDownMenu.items = {
    {text = "Действие", value = "1"},
    {text = "Нейтрализация", value = "2"},
    {text = "Провокация", value = "3"},
    {text = "Подкрепление", value = "4"},
    {text = "Метка охотника", value = "5"},
}

function ActionsDropDownMenu_OnClick(self)
    UIDropDownMenu_SetSelectedID(ActionsDropDownMenu, self:GetID())
    ActionsDropDownMenu.selectedValue = self.value

    for i = 1, #ActionsDropDownMenu.items do
        local item = ActionsDropDownMenu.items[i]
        if item ~= self then
            item.checked = false
        end
    end
    ActionsDropDownMenu_OnDropDownClick(self.value)
end


UIDropDownMenu_Initialize(ActionsDropDownMenu, function()
    for i, item in ipairs(ActionsDropDownMenu.items) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = item.text
        info.value = item.value
        info.func = ActionsDropDownMenu_OnClick
        UIDropDownMenu_AddButton(info)
    end
end)

UIDropDownMenu_SetWidth(ActionsDropDownMenu, 110)
UIDropDownMenu_SetButtonWidth(ActionsDropDownMenu, 110)
UIDropDownMenu_JustifyText(ActionsDropDownMenu, "LEFT")
UIDropDownMenu_SetSelectedID(ActionsDropDownMenu, 0)

function ActionsApplyBtn_OnClick()
    local selectedValue = ActionsDropDownMenu.selectedValue
    if (ActionsEditBox:GetText() == "") then
	    print("|cffff9716[ГМ-аддон]: Значение не должно равняться нулю или быть пустым.|r")
    else
        SendChatMessage(".setactions " .. selectedValue .. " " .. tonumber(ActionsEditBox:GetText()), "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"))
	end
end

-- Стандартные

DefaultDropDownMenu.items = {
    {text = "Усталость", value = "1"},
    {text = "Контроль", value = "2"},
    {text = "Усиление", value = "3"},
    {text = "Периодический урон", value = "4"},
}

function DefaultDropDownMenu_OnClick(self)
    UIDropDownMenu_SetSelectedID(DefaultDropDownMenu, self:GetID())
    DefaultDropDownMenu.selectedValue = self.value

    for i = 1, #DefaultDropDownMenu.items do
        local item = DefaultDropDownMenu.items[i]
        if item ~= self then
            item.checked = false
        end
    end
    DefaultDropDownMenu_OnDropDownClick(self.value)
end


UIDropDownMenu_Initialize(DefaultDropDownMenu, function()
    for i, item in ipairs(DefaultDropDownMenu.items) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = item.text
        info.value = item.value
        info.func = DefaultDropDownMenu_OnClick
        UIDropDownMenu_AddButton(info)
    end
end)

UIDropDownMenu_SetWidth(DefaultDropDownMenu, 110)
UIDropDownMenu_SetButtonWidth(DefaultDropDownMenu, 110)
UIDropDownMenu_JustifyText(DefaultDropDownMenu, "LEFT")
UIDropDownMenu_SetSelectedID(DefaultDropDownMenu, 0)

function DefaultApplyBtn_OnClick()
    local selectedValue = DefaultDropDownMenu.selectedValue
    if (DefaultEditBox:GetText() == "") then
	    print("|cffff9716[ГМ-аддон]: Значение не должно равняться нулю или быть пустым.|r")
    else
        SendChatMessage(".setstatus " .. selectedValue .. " " .. tonumber(DefaultEditBox:GetText()), "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"))
	end
end

-- Негативные

DebuffDropDownMenu.items = {
    {text = "Холод", value = "1"},
    {text = "Жар", value = "2"},
    {text = "Сон", value = "3"},
    {text = "Оглушение", value = "4"},
    {text = "Обездвиживание", value = "5"},
    {text = "Замешательство", value = "6"},
    {text = "Безумие", value = "7"},
    {text = "Разрушение брони", value = "8"},
    {text = "Уязвимость к магии", value = "9"},
    {text = "Уязвимость к природе", value = "10"},
    {text = "Уязвимость ко тьме", value = "11"},
    {text = "Уязвимость к скверне", value = "12"},
    {text = "Уязвимость к огню", value = "13"},
    {text = "Уязвимость к ветру", value = "14"},
    {text = "Уязвимость к земле", value = "15"},
    {text = "Уязвимость к воде", value = "16"},
    {text = "Уязвимость ко льду", value = "17"},
    {text = "Уязвимость к крови", value = "18"},
    {text = "Уязвимость к молнии", value = "19"},
    {text = "Буян", value = "20"},
    {text = "Антимагия", value = "21"},
}

function DebuffDropDownMenu_OnClick(self)
    UIDropDownMenu_SetSelectedID(DebuffDropDownMenu, self:GetID())
    DebuffDropDownMenu.selectedValue = self.value

    for i = 1, #DebuffDropDownMenu.items do
        local item = DebuffDropDownMenu.items[i]
        if item ~= self then
            item.checked = false
        end
    end
    DebuffDropDownMenu_OnDropDownClick(self.value)
end


UIDropDownMenu_Initialize(DebuffDropDownMenu, function()
    for i, item in ipairs(DebuffDropDownMenu.items) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = item.text
        info.value = item.value
        info.func = DebuffDropDownMenu_OnClick
        UIDropDownMenu_AddButton(info)
    end
end)

UIDropDownMenu_SetWidth(DebuffDropDownMenu, 110)
UIDropDownMenu_SetButtonWidth(DebuffDropDownMenu, 110)
UIDropDownMenu_JustifyText(DebuffDropDownMenu, "LEFT")
UIDropDownMenu_SetSelectedID(DebuffDropDownMenu, 0)

function DebuffApplyBtn_OnClick()
    local selectedValue = DebuffDropDownMenu.selectedValue
    if (DebuffEditBox:GetText() == "") then
	    print("|cffff9716[ГМ-аддон]: Значение не должно равняться нулю или быть пустым.|r")
    else
        SendChatMessage(".setdebuff " .. selectedValue .. " " .. tonumber(DebuffEditBox:GetText()), "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"))
	end
end

-- Ранения

WoundsDropDownMenu.items = {
    {text = "Легкая рана", value = "1"},
    {text = "Тяжелая рана", value = "2"},
    {text = "Перелом руки", value = "3"},
    {text = "Перелом ноги", value = "4"},
    {text = "Перелом челюсти", value = "5"},
    {text = "Кровопотеря", value = "6"},
    {text = "Немота", value = "7"},
}

function WoundsDropDownMenu_OnClick(self)
    UIDropDownMenu_SetSelectedID(WoundsDropDownMenu, self:GetID())
    WoundsDropDownMenu.selectedValue = self.value

    for i = 1, #WoundsDropDownMenu.items do
        local item = WoundsDropDownMenu.items[i]
        if item ~= self then
            item.checked = false
        end
    end
    WoundsDropDownMenu_OnDropDownClick(self.value)
end


UIDropDownMenu_Initialize(WoundsDropDownMenu, function()
    for i, item in ipairs(WoundsDropDownMenu.items) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = item.text
        info.value = item.value
        info.func = WoundsDropDownMenu_OnClick
        UIDropDownMenu_AddButton(info)
    end
end)

UIDropDownMenu_SetWidth(WoundsDropDownMenu, 110)
UIDropDownMenu_SetButtonWidth(WoundsDropDownMenu, 110)
UIDropDownMenu_JustifyText(WoundsDropDownMenu, "LEFT")
UIDropDownMenu_SetSelectedID(WoundsDropDownMenu, 0)

function WoundsApplyBtn_OnClick()
    local selectedValue = WoundsDropDownMenu.selectedValue
    if (WoundsEditBox:GetText() == "") then
	    print("|cffff9716[ГМ-аддон]: Поле ввода не должно быть пустым.|r")
    else
        SendChatMessage(".setharm " .. selectedValue .. " " .. tonumber(WoundsEditBox:GetText()), "WHISPER", GetDefaultLanguage("player"), GetUnitName("player"))
	end
end

-- Выставить энергию
function SetEnergyBtn_OnClick()
	if tonumber(SetEnergyEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".seten " .. tonumber(SetEnergyEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Снять энергию
function DamEnergyBtn_OnClick()
	if tonumber(DamEnergyEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".damen " .. tonumber(DamEnergyEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Добавить энергию
function AddEnergyBtn_OnClick()
	if tonumber(AddEnergyEditBox:GetText()) == nil then print("|cffff9716[ГМ-аддон]: Необходимо ввести значение.|r") return end
    SendChatMessage(".adden " .. tonumber(AddEnergyEditBox:GetText()),"WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"))
end

-- Дебаг
function FramePosses()
	if booleanPanelsIsBlock then
		MPA_BattlePanel:SetMovable(true);
		StateFrame:SetMovable(true);
		booleanPanelsIsBlock = false;
	else
		MPA_BattlePanel:ClearAllPoints()
		MPA_BattlePanel:SetPoint("TOP", MPA_MainPanel, "TOP", 0, 295)
		MPA_BattlePanel:SetMovable(false);
		StateFrame:ClearAllPoints()
		StateFrame:SetPoint("TOP", MPA_MainPanel, "TOP", 0, 295)
		StateFrame:SetMovable(false);
		booleanPanelsIsBlock = true;
	end
end