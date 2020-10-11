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

function CollectionatorTMogScannerFrameMixin:GetItem(index, link, scanInfo)
  local _, source = C_TransmogCollection.GetItemInfo(link)

  if source ~= nil then
    local visual = C_TransmogCollection.GetSourceInfo(source).visualID
    local set = C_TransmogCollection.GetAllAppearanceSources(visual)
    if #set == 0 then
      set = {source}
    end

    local uniqueCollected = false
    for _, altSource in ipairs(set) do
      uniqueCollected = uniqueCollected or C_TransmogCollection.GetSourceInfo(altSource).isCollected
    end

    return {
      id = source, visual = visual, index = index,
      levelRequired = select(5, GetItemInfo(link)),
      isCollected = C_TransmogCollection.GetSourceInfo(source).isCollected,
      uniqueCollected = uniqueCollected,
      playerCanLearn = C_TransmogCollection.PlayerKnowsSource(source),
    }

  else
    return nil
  end
end
