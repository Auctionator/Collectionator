CollectionatorTabFrameMixin = {}

function CollectionatorTabFrameMixin:OnLoad()
  Auctionator.Debug.Message("CollectionatorTabMixin:OnLoad()")

  self:SetUpExportCSVDialog()
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

function CollectionatorTabFrameMixin:SetUpExportCSVDialog()
  if AuctionatorDataProviderMixin.GetCSV then
    self.exportCSVDialog = CreateFrame("Frame", "CollectionatorDataExportFrame", self:GetParent(), "AuctionatorExportTextFrame")
    self.exportCSVDialog:SetPoint("CENTER")
  else
    self.ExportCSV:Hide()
  end
end

function CollectionatorTabFrameMixin:ExportCSVClicked()
  local currentView
  if self.TMogView:IsShown() then
    currentView = self.TMogView
  elseif self.PetView:IsShown() then
    currentView = self.PetView
  elseif self.ToyView:IsShown() then
    currentView = self.ToyView
  else
    currentView = self.MountView
  end

  currentView.DataProvider:GetCSV(function(result)
    self.exportCSVDialog:SetExportString(result)
    self.exportCSVDialog:Show()
  end)
end
