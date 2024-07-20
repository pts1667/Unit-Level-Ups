local perkDefs, perkIDTable = VFS.Include("luarules/configs/perkdefs.lua")
local perkFuncList = {}

for perkName,_ in pairs(perkDefs) do
  perkFuncList[perkName] = VFS.Include("luarules/configs/perkfuncs/perkfunclist/" .. string.lower(perkName) .. ".lua")
end

return perkFuncList