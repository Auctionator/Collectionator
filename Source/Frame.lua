local INVENTORY_TYPES_TO_SLOT = {
  ["INVTYPE_AMMO"] = {0},
  ["INVTYPE_HEAD"] = {1},
  ["INVTYPE_NECK"] = {2},
  ["INVTYPE_SHOULDER"] = {3},
  ["INVTYPE_BODY"] = {4},
  ["INVTYPE_CHEST"] = {5},
  ["INVTYPE_ROBE"] = {5},
  ["INVTYPE_WAIST"] = {6},
  ["INVTYPE_LEGS"] = {7},
  ["INVTYPE_FEET"] = {8},
  ["INVTYPE_WRIST"] = {9},
  ["INVTYPE_HAND"] = {10},
  --["INVTYPE_FINGER"] = {11,12},
  --["INVTYPE_TRINKET"] = {13,14},
  ["INVTYPE_CLOAK"] = {15},
  ["INVTYPE_WEAPON"] = {16,17},
  ["INVTYPE_SHIELD"] = {17},
  ["INVTYPE_2HWEAPON"] = {16},
  ["INVTYPE_WEAPONMAINHAND"] = {16},
  ["INVTYPE_WEAPONOFFHAND"] = {17},
  ["INVTYPE_HOLDABLE"] = {17},
  ["INVTYPE_RANGED"] = {18},
  ["INVTYPE_THROWN"] = {18},
  ["INVTYPE_RANGEDRIGHT"] = {18},
  ["INVTYPE_RELIC"] = {18},
  ["INVTYPE_TABARD"] = {19},
}

PMDressUpFrameMixin = {}

function PMDressUpFrameMixin:OnLoad()
  self.mode = "player"
  self:ClearScene()
  self:Show()
  self.ModelScene:Hide()
end

function PMDressUpFrameMixin:Process()
  if self:IsReady() then
    BatchStep(self:PlayerActor(), 1, 500)
  end
end

function PMDressUpFrameMixin:ClearScene()
  self.ModelScene:ClearScene();
  self.ModelScene:SetViewInsets(0, 0, 0, 0);
  self.ModelScene:TransitionToModelSceneID(290, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);
  SetupPlayerForModelScene(self.ModelScene, nil, false, false);
end

function PMDressUpFrameMixin:PlayerActor()
  return self.ModelScene:GetPlayerActor()
end

function PMDressUpFrameMixin:IsReady()
  return self:PlayerActor() and self:PlayerActor():IsLoaded()
end

function PMDressUpFrameMixin:OnUpdate()
  if not self:PlayerActor():IsLoaded() then
    print("setup")
    self:ClearScene()
  end
end

PM_SOURCES = {}
function GetSlotSource(index, link)
  local pa = PMDressUpFrame.ModelScene:GetPlayerActor()
  local possibleSlots = INVENTORY_TYPES_TO_SLOT[select(9, GetItemInfo(link))]
  if possibleSlots == nil then
    return false
  end

  for _, slot in ipairs(possibleSlots) do
    local source = pa:GetSlotTransmogSources(slot)
    if source ~= 0 then
      table.insert(PM_SOURCES, {s = source, index = index})
      break
    end
  end
end

PM_SOURCES = {}

local function GetFS()
  return AUCTIONATOR_RAW_FULL_SCAN[Auctionator.Variables.GetConnectedRealmRoot()] or {}
end

function FindSourceID(id)
  local result = {}
  for index, details in ipairs(PM_SOURCES) do
    if details.s == id then
      local entry = GetFS()[details.index]
      print(entry.itemLink)
      print(
        Auctionator.Utilities.CreateMoneyString(entry.auctionInfo[10]),
        entry.auctionInfo[17]
      )
    end
  end
end

function BatchStep(pa, start, limit)
  Auctionator.Debug.Message("MogHunter.BatchStep", start, limit)
  if start > #GetFS() then
    print("READY", start, #PM_SOURCES)
    return
  end
  print("partway", start, #PM_SOURCES)

  for i=start, math.min(limit, #GetFS()) do
    local link = GetFS()[i].itemLink

    local item = Item:CreateFromItemID(GetFS()[i].auctionInfo[17])
    item:ContinueOnItemLoad((function(index, link)
      return function()
        --local arr = {GetItemInfo(link)}
        if IsDressableItem(link) then
          --local pa = ClearScene(PMDressUpFrame)
          local result = pa:TryOn(link)
          if EnumerateTooltipLines(MogHunterTooltip, link) then
            GetSlotSource(index, link)
          end
        end
      end
    end)(i, link))
  end

  C_Timer.After(0.01, function()
    BatchStep(pa, limit + 1, limit + 1 + (limit-start))
  end)
end
