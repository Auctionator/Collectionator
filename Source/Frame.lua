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

HUNTING_SOURCES = {}
HUNTING_MISSED = 0
HUNTING_LEFT = 0

local function GetFS()
  return AUCTIONATOR_RAW_FULL_SCAN[Auctionator.Variables.GetConnectedRealmRoot()] or {}
end

HuntingDressUpFrameMixin = {}

function HuntingDressUpFrameMixin:OnLoad()
  self.sources = {}
  self.droppedCount = 0
  self.leftCount = 0
  FrameUtil.RegisterFrameForEvents(self, {
    "VARIABLES_LOADED"
  })

  self.mode = "player"
  self:ClearScene()
  self:Show()
  self.ModelScene:Hide()
end

function HuntingDressUpFrameMixin:OnEvent(...)
  Auctionator.EventBus:RegisterSource(self, "HuntingDressUpFrameMixin")
end

function HuntingDressUpFrameMixin:Process()
  Auctionator.EventBus:Fire(
    self,
    Hunting.Events.SourceLoadStart,
    self.sources
  )

  self.sources = {}
  self.droppedCount = 0
  self.leftCount = #GetFS()

  if self:IsReady() then
    self:BatchStep(1, 500)
  end
end

function HuntingDressUpFrameMixin:ClearScene()
  self.ModelScene:ClearScene();
  self.ModelScene:SetViewInsets(0, 0, 0, 0);
  self.ModelScene:TransitionToModelSceneID(290, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);
  self:ResetPlayer()
end

function HuntingDressUpFrameMixin:ResetPlayer()
  SetupPlayerForModelScene(self.ModelScene, nil, false, false);
end

function HuntingDressUpFrameMixin:PlayerActor()
  return self.ModelScene:GetPlayerActor()
end

function HuntingDressUpFrameMixin:IsReady()
  return self:PlayerActor() and self:PlayerActor():IsLoaded()
end

function HuntingDressUpFrameMixin:OnUpdate()
  if not self:PlayerActor():IsLoaded() then
    self:ClearScene()
  end
end


function HuntingDressUpFrameMixin:GetSlotSource(index, link)
  local possibleSlots = INVENTORY_TYPES_TO_SLOT[select(9, GetItemInfo(link))]
  if not possibleSlots then
    self.droppedCount = self.droppedCount + 1
    return
  elseif #possibleSlots > 1 then
    self:ResetPlayer()
  end

  local pa = self.ModelScene:GetPlayerActor()

  pa:TryOn(link)

  for _, slot in ipairs(possibleSlots) do
    local source = pa:GetSlotTransmogSources(slot)
    if source ~= 0 then
      table.insert(self.sources, {id = source, index = index})
      return
    end
  end
  self.droppedCount = self.droppedCount + 1
end

function HuntingDressUpFrameMixin:BatchStep(start, limit)
  Auctionator.Debug.Message("HuntingDressUpFrameMixin:BatchStep", start, limit)
  if start > #GetFS() then
    Auctionator.Debug.Message("HuntingDressUpFrameMixin:BatchStep", "READY", start, self.droppedCount, #self.sources)
    return
  end

  for i=start, math.min(limit, #GetFS()) do
    local link = GetFS()[i].itemLink

    local item = Item:CreateFromItemID(GetFS()[i].replicateInfo[17])
    item:ContinueOnItemLoad((function(index, link)
      return function()
        if IsDressableItem(link) then
          self:GetSlotSource(index, link)
        end

        self.leftCount = self.leftCount - 1
        if self.leftCount == 0 then
          Auctionator.EventBus:Fire(
            self,
            Hunting.Events.SourceLoadEnd,
            self.sources
          )
        end
      end
    end)(i, link))
  end

  C_Timer.After(0.01, function()
    self:BatchStep(limit + 1, limit + 1 + (limit-start))
  end)
end

function FindSourceID(id)
  local result = {}
  for index, details in ipairs(HuntingDressUpFrame.sources) do
    if details.id == id then
      local entry = GetFS()[details.index]
      print(entry.itemLink)
      print(
        Auctionator.Utilities.CreateMoneyString(entry.replicateInfo[10]),
        entry.replicateInfo[17]
      )
    end
  end
end
