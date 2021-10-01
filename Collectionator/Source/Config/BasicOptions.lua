CollectionatorConfigBasicOptionsFrameMixin = {}

function CollectionatorConfigBasicOptionsFrameMixin:OnLoad()
  Auctionator.Debug.Message("CollectionatorConfigBasicOptionsFrameMixin:OnLoad()")

  self.name = COLLECTIONATOR_L_COLLECTIONATOR

  self.cancel = function()
    self:Cancel()
  end

  self.okay = function()
    self:Save()
  end

  InterfaceOptions_AddCategory(self, "Collectionator")
end

function CollectionatorConfigBasicOptionsFrameMixin:OnShow()
  Auctionator.Debug.Message("CollectionatorConfigBasicOptionsFrameMixin:OnShow()")

  self.RecipeCaching:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_RECIPE_CACHING))
end

function CollectionatorConfigBasicOptionsFrameMixin:Save()
  Auctionator.Debug.Message("CollectionatorConfigBasicOptionsFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.COLLECTIONATOR_RECIPE_CACHING, self.RecipeCaching:GetChecked())
end

function CollectionatorConfigBasicOptionsFrameMixin:Cancel()
  Auctionator.Debug.Message("CollectionatorConfigBasicOptionsFrameMixin:Cancel()")
end

function CollectionatorConfigBasicOptionsFrameMixin:ResetRecipeCache()
  Auctionator.Debug.Message("CollectionatorConfigBasicOptionsFrameMixin:ResetRecipeCache()")
  CollectionatorRecipeCacheFrame:ResetCache()
end
