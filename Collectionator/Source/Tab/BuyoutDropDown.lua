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
    confirmInfo.text = COLLECTIONATOR_L_BUYOUT .. ": " .. Auctionator.Utilities.CreateMoneyString(self.auctionInfo.buyoutAmount)

    confirmInfo.disabled = false
    confirmInfo.func = function()
      C_AuctionHouse.PlaceBid(self.auctionInfo.auctionID, self.auctionInfo.buyoutAmount)
      PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    end
  end

  local allNames = self.rowData.names or {self.rowData.name}
  local searchInfo = UIDropDownMenu_CreateInfo()
  searchInfo.notCheckable = 1
  searchInfo.text = AUCTIONATOR_L_SEARCH .. ": " .. allNames[1]

  searchInfo.disabled = false
  searchInfo.func = function()
    Auctionator.API.v1.MultiSearchExact("Collectionator", allNames)
  end

  local cancelInfo = UIDropDownMenu_CreateInfo()
  cancelInfo.notCheckable = 1
  cancelInfo.text = AUCTIONATOR_L_CANCEL

  cancelInfo.disabled = false
  cancelInfo.func = function()
  end

  UIDropDownMenu_AddButton(confirmInfo)
  UIDropDownMenu_AddButton(searchInfo)
  UIDropDownMenu_AddButton(cancelInfo)
end

function CollectionatorBuyoutDropDownMixin:Callback(auctionInfo, rowData)
  self.auctionInfo = auctionInfo
  self.rowData = rowData
  ToggleDropDownMenu(1, nil, self, "cursor")
end
