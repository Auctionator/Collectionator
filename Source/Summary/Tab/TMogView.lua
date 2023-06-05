CollectionatorSummaryTMogViewMixin = CreateFromMixins(CollectionatorSummaryViewMixin)

function CollectionatorSummaryTMogViewMixin:OnLoad()
  CollectionatorSummaryViewMixin.OnLoad(self)

  self.IncludeCrafted:SetChecked(true)
end
