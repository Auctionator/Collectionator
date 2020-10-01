HuntingTMogRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function HuntingTMogRowMixin:OnEnter()
  AuctionHouseUtil.LineOnEnterCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnEnter(self)
end

function HuntingTMogRowMixin:OnLeave()
  AuctionHouseUtil.LineOnLeaveCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnLeave(self)
end

function HuntingTMogRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("HuntingTMogRowMixin:OnClick()")

  if IsModifiedClick("DRESSUP") then
    DressUpLink(self.rowData.itemLink);
  else
    Auctionator.API.v1.MultiSearchExact("Hunting", {self.rowData.name})
  end
end
