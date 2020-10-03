CollectionatorTMogViewMixin = {}

function CollectionatorTMogViewMixin:OnLoad()
  Auctionator.Debug.Message("CollectionatorTabMixin:OnLoad()")
  self.ResultsListing:Init(self.DataProvider)
end

function CollectionatorTMogViewMixin:OnShow()
  self.Scanner:Process()
end

function CollectionatorTMogViewMixin:OnHide()
end
