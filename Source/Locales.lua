local currentLocale = {}

local function FixMissingTranslations(incomplete, locale)
  if locale == "enUS" then
    return
  end

  local enUS = COLLECTIONATOR_LOCALES["enUS"]()
  for key, val in pairs(enUS) do
    if incomplete[key] == nil then
      incomplete[key] = val
    end
  end
end

if COLLECTIONATOR_LOCALES[GetLocale()] ~= nil then
  currentLocale = COLLECTIONATOR_LOCALES[GetLocale()]()

  FixMissingTranslations(currentLocale, GetLocale())
else
  currentLocale = COLLECTIONATOR_LOCALES["enUS"]()
end

-- Export constants into the global scope (for XML frames to use)
for key, value in pairs(currentLocale) do
  _G["COLLECTIONATOR_L_"..key] = value
end
