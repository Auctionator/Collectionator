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
  self.ToyView:Hide()
  self.MountView:Hide()
end

function CollectionatorTabFrameMixin:ActivateButtons()
  self.TMogButton:SetEnabled(not self.TMogView:IsShown())
  self.PetButton:SetEnabled(not self.PetView:IsShown())
  self.ToyButton:SetEnabled(not self.ToyView:IsShown())
  self.MountButton:SetEnabled(not self.MountView:IsShown())
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

function CollectionatorTabFrameMixin:ToyMode()
  self:HideViews()
  self.ToyView:Show()
  self:ActivateButtons()
end

function CollectionatorTabFrameMixin:MountMode()
  self:HideViews()
  self.MountView:Show()
  self:ActivateButtons()
end
