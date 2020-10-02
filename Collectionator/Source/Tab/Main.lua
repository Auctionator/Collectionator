CollectionatorTabMixin = {}

function CollectionatorTabMixin:OnLoad()
  Auctionator.Debug.Message("CollectionatorTabMixin:OnLoad()")
  self.ResultsListing:Init(self.DataProvider)
end

function CollectionatorTabMixin:OnShow()
  CollectionatorDressUpFrame:Process()
end
