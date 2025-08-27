local addonName, addon = ...
addon.LQTip = addon.LQTip or LibStub("LibQTip-1.0",true)
addon.QTipExtras = addon.QTipExtras or {}

addon.QTipExtras.iconProvider, addon.QTipExtras.iconPrototype = addon.LQTip:CreateCellProvider()
local iconProvider, iconPrototype = addon.QTipExtras.iconProvider, addon.QTipExtras.iconPrototype
function iconPrototype:InitializeCell()
  self.iconFrame = CreateFrame("Frame",nil,self)
  self.iconFrame:SetAllPoints()
  self.iconFrame:SetFrameLevel(self:GetFrameLevel()+1)
  self.iconFrame:Show()
  self.iconTexture = self.iconFrame:CreateTexture()
  self.iconTexture:SetPoint("LEFT")
end
function iconPrototype:SetupCell(tooltip, value, justification, font, size, resizerFunc)
  local assetType = type(value)
  if assetType == "number" or assetType == "string" then
    self.iconTexture:SetTexture(value)
    self.iconTexture:SetTexCoord(0.1,0.9,0.1,0.9)
    self.iconTexture:SetSize(size, size)
    self.iconFrame:SetPoint("RIGHT", self, "LEFT", size+2, 0)
  end
  if assetType == "table" then
    self.iconTexture:SetTexture('')
    value = resizerFunc(size)
    self.iconFrame:SetPoint("RIGHT", self, "LEFT", size+2, 0)
    value:ClearAllPoints()
    value:SetParent(self.iconFrame)
    value:SetPoint("LEFT")
    value:SetSize(size, size)
  end
  return size, size
end
function iconPrototype:getContentHeight()
    local iconFrame = self.iconFrame
    local height = self.iconFrame:GetHeight()
    return height
end
function iconPrototype:GetPosition()
    return self._line, self._column
end

addon.QTipExtras.stackProvider, addon.QTipExtras.stackPrototype = addon.LQTip:CreateCellProvider()
local stackProvider, stackPrototype = addon.QTipExtras.stackProvider, addon.QTipExtras.stackPrototype
function stackPrototype:InitializeCell()
  self.fsTop = self:CreateFontString()
  self.fsTop:SetFontObject(_G.GameTooltipHeaderText)
  -- local file,height,flags = self.fsTop:GetFont()
  -- self.fsTop:SetFont(file,height,"OUTLINE")
  self.fsBL = self:CreateFontString()
  self.fsBL:SetFontObject(_G.GameTooltipText)
  -- file,height,flags = self.fsTop:GetFont()
  -- self.fsBL:SetFont(file,height,"OUTLINE")
  self.fsBR = self:CreateFontString()
  self.fsBR:SetFontObject(_G.GameTooltipText)
  -- file,height,flags = self.fsTop:GetFont()
  -- self.fsBR:SetFont(file,height,"OUTLINE")
end
function stackPrototype:SetupCell(tooltip, value, justification, font)
  local top, left, right = unpack(value)
  top = top or ''
  left = left or ''
  right = right or ''

  self.fsTop:ClearAllPoints()
  self.fsTop:SetJustifyH(justification)
  self.fsTop:SetText(top)
  self.fsTop:SetShadowColor(0,0,0,1)
  self.fsTop:SetShadowOffset(1,-1)
  local topwidth = self.fsTop:GetStringWidth()
  self.fsBL:ClearAllPoints()
  self.fsBL:SetJustifyH("LEFT")
  self.fsBL:SetText(left)
  self.fsBL:SetShadowColor(0,0,0,1)
  self.fsBL:SetShadowOffset(1,-1)
  self.fsBR:ClearAllPoints()
  self.fsBR:SetJustifyH("RIGHT")
  self.fsBR:SetText(right)
  self.fsBR:SetShadowColor(0,0,0,1)
  self.fsBR:SetShadowOffset(1,-1)
  local bottomwidth = self.fsBL:GetStringWidth() + self.fsBR:GetStringWidth() + 20

  self.fsTop:SetPoint("TOPLEFT")
  self.fsBL:SetPoint("BOTTOMLEFT")
  self.fsBR:SetPoint("BOTTOMRIGHT")

  local width = bottomwidth >= topwidth and bottomwidth or topwidth
  local height = self.fsTop:GetHeight() + self.fsBL:GetHeight() + 2

  return width, height
end
function stackPrototype:getContentHeight()
  return self.fsTop:GetHeight() + self.fsBL:GetHeight()
end
function stackPrototype:GetPosition()
  return self._line, self._column
end