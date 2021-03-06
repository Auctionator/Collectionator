CollectionatorBuyoutDropDownMixin = {}

function CollectionatorBuyoutDropDownMixin:OnLoad()
  UIDropDownMenu_Initialize(self, CollectionatorBuyoutDropDownMixin.Initialize, "MENU")
  Auctionator.EventBus:Register(self, {
    Collectionator.Events.ShowBuyoutOptions,
  })
end

function CollectionatorBuyoutDropDownMixin:ReceiveEvent(event, ...)
  if event == Collectionator.Events.ShowBuyoutOptions then
    self:Callback(...)
  end
end

function CollectionatorBuyoutDropDownMixin:Initialize()
  if not self.auctionInfo and not self.rowData then
    HideDropDownMenu(1)
    return
  end

  local confirmInfo = UIDropDownMenu_CreateInfo()
  confirmInfo.notCheckable = 1
  if self.auctionInfo == nil then
    confirmInfo.text = COLLECTIONATOR_L_EXACT_ITEM_UNAVAILABLE
    confirmInfo.disabled = true
  elseif self.auctionInfo.buyoutAmount == nil then
    confirmInfo.text = COLLECTIONATOR_L_BID_REQUIRED .. " " Auctionator.Utilities.CreateMoneyString(self.auctionInfo.bidAmount)
    confirmInfo.disabled = true
  else
    confirmInfo.text = COLLECTIONATOR_L_BUYOUT .. " " .. Auctionator.Utilities.CreateMoneyString(self.auctionInfo.buyoutAmount)

    confirmInfo.disabled = false
    confirmInfo.func = function()
      C_AuctionHouse.PlaceBid(self.auctionInfo.auctionID, self.auctionInfo.buyoutAmount)
      PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    end
  end
  confirmInfo.tooltipTitle = COLLECTIONATOR_L_BUYOUT
  confirmInfo.tooltipText = COLLECTIONATOR_L_BUYOUT_TOOLTIP
  confirmInfo.tooltipOnButton = 1

  local searchInfo = UIDropDownMenu_CreateInfo()
  searchInfo.notCheckable = 1
  searchInfo.text = COLLECTIONATOR_L_SEARCH_FOR_ALTERNATIVES
  searchInfo.disabled = false
  searchInfo.tooltipTitle = COLLECTIONATOR_L_ALTERNATIVE_OPTIONS
  searchInfo.tooltipText = COLLECTIONATOR_L_SEARCH_FOR_ALTERNATIVES_TOOLTIP
  searchInfo.tooltipOnButton = 1

  local names = self.rowData.names or {self.rowData.name}
  searchInfo.func = function()
    Auctionator.API.v1.MultiSearchExact("Collectionator", names)
  end

  local titleInfo = UIDropDownMenu_CreateInfo()
  titleInfo.isTitle = true
  titleInfo.notCheckable = 1
  titleInfo.text = Collectionator.Utilities.ColorName(self.rowData.itemLink, names[1])
  titleInfo.justifyH = "CENTER"
  titleInfo.icon = self.rowData.iconTexture

  local cancelInfo = UIDropDownMenu_CreateInfo()
  cancelInfo.notCheckable = 1
  cancelInfo.text = AUCTIONATOR_L_CANCEL
  cancelInfo.disabled = false

  UIDropDownMenu_AddButton(titleInfo)
  UIDropDownMenu_AddButton(confirmInfo)
  UIDropDownMenu_AddButton(searchInfo)
  UIDropDownMenu_AddButton(cancelInfo)
end

function CollectionatorBuyoutDropDownMixin:Callback(auctionInfo, rowData)
  self.auctionInfo = auctionInfo
  self.rowData = rowData
  ToggleDropDownMenu(1, nil, self, "cursor")
end
