CollectionatorReplicateTMogViewMixin = CreateFromMixins(CollectionatorReplicateViewMixin)

function CollectionatorReplicateTMogViewMixin:OnLoad()
  CollectionatorReplicateViewMixin.OnLoad(self)

  self.QualityFilter:ToggleFilter(Enum.ItemQuality.Poor)
  self.QualityFilter:ToggleFilter(Enum.ItemQuality.Common)
end
