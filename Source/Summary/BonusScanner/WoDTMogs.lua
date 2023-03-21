local WoDTMogsItemIDs = {
  109168,
  109171,
  109172,
  109173,
  109174,
  111526,
  113131,
  113134,
  113270,
  114230,
  114231,
  114232,
  114233,
  114234,
  114235,
  114236,
  114237,
  114809,
  114810,
  114811,
  114812,
  114813,
  114814,
  114815,
  114816,
  114817,
  114818,
  114819,
  114828,
  114829,
  114831,
  116164,
  116165,
  116166,
  116167,
  116168,
  116169,
  116171,
  116174,
  116175,
  116176,
  116177,
  116178,
  116179,
  116180,
  116181,
  116182,
  116183,
  116187,
  116188,
  116189,
  116190,
  116191,
  116192,
  116193,
  116194,
  116425,
  116426,
  116427,
  116453,
  116454,
  116644,
  116646,
  116647,
  120259,
  120261,
}

CollectionatorSummaryWoDTMogBonusScannerFrameMixin = {}

function CollectionatorSummaryWoDTMogBonusScannerFrameMixin:OnLoad()
end

function CollectionatorSummaryWoDTMogBonusScannerFrameMixin:CheckWoDItems(fullScan)
  local waiting = 0
  local done = false
  for _, result in ipairs(fullScan) do
    if tIndexOf(WoDTMogsItemIDs, result.itemKey.itemID) ~= nil then
      print("hit")
    end
  end
  done = true
end
