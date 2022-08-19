CollectionatorRecipeViewMixin = CreateFromMixins(CollectionatorViewMixin)

function CollectionatorRecipeViewMixin:OnLoad()
  CollectionatorViewMixin.OnLoad(self)

  self.Usable:SetSelectedValue(Collectionator.Constants.RecipesUsableOption.PreviousCharacter)
end
