CollectionatorBuyWarningDialogMixin = {}

function CollectionatorBuyWarningDialogMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "CollectionatorBuyWarningDialogMixin")
  Auctionator.EventBus:Register(self, {
    Collectionator.Events.ConfirmAndDelayEvent
  })
  self:Reset()
end

function CollectionatorBuyWarningDialogMixin:Reset()
  self:Hide()
  self.ContinueButton:Disable()
end

function CollectionatorBuyWarningDialogMixin:OnHide()
  self:Reset()
end

function CollectionatorBuyWarningDialogMixin:ReceiveEvent(event, ...)
  if event == Collectionator.Events.ConfirmAndDelayEvent then
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

function CollectionatorBuyWarningDialogMixin:Continue()
  self:Reset()
  Auctionator.EventBus:Fire(self, self.returnEvent, self.returnData)
end
