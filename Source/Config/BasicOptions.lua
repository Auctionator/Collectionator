CollectionatorConfigBasicOptionsFrameMixin = {}

function CollectionatorConfigBasicOptionsFrameMixin:OnLoad()
  Auctionator.Debug.Message("CollectionatorConfigBasicOptionsFrameMixin:OnLoad()")
  self:SetParent(SettingsPanel or InterfaceOptionsFrame)

  self:Show()

  self.name = COLLECTIONATOR_L_COLLECTIONATOR

  self.OnCommit = function()
    self:Save()
  end
  self.OnDefault = function() end
  self.OnRefresh = function() end

  local category = Settings.RegisterCanvasLayoutCategory(self, self.name)
  category.ID = self.name
  Settings.RegisterAddOnCategory(category)
end

function CollectionatorConfigBasicOptionsFrameMixin:OnShow()
  Auctionator.Debug.Message("CollectionatorConfigBasicOptionsFrameMixin:OnShow()")

  self.Summary:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_SUMMARY))
  self.Replicate:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_REPLICATE))

  self.RecipeCaching:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_RECIPE_CACHING))
  self.PurchaseWatch:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_PURCHASE_WATCH))
end

function CollectionatorConfigBasicOptionsFrameMixin:Save()
  Auctionator.Debug.Message("CollectionatorConfigBasicOptionsFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.COLLECTIONATOR_SUMMARY, self.Summary:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.COLLECTIONATOR_REPLICATE, self.Replicate:GetChecked())

  Auctionator.Config.Set(Auctionator.Config.Options.COLLECTIONATOR_RECIPE_CACHING, self.RecipeCaching:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.COLLECTIONATOR_PURCHASE_WATCH, self.PurchaseWatch:GetChecked())
end

function CollectionatorConfigBasicOptionsFrameMixin:Cancel()
  Auctionator.Debug.Message("CollectionatorConfigBasicOptionsFrameMixin:Cancel()")
end

function CollectionatorConfigBasicOptionsFrameMixin:ResetRecipeCache()
  Auctionator.Debug.Message("CollectionatorConfigBasicOptionsFrameMixin:ResetRecipeCache()")
  CollectionatorRecipeCacheFrame:ResetCache()
end

function CollectionatorConfigBasicOptionsFrameMixin:ResetPurchaseWatch()
  Auctionator.Debug.Message("CollectionatorConfigBasicOptionsFrameMixin:ResetPurchaseWatch()")
  CollectionatorPurchaseWatchFrame:ResetData()
end
