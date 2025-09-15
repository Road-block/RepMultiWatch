local addonName, addon = ...
local L = addon.L
local fallback_icon = 236682
local faction_data = { -- id = {index, friend, icon}, -- name
  [21] = {1, 0, -1}, -- Booty Bay
  [47] = {20, 0, 255138}, -- Ironforge
  [54] = {18, 0, 255139}, -- Gnomeregan
  [59] = {4, 0, -1}, -- Thorium Brotherhood
  [67] = {12, 0, 255132}, -- Horde
  [68] = {17, 0, 255143}, -- Undercity
  [69] = {21, 0, 255141}, -- Darnassus
  [72] = {19, 0, 255140}, -- Stormwind
  [76] = {14, 0, 255142}, -- Orgrimmar
  [81] = {16, 0, 255144}, -- Thunder Bluff
  [87] = {0, 0, 133168}, -- Bloodsail Buccaneers
  [92] = {2, 0, -1}, -- Gelkis Clan Centaur
  [93] = {3, 0, -1}, -- Magram Clan Centaur
  [169] = {0, 0, -1}, -- Steamwheedle Cartel
  [270] = {1, 0, 132529}, -- Zandalar Tribe
  [349] = {5, 0, -1}, -- Ravenholdt
  [369] = {7, 0, -1}, -- Gadgetzan
  [469] = {1, 0, 255130}, -- Alliance
  [470] = {9, 0, -1}, -- Ratchet
  [509] = {3, 0, 132351}, -- The League of Arathor
  [510] = {2, 0, 237568}, -- The Defilers
  [529] = {3, 0, 133440}, -- Argent Dawn
  [530] = {5, 0, 255145}, -- Darkspear Trolls
  [576] = {5, 0, 236696}, -- Timbermaw Hold
  [577] = {8, 0, -1}, -- Everlook
  [609] = {6, 0, -1}, -- Cenarion Circle
  [729] = {1, 0, 133287}, -- Frostwolf Clan
  [730] = {0, 0, 133433}, -- Stormpike Guard
  [749] = {2, 0, 135862}, -- Hydraxian Waterlords
  [809] = {4, 0, 354719}, -- Shen'dralar
  [889] = {6, 0, 132366}, -- Warsong Outriders
  [890] = {5, 0, 132279}, -- Silverwing Sentinels
  [891] = {7, 0, -1}, -- Alliance Forces
  [892] = {8, 0, -1}, -- Horde Forces
  [909] = {0, 0, 134481}, -- Darkmoon Faire
  [910] = {4, 0, 134156}, -- Brood of Nozdormu
  [911] = {5, 0, 255136}, -- Silvermoon City
  [922] = {6, 0, -1}, -- Tranquillien
  [929] = {1, 0, -1}, -- Bloodmaul Clan
  [930] = {9, 0, 255137}, -- Exodar
  [932] = {8, 0, -1}, -- The Aldor
  [933] = {0, 0, 132881}, -- The Consortium
  [934] = {2, 0, -1}, -- The Scryers
  [935] = {9, 0, -1}, -- The Sha'tar
  [936] = {9, 0, -1}, -- Shattrath City
  [941] = {1, 0, 134060}, -- The Mag'har
  [942] = {4, 0, -1}, -- Cenarion Expedition
  [946] = {8, 0, -1}, -- Honor Hold
  [947] = {7, 0, -1}, -- Thrallmar
  [967] = {3, 0, 135933}, -- The Violet Eye
  [970] = {5, 0, 134532}, -- Sporeggar
  [978] = {6, 0, 134060}, -- Kurenai
  [989] = {7, 0, -1}, -- Keepers of Time
  [990] = {7, 0, 132856}, -- The Scale of the Sands
  [1011] = {69, 0, -1}, -- Lower City
  [1012] = {70, 0, 236691}, -- Ashtongue Deathsworn
  [1015] = {71, 0, 132250}, -- Netherwing
  [1031] = {72, 0, 132191}, -- Sha'tari Skyguard
  [1037] = {88, 0, 136002}, -- Alliance Vanguard
  [1038] = {73, 0, 133594}, -- Ogri'la
  [1050] = {74, 0, -1}, -- Valiance Expedition
  [1052] = {75, 0, 136003}, -- Horde Expedition
  [1064] = {76, 0, -1}, -- The Taunka
  [1067] = {77, 0, -1}, -- The Hand of Vengeance
  [1068] = {78, 0, -1}, -- Explorers' League
  [1073] = {79, 0, 236697}, -- The Kalu'ak
  [1077] = {80, 0, 134993}, -- Shattered Sun Offensive
  [1085] = {81, 0, -1}, -- Warsong Offensive
  [1090] = {84, 0, 236693}, -- Kirin Tor
  [1091] = {83, 0, 236699}, -- The Wyrmrest Accord
  [1094] = {90, 0, 132849}, -- The Silver Covenant
  [1098] = {91, 0, 236694}, -- Knights of the Ebon Blade
  [1104] = {92, 0, 132266}, -- Frenzyheart Tribe
  [1105] = {93, 0, 134169}, -- The Oracles
  [1106] = {94, 0, 133441}, -- Argent Crusade
  [1117] = {95, 0, -1}, -- Sholazar Basin
  [1119] = {97, 0, -1}, -- The Sons of Hodir
  [1124] = {98, 0, 132850}, -- The Sunreavers
  [1126] = {99, 0, -1}, -- The Frostborn
  [1133] = {105, 0, -1}, -- Bilgewater Cartel
  [1134] = {106, 0, -1}, -- Gilneas
  [1135] = {110, 0, 456567}, -- The Earthen Ring
  [1156] = {104, 0, 133441}, -- The Ashen Verdict
  [1158] = {113, 0, 456570}, -- Guardians of Hyjal
  [1168] = {114, 0, -1}, -- Guild
  [1171] = {116, 0, 456572}, -- Therazane
  [1172] = {117, 0, 456565}, -- Dragonmaw Clan
  [1173] = {118, 0, 456574}, -- Ramkahen
  [1174] = {119, 0, 456575}, -- Wildhammer Clan
  [1177] = {122, 0, 456564}, -- Baradin's Wardens
  [1178] = {123, 0, 456571}, -- Hellscream's Reach
  [1204] = {127, 0, 512609}, -- Avengers of Hyjal
  [1216] = {131, 0, -1}, -- Shang Xi's Academy
  [1228] = {144, 0, -1}, -- Forest Hozen
  [1242] = {143, 0, -1}, -- Pearlfin Jinyu
  [1243] = {-1, 0, -1}, -- Hozen
  [1265] = {-1, 0, -1}, -- Shen'dralar
  [1268] = {-1, 0, -1}, -- Mogu
  [1269] = {167, 0, 643910}, -- Golden Lotus
  [1270] = {182, 0, 645204},  -- Shado-Pan
  [1271] = {154, 0, 646324}, -- Order of the Cloud Serpent
  [1272] = {171, 0, 645198}, -- The Tillers
  [1273] = {156, 21, -1}, -- Jogu the Drunk
  [1275] = {158, 17, -1}, -- Ella
  [1276] = {159, 22, -1}, -- Old Hillpaw
  [1277] = {160, 16, -1}, -- Chee Chee
  [1278] = {161, 23, -1}, -- Sho
  [1279] = {162, 20, -1}, -- Haohan Mudclaw
  [1280] = {163, 24, -1}, -- Tina Mudclaw
  [1281] = {164, 19, -1}, -- Gina Mudclaw
  [1282] = {165, 18, -1}, -- Fish Fellreed
  [1283] = {166, 2, -1}, -- Farmer Fung
  [1302] = {172, 0, 643874}, -- The Anglers
  [1336] = {-1, 0, -1}, -- The Mantid Swarm
  [1337] = {181, 0, 646377}, -- The Klaxxi
  [1341] = {183, 0, 645203}, -- The August Celestials
  [1345] = {184, 0, 645218}, -- The Lorewalkers
  [1351] = {186, 0, -1}, -- The Brewmasters
  [1352] = {187, 0, -1}, -- Huojin Pandaren
  [1353] = {188, 0, -1}, -- Tushui Pandaren
  [1358] = {192, 26, 133152}, -- Nat Pagle
  [1359] = {193, 0, 656543}, -- The Black Prince
  [1374] = {197, 28, 237499}, -- Brawl'gar Arena
  [1375] = {198, 0, 464078}, -- Dominance Offensive
  [1376] = {199, 0, 464076}, -- Operation Shieldwall
  [1387] = {207, 0, 801132}, -- Kirin Tor Offensive
  [1388] = {208, 0, 838819}, -- Sunreaver Onslaught
  [1416] = {221, 0, -1}, -- Akama's Trust
  [1419] = {220, 43, -1}, -- Bizmo's Brawlpub
  [1435] = {228, 0, 645204}, -- ShadoPan Assault
  [1440] = {229, 72, -1}, -- Darkspear Rebellion
  [1492] = {241, 0, 607848}, -- Emperor Shaohao
}
local faction_vendors = {
  [1341] = {
    [FACTION_HORDE]={name=L["Sage Lotusbloom"], map=390, x=62.6, y=23.2},
    [FACTION_ALLIANCE]={name=L["Sage Whiteheart"], map=390, x=84.6, y=63.6}},
  [1269] = {[FACTION_NEUTRAL]={name=L["Jaluu the Generous"], map=390, x=74.2, y=42.6}},
  [1302] = {[FACTION_NEUTRAL]={name=L["Nat Pagle"], map=418, x=68.4, y=43.4}},
  [1337] = {[FACTION_NEUTRAL]={name=L["Ambersmith Zikk"], map=422, x=55.0, y=35.6}},
  [1345] = {[FACTION_NEUTRAL]={name=L["Tan Shin Tiao"], map=390, x=82.2, y=29.4}},
  [1271] = {[FACTION_NEUTRAL]={name=L["San Redscale"], map=371, x=56.6, y=44.4}},
  [1270] = {[FACTION_NEUTRAL]={name=L["Rushi the Fox"], map=388, x=48.8, y=70.6}},
  [1272] = {[FACTION_NEUTRAL]={name=L["Gina Mudclaw"], map=376, x=53.2, y=51.6}},
  [1359] = {[FACTION_NEUTRAL]={name=L["Blacktalon Quartermaster"], map=433, x=54.6, y=72.6}},
  [1375] = {[FACTION_HORDE]={name=L["Tuskripper Grukna"], map=418, x=10.8, y=53.4}},
  [1376] = {[FACTION_ALLIANCE]={name=L["Agent Malley"], map=418, x=89.6, y=33.4}},
  [1388] = {[FACTION_HORDE]={
    {name=L["Vasarin Redmorn (P1)"], map=504, x=28.2, y=51.6},
    {name=L["Vasarin Redmorn (P2+)"], map=504, x=33.4, y=32.4}
  }},
  [1387] = {[FACTION_ALLIANCE]={
    {name=L["Hiren Loresong (P1)"], map=504, x=34.8, y=90.0},
    {name=L["Hiren Loresong (P2+)"], map=504, x=64.6, y=74.6}
  }}
}
local faction_cache = {}
function addon:GetFactionVendor(factionID)
  local vendor_data = faction_vendors[factionID]
  local location_data = vendor_data and (vendor_data[addon.playerFaction] or vendor_data[FACTION_NEUTRAL])
  if location_data then
    local faction_name
    if not faction_cache[factionID] then
      faction_cache[factionID] = addon:GetFactionInfoByID(factionID)
    end
    local faction_name = faction_cache[factionID] or ""
    return location_data, faction_name
  end
end
function addon:GetFactionData(faction_id)
  local data = faction_data[faction_id]
  local bar_name, bar_value, bar_min, bar_max, bar_reaction, standing, icon, has_bonus, can_bonus
  if data then
    local friend_id = data[2]
    icon = data[3]
    local factionName, _, factionStandingID, factionBarMin, factionBarMax, factionBarValue, _, _, _, _, factionHasRep, _, _, factionID, hasBonusRep = addon:GetFactionInfoByID(faction_id)
    faction_cache[factionID] = factionName
    local gender = UnitSex("player")
    if friend_id and friend_id > 0 then
      local friendID, friendRep, friendMaxRep, friendName, _, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = addon:GetFriendshipReputation(faction_id)
      bar_name = friendName
      bar_value = friendRep
      bar_min = friendThreshold
      bar_max = nextFriendThreshold
      bar_reaction = friendTextLevel
      standing = factionStandingID
      icon = friendTexture
    elseif faction_id == addon.guildFactionID then
      local guildFactionID, guildName, guildDescription, guildStandingID, guildBarMin, guildBarMax, guildBarValue = addon:GetGuildFactionInfo()
      bar_name = guildName
      bar_value = guildBarValue
      bar_min = guildBarMin
      bar_max = guildBarMax
      bar_reaction = GetText("FACTION_STANDING_LABEL"..guildStandingID, gender)
      standing = guildStandingID
      icon = addon.GuildLogo(0)
    else
      bar_name = factionName
      bar_value = factionBarValue
      bar_min = factionBarMin
      bar_max = factionBarMax
      bar_reaction = GetText("FACTION_STANDING_LABEL"..factionStandingID, gender)
      icon = icon ~= -1 and icon or fallback_icon
      standing = factionStandingID
      has_bonus = hasBonusRep
      if (not has_bonus) and (standing and standing >= addon.commendationRank) then
        local location_data = self:GetFactionVendor(factionID)
        if location_data then
          can_bonus = location_data
        end
      end
    end
  end
  return bar_name, bar_value, bar_min, bar_max, bar_reaction, standing, icon, has_bonus, can_bonus
end
