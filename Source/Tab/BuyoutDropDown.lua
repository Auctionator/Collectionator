CollectionatorBuyoutDropDownMixin = {}

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

function CollectionatorBuyoutDropDownMixin:OnLoad()
  LibDD:Create_UIDropDownMenu(self)
  LibDD:UIDropDownMenu_SetInitializeFunction(self, CollectionatorBuyoutDropDownMixin.Initialize)
  LibDD:UIDropDownMenu_SetDisplayMode(self, "MENU")
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
    LibDD:HideDropDownMenu(1)
    return
  end

  local confirmInfo = LibDD:UIDropDownMenu_CreateInfo()
  confirmInfo.notCheckable = 1
  if self.auctionInfo == nil then
    confirmInfo.text = COLLECTIONATOR_L_EXACT_ITEM_UNAVAILABLE
    confirmInfo.disabled = true
  elseif self.auctionInfo.containsAccountItem then
    confirmInfo.text = COLLECTIONATOR_L_YOU_OWN_THE_ITEM_LISTING
    confirmInfo.disabled = true
  elseif self.auctionInfo.buyoutAmount == nil then
    confirmInfo.text = COLLECTIONATOR_L_BID_REQUIRED .. " " GetMoneyString(self.auctionInfo.bidAmount, true)
    confirmInfo.disabled = true
  else
    confirmInfo.text = COLLECTIONATOR_L_BUYOUT .. " " .. GetMoneyString(self.auctionInfo.buyoutAmount, true)

    confirmInfo.disabled = false
    confirmInfo.func = function()
      Auctionator.EventBus
        :RegisterSource(self, "buyout dropdown")
        :Fire(self, Collectionator.Events.PurchaseAttempted, self.auctionInfo.auctionID)
        :UnregisterSource(self)
      C_AuctionHouse.PlaceBid(self.auctionInfo.auctionID, self.auctionInfo.buyoutAmount)
      PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    end
  end
  confirmInfo.tooltipTitle = COLLECTIONATOR_L_BUYOUT
  confirmInfo.tooltipText = COLLECTIONATOR_L_BUYOUT_TOOLTIP
  confirmInfo.tooltipOnButton = 1

  local searchInfo = LibDD:UIDropDownMenu_CreateInfo()
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

  local titleInfo = LibDD:UIDropDownMenu_CreateInfo()
  titleInfo.isTitle = true
  titleInfo.notCheckable = 1
  titleInfo.text = Collectionator.Utilities.ColorName(self.rowData.itemLink, names[1])
  titleInfo.justifyH = "CENTER"
  titleInfo.icon = self.rowData.iconTexture

  local cancelInfo = LibDD:UIDropDownMenu_CreateInfo()
  cancelInfo.notCheckable = 1
  cancelInfo.text = AUCTIONATOR_L_CANCEL
  cancelInfo.disabled = false

  LibDD:UIDropDownMenu_AddButton(titleInfo)
  LibDD:UIDropDownMenu_AddButton(confirmInfo)
  LibDD:UIDropDownMenu_AddButton(searchInfo)
  LibDD:UIDropDownMenu_AddButton(cancelInfo)
end

function CollectionatorBuyoutDropDownMixin:Callback(auctionInfo, rowData)
  self.auctionInfo = auctionInfo
  self.rowData = rowData
  LibDD:ToggleDropDownMenu(1, nil, self, "cursor")
end
