CollectionatorTMogScannerFrameMixin = CreateFromMixins(CollectionatorScannerFrameMixin)

function CollectionatorTMogScannerFrameMixin:OnLoad()
  CollectionatorScannerFrameMixin.OnLoad(self)

  self.SCAN_START_EVENT = Collectionator.Events.SourceLoadStart
  self.SCAN_END_EVENT = Collectionator.Events.SourceLoadEnd
  self.SCAN_STEP =  750
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
    return {
      id = source, visual = visual, index = index, set = set,
      levelRequired = select(5, GetItemInfo(link)),
    }

  else
    return nil
  end
end
