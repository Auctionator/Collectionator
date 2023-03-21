CollectionatorSummaryTabFrameMixin = {}

function CollectionatorSummaryTabFrameMixin:OnLoad()
  Auctionator.Debug.Message("CollectionatorSummaryTabMixin:OnLoad()")
  self:HideViews()
end

function CollectionatorSummaryTabFrameMixin:OnShow()
  self:ActivateButtons()
end

function CollectionatorSummaryTabFrameMixin:HideViews()
  self.TMogView:Hide()
  self.PetView:Hide()
  self.ToyView:Hide()
  self.MountView:Hide()
  self.RecipeView:Hide()
end

function CollectionatorSummaryTabFrameMixin:ActivateButtons()
  self.TMogButton:SetEnabled(not self.TMogView:IsShown())
  self.PetButton:SetEnabled(not self.PetView:IsShown())
  self.ToyButton:SetEnabled(not self.ToyView:IsShown())
  self.MountButton:SetEnabled(not self.MountView:IsShown())
  self.RecipeButton:SetEnabled(not self.RecipeView:IsShown())
end

function CollectionatorSummaryTabFrameMixin:PetMode()
  self:HideViews()
  self.PetView:Show()
  self:ActivateButtons()
end

function CollectionatorSummaryTabFrameMixin:TMogMode()
  self:HideViews()
  self.TMogView:Show()
  self:ActivateButtons()
end

function CollectionatorSummaryTabFrameMixin:ToyMode()
  self:HideViews()
  self.ToyView:Show()
  self:ActivateButtons()
end

function CollectionatorSummaryTabFrameMixin:MountMode()
  self:HideViews()
  self.MountView:Show()
  self:ActivateButtons()
end

function CollectionatorSummaryTabFrameMixin:RecipeMode()
  self:HideViews()
  self.RecipeView:Show()
  self:ActivateButtons()
end

function CollectionatorSummaryTabFrameMixin:OpenOptions()
  Settings.OpenToCategory(COLLECTIONATOR_L_COLLECTIONATOR)
end
