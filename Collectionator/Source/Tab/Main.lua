CollectionatorTabFrameMixin = {}

function CollectionatorTabFrameMixin:OnLoad()
  Auctionator.Debug.Message("CollectionatorTabMixin:OnLoad()")
  self:HideViews()
end

function CollectionatorTabFrameMixin:OnShow()
  self:ActivateButtons()
end

function CollectionatorTabFrameMixin:HideViews()
  self.TMogView:Hide()
  self.PetView:Hide()
end

function CollectionatorTabFrameMixin:ActivateButtons()
  self.TMogButton:SetEnabled(not self.TMogView:IsShown())
  self.PetButton:SetEnabled(not self.PetView:IsShown())
end

function CollectionatorTabFrameMixin:PetMode()
  self:HideViews()
  self.PetView:Show()
  self:ActivateButtons()
end

function CollectionatorTabFrameMixin:TMogMode()
  self:HideViews()
  self.TMogView:Show()
  self:ActivateButtons()
end
