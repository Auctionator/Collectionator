PMTabMixin = {}

function PMTabMixin:OnLoad()
  Auctionator.Debug.Message("PMTabMixin:OnLoad()")
  self.ResultsListing:Init(self.DataProvider)
end

function PMTabMixin:ProcessFSClicked()
  Auctionator.Debug.Message("PMTabMixin:ProcessFSClicked()")
  PMDressUpFrame:Process()
end

function PMTabMixin:CacheTextUpdate()
  Auctionator.Debug.Message("PMTabMixin:CacheTextUpdate()")
  if Auctionator.Config.Get(Auctionator.Config.Options.CACHE_FULL_SCAN) then
    self.ActivateCache:SetText("Disable Cache")
  else
    self.ActivateCache:SetText("Enable Cache")
  end
end

function PMTabMixin:ActivateCacheToggle()
  Auctionator.Debug.Message("PMTabMixin:ActivateCache()")
  Auctionator.Config.Set(Auctionator.Config.Options.CACHE_FULL_SCAN, not Auctionator.Config.Get(Auctionator.Config.Options.CACHE_FULL_SCAN))
end
