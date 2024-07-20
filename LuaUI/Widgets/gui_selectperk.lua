function widget:GetInfo()
  return {
    name      = "Perk Selector",
    desc      = "Select perks for units",
    author    = "Presstabstart, PetTurtle",
    date      = "now",
    license   = "GNU GPL v2 or later",
    layer     = 0,
    enabled   = true  --  loaded by default?
 }
end

VFS.Include("LuaRules/Configs/customcmds.h.lua")
local perkInfo, perkIDTable = VFS.Include("LuaRules/configs/perkdefs.lua")
local uluSettings = VFS.Include("LuaRules/configs/levelupsettings.lua")

local CMD_INSERT = CMD.INSERT
local CMD_OPT_SHIFT    = CMD.OPT_SHIFT
local CMD_PERK_SELECT = 51518

local Chili = nil
local window = nil
local perkTreePanel = nil
local windowLineCtrl = nil
local window_opener = nil
local selectedUnit = nil
local perkCounter = nil

local perkTreeOpen = true
local perkOpenerVisible = true

local buttons = {}
local buttonImages = {}
local buttonNames = {}
local lines = {}
local perkButtonTable = {}

local function selectPerkCommand(self, unitID, perkName)
  Spring.GiveOrderToUnit(unitID, CMD_INSERT, {0, CMD_PERK_SELECT, CMD_OPT_SHIFT, perkInfo[perkName].id}, {"alt"})
end

local function getSelectedPerkUnit()
  return selectedUnit
end

WG.GetSelectedPerkUnit = getSelectedPerkUnit

local function createLine(fromX, fromY, toX, toY)
  local x = math.min(fromX, toX)
  local width = math.max(fromX, toX) - x
  local y = math.min(fromY, toY)
  local height = math.max(fromY, toY) - y
  
  lines[#lines+1] = {
    x = x,
    y = y,
    width = width,
    height = height
  }
end

local function drawLines(w, h, c)
  for i=1,#lines do
    local x1 = lines[i].x / w
    local y1 = lines[i].y / h
    local x2 = (lines[i].x + lines[i].width) / w
    local y2 = (lines[i].y + lines[i].height) / h
    c = c or {1.0, 1.0, 1.0}
    gl.Color(c)
    gl.Vertex(x1, y1)
    gl.Color(c)
    gl.Vertex(x2, y2)
  end
end

local function createPerkButton(x, y, perkName)
  local iconName = perkInfo[perkName].icon or "perk_placeholder.png"
  buttons[#buttons+1] = Chili.Button:New {
    x = x,
    y = y,
    width = 80,
    height = 80,
    margin = {0,0,0,0},
    padding = {0,0,0,0},
    caption = "",
    tooltip = perkInfo[perkName].description,
    onClick = {
      function (self)
        selectPerkCommand(self, selectedUnit, perkName)
      end
    },
    parent = perkTreePanel
  }

  buttonImages[#buttonImages+1] = Chili.Image:New {
    width = 48,
    height = 48,
    x = 8,
    y = 24,
    align = "center",
    file = "LuaUI/Images/"..iconName,
    keepAspect = false,
    parent = buttons[#buttons]
  }

  buttonNames[#buttonNames+1] = Chili.Label:New {
    width = '100%',
    height = '20%',
    x = 6,
    y = 6,
    valign = "top",
    caption = perkInfo[perkName].name,
    fontSize = 10,
    fontShadow = false,
    parent = buttons[#buttons]
  }

  perkButtonTable[perkName] = #buttons
  return buttons[#buttons]
end

local function fillWithPerk(perkName, angle, level, x, y)
  createPerkButton(x, y, perkName)
  local perksThatRequire = {}
  for perkIterName, perk in pairs(perkInfo) do
    if perk.prerequisites then
      for i,perkReqName in ipairs(perk.prerequisites) do
        if perkReqName == perkName then
          perksThatRequire[#perksThatRequire+1] = perkIterName
        end
      end
    end
  end

  local adjLevel = 1 + (level - 1) * 0.5
  local angleBegin = angle - (40.0 / adjLevel)
  local angleEnd = angle + (40.0 / adjLevel)
  for i,addPerk in ipairs(perksThatRequire) do
    local perkAngle = (angleBegin + (i / #perksThatRequire) * (angleEnd - angleBegin)) % 360;
    local perkX = x + math.cos(math.rad(perkAngle)) * 128.0;
    local perkY = y + math.sin(math.rad(perkAngle)) * 128.0;

    createLine(x, y, perkX, perkY)
    fillWithPerk(addPerk, perkAngle, level + 1, perkX, perkY)
  end
end

local function hasPrereqs(perkName, perks)
  local prereqList = perkInfo[perkName].prerequisites
  for i=1,#prereqList do
    if not perks[prereqList[i]] then
      return false
    end
  end

  return true
end


local function fillPerkTree(rootPosX, rootPosY)
  local rootPosX, rootPosY = perkTreePanel.width * 0.5, perkTreePanel.height * 0.5
  local rootPerks = {}
  for perkName, perk in pairs(perkInfo) do
    if not perk.prerequisites then
      rootPerks[#rootPerks+1] = perkName
    end
  end

  for i,rootPerk in ipairs(rootPerks) do
    local angle = (i / #rootPerks) * 360.0
    local childX = rootPosX + math.cos(math.rad(angle)) * 128.0
    local childY = rootPosY + math.sin(math.rad(angle)) * 128.0
    createLine(rootPosX, rootPosY, childX, childY)
    fillWithPerk(rootPerk, angle, 1, childX, childY)
  end
end

-- TODO: stop being lazy and recursively hide children
local function windowVisible(vis)
  if vis and (not perkTreeOpen) then
    window:Show()
    perkTreePanel:Show()
    --windowLineCtrl:Show()
    for i=2,#buttons do
      buttons[i]:Show()
      buttonImages[i-1]:Show()
      buttonNames[i-1]:Show()
    end
  elseif (not vis) and perkTreeOpen then
    window:Hide()
    perkTreePanel:Hide()
    --windowLineCtrl:Hide()
    for i=2,#buttons do
      buttons[i]:Hide()
      buttonImages[i-1]:Hide()
      buttonNames[i-1]:Hide()
    end
  end

  perkTreeOpen = vis
end

local function PerksOpenerVisible(vis)
  if vis and (not perkOpenerVisible) then
    window_opener:Show()
    buttons[1]:Show()
    WG.ShowXPBar()
  elseif (not vis) and perkOpenerVisible then
    window_opener:Hide()
    buttons[1]:Hide()
    WG.HideXPBar()
  end

  perkOpenerVisible = vis
end

function widget:Initialize()
  Chili = WG.Chili
  if not Chili then
    widgetHandler:RemoveWidget()
    return
  end

  window_opener = Chili.Window:New {
    dockable = false,
    name = "Perk Info",
    x = 40,
    y = 40,
    width = 256,
    height = 96,
    margin = {5, 5, 5, 5},
    padding = {5, 5, 5, 5},
    classname = "perk_info",
    draggable = true,
    resizable = false,
    tweakDraggable = true,
    tweakResizable = false,
    parent = Chili.Screen0
  }

  buttons[#buttons+1] = Chili.Button:New {
    x = 0,
    y = 24,
    width = 100,
    height = 40,
    margin = {4,4,4,4},
    padding = {4,4,4,4},
    caption = "Perk Tree",
    onClick = {
      function (self)
        windowVisible(not perkTreeOpen)
      end
    },
    parent = window_opener
  }

  WG.AttachXPBar(window_opener)

  window = Chili.Window:New {
    dockable = false,
    name = "Perk Tree",
    x = '20%',
    y = '20%',
    width = '60%',
    height = '75%',
    minWidth = 400,
    minHeight = 400,
    margin = {5, 5, 5, 5},
    padding = {5, 5, 5, 5},
    classname = "main_window",
    draggable = true,
    resizable = false,
    tweakDraggable = true,
    tweakResizable = false,
    minimizable = false,
    parent = Chili.Screen0,
  }

  perkTreePanel = Chili.Panel:New {
    x = 0,
    y = 0,
    width = '100%',
    height = '100%',
    backgroundColor = {0.1, 0.1, 0.1, 0.5},
    borderColor = {1.0, 1.0, 1.0, 1.0},
    parent = window
  }

  perkCounter = Chili.Label:New {
    caption = "Available perks: ",
    fontSize = 16,
    valign = "bottom",
    align = "left",
    fontShadow = false,
    parent = perkTreePanel
  }

  fillPerkTree(perkTreePanel.width * 0.5, perkTreePanel.height * 0.5)
  perkTreePanel:Invalidate()
  perkTreePanel:UpdateClientArea()
  windowVisible(false)
  PerksOpenerVisible(false)
end

local function getPerks(unitID)
  local perks = {}
  for perkName,perk in pairs(perkInfo) do
    local hasPerk = (Spring.GetUnitRulesParam(unitID, "perk_"..perkName) and true) or false
    if hasPerk then
      perks[perkName] = true
    end
  end

  return perks
end

local function updatePerkTree()
  if not selectedUnit then
    return
  end

  local perks = getPerks(selectedUnit)
  for perkName,_ in pairs(perkInfo) do
    local buttonID = perkButtonTable[perkName]
    if perks[perkName] and not (buttons[buttonID].perkToggled) then
      buttons[buttonID].backgroundColor = {0.1, 0.9, 0.1, 0.5}
      buttons[buttonID].perkToggled = true
      buttons[buttonID]:Invalidate()
    elseif (not perks[perkName]) then
      if perkInfo[perkName].prerequisites and (not hasPrereqs(perkName, perks)) then
        buttons[buttonID].backgroundColor = {0.9, 0.1, 0.1, 0.5}
      else
        buttons[buttonID].backgroundColor = nil
      end

      if buttons[buttonID].perkToggled then
        buttons[buttonID].perkToggled = false
      end

      buttons[buttonID]:Invalidate()
    end
  end

  local numPerks = Spring.GetUnitRulesParam(selectedUnit, "perk_points")
  if numPerks then
    perkCounter:SetCaption("Available perks: "..numPerks)
  end
end

local function updatePerkOpener(newUnit)
  local usesPerks = (Spring.GetUnitRulesParam(newUnit, "perk_points") and true) or false
  if usesPerks then
    PerksOpenerVisible(true)

    if not (newUnit == selectedUnit) then
      selectedUnit = newUnit
      updatePerkTree()
      return
    end
  else
    selectedUnit = newUnit
    PerksOpenerVisible(false)
    windowVisible(false)
    window_opener:Show()
    WG.ShowXPBar()
    return
  end
end

function widget:CommandsChanged()
  local units = Spring.GetSelectedUnits()
  if (not units) or not (#units == 1) then
    PerksOpenerVisible(false)
    windowVisible(false)
    selectedUnit = nil
    return
  end

  updatePerkOpener(units[1])
end

function widget:UnitExperience(unitID, unitDefID, unitTeam, exp, oldExp)
  local madeElite = exp >= uluSettings.eliteLevel and oldExp < uluSettings.eliteLevel
  if madeElite and unitID == selectedUnit then
    updatePerkOpener(unitID)
  end
end

function widget:UnitCmdDone(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOpts, cmdTag)
  updatePerkTree() -- todo
end