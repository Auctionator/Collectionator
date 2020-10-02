CollectionatorDataFrameMixin = {}

function CollectionatorDataFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "VARIABLES_LOADED"
  })
end

function CollectionatorDataFrameMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.FullScan.Events.ScanComplete then
    COLLECTIONATOR_LAST_FULL_SCAN = {
      realm = Auctionator.Variables.GetConnectedRealmRoot(),
      db = eventData,
    }
  end
end

function CollectionatorDataFrameMixin:OnEvent(event, ...)
  if event == "VARIABLES_LOADED" then
    Auctionator.EventBus:Register(self, {
      Auctionator.FullScan.Events.ScanComplete
    })
  end
end
