return {
  onPick = function (unitID)
    if GG.MiniMeList[unitID] then
      GG.CreateShieldDummy({ unit = unitID }, "small")
    end
  end
}