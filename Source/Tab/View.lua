CollectionatorViewMixin = {}

function CollectionatorViewMixin:OnLoad()
  self.ResultsListing:Init(self.DataProvider)
end

function CollectionatorViewMixin:OnShow()
  self.Scanner:Process()
end

function CollectionatorViewMixin:Refresh()
  if IsShiftKeyDown() then
    self.Scanner:Refresh()
  else
    self.DataProvider:Refresh()
  end
end
