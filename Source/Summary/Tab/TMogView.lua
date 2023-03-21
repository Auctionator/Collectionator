CollectionatorSummaryTMogViewMixin = CreateFromMixins(CollectionatorSummaryViewMixin)

function CollectionatorSummaryTMogViewMixin:OnLoad()
  CollectionatorSummaryViewMixin.OnLoad(self)

  self.QualityFilter:ToggleFilter(Enum.ItemQuality.Poor)
  self.QualityFilter:ToggleFilter(Enum.ItemQuality.Common)
end
