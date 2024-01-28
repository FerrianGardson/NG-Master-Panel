
function MasterPanel:TargetDeleteNPC()
    if UnitIsPlayer("target") or UnitName("target") == nil then
        print("|cffff9716[ГМ-аддон]: Возьмите в цель НПС.|r")
    else
        PlaySound(89)
        SendChatMessage(".npc del","WHISPER" ,GetDefaultLanguage("player"),GetUnitName("player"));
    end
end