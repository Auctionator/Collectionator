HuntingTabMixin = {}

function HuntingTabMixin:OnLoad()
  Auctionator.Debug.Message("HuntingTabMixin:OnLoad()")
  self.ResultsListing:Init(self.DataProvider)
end

function HuntingTabMixin:ProcessFSClicked()
  Auctionator.Debug.Message("HuntingTabMixin:ProcessFSClicked()")
  HuntingDressUpFrame:Process()
end
