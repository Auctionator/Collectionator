CollectionatorDataFrameMixin = {}

function CollectionatorDataFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "VARIABLES_LOADED"
  })
end

function CollectionatorDataFrameMixin:ReceiveEvent(eventName, eventData)
  if eventName == Collectionator.FullScan.Events.ScanComplete then
    COLLECTIONATOR_LAST_FULL_SCAN = {
      realm = Auctionator.Variables.GetConnectedRealmRoot(),
      data = eventData,
    }
  end
end

function CollectionatorDataFrameMixin:OnEvent(event, ...)
  if event == "VARIABLES_LOADED" then
    Auctionator.EventBus:Register(self, {
      Collectionator.FullScan.Events.ScanComplete
    })
  end
end
