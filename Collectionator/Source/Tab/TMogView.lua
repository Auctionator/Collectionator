CollectionatorTMogViewMixin = {}

function CollectionatorTMogViewMixin:OnLoad()
  Auctionator.Debug.Message("CollectionatorTabMixin:OnLoad()")
  self.ResultsListing:Init(self.DataProvider)
end

function CollectionatorTMogViewMixin:OnShow()
  CollectionatorDressUpFrame:Process()
end

function CollectionatorTMogViewMixin:OnHide()
  CollectionatorDressUpFrame:Abort()
end
