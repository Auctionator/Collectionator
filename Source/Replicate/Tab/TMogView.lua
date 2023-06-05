CollectionatorReplicateTMogViewMixin = CreateFromMixins(CollectionatorReplicateViewMixin)

function CollectionatorReplicateTMogViewMixin:OnLoad()
  CollectionatorReplicateViewMixin.OnLoad(self)

  self.IncludeCrafted:SetChecked(true)
end
