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

CollectionatorTMogScannerFrameMixin = {}

function CollectionatorTMogScannerFrameMixin:OnLoad()
  self.sources = {}
  self.droppedCount = 0
  self.leftCount = 0

  self.mode = "player"
  self:ClearScene()

  self.dirty = false

  Auctionator.EventBus:RegisterSource(self, "CollectionatorTMogScannerFrameMixin")
  Auctionator.EventBus:Register(self, {
    Auctionator.FullScan.Events.ScanComplete
  })
  self:LoadOldScan()
end

function CollectionatorTMogScannerFrameMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.FullScan.Events.ScanComplete then
    self.dirty = true
    self.fullScan = eventData

    if self:IsShown() then
      self:Process()
    end
  end
end

function CollectionatorTMogScannerFrameMixin:LoadOldScan()
  local oldScan = COLLECTIONATOR_LAST_FULL_SCAN
  if oldScan and oldScan.realm == Auctionator.Variables.GetConnectedRealmRoot() then
    self.dirty = true
    self.fullScan = oldScan.data or {}
  end
end

function CollectionatorTMogScannerFrameMixin:Process()
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

  assert(self:IsReady())
  self:BatchStep(1, 500)
end

function CollectionatorTMogScannerFrameMixin:ClearScene()
  self.ModelScene:ClearScene();
  self.ModelScene:SetViewInsets(0, 0, 0, 0);
  self.ModelScene:TransitionToModelSceneID(290, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);
  self:ResetPlayer()
end

function CollectionatorTMogScannerFrameMixin:ResetPlayer()
  SetupPlayerForModelScene(self.ModelScene, nil, false, false);
end

function CollectionatorTMogScannerFrameMixin:PlayerActor()
  return self.ModelScene:GetPlayerActor()
end

function CollectionatorTMogScannerFrameMixin:IsReady()
  return self:PlayerActor() and self:PlayerActor():IsLoaded()
end

function CollectionatorTMogScannerFrameMixin:OnUpdate()
  if not self:PlayerActor():IsLoaded() then
    self:ClearScene()
  end
end


function CollectionatorTMogScannerFrameMixin:GetSlotSource(index, link)
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
      local visual = C_TransmogCollection.GetSourceInfo(source).visualID
      local set = C_TransmogCollection.GetAllAppearanceSources(visual)
      if #set == 0 then
        set = {source}
      end
      table.insert(self.sources, {
        id = source, visual = visual, index = index, set = set
      })
      return
    end
  end
  self.droppedCount = self.droppedCount + 1
end

function CollectionatorTMogScannerFrameMixin:BatchStep(start, limit)
  Auctionator.Debug.Message("CollectionatorTMogScannerFrameMixin:BatchStep", start, limit)
  if start > #self.fullScan then
    Auctionator.Debug.Message("CollectionatorTMogScannerFrameMixin:BatchStep", "READY", start, self.droppedCount, #self.sources)
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
