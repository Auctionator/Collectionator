HuntingTabMixin = {}

function HuntingTabMixin:OnLoad()
  Auctionator.Debug.Message("HuntingTabMixin:OnLoad()")
  self.ResultsListing:Init(self.DataProvider)
end

function HuntingTabMixin:ProcessFSClicked()
  Auctionator.Debug.Message("HuntingTabMixin:ProcessFSClicked()")
  HuntingDressUpFrame:Process()
end

function HuntingTabMixin:CacheTextUpdate()
  Auctionator.Debug.Message("HuntingTabMixin:CacheTextUpdate()")
  if Auctionator.Config.Get(Auctionator.Config.Options.CACHE_FULL_SCAN) then
    self.ActivateCache:SetText("Disable Cache")
  else
    self.ActivateCache:SetText("Enable Cache")
  end
end

function HuntingTabMixin:ActivateCacheToggle()
  Auctionator.Debug.Message("HuntingTabMixin:ActivateCache()")
  Auctionator.Config.Set(Auctionator.Config.Options.CACHE_FULL_SCAN, not Auctionator.Config.Get(Auctionator.Config.Options.CACHE_FULL_SCAN))
end
