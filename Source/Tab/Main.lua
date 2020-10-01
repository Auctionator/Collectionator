HuntingTabMixin = {}

function HuntingTabMixin:OnLoad()
  Auctionator.Debug.Message("HuntingTabMixin:OnLoad()")
  self.ResultsListing:Init(self.DataProvider)
end
