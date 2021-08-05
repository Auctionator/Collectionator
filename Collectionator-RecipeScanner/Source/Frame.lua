Collectionator_RecipeScannerFrameMixin = {}

function Collectionator_RecipeScannerFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "VARIABLES_LOADED",
    "TRADE_SKILL_DATA_SOURCE_CHANGED",
  })
end

function Collectionator_RecipeScannerFrameMixin:OnEvent(event, ...)
  if event == "VARIABLES_LOADED" then
    self:SetupVariables()
  elseif event == "TRADE_SKILL_DATA_SOURCE_CHANGED" then
    self:CacheKnownRecipes()
  end
end

function Collectionator_RecipeScannerFrameMixin:SetupVariables()
  COLLECTIONATOR_KNOWN_RECIPES = COLLECTIONATOR_KNOWN_RECIPES or {}
  self.knownIDs = COLLECTIONATOR_KNOWN_RECIPES

  COLLECTIONATOR_COULD_KNOW_RECIPE = COLLECTIONATOR_COULD_KNOW_RECIPE or {}
  self.couldKnowIDs = COLLECTIONATOR_COULD_KNOW_RECIPE

  self.realmAndFaction = Collectionator.Utilities.GetRealmAndFaction()
end

function Collectionator_RecipeScannerFrameMixin:CacheSpell(db, spellID)
  if db[spellID] == nil then
    db[spellID] = {}
  end

  if tIndexOf(db[spellID], self.realmAndFaction) == nil then
    table.insert(db[spellID], self.realmAndFaction)
  end
end

function Collectionator_RecipeScannerFrameMixin:CacheKnownRecipes()
  local allRecipeIDs = C_TradeSkillUI.GetAllRecipeIDs()

  for _, spellID in ipairs(allRecipeIDs) do
    if IsPlayerSpell(spellID) then
      self:CacheSpell(self.knownIDs, spellID)
    end
    self:CacheSpell(self.couldKnowIDs, spellID)
  end
end
