PMTabMixin = {}

function PMTabMixin:OnLoad()
  Auctionator.Debug.Message("PMTabMixin:OnLoad()")
  self.ResultsListing:Init(self.DataProvider)
end

function PMTabMixin:ProcessFSClicked()
  Auctionator.Debug.Message("PMTabMixin:ProcessFSClicked()")
  PMDressUpFrame:Process()
end
