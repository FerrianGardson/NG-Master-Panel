--[[local MPA_LDB = LibStub("LibDataBroker-1.1"):NewDataObject("MPA_Minimap", {
    type = "data source",
    text = "MPA_Minimap",
    icon = "Interface\\Icons\\inv_misc_dice_01",
    OnClick = function()
                MasterPanel:MinMapButtonFunc()
              end,
    OnEnter = function()
                GameTooltip:ClearLines()
                GameTooltip:SetOwner(LibDBIcon10_MPA_Minimap,"ANCHOR_TOP");
				GameTooltip:AddLine("MasterPanel Noblegarden")
				GameTooltip:AddLine("Нажмите для открытия меню")
				GameTooltip:Show()
              end,
    })

local MinimapIconButton = LibStub("LibDBIcon-1.0")

function MasterPanel:OnInitialize()
self.db = LibStub("AceDB-3.0"):New("MinMapDB", {
    profile = {
        minimap = {
            hide = false, }, }, })
MinimapIconButton:Register("MPA_Minimap", MPA_LDB, self.db.profile.minimap)
end]]

function MasterPanel:MinMapButtonOnOff()
self.db.profile.minimap.hide = not self.db.profile.minimap.hide
    if self.db.profile.minimap.hide then
		MinimapIconButton:Hide("MPA_Minimap")
	else
		MinimapIconButton:Show("MPA_Minimap")
	end
end

function MasterPanel:MinMapButtonOff()
    MinimapIconButton:Hide("MPA_Minimap")
end