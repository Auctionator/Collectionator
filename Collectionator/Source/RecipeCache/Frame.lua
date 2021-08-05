CollectionatorRecipeCacheFrameMixin = {}

function CollectionatorRecipeCacheFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "VARIABLES_LOADED",
    "TRADE_SKILL_DATA_SOURCE_CHANGED",
  })
end

function CollectionatorRecipeCacheFrameMixin:OnEvent(event, ...)
  if event == "VARIABLES_LOADED" then
    self:SetupVariables()
  elseif event == "TRADE_SKILL_DATA_SOURCE_CHANGED" then
    self:CacheKnownRecipes()
  end
end

function CollectionatorRecipeCacheFrameMixin:SetupVariables()
  COLLECTIONATOR_RECIPES_CACHE = COLLECTIONATOR_RECIPES_CACHE or {
    known = {},
    couldKnow = {},
  }
  self.knownIDs = COLLECTIONATOR_RECIPES_CACHE.known
  self.couldKnowIDs = COLLECTIONATOR_RECIPES_CACHE.couldKnow

  self.realmAndFaction = Collectionator.Utilities.GetRealmAndFaction()
end

function CollectionatorRecipeCacheFrameMixin:CacheSpell(db, spellID)
  if db[spellID] == nil then
    db[spellID] = {}
  end

  if tIndexOf(db[spellID], self.realmAndFaction) == nil then
    table.insert(db[spellID], self.realmAndFaction)
  end
end

function CollectionatorRecipeCacheFrameMixin:CacheKnownRecipes()
  local allRecipeIDs = C_TradeSkillUI.GetAllRecipeIDs()

  for _, spellID in ipairs(allRecipeIDs) do
    if IsPlayerSpell(spellID) then
      self:CacheSpell(self.knownIDs, spellID)
    end
    self:CacheSpell(self.couldKnowIDs, spellID)
  end
end
