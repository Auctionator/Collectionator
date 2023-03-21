CollectionatorSummaryViewMixin = {}

function CollectionatorSummaryViewMixin:OnLoad()
  self.ResultsListing:Init(self.DataProvider)

  Auctionator.EventBus:RegisterSource(self, "CollectionatorSummaryViewMixin")
end

function CollectionatorSummaryViewMixin:OnShow()
  self.Scanner:Process()
end

function CollectionatorSummaryViewMixin:Refresh()
  self.BuyCheapest:Reset()
  if IsShiftKeyDown() then
    self.Scanner:Refresh()
  else
    self.DataProvider:Refresh()
  end
end

function CollectionatorSummaryViewMixin:ReceiveEvent(event, ...)
end
