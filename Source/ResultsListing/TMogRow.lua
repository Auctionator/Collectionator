MogHunterTMogRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function MogHunterTMogRowMixin:OnEnter()
  AuctionHouseUtil.LineOnEnterCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnEnter(self)
end

function MogHunterTMogRowMixin:OnLeave()
  AuctionHouseUtil.LineOnLeaveCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnLeave(self)
end

function MogHunterTMogRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("MogHunterTMogRowMixin:OnClick()")

  if IsModifiedClick("DRESSUP") then
    DressUpLink(self.rowData.itemLink);
  else
    Auctionator.API.v1.MultiSearchExact("MogHunter", {self.rowData.name})
  end
end
