CollectionatorReplicateBuyoutDropDownMixin = {}

function CollectionatorReplicateBuyoutDropDownMixin:OnLoad()
  Auctionator.EventBus:Register(self, {
    Collectionator.Events.ReplicateShowBuyoutOptions,
  })
end

function CollectionatorReplicateBuyoutDropDownMixin:ReceiveEvent(event, ...)
  if event == Collectionator.Events.ReplicateShowBuyoutOptions then
    self:Callback(...)
  end
end

function CollectionatorReplicateBuyoutDropDownMixin:ShowMenu()
  if not self.auctionInfo and not self.rowData then
    return
  end

  MenuUtil.CreateContextMenu(self:GetParent(), function(_, rootDescription)
    local names = self.rowData.names or {self.rowData.name}
    local title = rootDescription:CreateTitle(Collectionator.Utilities.ColorName(self.rowData.itemLink, names[1]))
    title:AddInitializer(function(title, description, menu)
      local leftTexture = title:AttachTexture();
      leftTexture:SetSize(18, 18);
      leftTexture:SetPoint("LEFT");
      leftTexture:SetTexture(self.rowData.iconTexture);
      title.fontString:SetPoint("LEFT", leftTexture, "RIGHT", 5, 0)
      local width, height = 20 + title.fontString:GetUnboundedStringWidth() + leftTexture:GetWidth(), 20
      return width, height
    end)

    if self.auctionInfo == nil then
      rootDescription:CreateTitle(GRAY_FONT_COLOR:WrapTextInColorCode(COLLECTIONATOR_L_EXACT_ITEM_UNAVAILABLE))
    elseif self.auctionInfo.containsAccountItem then
      rootDescription:CreateTitle(GRAY_FONT_COLOR:WrapTextInColorCode(COLLECTIONATOR_L_YOU_OWN_THE_ITEM_LISTING))
    elseif self.auctionInfo.buyoutAmount == nil then
      rootDescription:CreateTitle(COLLECTIONATOR_L_BID_REQUIRED .. " " .. GetMoneyString(self.auctionInfo.bidAmount, true))
    else
      local button = rootDescription:CreateButton(
        COLLECTIONATOR_L_BUYOUT .. " " .. GetMoneyString(self.auctionInfo.buyoutAmount, true),
        function()
          Auctionator.EventBus
            :RegisterSource(self, "buyout dropdown")
            :Fire(self, Collectionator.Events.PurchaseAttempted, self.auctionInfo.auctionID, self.auctionInfo.itemLink)
            :UnregisterSource(self)
          C_AuctionHouse.PlaceBid(self.auctionInfo.auctionID, self.auctionInfo.buyoutAmount)
          PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
        end
      )
      button:SetTooltip(function(tooltip)
        tooltip:SetText(COLLECTIONATOR_L_BUYOUT)
        tooltip:AddLine(COLLECTIONATOR_L_BUYOUT_TOOLTIP)
      end)
    end

    local searchButton = rootDescription:CreateButton(
      COLLECTIONATOR_L_SEARCH_FOR_ALTERNATIVES,
      function()
        Auctionator.API.v1.MultiSearchExact("Collectionator", names)
      end
    )
    searchButton:SetTooltip(function(tooltip)
      tooltip:SetText(COLLECTIONATOR_L_ALTERNATIVE_OPTIONS)
      tooltip:AddLine(COLLECTIONATOR_L_SEARCH_FOR_ALTERNATIVES_TOOLTIP)
    end)

    rootDescription:CreateButton(COLLECTIONATOR_L_HIDE_ITEM, function()
      Auctionator.EventBus
        :RegisterSource(self, "buyout dropdown")
        :Fire(self, Collectionator.Events.HideItem, self.auctionInfo.itemLink)
        :UnregisterSource(self)
      end
    )

    rootDescription:CreateButton(AUCTIONATOR_L_CANCEL, function() end)
  end)
end

function CollectionatorReplicateBuyoutDropDownMixin:Callback(auctionInfo, rowData)
  self.auctionInfo = auctionInfo
  self.rowData = rowData
  self:ShowMenu()
end
