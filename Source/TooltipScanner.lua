MogHunterTooltipMixin = {}

function MogHunterTooltipMixin:OnLoad()
  local item = Item:CreateFromItemID(164443)
  item:ContinueOnItemLoad(function()
    --EnumerateTooltipLines(MogHunterTooltip, "|cff1eff00|Hitem:164443::::::::20:260::::::|h[Spiritbough Bindings]|h|r")
  end)
end

local function IsBlueColor(r, g, b, a)
  r = math.ceil(r*100)
  g = math.ceil(g*100)
  b = math.ceil(b*100)
  a = math.ceil(a*100)

  return r==54 and g==67 and b == 100 and a == 100
end

local function ScanTooltipRegions(regions, textToFind)
  for _, region in ipairs(regions) do
    if region and region:GetObjectType() == "FontString" and
        region:GetText() == textToFind then
      return true
    end
  end
  return false
end

function ScanTooltipFor(link, textToFind)
  MogHunterTooltip:ClearLines()
  if string.match(link, "battlepet") then
    return false
  end
  MogHunterTooltip:SetHyperlink(link)
  local result = ScanTooltipRegions({MogHunterTooltip:GetRegions()}, textToFind)
  return result
end
