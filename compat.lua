local addonName, addon = ...
addon.guildFactionID = 1168
addon.guildLogoFrame = CreateFrame("Frame", nil, UIParent)
addon.FACTION_BAR_COLORS = {
  [1] = {r = 1, g = 0.1, b = 0.1},
  [2] = {r = 1, g = 0.5, b = 0.25},
  [3] = {r = 1, g = 0.7, b = 0.3},
  [4] = {r = 1, g = 1, b = 0},
  [5] = {r = 0.32, g = 0.67, b = 0},
  [6] = {r = 0, g = 0.43922, b = 1},
  [7] = {r = 0.63922, g = 0.20784, b = 0.93333},
  [8] = {r = 0.90196, g = 0.8, b = 0.50196},
[100] = {r = 0.90196, g = 0.8, b = 0.50196},
}

function addon:GetFactionInfoByID(faction_id)
  local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus, canSetInactive, isAccountWide
  if C_Reputation and C_Reputation.GetFactionDataByID then
    local data = C_Reputation.GetFactionDataByID(faction_id)
    if data then
       name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = data.name, data.description, data.reaction, data.currentReactionThreshold, data.nextReactionThreshold, data.currentStanding, data.atWarWith, data.canToggleAtWar, data.isHeader, data.isCollapsed, (data.isHeaderWithRep or data.reaction and true or false), data.isWatched, data.isChild, data.factionID, data.hasBonusRepGain, nil, data.canSetInactive, data.isAccountWide
    end
  elseif _G.GetFactionInfoByID then
    name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = _G.GetFactionInfoByID(faction_id)
  end
  return name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus, canSetInactive, isAccountWide
end

function addon:GetFactionInfo(faction_index)
  local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus, canSetInactive, isAccountWide
  if C_Reputation and C_Reputation.GetFactionDataByIndex then
    local data = C_Reputation.GetFactionDataByIndex(faction_index)
    if data then
      name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = data.name, data.description, data.reaction, data.currentReactionThreshold, data.nextReactionThreshold, data.currentStanding, data.atWarWith, data.canToggleAtWar, data.isHeader, data.isCollapsed, (data.isHeaderWithRep or data.reaction and true or false), data.isWatched, data.isChild, data.factionID, data.hasBonusRepGain, nil, data.canSetInactive, data.isAccountWide
    end
  elseif _G.GetFactionInfo then
    name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus, canSetInactive, isAccountWide = _G.GetFactionInfo(faction_index)
  end
  return name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus, canSetInactive, isAccountWide
end

function addon:GetFriendshipReputation(faction_id)
  local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold, reversedColor, overrideColor
  if C_GossipInfo and C_GossipInfo.GetFriendshipReputation then
    local data = C_GossipInfo.GetFriendshipReputation(faction_id)
    if data then
      friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = data.friendshipFactionID, data.standing, data.maxRep, data.name, data.text, data.texture, data.reaction, data.reactionThreshold, data.nextThreshold, data.reversedColor, data.overrideColor
    end
  elseif _G.GetFriendshipReputation then
    friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = _G.GetFriendshipReputation(faction_id)
  end
  return friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold, reversedColor, overrideColor
end

function addon:GetFriendshipReputationRanks(faction_id)
  local currentRank, maxRank
  if C_GossipInfo and C_GossipInfo.GetFriendshipReputationRanks then
    local data = C_GossipInfo.GetFriendshipReputationRanks(faction_id)
    if data then
      currentRank, maxRank = data.currentLevel, data.maxLevel
    end
  elseif _G.GetFriendshipReputationRanks then
    currentRank, maxRank = _G.GetFriendshipReputationRanks(faction_id)
  end
  return currentRank, maxRank
end

function addon:GetGuildFactionInfo()
  local factionID, guildName, description, standingID, barMin, barMax, barValue
  if C_Reputation and C_Reputation.GetGuildFactionData then
    local data = C_Reputation.GetGuildFactionData()
    if data then
      factionID, guildName, description, standingID, barMin, barMax, barValue = data.factionID, data.name, data.description, data.reaction, data.currentReactionThreshold, data.nextReactionThreshold, data.currentStanding
    end
  elseif _G.GetGuildFactionInfo then
    factionID = addon.guildFactionID
    guildName, description, standingID, barMin, barMax, barValue = _G.GetGuildFactionInfo()
  end
  return factionID, guildName, description, standingID, barMin, barMax, barValue
end

function addon.GuildLogo(size)
  local size = size or 64
  local f = addon.guildLogoFrame
  f:SetWidth(size)
  f:SetHeight(size)
  f:SetPoint("CENTER",UIParent,"CENTER",0,0)
  local halfsize = size/2

  local tabardBackgroundUpper, tabardBackgroundLower, tabardEmblemUpper, tabardEmblemLower, tabardBorderUpper, tabardBorderLower = GetGuildTabardFiles()
  if ( not tabardEmblemUpper ) then
    tabardBackgroundUpper = 180159
    tabardBackgroundLower = 180158
  end

  f.bgUL = f.bgUL or f:CreateTexture(nil, "BACKGROUND")
  f.bgUL:SetWidth(halfsize)
  f.bgUL:SetHeight(halfsize)
  f.bgUL:SetPoint("TOPLEFT",f,"TOPLEFT",0,0)
  f.bgUL:SetTexCoord(0.5,1,0,1)
  f.bgUR = f.bgUR or f:CreateTexture(nil, "BACKGROUND")
  f.bgUR:SetWidth(halfsize)
  f.bgUR:SetHeight(halfsize)
  f.bgUR:SetPoint("LEFT", f.bgUL, "RIGHT", 0, 0)
  f.bgUR:SetTexCoord(1,0.5,0,1)
  f.bgBL = f.bgBL or f:CreateTexture(nil, "BACKGROUND")
  f.bgBL:SetWidth(halfsize)
  f.bgBL:SetHeight(halfsize)
  f.bgBL:SetPoint("TOP", f.bgUL, "BOTTOM", 0, 0)
  f.bgBL:SetTexCoord(0.5,1,0,1)
  f.bgBR = f.bgBR or f:CreateTexture(nil, "BACKGROUND")
  f.bgBR:SetWidth(halfsize)
  f.bgBR:SetHeight(halfsize)
  f.bgBR:SetPoint("LEFT", f.bgBL, "RIGHT", 0,0)
  f.bgBR:SetTexCoord(1,0.5,0,1)

  f.bdUL = f.bdUL or f:CreateTexture(nil, "BORDER")
  f.bdUL:SetWidth(halfsize)
  f.bdUL:SetHeight(halfsize)
  f.bdUL:SetPoint("TOPLEFT", f.bgUL, "TOPLEFT", 0,0)
  f.bdUL:SetTexCoord(0.5,1,0,1)
  f.bdUR = f.bdUR or f:CreateTexture(nil, "BORDER")
  f.bdUR:SetWidth(halfsize)
  f.bdUR:SetHeight(halfsize)
  f.bdUR:SetPoint("LEFT", f.bdUL, "RIGHT", 0,0)
  f.bdUR:SetTexCoord(1,0.5,0,1)
  f.bdBL = f.bdBL or f:CreateTexture(nil, "BORDER")
  f.bdBL:SetWidth(halfsize)
  f.bdBL:SetHeight(halfsize)
  f.bdBL:SetPoint("TOP", f.bdUL, "BOTTOM", 0,0)
  f.bdBL:SetTexCoord(0.5,1,0,1)
  f.bdBR = f.bdBR or f:CreateTexture(nil, "BORDER")
  f.bdBR:SetWidth(halfsize)
  f.bdBR:SetHeight(halfsize)
  f.bdBR:SetPoint("LEFT", f.bdBL, "RIGHT", 0,0)
  f.bdBR:SetTexCoord(1,0.5,0,1)

  f.emUL = f.emUL or f:CreateTexture(nil, "BORDER")
  f.emUL:SetWidth(halfsize)
  f.emUL:SetHeight(halfsize)
  f.emUL:SetPoint("TOPLEFT", f.bgUL, "TOPLEFT", 0,0)
  f.emUL:SetTexCoord(0.5,1,0,1)
  f.emUR = f.emUR or f:CreateTexture(nil, "BORDER")
  f.emUR:SetWidth(halfsize)
  f.emUR:SetHeight(halfsize)
  f.emUR:SetPoint("LEFT", f.bdUL, "RIGHT", 0,0)
  f.emUR:SetTexCoord(1,0.5,0,1)
  f.emBL = f.emBL or f:CreateTexture(nil, "BORDER")
  f.emBL:SetWidth(halfsize)
  f.emBL:SetHeight(halfsize)
  f.emBL:SetPoint("TOP", f.emUL, "BOTTOM", 0,0)
  f.emBL:SetTexCoord(0.5,1,0,1)
  f.emBR = f.emBR or f:CreateTexture(nil, "BORDER")
  f.emBR:SetWidth(halfsize)
  f.emBR:SetHeight(halfsize)
  f.emBR:SetPoint("LEFT", f.emBL, "RIGHT", 0,0)
  f.emBR:SetTexCoord(1,0.5,0,1)

  f.bgUL:SetTexture(tabardBackgroundUpper)
  f.bgUR:SetTexture(tabardBackgroundUpper)
  f.bgBL:SetTexture(tabardBackgroundLower)
  f.bgBR:SetTexture(tabardBackgroundLower)

  f.emUL:SetTexture(tabardEmblemUpper)
  f.emUR:SetTexture(tabardEmblemUpper)
  f.emBL:SetTexture(tabardEmblemLower)
  f.emBR:SetTexture(tabardEmblemLower)

  f.bdUL:SetTexture(tabardBorderUpper)
  f.bdUR:SetTexture(tabardBorderUpper)
  f.bdBL:SetTexture(tabardBorderLower)
  f.bdBR:SetTexture(tabardBorderLower)

  return f
end