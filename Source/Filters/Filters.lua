CollectionatorFilterDropDownMixin = {}

function CollectionatorFilterDropDownMixin:GetValue(filter)
  return self.filters[filter]
end

function CollectionatorFilterDropDownMixin:GetFilters()
  --Override
  return {}
end
function CollectionatorFilterDropDownMixin:GetFilterName(filter)
  --Override
  return ""
end

function CollectionatorFilterDropDownMixin:OnLoad()
  self:Reset()
end

function CollectionatorFilterDropDownMixin:Reset()
  self.filters = {}
  for _, petType in ipairs(self:GetFilters()) do
    self.filters[petType] = true
  end
end

function CollectionatorFilterDropDownMixin:ToggleNone()
  local anyTrue = false
  for filter, _ in pairs(self.filters) do
    anyTrue = anyTrue or self.filters[filter]
  end

  if anyTrue then
    for filter, _ in pairs(self.filters) do
      self.filters[filter] = false
    end
  else
    self:Reset()
  end
end

function CollectionatorFilterDropDownMixin:ToggleFilter(name)
  self.filters[name] = not self.filters[name]
end

function CollectionatorFilterDropDownMixin:OnClick()
  local menu
  menu = MenuUtil.CreateContextMenu(self, function(_, rootDescription)
    rootDescription:CreateCheckbox(AUCTIONATOR_L_NONE,
    function() return false end,
    function()
      self:ToggleNone()
    end)
    for _, filter in ipairs(self:GetFilters()) do
      rootDescription:CreateCheckbox(self:GetFilterName(filter), function()
        return self:GetValue(filter)
      end, function()
        self:ToggleFilter(filter)
      end)
    end
  end)
  PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

local function GetPetIcon(filterName)
  return "Interface\\PetBattles\\PetIcon-" .. PET_TYPE_SUFFIX[filterName]
end

CollectionatorPetSpeciesFilterMixin = CreateFromMixins(CollectionatorFilterDropDownMixin)

function CollectionatorPetSpeciesFilterMixin:GetFilters()
  return {
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10
  }
end

function CollectionatorPetSpeciesFilterMixin:GetFilterName(filter)
  local petIcon =  CreateTextureMarkup(GetPetIcon(filter), 70, 64, 18, 16, 16/128, 112/128, 0/256, 88/256)
  local filterName = _G["BATTLE_PET_NAME_" .. tostring(filter)]
  return petIcon .. "  " .. filterName
end

CollectionatorQualityFilterMixin = CreateFromMixins(CollectionatorFilterDropDownMixin)

function CollectionatorQualityFilterMixin:GetFilters()
  return {
    Enum.ItemQuality.Poor, Enum.ItemQuality.Common or Enum.ItemQuality.Standard, Enum.ItemQuality.Uncommon or Enum.ItemQuality.Good, Enum.ItemQuality.Rare, Enum.ItemQuality.Epic
  }
end

function CollectionatorQualityFilterMixin:GetFilterName(filter)
  local filterName = _G["ITEM_QUALITY" .. filter .. "_DESC"]
  return ITEM_QUALITY_COLORS[filter].color:WrapTextInColorCode(filterName)
end

CollectionatorArmorFilterMixin = CreateFromMixins(CollectionatorFilterDropDownMixin)

function CollectionatorArmorFilterMixin:GetFilters()
  return {
    0, 1, 2, 3, 4, 5, 6
  }
end

function CollectionatorArmorFilterMixin:GetFilterName(filter)
  return GetItemSubClassInfo(4, filter)
end

CollectionatorWeaponFilterMixin = CreateFromMixins(CollectionatorFilterDropDownMixin)

function CollectionatorWeaponFilterMixin:GetFilters()
  return {
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15, 16, 18, 19, 20
  }
end

function CollectionatorWeaponFilterMixin:GetFilterName(filter)
  return GetItemSubClassInfo(2, filter)
end

local SLOTS = {
  1, 3, 4, 5, 6, 7, 8, 9, 10, 16, 17, 15, 19
}

local SLOTS_TO_NAME = {
  INVTYPE_HEAD,
  INVTYPE_NECK,
  INVTYPE_SHOULDER,
  INVTYPE_BODY,
  INVTYPE_CHEST,
  INVTYPE_WAIST,
  INVTYPE_LEGS,
  INVTYPE_FEET,
  INVTYPE_WRIST,
  INVTYPE_HAND,
  nil,
  nil,
  nil,
  nil,
  INVTYPE_CLOAK,
  INVTYPE_WEAPONMAINHAND,
  INVTYPE_WEAPONOFFHAND,
  nil,
  INVTYPE_TABARD
}

CollectionatorSlotFilterMixin = CreateFromMixins(CollectionatorFilterDropDownMixin)
function CollectionatorSlotFilterMixin:GetFilters()
  return SLOTS
end
function CollectionatorSlotFilterMixin:GetFilterName(filter)
  return SLOTS_TO_NAME[filter]
end

local MOUNT_TYPES = {
  230, 424, 254
}

local MOUNT_TYPES_TO_NAME = {
  [230] = COLLECTIONATOR_L_MOUNT_GROUND,
  [424] = COLLECTIONATOR_L_MOUNT_FLYING,
  [254] = COLLECTIONATOR_L_MOUNT_SWIMMING
}

CollectionatorMountTypeFilterMixin = CreateFromMixins(CollectionatorFilterDropDownMixin)
function CollectionatorMountTypeFilterMixin:GetFilters()
  return MOUNT_TYPES
end
function CollectionatorMountTypeFilterMixin:GetFilterName(filter)
  return MOUNT_TYPES_TO_NAME[filter]
end

local PROFESSION_SUBCLASSES = {
  Enum.ItemRecipeSubclass.Leatherworking,
  Enum.ItemRecipeSubclass.Tailoring,
  Enum.ItemRecipeSubclass.Engineering,
  Enum.ItemRecipeSubclass.Blacksmithing,
  Enum.ItemRecipeSubclass.Alchemy,
  Enum.ItemRecipeSubclass.Enchanting,
  Enum.ItemRecipeSubclass.Jewelcrafting,
  Enum.ItemRecipeSubclass.Inscription,
  Enum.ItemRecipeSubclass.Cooking,
  Enum.ItemRecipeSubclass.Fishing,
  Enum.ItemRecipeSubclass.FirstAid,
  Enum.ItemRecipeSubclass.Book,
}

CollectionatorProfessionFilterMixin = CreateFromMixins(CollectionatorFilterDropDownMixin)

function CollectionatorProfessionFilterMixin:GetFilters()
  return PROFESSION_SUBCLASSES
end

function CollectionatorProfessionFilterMixin:GetFilterName(filter)
  return GetItemSubClassInfo(Enum.ItemClass.Recipe, filter)
end
