CollectionatorReplicateRecipeViewMixin = CreateFromMixins(CollectionatorReplicateViewMixin)

function CollectionatorReplicateRecipeViewMixin:OnLoad()
  CollectionatorReplicateViewMixin.OnLoad(self)

  self.Usable:SetSelectedValue(Collectionator.Constants.RecipesUsableOption.PreviousCharacter)
end
