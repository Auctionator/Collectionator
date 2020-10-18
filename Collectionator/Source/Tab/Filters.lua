CollectionatorFilterDropDownMixin = {}
local function CollectionatorFilterDropDownMenu_Initialize(self)
  local filterButton = self:GetParent()

  local filters = PET_TYPES
  for filter, _ in pairs(filterButton.filters) do
    local info = UIDropDownMenu_CreateInfo()
    info.text = filterButton:GetFilterName(filter)
    info.value = nil
    info.isNotRadio = true
    info.checked = filterButton.filters[filter]
    info.keepShownOnClick = 1
    info.func = function(button)
      filterButton:ToggleFilter(filter)
    end
    UIDropDownMenu_AddButton(info)
  end
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
  UIDropDownMenu_SetInitializeFunction(self.DropDown, CollectionatorFilterDropDownMenu_Initialize)
  UIDropDownMenu_SetDisplayMode(self.DropDown, "MENU")
end

function CollectionatorFilterDropDownMixin:Reset()
  self.filters = {}
  for _, petType in ipairs(self:GetFilters()) do
    self.filters[petType] = true
  end
end

function CollectionatorFilterDropDownMixin:ToggleFilter(name)
  self.filters[name] = not self.filters[name]
end

function CollectionatorFilterDropDownMixin:OnClick()
	local level = 1
	local value = nil
	ToggleDropDownMenu(1, nil, self.DropDown, self, 9, 3)
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
    1, 2, 3, 4
  }
end

function CollectionatorQualityFilterMixin:GetFilterName(filter)
  local filterName = _G["ITEM_QUALITY" .. filter .. "_DESC"]
  return ITEM_QUALITY_COLORS[filter].color:WrapTextInColorCode(filterName)
end
