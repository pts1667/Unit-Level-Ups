function widget:GetInfo()
  return {
    name      = "Stack Info",
    desc      = "Displays unit stack info",
    author    = "Presstabstart",
    date      = "now",
    license   = "GNU GPL v2 or later",
    layer     = 0,
    enabled   = true  --  loaded by default?
 }
end

local stackDefs = VFS.Include("luarules/configs/stackdefs.lua")

local Chili = nil
local stackWindow = nil
local stackIcons = {}
local stackLabels = {}

local function getStackInfo(unitID)
  local stackInfo = {}
  for effectName,_ in pairs(stackDefs) do
    stackInfo[effectName] = Spring.GetUnitRulesParam(unitID, "stack_" .. effectName)
  end

  return stackInfo
end

function widget:Initialize()
  Chili = WG.Chili
  if not Chili then
    widgetHandler:RemoveWidget()
    return
  end

  stackWindow = Chili.Window:New {
    dockable = false,
    name = "Stack Window",
    x = '70%',
    y = 40,
    width = '30%',
    height = 150,
    margin = {5, 5, 5, 5},
    padding = {5, 5, 5, 5},
    classname = "stack_info",
    draggable = false,
    resizable = false,
    tweakDraggable = false,
    tweakResizable = false,
    parent = Chili.Screen0
  }

  local n = 0
  local windowWidth = stackWindow.width
  for stackName,stackInfo in pairs(stackDefs) do
    local x = (n * 64) % windowWidth
    local y = math.floor((n * 64) / windowWidth) * 64
    stackIcons[stackName] = Chili.Image:New {
      x = x,
      y = y,
      width = 64,
      height = 64,
      file = "LuaUI/Images/" .. stackInfo.icon,
      parent = stackWindow
    }

    stackLabels[stackName] = Chili.Label:New {
      x = 8,
      y = 8,
      width = 50,
      height = 24,
      fontSize = 24,
      fontShadow = false,
      parent = stackIcons[stackName]
    }

    n = n + 1
  end

  for effectName,_ in pairs(stackDefs) do
    stackIcons[effectName]:Hide()
    stackLabels[effectName]:Hide()
  end
end

function widget:GameFrame(frame)
  local selectedUnit = WG.GetSelectedPerkUnit()
  if not selectedUnit then 
    for effectName,_ in pairs(stackDefs) do
      stackIcons[effectName]:Hide()
      stackLabels[effectName]:Hide()
    end

    return
  end

  local stackInfo = getStackInfo(selectedUnit)
  for effectName,numStacks in pairs(stackInfo) do
    stackLabels[effectName]:SetCaption(tostring(numStacks))
  end

  for effectName,_ in pairs(stackDefs) do
    if stackInfo[effectName] and (stackInfo[effectName] > 0) then
      stackIcons[effectName]:Show()
      stackLabels[effectName]:Show()
    else
      stackIcons[effectName]:Hide()
      stackLabels[effectName]:Hide()
    end
  end
end