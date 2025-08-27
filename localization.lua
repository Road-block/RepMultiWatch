local addonName, addon = ...

local L = setmetatable({}, { __index = function(t, k)
  local v = tostring(k)
  rawset(t, k, v)
  return v
end })

addon.L = L

local LOCALE = GetLocale()

if LOCALE == "esES" or LOCALE == "esMX" then
  return
elseif LOCALE == "frFR" then
  return
elseif LOCALE == "ruRU" then
  return
elseif LOCALE == "koKR" then
  return
end