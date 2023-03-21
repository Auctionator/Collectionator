CollectionatorReplicateViewMixin = {}

function CollectionatorReplicateViewMixin:OnLoad()
  self.ResultsListing:Init(self.DataProvider)

  Auctionator.EventBus:RegisterSource(self, "CollectionatorReplicateViewMixin")
end

function CollectionatorReplicateViewMixin:OnShow()
  self.Scanner:Process()
end

function CollectionatorReplicateViewMixin:Refresh()
  self.BuyCheapest:Reset()
  if IsShiftKeyDown() then
    self.Scanner:Refresh()
  else
    self.DataProvider:Refresh()
  end
end

function CollectionatorReplicateViewMixin:ReceiveEvent(event, ...)
end
