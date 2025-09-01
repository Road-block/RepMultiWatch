-- boilerplate
local addonName, addon = ...
local L = addon.L
addon.events = CreateFrame("Frame")
addon.OnEvent = function(self,event,...)
  return addon[event] and addon[event](addon,event,...)
end
addon.events:SetScript("OnEvent", addon.OnEvent)
function addon:RegisterEvent(event)
  if C_EventUtils.IsEventValid(event) then
    addon.events:RegisterEvent(event)
  end
end
function addon:UnregisterEvent(event)
  if C_EventUtils.IsEventValid(event) then
    if addon.events:IsEventRegistered(event) then
      addon.events:UnregisterEvent(event)
    end
  end
end
function addon:IsEventRegistered(event)
  if C_EventUtils.IsEventValid(event) then
    return addon.events:IsEventRegistered(event)
  end
end
function addon:RegisterUnitEvent(event,unit)
  if C_EventUtils.IsEventValid(event) then
    addon.events:RegisterUnitEvent(event,unit)
  end
end
local LABEL = "|T236681:14:14|t|cff00BFFFRep|r |cff00ff00Multi|r-Watch"
local LABEL_COLON = format("%s%s",LABEL,HEADER_COLON)
local LABEL_SHORT = "|T236681:14:14|t|cff007FFFRep|r|cff00ff00Multi|rW"
local ADD_WATCH = "|T136814:14|t"..L["Add to Rep Multi-Watch"]
local REM_WATCH = "|T136813:14|t"..L["Remove from Rep Multi-Watch"]
local HAS_BONUS = "  |T519957:14:14:0:0:32:32:0:32:0:32:32:224:32|t"
local CAN_BONUS = "  |T133784:14:14:0:0:64:64:2:62:2:62:255:255:224|t"

local tsort = table.sort
local tinsert = table.insert
local After = C_Timer.After

local watchedRepData = {}

function addon:Print(msg)
  if msg and msg:trim() ~= "" then
    local chatFrame = (DEFAULT_CHAT_FRAME or SELECTED_CHAT_FRAME)
    local out = format("%s:%s",LABEL_SHORT,msg)
    chatFrame:AddMessage(out)
  end
end

local function ShouldQueue()
  if InCombatLockdown() then
    if not addon:IsEventRegistered("PLAYER_REGEN_ENABLED") then
      addon:RegisterEvent("PLAYER_REGEN_ENABLED")
    end
    return true
  end
end
local taskQueue = {}
function addon.RunQueue()
  if not ShouldQueue() then
    local queue_length = CountTable(taskQueue)
    while queue_length > 0 do
      (tremove(taskQueue))()
      queue_length = CountTable(taskQueue)
    end
  end
end

function addon.UpdateLDBText()
  if addon.LDBObj then
    addon.LDBObj.text = LABEL
  end
end

local function sorter_standing_progress(a, b)
  if a.standing ~= b.standing then
    return a.standing > b.standing
  elseif a.perc ~= b.perc then
    return a.perc > b.perc
  else
    return a.name < b.name
  end
end

local watch_to_remove = {}
function addon.SortWatchedReps()
  watchedRepData = wipe(watchedRepData)
  local removeMaxed = addon.db_pc.unwatchmax
  if removeMaxed then wipe(watch_to_remove) end
  for faction_id,status in pairs(addon.db_pc.watched) do
    local bar_name, bar_value, bar_min, bar_max, bar_reaction, standing, icon, has_bonus, can_bonus = addon:GetFactionData(faction_id)
    local maxed = (bar_value >= 42000) or (not bar_max)
    if not bar_max then -- friendship prob
      --bar_max = bar_min + 1000
      bar_max = 1
      bar_min = 0
      bar_value = 1
    else
      bar_max = bar_max - bar_min
      bar_value = bar_value - bar_min
    end
    if maxed then standing = 100 end -- sort all maxed to the top regardless of absolute rank value
    local progval, progtext = bar_value/bar_max, format("%s/%s",bar_value,bar_max)
    if removeMaxed and maxed then
      watch_to_remove[faction_id] = bar_name
    else
      tinsert(watchedRepData,{name=bar_name, reaction=bar_reaction, prog=progtext, icon=icon, bonus=has_bonus, get_bonus=can_bonus, standing=standing, perc=progval})
    end
  end
  tsort(watchedRepData,sorter_standing_progress)
  if removeMaxed and CountTable(watch_to_remove) > 0 then
    for id, name in pairs(watch_to_remove) do
      addon.db_pc.watched[id] = nil
      addon:Print(format(L["%s maxed! Un-watching."],name))
    end
  end
  return watchedRepData
end

function addon.TooltipHelpShow(self, data)
  GameTooltip:SetOwner(data.parent, "ANCHOR_NONE")
  GameTooltip:AddLine(data.content)
  GameTooltip:ClearAllPoints()
  local x,y = GetCursorPosition()
  local uiScale = UIParent:GetEffectiveScale()
  if x < GetScreenWidth()*uiScale/2 then
    GameTooltip:SetPoint("BOTTOMLEFT",data.parent,"BOTTOMRIGHT")
  else
    GameTooltip:SetPoint("BOTTOMRIGHT",data.parent,"BOTTOMLEFT")
  end
  GameTooltip:Show()
end
function addon.TooltipHelpHide(self, data)
  if GameTooltip:IsOwned(data.parent) then
    GameTooltip_Hide()
  end
end

local map_name_cache = {}
function addon.VendorLocationText(location_data)
  local vendorName = location_data.name
  if vendorName then
    local locationText = ""
    local mapName
    local mapID = location_data.map
    if mapID and not map_name_cache[mapID] then
      local mapInfo = C_Map.GetMapInfo(mapID)
      if mapInfo then
        map_name_cache[mapID] = mapInfo.name
      end
    end
    mapName = map_name_cache[mapID] or ""
    locationText = format("\n|cff00ff00%s|r - %s (|cffffffff%s, %s|r)",vendorName,mapName,location_data.x, location_data.y)
    return locationText
  elseif location_data[1] and type(location_data[1])=="table" then
    local locationText = ""
    for i,loc_data in ipairs(location_data) do
      locationText = locationText .. (addon.VendorLocationText(loc_data))
    end
    return locationText
  end
end

function addon.OnLDBIconTooltipShow(obj)
  local its_a_me = (addon.selectedCharacterKey == addon.characterKey)
  if its_a_me then
    addon.SortWatchedReps()
  end
  addon.watchesAdded = false
  local iconProvider = addon.QTipExtras.iconProvider
  local stackProvider = addon.QTipExtras.stackProvider
  if addon.LQTip then
    if not addon.LQTip:IsAcquired(addonName.."QTip1.0") then
      addon.QTip = addon.LQTip:Acquire(addonName.."QTip1.0",3,"LEFT","LEFT","LEFT")
    else
      addon.QTip:Clear()
    end
    addon.QTip:SetAutoHideDelay(1.5,obj,addon.OnLDBIconTooltipHide)
    -- header
    local line = addon.QTip:AddLine()
    local header
    if its_a_me then
      header = LABEL
    else
      header = format("%s (%s)",LABEL,addon.selectedCharacterKey)
    end
    addon.QTip:SetCell(line,1,header,nil,"CENTER",3)
    -- content loop
    if #addon.watchContainer > 0 then
      -- data: name, reaction, prog, icon [bonus, get_bonus, standing, perc]
      for _,data in ipairs(addon.watchContainer) do
        line = addon.QTip:AddLine()
        addon.QTip:SetCell(line,1, data.icon, iconProvider, 20, addon.GuildLogo)
        local name = data.name
        if data.bonus then
          name = name .. HAS_BONUS
          addon.QTip:SetLineScript(line, "OnEnter", addon.TooltipHelpShow, {parent=addon.QTip, content=L["Grand Commendation |cff00ff00Applied|r"]})
          addon.QTip:SetLineScript(line, "OnLeave", addon.TooltipHelpHide, {parent=addon.QTip})
        elseif data.get_bonus then
          name = name .. CAN_BONUS
          local vendorLocation = addon.VendorLocationText(data.get_bonus) or ""
          addon.QTip:SetLineScript(line, "OnEnter", addon.TooltipHelpShow, {parent=addon.QTip, content=L["Grand Commendation |cffFFFFFFAvailable|r"]..vendorLocation})
          addon.QTip:SetLineScript(line, "OnLeave", addon.TooltipHelpHide, {parent=addon.QTip})
        end
        addon.QTip:SetCell(line,2, {name,data.reaction,data.prog}, 2, stackProvider)
        local cell1, cell2 = addon.QTip.lines[line].cells[1], addon.QTip.lines[line].cells[2]
        local color = addon.FACTION_BAR_COLORS[data.standing] or addon.FACTION_BAR_COLORS[5]
        addon.QTip:SetCellColor(line, 2, color.r, color.g, color.b, 1)
        if cell1.iconFrame then
          cell2:SetPoint("LEFT",cell1.iconFrame,"RIGHT",2,0)
        end
      end
      addon.watchesAdded = true
    end

    if not addon.watchesAdded then
      line = addon.QTip:AddLine('')
      line = addon.QTip:AddLine()
      addon.QTip:SetCell(line,1,L["Manage Reps from Reputation Pane"],nil,"CENTER",3)
      addon.QTip:SetCellTextColor(line,1,1,1,1)
    end

    -- footer
    line = addon.QTip:AddSeparator()
    line = addon.QTip:AddLine(L["Left-Click:"],L["Options"])
    addon.QTip:SetLineTextColor(line,0.7,0.7,0.7)
    line = addon.QTip:AddLine(L["Right-Click:"],L["Alt Viewer"])
    addon.QTip:SetLineTextColor(line,0.7,0.7,0.7)
    line = addon.QTip:AddLine(L["Middle-Click:"],L["Reputation Pane"])
    addon.QTip:SetLineTextColor(line,0.7,0.7,0.7)
    if CountTable(addon.db_pc.watched) > 0 then
      line = addon.QTip:AddLine("/repmultiwatch clearall",L["Unwatch ALL Reputations"])
      addon.QTip:SetCellTextColor(line,1,0.7,0.7,0.7)
      addon.QTip:SetCellTextColor(line,2,0.9,0.2,0.2)
      addon.QTip:SetLineScript(line, "OnMouseUp", addon.RemoveAllWatches, true)
      addon.QTip:SetLineScript(line, "OnEnter", addon.TooltipHelpShow, {parent=addon.QTip, content=L["Shift-Click: Unwatch All\n|cffff0000No Confirmation|r"]})
      addon.QTip:SetLineScript(line, "OnLeave", addon.TooltipHelpHide, {parent=addon.QTip})
    end
    addon.QTip:SmartAnchorTo(obj)

    addon.QTip:Show()
    addon.QTip:UpdateScrolling(600)
  end
end

function addon.OnLDBIconTooltipHide()
  if addon.LQTip:IsAcquired(addonName.."QTip1.0") then
    if GameTooltip:IsOwned(addon.QTip) then
      GameTooltip_Hide()
    end
    addon.LQTip:Release(addon.QTip)
  end
end

function addon.OnLDBIconClick(frame, mbutton, down)
  if mbutton == "LeftButton" then
    Settings.OpenToCategory(addon._category:GetID())
  elseif mbutton == "RightButton" then
    addon.OnLDBIconTooltipHide()
    local menu = MenuUtil.CreateRadioContextMenu(frame,
      addon.IsCharacterSelected,
      addon.SelectCharacter,
      {_G.YOU,addon.characterKey},
      addon.GetCharactersTuple()
    )
  elseif mbutton == "MiddleButton" then
    ToggleCharacter("ReputationFrame")
  end
end

local characters = {}
local alphaSort = function(a,b)
  return a[1] < b[1]
end
function addon.GetCharactersTuple()
  characters = wipe(characters)
  for characterKey in pairs(addon.db.allChars) do
    if characterKey ~= addon.characterKey then
      tinsert(characters,{characterKey,characterKey})
    end
  end
  tsort(characters,alphaSort)
  return unpack(characters)
end

function addon.IsCharacterSelected(charKey)
  return charKey == addon.selectedCharacterKey
end

function addon.SelectCharacter(charKey)
  addon.selectedCharacterKey = charKey
  addon.SetRepwatchContainer()
end

function addon.RemoveCharacter(charKey)
  local found
  for characterKey in pairs(addon.db.allChars) do
    if (charKey == characterKey:lower()) and not (characterKey == addon.characterKey) then
      found = true
      addon.db.allChars[characterKey] = nil
      addon:Print(format("%s %s",characterKey,L["Removed"]))
    end
  end
  if not found then
    addon:Print(L["Invalid <name-realm> supplied"])
    print(L["  Available characters"])
    for c, _ in pairs(addon.db.allChars) do
      if not (c == addon.characterKey) then
        print(format("    %s",c))
      end
    end
  end
end

function addon.RemoveAllWatches(tooltip_click)
  if tooltip_click and not IsShiftKeyDown() then return end
  for k,v in pairs(addon.db_pc.watched) do
    addon.db_pc.watched[k] = nil
  end
  addon.SortWatchedReps()
  if addon.LQTip:IsAcquired(addonName.."QTip1.0") then
    addon.LQTip:Release(addon.QTip)
  end
  addon:Print(L["All Reputations Watches removed"])
end

function addon.SetRepwatchContainer()
  if addon.selectedCharacterKey == addon.characterKey then
    addon.watchContainer = watchedRepData
  else
    if addon.db.allChars[addon.selectedCharacterKey] then
      addon.watchContainer = addon.db.allChars[addon.selectedCharacterKey]
    end
  end
end

function addon.ToggleRepWatch(bar, button, down)
  local hasRep = bar and bar.hasRep or false
  local faction_index = bar and bar.index or false
  if not (faction_index and hasRep) then return end
  local name, _, standingID, barMin, barMax, barValue, _, _, _, _, hasRep, _, _, factionID, _, _, _, _ = addon:GetFactionInfo(faction_index)
  local modKey, modCheck = addon.db_pc.modifier
  if modKey == "SHIFT" then
    modCheck = IsShiftKeyDown
  elseif modKey == "CTRL" then
    modCheck = IsCtrlKeyDown
  elseif modKey == "ALT" then
    modCheck = IsAltKeyDown
  end
  if modCheck() then
    if addon.db_pc.watched[factionID] then
      addon.db_pc.watched[factionID] = nil
    else
      addon.db_pc.watched[factionID] = true
    end
    addon.SortWatchedReps()
  end
end

function addon.AddToTooltip(row, motion)
  local hasRep = row and row.hasRep or false
  local faction_index = row and row.index or false
  if not (faction_index and hasRep) then return end
  local name, _, standingID, barMin, barMax, barValue, _, _, _, _, hasRep, _, _, factionID, _, _, _, _ = addon:GetFactionInfo(faction_index)
  local keyHint = ''
  local modKey = addon.db_pc.modifier
  if modKey == "SHIFT" then
    keyHint = L["Shift-Click"]
  elseif modKey == "CTRL" then
    keyHint = L["Ctrl-Click"]
  elseif modKey == "ALT" then
    keyHint = L["Alt-Click"]
  end
  keyHint = ORANGE_FONT_COLOR:WrapTextInColorCode(keyHint)
  After(0,function()
    if not GameTooltip:IsOwned(row) then
      GameTooltip:SetOwner(row,"ANCHOR_CURSOR")
    end
    if addon.db_pc.watched[factionID] then
      GameTooltip:AddDoubleLine(keyHint,REM_WATCH)
    else
      GameTooltip:AddDoubleLine(keyHint,ADD_WATCH)
    end
    GameTooltip:Show()
  end)
end

function addon.ResetTooltip(row)
  if GameTooltip:IsOwned(row) then
    GameTooltip_Hide()
  end
end

function addon.PostHookBarsOnEnter()
  for i=1, NUM_FACTIONS_DISPLAYED do
    local row = _G["ReputationBar"..i]
    if row and not row[addonName.."_hook"] then
      row:HookScript("OnEnter", addon.AddToTooltip)
      row:HookScript("OnLeave", addon.ResetTooltip)
      row:HookScript("OnHide", addon.ResetTooltip)
      row[addonName.."_hook"] = true
    end
  end
end

function addon:RefreshDisplay()

end

local defaults_perchar = {
  watched = {},
  minimap = {
    hide = false,
    lock = false,
    minimapPos = 275,
  },
  modifier = "SHIFT",
  unwatchmax = false,
}
local defaults = {
  allChars = {}
}

addon:RegisterEvent("ADDON_LOADED")
function addon:ADDON_LOADED(event,...)
  if ... == addonName then
    RepMultiWatchDB = RepMultiWatchDB or {}
    RepMultiWatchPC = RepMultiWatchPC or {}
    -- upgrade sv if something was added to defaults
    for k,v in pairs(defaults) do
      if RepMultiWatchDB[k] == nil then
        if type(v) == "table" then
          RepMultiWatchDB[k] = CopyTable(v)
        else
          RepMultiWatchDB[k] = v
        end
      end
    end
    for k,v in pairs(defaults_perchar) do
      if RepMultiWatchPC[k] == nil then
        if type(v) == "table" then
          RepMultiWatchPC[k] = CopyTable(v)
        else
          RepMultiWatchPC[k] = v
        end
      end
    end
    if IsLoggedIn() then
      self:PLAYER_LOGIN("PLAYER_LOGIN")
    else
      self:RegisterEvent("PLAYER_LOGIN")
    end
  end
end

function addon:PLAYER_LOGIN(event)
  addon:UnregisterEvent("PLAYER_LOGIN")
  self.db = RepMultiWatchDB
  self.db_pc = RepMultiWatchPC
  self:RegisterEvent("FACTION_UPDATE")
  hooksecurefunc("ReputationBar_OnClick", addon.ToggleRepWatch)
  EventUtil.ContinueOnAddOnLoaded("Blizzard_UIPanels_Game", addon.PostHookBarsOnEnter)
  addon.LDB = addon.LDB or LibStub("LibDataBroker-1.1",true)
  addon.LDBIcon = addon.LDBIcon or LibStub("LibDBIcon-1.0",true)
  addon.LDBObj = addon.LDBObj or addon.LDB:NewDataObject(addonName,
    {
      type = "data source",
      text = addonName,
      icon = 236681,
      label = "RepMulti",
      OnEnter = addon.OnLDBIconTooltipShow,
--      OnLeave = addon.OnLDBIconTooltipHide,
      OnClick = addon.OnLDBIconClick,
    })
  addon.LDBIcon:Register(addonName, addon.LDBObj, addon.db_pc.minimap)
  --addon.UpdateLDBText()
  addon:CreateSettings()
  addon:RegisterEvent("PLAYER_LOGOUT")
  addon.characterKey = format("%s-%s",(UnitNameUnmodified("player")),(GetNormalizedRealmName()))
  addon.playerFaction = UnitFactionGroup("player")
  addon.selectedCharacterKey = addon.characterKey
  addon.watchContainer = watchedRepData
end

function addon:PLAYER_LOGOUT(event)
  if CountTable(addon.db_pc.watched) > 0 then
    watchedRepData = addon.SortWatchedReps()
    addon.db.allChars[addon.characterKey] = CopyTable(watchedRepData)
  end
end

function addon:FACTION_UPDATE(event)
  if CountTable(self.db_pc.watched) > 0 then
    addon.SortWatchedReps()
  end
end

function addon:PLAYER_REGEN_ENABLED(event)
  self.RunQueue()
end

local addonUpper, addonLower = addonName:upper(), addonName:lower()
_G["SLASH_"..addonUpper.."1"] = "/"..addonLower
_G["SLASH_"..addonUpper.."2"] = "/rmw"
SlashCmdList[addonUpper] = function(msg, editbox)
  local option = {}
  if not msg or msg:trim()=="" then
    Settings.OpenToCategory(addon._category:GetID())
  else
    msg = msg:lower()
    for token in msg:gmatch("(%S+)") do
      tinsert(option,token)
    end
    local cmd = option[1]
    if cmd == "clear" or cmd == "clearall" then
      addon.RemoveAllWatches()
    elseif cmd == "rm" or cmd == "del" then
      local charKey = option[2]
      if not charKey or (charKey:trim()=="") then
        addon:Print(L["<name-realm> argument missing"])
        print(L["  Available characters"])
        for c, _ in pairs(addon.db.allChars) do
          if not (c == addon.characterKey) then
            print(format("    %s",c))
          end
        end
      else
        addon.RemoveCharacter(charKey)
      end
    end
    if (msg:find("?") or msg:find("help")) then
      addon:Print(L["Commands"])
      print("  /rmw clearall : removes all watches")
      print("  /rmw del name-realm : remove an inactive character/alt")
    end
  end
end

_G[addonName] = addon -- DEBUG
