CollectionatorTMogViewMixin = CreateFromMixins(CollectionatorViewMixin)

function CollectionatorTMogViewMixin:OnLoad()
  CollectionatorViewMixin.OnLoad(self)

  self.QualityFilter:ToggleFilter(Enum.ItemQuality.Poor)
  self.QualityFilter:ToggleFilter(Enum.ItemQuality.Common)
end
