CollectionatorReplicateTabFrameMixin = {}

function CollectionatorReplicateTabFrameMixin:OnLoad()
  Auctionator.Debug.Message("CollectionatorReplicateTabMixin:OnLoad()")
  self:HideViews()
end

function CollectionatorReplicateTabFrameMixin:OnShow()
  self:ActivateButtons()
end

function CollectionatorReplicateTabFrameMixin:HideViews()
  self.TMogView:Hide()
  self.PetView:Hide()
  self.ToyView:Hide()
  self.MountView:Hide()
  self.RecipeView:Hide()
end

function CollectionatorReplicateTabFrameMixin:ActivateButtons()
  self.TMogButton:SetEnabled(not self.TMogView:IsShown())
  self.PetButton:SetEnabled(not self.PetView:IsShown())
  self.ToyButton:SetEnabled(not self.ToyView:IsShown())
  self.MountButton:SetEnabled(not self.MountView:IsShown())
  self.RecipeButton:SetEnabled(not self.RecipeView:IsShown())
end

function CollectionatorReplicateTabFrameMixin:PetMode()
  self:HideViews()
  self.PetView:Show()
  self:ActivateButtons()
end

function CollectionatorReplicateTabFrameMixin:TMogMode()
  self:HideViews()
  self.TMogView:Show()
  self:ActivateButtons()
end

function CollectionatorReplicateTabFrameMixin:ToyMode()
  self:HideViews()
  self.ToyView:Show()
  self:ActivateButtons()
end

function CollectionatorReplicateTabFrameMixin:MountMode()
  self:HideViews()
  self.MountView:Show()
  self:ActivateButtons()
end

function CollectionatorReplicateTabFrameMixin:RecipeMode()
  self:HideViews()
  self.RecipeView:Show()
  self:ActivateButtons()
end

function CollectionatorReplicateTabFrameMixin:OpenOptions()
  Settings.OpenToCategory(COLLECTIONATOR_L_COLLECTIONATOR)
end
