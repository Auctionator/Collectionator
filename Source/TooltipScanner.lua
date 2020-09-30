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

local function EnumerateTooltipLines_helper(...)
  for i = 1, select("#", ...) do
    local region = select(i, ...)
    if region and region:GetObjectType() == "FontString" and
        IsBlueColor(region:GetTextColor()) and region:GetText() then
      return true
    end
  end
  return false
end

function EnumerateTooltipLines(tooltip, link)
  MogHunterTooltip:ClearLines()
  if string.match(link, "battlepet") then
    return false
  end
  MogHunterTooltip:SetHyperlink(link)
  local result = EnumerateTooltipLines_helper(tooltip:GetRegions())
  return result
end
