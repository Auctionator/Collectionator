CollectionatorSummaryRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function CollectionatorSummaryRowMixin:OnEnter()
  --AuctionHouseUtil.LineOnEnterCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnEnter(self)
end

function CollectionatorSummaryRowMixin:OnLeave()
  --AuctionHouseUtil.LineOnLeaveCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnLeave(self)
end

function CollectionatorSummaryRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("CollectionatorSummaryRowMixin:OnClick()")

  if IsModifiedClick("DRESSUP") then
    local itemKeyInfo = self.rowData.itemKeyInfo
    if itemKeyInfo.appearanceLink then
      local _, _, hyperlinkString = ExtractHyperlinkString(itemKeyInfo.appearanceLink);
      DressUpTransmogLink(hyperlinkString);
    else
      if itemKeyInfo.battlePetLink then
        DressUpBattlePetLink(itemKeyInfo.battlePetLink);
      else
        local item = Item:CreateFromItemID(self.rowData.itemKey.itemID)
        item:ContinueOnItemLoad(function()
          local _, itemLink = C_Item.GetItemInfo(self.rowData.itemKey.itemID)
          DressUpLink(itemLink);
        end)
      end
    end
  else
    Auctionator.EventBus
      :RegisterSource(self, "CollectionatorSummaryRowMixin")
      :Fire(self, Collectionator.Events.SummaryBuyQueryRequest, {
        itemKey = self.rowData.itemKey,
        itemKeyInfo = self.rowData.itemKeyInfo,
        queryType = self.queryType,
        returnEvent = Collectionator.Events.SummaryShowBuyoutOptions,
        returnData = self.rowData,
      })
      :UnregisterSource(self)
  end
end

function CollectionatorSummaryRowMixin:Populate(...)
  AuctionatorResultsRowTemplateMixin.Populate(self, ...)

  self.SelectedHighlight:SetShown(self.rowData.selected)
end

CollectionatorSummaryTMogRowMixin = CreateFromMixins(CollectionatorSummaryRowMixin)
CollectionatorSummaryTMogRowMixin.queryType = "TMOG"

CollectionatorSummaryPetRowMixin = CreateFromMixins(CollectionatorSummaryRowMixin)
CollectionatorSummaryPetRowMixin.queryType = "PET"

CollectionatorSummaryToyMountRowMixin = CreateFromMixins(CollectionatorSummaryRowMixin)
CollectionatorSummaryToyMountRowMixin.queryType = "OTHER"
