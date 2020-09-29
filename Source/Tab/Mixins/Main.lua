PMTabMixin = {}

function PMTabMixin:OnLoad()
  Auctionator.Debug.Message("PMTabMixin:OnLoad()")
end

function PMTabMixin:ProcessFSClicked()
  Auctionator.Debug.Message("PMTabMixin:ProcessFSClicked()")
  PMDressUpFrame:Process()
end
