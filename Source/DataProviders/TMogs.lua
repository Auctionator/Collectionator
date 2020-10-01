local TMOG_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = AUCTIONATOR_L_NAME,
    cellTemplate = "AuctionatorItemKeyCellTemplate",
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = "Choices",
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

HuntingDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function HuntingDataProviderMixin:OnLoad()
  AuctionatorDataProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register(self, {
    Hunting.Events.SourceLoadStart,
    Hunting.Events.SourceLoadEnd,
  })

  self.processCountPerUpdate = 500
  self.dirty = false
end

function HuntingDataProviderMixin:OnShow()
  if self.dirty then
    self:Refresh()
  end
end

function HuntingDataProviderMixin:ReceiveEvent(eventName, eventData)
  if eventName == Hunting.Events.SourceLoadStart then
    self.onSearchStarted()
  elseif eventName == Hunting.Events.SourceLoadEnd then
    self.sources = eventData

    self.dirty = true
    if self:IsShown() then
      self:Refresh()
    end
  end
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

local function GetFS()
  return AUCTIONATOR_RAW_FULL_SCAN[Auctionator.Variables.GetConnectedRealmRoot()] or {}
end

local function ColorName(link, name)
  local qualityColor = Auctionator.Utilities.GetQualityColorFromLink(link)
  return "|c" .. qualityColor .. name .. "|r"
end

local function MergeBySourceID(sources, fullScan)
  local sourceMap = {}
  for _, sourceInfo in ipairs(sources) do
    local id = sourceInfo.id
    local quantity = fullScan[sourceInfo.index].replicateInfo[3]
    local price = fullScan[sourceInfo.index].replicateInfo[10]

    if sourceMap[id] == nil then
      sourceMap[id] = {
        index = sourceInfo.index,
        quantity = quantity,
        price = price,
      }
    else
      sourceMap[id].quantity = sourceMap[id].quantity + quantity

      if price < sourceMap[id].price then
        sourceMap[id].index = sourceInfo.index
      end
    end
  end

  local result = {}

  for key, value in pairs(sourceMap) do
    table.insert(result, {id = key, index = value.index, quantity = value.quantity})
  end

  return result
end

function HuntingDataProviderMixin:Refresh()
  self:Reset()
  self.onSearchStarted()
  self.dirty = false

  local merged = MergeBySourceID(self.sources, GetFS())

  local results = {}

  for _, sourceInfo in ipairs(merged) do
    local info = GetFS()[sourceInfo.index]
    local allClasses = C_TransmogCollection.GetSourceInfo(sourceInfo.id)
    if info.replicateInfo[4] > 1 and not allClasses.isCollected then
      table.insert(results, {
        index = sourceInfo.index,
        itemName = ColorName(info.itemLink, info.replicateInfo[1]),
        name = info.replicateInfo[1],
        quantity = sourceInfo.quantity,
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
