function widget:GetInfo()
  return {
    name      = "XP Bar",
    desc      = "Display %XP and current level",
    author    = "Presstabstart",
    date      = "now",
    license   = "GNU GPL v2 or later",
    layer     = 0,
    enabled   = true  --  loaded by default?
 }
end

local Chili = nil
local screen = nil
local XPPanel = nil
local XPBar = nil
local XPLabel = nil

function widget:Initialize()
  Chili = WG.Chili
  if not Chili then
    widgetHandler:RemoveWidget()
    return
  end
end

local function attachXPBar(parent)
  if not Chili then
    Chili = WG.Chili
    if not Chili then
      widgetHandler:RemoveWidget()
      return
    end
  end

  XPBar = Chili.Progressbar:New {
    parent = parent,
    x = 0,
    y = 0,
    width = '100%',
    height = 24,
  }
end

local function updateXPBarCaption(experience)
  if XPBar then
    XPBar:SetCaption("Level " .. tostring(math.floor(experience)))
  end
end

local function hideXPBar()
  if XPBar then
    XPBar:Hide()
  end
end

local function showXPBar()
  if XPBar then
    XPBar:Show()
  end
end

WG.ShowXPBar = showXPBar
WG.HideXPBar = hideXPBar
WG.AttachXPBar = attachXPBar

function widget:GameFrame(frame)
  local unitID = WG.GetSelectedPerkUnit()
  
  if unitID then
    local experience = Spring.GetUnitExperience(unitID)
    if experience then
      local lvl,progress = math.modf(experience)
      XPBar:SetValue(progress)
      XPBar:SetMinMax(0.0, 1.0)
      updateXPBarCaption(lvl)
    end
  end
end