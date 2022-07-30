CollectionatorRecipeCacheFrameMixin = {}

function CollectionatorRecipeCacheFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "PLAYER_LOGIN",
    "TRADE_SKILL_DATA_SOURCE_CHANGED",
  })
end

function CollectionatorRecipeCacheFrameMixin:OnEvent(event, ...)
  if event == "PLAYER_LOGIN" then
    self:SetupVariables()
  elseif event == "TRADE_SKILL_DATA_SOURCE_CHANGED" then
    if Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_RECIPE_CACHING) then
      self:CacheKnownRecipes()
    end
  end
end

function CollectionatorRecipeCacheFrameMixin:ResetCache()
  COLLECTIONATOR_RECIPES_CACHE = {
    known = {},
    couldKnow = {},
  }
  self.knownIDs = COLLECTIONATOR_RECIPES_CACHE.known
  self.couldKnowIDs = COLLECTIONATOR_RECIPES_CACHE.couldKnow
end

function CollectionatorRecipeCacheFrameMixin:SetupVariables()
  if COLLECTIONATOR_RECIPES_CACHE == nil then
    self:ResetCache()
  end
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
      self.knownIDs[spellID] = true
    end
    self:CacheSpell(self.couldKnowIDs, spellID)
  end
end
