if not gadgetHandler:IsSyncedCode() then return end

function gadget:GetInfo()
  return {
    name      = "Unit effect stacks",
    desc      = "Stacks",
    author    = "Presstabstart",
    date      = "now",
    license   = "GNU GPL v2 or later",
    layer     = 0,
    enabled   = true  --  loaded by default?
 }
end

local Queue = VFS.Include("luarules/utils/queue.lua")
local stacks = {}

local function addStackQueue(unitID, effectName, duration, maxStacks)
  stacks[unitID] = stacks[unitID] or {}
  stacks[unitID][effectName] = {
    stackQueue = Queue.new(),
    duration = duration,
    max = maxStacks
  }
end

local function removeStackQueue(unitID, effectName)
  if stacks[unitID] then
    stacks[unitID][effectName] = nil
  end
end

local function addStack(unitID, effectName)
  local unitStacks = stacks[unitID]
  local stackInfo = unitStacks[effectName]
  local stackQueue = stackInfo.stackQueue

  if Queue.len(stackQueue) > stacks[unitID][effectName].max then
    Queue.popright(stackQueue)
  end

  Queue.pushleft(stackQueue, Spring.GetGameFrame())
end

local function popStack(unitID, effectName)
  Queue.popright(stacks[unitID][effectName].stackQueue)
end

local function updateStackInfo(unitID)
  for effectName,stackQueueInfo in pairs(stacks[unitID]) do
    local stackLen = Queue.len(stackQueueInfo.stackQueue)
    Spring.SetUnitRulesParam(unitID, "stack_" .. effectName, stackLen)
  end
end

local function getNumStacks(unitID, stackEffect)
  if stacks[unitID] and stacks[unitID][stackEffect] then
    return Queue.len(stacks[unitID][stackEffect].stackQueue)
  end

  return 0
end

GG.AddStackQueue = addStackQueue
GG.RemoveStackQueue = removeStackQueue
GG.UpdateStackInfo = updateStackInfo
GG.AddStack = addStack
GG.PopStack = popStack
GG.GetNumStacks = getNumStacks

function gadget:UnitDestroyed(unitID)
  if stacks[unitID] then
    stacks[unitID] = nil
  end
end

function gadget:GameFrame(frame)
  for unitID,stackTable in pairs(stacks) do
    for effectname,stackQueueInfo in pairs(stackTable) do
      local stackQueue = stackQueueInfo.stackQueue
      local duration = stackQueueInfo.duration
      while stackQueue[stackQueue.last] and ((frame - stackQueue[stackQueue.last]) > duration) do
        Queue.popright(stackQueue)
      end
    end

    updateStackInfo(unitID)
  end
end