CollectionatorViewMixin = {}

function CollectionatorViewMixin:OnLoad()
  self.ResultsListing:Init(self.DataProvider)
end

function CollectionatorViewMixin:OnShow()
  self.Scanner:Process()
end
