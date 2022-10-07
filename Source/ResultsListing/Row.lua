CollectionatorRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function CollectionatorRowMixin:OnEnter()
  AuctionHouseUtil.LineOnEnterCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnEnter(self)
end

function CollectionatorRowMixin:OnLeave()
  AuctionHouseUtil.LineOnLeaveCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnLeave(self)
end

function CollectionatorRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("CollectionatorRowMixin:OnClick()")

  if IsModifiedClick("DRESSUP") then
    DressUpLink(self.rowData.itemLink);
  else
    Auctionator.EventBus
      :RegisterSource(self, "CollectionatorRowMixin")
      :Fire(self, Collectionator.Events.BuyQueryRequest, {
        itemLink = self.rowData.itemLink,
        queryType = self.queryType,
        returnEvent = Collectionator.Events.ShowBuyoutOptions,
        returnData = self.rowData,
      })
      :UnregisterSource(self)
  end
end

CollectionatorTMogRowMixin = CreateFromMixins(CollectionatorRowMixin)
CollectionatorTMogRowMixin.queryType = "TMOG"

CollectionatorPetRowMixin = CreateFromMixins(CollectionatorRowMixin)
CollectionatorPetRowMixin.queryType = "PET"

CollectionatorToyMountRowMixin = CreateFromMixins(CollectionatorRowMixin)
CollectionatorToyMountRowMixin.queryType = "OTHER"
