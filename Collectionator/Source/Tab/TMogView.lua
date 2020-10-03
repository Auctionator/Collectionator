CollectionatorTMogViewMixin = {}

function CollectionatorTMogViewMixin:OnShow()
  self.Scanner:Process()
end

function CollectionatorTMogViewMixin:OnHide()
end
