local PURCHASE_WATCH_VERSION = 2

local PURCHASE_EVENTS = {
  "AUCTION_CANCELED",
  "AUCTION_HOUSE_CLOSED",
}
CollectionatorPurchaseWatchFrameMixin = {}

function CollectionatorPurchaseWatchFrameMixin:OnLoad()
  self:RegisterEvent("ADDON_LOADED")
  Auctionator.EventBus:RegisterSource(self, "CollectionatorPurchaseWatchFrameMixin")
end

function CollectionatorPurchaseWatchFrameMixin:RegisterNeededEvents()
  if not self.registeredEvents and next(self.waitingIDs) ~= nil then
    FrameUtil.RegisterFrameForEvents(self, PURCHASE_EVENTS)
    self.registeredEvents = true
  elseif self.registeredEvents and next(self.waitingIDs) == nil then
    FrameUtil.UnregisterFrameForEvents(self, PURCHASE_EVENTS)
    self.registeredEvents = false
  end
end

function CollectionatorPurchaseWatchFrameMixin:OnEvent(event, ...)
  if event == "ADDON_LOADED" then
    local addonName = ...
    if addonName == "Collectionator" then
      self:UnregisterEvent("ADDON_LOADED")

      if not COLLECTIONATOR_PURCHASES or COLLECTIONATOR_PURCHASES.Version ~= PURCHASE_WATCH_VERSION then
        self:ResetData()
      else
        Collectionator.State.Purchases = COLLECTIONATOR_PURCHASES
      end

      self.registeredEvents = false

      self.waitingIDs = {}

      Auctionator.EventBus:Register(self, {
        Collectionator.Events.PurchaseAttempted
      })
    end

  elseif event == "AUCTION_CANCELED" then
    self:ProcessPurchase(...)
    self:RegisterNeededEvents()

  elseif event == "AUCTION_HOUSE_CLOSED" then
    self.waitingIDs = {}
    self:RegisterNeededEvents()
  end
end

function CollectionatorPurchaseWatchFrameMixin:ReceiveEvent(eventName, ...)
  if not Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_PURCHASE_WATCH) then
    return
  end

  if eventName == Collectionator.Events.PurchaseAttempted then
    local auctionID, itemLink = ...
    self.waitingIDs[auctionID] = itemLink
    self:RegisterNeededEvents()
  end
end

function CollectionatorPurchaseWatchFrameMixin:ResetData()
  COLLECTIONATOR_PURCHASES = {
    TMog = {},
    Pets = {},
    Toys = {},
    Mounts = {},
    Recipes = {},
    Version = PURCHASE_WATCH_VERSION,
  }
  Collectionator.State.Purchases = COLLECTIONATOR_PURCHASES
end

function CollectionatorPurchaseWatchFrameMixin:ProcessPurchase(auctionID)
  if self.waitingIDs[auctionID] == nil then
    return
  end

  local itemLink = self.waitingIDs[auctionID]

  if string.match(itemLink, "battlepet") then
    self:ProcessPetDetails(itemLink)
  else
    local itemID = C_Item.GetItemInfoInstant(itemLink)
    ItemEventListener:AddCallback(itemID, function()
      local classID, subClassID = select(12, C_Item.GetItemInfo(itemLink))

      if classID == Enum.ItemClass.Weapon or classID == Enum.ItemClass.Armor then
        self:ProcessTMogDetails(itemLink)
      elseif C_PetJournal.GetPetInfoByItemID(itemID) ~= nil then
        self:ProcessPetDetails(itemLink)
      elseif C_ToyBox.GetToyInfo(itemID) ~= nil then
        self:ProcessToyDetails(itemID)
      elseif classID == Enum.ItemClass.Miscellaneous and subClassID == Enum.ItemMiscellaneousSubclass.Mount then
        self:ProcessMountDetails(itemID)
      elseif classID == Enum.ItemClass.Recipe then
        self:ProcessRecipeDetails(itemID)
      end
    end)
  end
  self.waitingIDs[auctionID] = nil
end

function CollectionatorPurchaseWatchFrameMixin:ProcessTMogDetails(itemLink)
  local _, source = C_TransmogCollection.GetItemInfo(itemLink)
  if source == nil then
    _, source = C_TransmogCollection.GetItemInfo(C_Item.GetItemInfoInstant(itemLink))
  end
  if source ~= nil then
    local sourceInfo = C_TransmogCollection.GetSourceInfo(source)
    Collectionator.State.Purchases.TMog[source] = true

    Auctionator.EventBus:Fire(self, Collectionator.Events.TMogPurchased)
  end
end

function CollectionatorPurchaseWatchFrameMixin:ProcessPetDetails(itemLink)
  local petID, petLevel
  if string.match(itemLink, "battlepet") then
    petID = tonumber(string.match(itemLink, "battlepet:(%d+):"))
    petLevel = Auctionator.Utilities.GetPetLevelFromLink(itemLink)
  else
    local itemID = C_Item.GetItemInfoInstant(itemLink)
    petID = select(13, C_PetJournal.GetPetInfoByItemID(itemID))
    petLevel = 1
  end

  Collectionator.State.Purchases.Pets[petID] = Collectionator.State.Purchases.Pets[petID] or {}
  Collectionator.State.Purchases.Pets[petID][petLevel] = true

  Auctionator.EventBus:Fire(self, Collectionator.Events.PetPurchased)
end

function CollectionatorPurchaseWatchFrameMixin:ProcessToyDetails(itemID)
  local toyID = C_ToyBox.GetToyInfo(itemID)

  Collectionator.State.Purchases.Toys[toyID] = true

  Auctionator.EventBus:Fire(self, Collectionator.Events.ToyPurchased)
end

function CollectionatorPurchaseWatchFrameMixin:ProcessMountDetails(itemID)
  local mountID = C_MountJournal.GetMountFromItem(itemID)

  Collectionator.State.Purchases.Mounts[mountID] = true

  Auctionator.EventBus:Fire(self, Collectionator.Events.MountPurchased)
end

function CollectionatorPurchaseWatchFrameMixin:ProcessRecipeDetails(itemID)
  local spellID = COLLECTIONATOR_RECIPES_TO_IDS[itemID]

  if spellID ~= nil then
    Collectionator.State.Purchases.Recipes[spellID] = true

    Auctionator.EventBus:Fire(self, Collectionator.Events.RecipePurchased)
  end
end
