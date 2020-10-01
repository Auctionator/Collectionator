local TMOG_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = AUCTIONATOR_L_NAME,
    cellTemplate = "AuctionatorItemKeyCellTemplate",
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_QUANTITY,
    headerParameters = { "quantity" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "quantity" },
    width = 70
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_UNIT_PRICE,
    headerParameters = { "price" },
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "price" },
    width = 150,
  },
}

local DATA_EVENTS = {
  "OWNED_AUCTIONS_UPDATED",
  "AUCTION_CANCELED"
}

local EVENT_BUS_EVENTS = {
  Auctionator.Cancelling.Events.RequestCancel,
  Auctionator.Cancelling.Events.UndercutStatus,
  Auctionator.Cancelling.Events.UndercutScanStart,
}

HuntingDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function HuntingDataProviderMixin:OnLoad()
  AuctionatorDataProviderMixin.OnLoad(self)
end

function HuntingDataProviderMixin:OnShow()
  Auctionator.EventBus:Register(self, EVENT_BUS_EVENTS)

  FrameUtil.RegisterFrameForEvents(self, DATA_EVENTS)
end

function HuntingDataProviderMixin:OnHide()
  Auctionator.EventBus:Unregister(self, EVENT_BUS_EVENTS)

  FrameUtil.UnregisterFrameForEvents(self, DATA_EVENTS)
end

local COMPARATORS = {
  price = Auctionator.Utilities.NumberComparator,
  name = Auctionator.Utilities.StringComparator,
  quantity = Auctionator.Utilities.NumberComparator,
  timeLeft = Auctionator.Utilities.NumberComparator,
  undercut = Auctionator.Utilities.StringComparator,
}

function HuntingDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end

function HuntingDataProviderMixin:OnEvent(eventName, auctionID, ...)
end

function HuntingDataProviderMixin:ReceiveEvent(eventName, eventData, ...)
end

local function GetFS()
  return AUCTIONATOR_RAW_FULL_SCAN[Auctionator.Variables.GetConnectedRealmRoot()] or {}
end

local function ColorName(link, name)
  local qualityColor = Auctionator.Utilities.GetQualityColorFromLink(link)
  return "|c" .. qualityColor .. name .. "|r"
end

function HuntingDataProviderMixin:Refresh()
  self:Reset()

  local results = {}

  for _, sourceInfo in ipairs(HUNTING_SOURCES) do
    local info = GetFS()[sourceInfo.index]
    local allClasses = C_TransmogCollection.GetSourceInfo(sourceInfo.s)
    if info.replicateInfo[4] > 1 and not allClasses.isCollected then
      table.insert(results, {
        index = sourceInfo.index,
        itemName = ColorName(info.itemLink, info.replicateInfo[1]),
        name = info.replicateInfo[1],
        quantity = info.replicateInfo[3],
        price = info.replicateInfo[10] or info.replicateInfo[11],
        itemLink = info.itemLink, -- Used for tooltips
        iconTexture = info.replicateInfo[2],
      })
    end
  end
  self:AppendEntries(results, true)
end

function HuntingDataProviderMixin:UniqueKey(entry)
  return tostring(entry.index)
end

function HuntingDataProviderMixin:GetTableLayout()
  return TMOG_TABLE_LAYOUT
end

function HuntingDataProviderMixin:GetRowTemplate()
  return "HuntingTMogRowTemplate"
end
