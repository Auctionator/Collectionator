CollectionatorReplicateRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function CollectionatorReplicateRowMixin:OnEnter()
  AuctionHouseUtil.LineOnEnterCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnEnter(self)
end

function CollectionatorReplicateRowMixin:OnLeave()
  AuctionHouseUtil.LineOnLeaveCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnLeave(self)
end

function CollectionatorReplicateRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("CollectionatorReplicateRowMixin:OnClick()")

  if IsModifiedClick("DRESSUP") then
    DressUpLink(self.rowData.itemLink);
  else
    Auctionator.EventBus
      :RegisterSource(self, "CollectionatorReplicateRowMixin")
      :Fire(self, Collectionator.Events.ReplicateBuyQueryRequest, {
        itemLink = self.rowData.itemLink,
        queryType = self.queryType,
        returnEvent = Collectionator.Events.ReplicateShowBuyoutOptions,
        returnData = self.rowData,
      })
      :UnregisterSource(self)
  end
end

function CollectionatorReplicateRowMixin:Populate(...)
  AuctionatorResultsRowTemplateMixin.Populate(self, ...)

  self.SelectedHighlight:SetShown(self.rowData.selected)
end

CollectionatorReplicateTMogRowMixin = CreateFromMixins(CollectionatorReplicateRowMixin)
CollectionatorReplicateTMogRowMixin.queryType = "TMOG"

CollectionatorReplicatePetRowMixin = CreateFromMixins(CollectionatorReplicateRowMixin)
CollectionatorReplicatePetRowMixin.queryType = "PET"

CollectionatorReplicateToyMountRowMixin = CreateFromMixins(CollectionatorReplicateRowMixin)
CollectionatorReplicateToyMountRowMixin.queryType = "OTHER"
