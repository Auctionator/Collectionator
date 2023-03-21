CollectionatorSummaryRecipeViewMixin = CreateFromMixins(CollectionatorSummaryViewMixin)

function CollectionatorSummaryRecipeViewMixin:OnLoad()
  CollectionatorSummaryViewMixin.OnLoad(self)

  self.Usable:SetSelectedValue(Collectionator.Constants.RecipesUsableOption.PreviousCharacter)
end
