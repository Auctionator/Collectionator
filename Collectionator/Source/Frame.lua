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

CollectionatorDressUpFrameMixin = {}

function CollectionatorDressUpFrameMixin:OnLoad()
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

  self.dirty = false
end

function CollectionatorDressUpFrameMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.FullScan.Events.ScanComplete then
    self.dirty = true
    self.fullScan = eventData

    if self:IsShown() then
      self:Process()
    end
  end
end

function CollectionatorDressUpFrameMixin:LoadOldScan()
  local oldScan = COLLECTIONATOR_LAST_FULL_SCAN
  if oldScan and oldScan.realm == Auctionator.Variables.GetConnectedRealmRoot() then
    self.dirty = true
    self.fullScan = oldScan.data or {}
  end
end

function CollectionatorDressUpFrameMixin:OnEvent(event, ...)
  Auctionator.EventBus:RegisterSource(self, "CollectionatorDressUpFrameMixin")
  if event == "VARIABLES_LOADED" then
    Auctionator.EventBus:Register(self, {
      Auctionator.FullScan.Events.ScanComplete
    })
    self:LoadOldScan()
  end
end

function CollectionatorDressUpFrameMixin:Process()
  if not self.dirty or #self.fullScan == 0 then
    return
  end

  self.dirty = false

  Auctionator.EventBus:Fire(
    self,
    Collectionator.Events.SourceLoadStart,
    self.sources
  )

  self.sources = {}
  self.droppedCount = 0
  self.leftCount = #self.fullScan

  if self:IsReady() then
    self:BatchStep(1, 500)
  end
end

function CollectionatorDressUpFrameMixin:ClearScene()
  self.ModelScene:ClearScene();
  self.ModelScene:SetViewInsets(0, 0, 0, 0);
  self.ModelScene:TransitionToModelSceneID(290, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);
  self:ResetPlayer()
end

function CollectionatorDressUpFrameMixin:ResetPlayer()
  SetupPlayerForModelScene(self.ModelScene, nil, false, false);
end

function CollectionatorDressUpFrameMixin:PlayerActor()
  return self.ModelScene:GetPlayerActor()
end

function CollectionatorDressUpFrameMixin:IsReady()
  return self:PlayerActor() and self:PlayerActor():IsLoaded()
end

function CollectionatorDressUpFrameMixin:OnUpdate()
  if not self:PlayerActor():IsLoaded() then
    self:ClearScene()
  end
end


function CollectionatorDressUpFrameMixin:GetSlotSource(index, link)
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

function CollectionatorDressUpFrameMixin:BatchStep(start, limit)
  Auctionator.Debug.Message("CollectionatorDressUpFrameMixin:BatchStep", start, limit)
  if start > #self.fullScan then
    Auctionator.Debug.Message("CollectionatorDressUpFrameMixin:BatchStep", "READY", start, self.droppedCount, #self.sources)
    return
  end

  for i=start, math.min(limit, #self.fullScan) do
    local link = self.fullScan[i].itemLink

    local item = Item:CreateFromItemID(self.fullScan[i].replicateInfo[17])
    item:ContinueOnItemLoad((function(index, link)
      return function()
        if IsDressableItem(link) then
          self:GetSlotSource(index, link)
        end

        self.leftCount = self.leftCount - 1
        if self.leftCount == 0 then
          Auctionator.EventBus:Fire(
            self,
            Collectionator.Events.SourceLoadEnd,
            self.sources,
            self.fullScan
          )
        end
      end
    end)(i, link))
  end

  C_Timer.After(0.01, function()
    self:BatchStep(limit + 1, limit + 1 + (limit-start))
  end)
end
