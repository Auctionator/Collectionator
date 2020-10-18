CollectionatorTMogScannerFrameMixin = CreateFromMixins(CollectionatorScannerFrameMixin)

function CollectionatorTMogScannerFrameMixin:OnLoad()
  CollectionatorScannerFrameMixin.OnLoad(self)

  self.SCAN_START_EVENT = Collectionator.Events.SourceLoadStart
  self.SCAN_END_EVENT = Collectionator.Events.SourceLoadEnd
  self.SCAN_STEP =  Collectionator.Constants.TMOG_SCAN_STEP_SIZE
end

function CollectionatorTMogScannerFrameMixin:GetSourceName()
  return "CollectionatorTMogScannerFrameMixin"
end

function CollectionatorTMogScannerFrameMixin:FilterLink(link)
  return select(2, C_TransmogCollection.GetItemInfo(link))
end

function CollectionatorTMogScannerFrameMixin:GetItem(index, link, scanInfo)
  local _, source = C_TransmogCollection.GetItemInfo(link)

  if source ~= nil then
    local visual = C_TransmogCollection.GetSourceInfo(source).visualID

    local set = C_TransmogCollection.GetAllAppearanceSources(visual)
    if #set == 0 then
      set = {source}
    end

    local armorType = -1
    local weaponType = -1

    local itemInfo = {GetItemInfo(link)}
    if itemInfo[12] == 4 then
      armorType = itemInfo[13]
    elseif itemInfo[12] == 2 then
      weaponType = itemInfo[13]
    end

    return {
      id = source, visual = visual, index = index, set = set,
      armor = armorType, weapon = weaponType,
      levelRequired = select(5, GetItemInfo(link)),
    }

  else
    return nil
  end
end
