CollectionatorBuyoutFrameMixin = {}

local BUYOUT_EVENTS = {
  "AUCTION_HOUSE_CLOSED"
  "ITEM_SEARCH_RESULTS_UPDATED"
}

function CollectionatorBuyoutFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorBuyoutFrameMixin:OnLoad")
  Auctionator.EventBus:RegisterSource(self, "AuctionatorBuyoutFrameMixin")

  Auctionator.EventBus:Register(self, {Collectionator.Buyout.Events.ShowBuyout})

  --Auctionator.EventBus
  --  :RegisterSource(self, "CancellingListResultRow")
  --  :Fire(self, Auctionator.Cancelling.Events.RequestCancel, self.rowData.id)
  --  :UnregisterSource(self)
end

function CollectionatorBuyoutFrameMixin:OnEvent(eventName, ...)
end

function CollectionatorBuyoutFrameMixin:ReceiveEvent(eventName, rowData)
  if eventName == Collectionator.Buyout.Events.ShowBuyoutPet then
    self:RegisterForEvents()
    --self.expectedItemKey = {

  end

end

function AuctionatorBuyoutFrameMixin:RegisterForEvents()
  Auctionator.Debug.Message("AuctionatorBuyoutFrameMixin:RegisterForEvents()")

  FrameUtil.RegisterFrameForEvents(self, BUYOUT_EVENTS)
end
