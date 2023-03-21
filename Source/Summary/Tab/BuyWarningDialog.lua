CollectionatorSummaryBuyWarningDialogMixin = {}

function CollectionatorSummaryBuyWarningDialogMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "CollectionatorSummaryBuyWarningDialogMixin")
  Auctionator.EventBus:Register(self, {
    Collectionator.Events.SummaryConfirmAndDelayEvent
  })
  self:Reset()
end

function CollectionatorSummaryBuyWarningDialogMixin:Reset()
  self:Hide()
  self.ContinueButton:Disable()
end

function CollectionatorSummaryBuyWarningDialogMixin:OnHide()
  self:Reset()
end

function CollectionatorSummaryBuyWarningDialogMixin:ReceiveEvent(event, ...)
  if event == Collectionator.Events.SummaryConfirmAndDelayEvent then
    if self.ContinueButton:IsEnabled() then
      self:Continue()
    end

    local text, returnEvent, returnData = ...
    self.Text:SetText(RED_FONT_COLOR:WrapTextInColorCode(text))
    self.returnEvent = returnEvent
    self.returnData = returnData
    self.ContinueButton:Enable()
    self:Show()
  end
end

function CollectionatorSummaryBuyWarningDialogMixin:Continue()
  self:Reset()
  Auctionator.EventBus:Fire(self, self.returnEvent, self.returnData)
end
