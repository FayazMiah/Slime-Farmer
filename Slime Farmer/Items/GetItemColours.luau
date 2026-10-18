
local items = game.ServerStorage.GameItems:GetChildren()
local RS = game:GetService("ReplicatedStorage")
local indicatorBackgroundColour = Color3.fromRGB(34, 34, 34)
local colourValues = RS.ItemInformation.ItemColours

local function colorDistance(color1, color2)
	local rDiff = color1.R - color2.R
	local gDiff = color1.G - color2.G
	local bDiff = color1.B - color2.B
	return math.sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff)
end


local function isColorTooSimilar(targetColor, comparisonColor, threshold)
	local distance = colorDistance(targetColor, comparisonColor)
	return distance < threshold
end

local function lightenColor(color, factor)
	local newR = math.min(color.R + factor, 1)
	local newG = math.min(color.G + factor, 1)
	local newB = math.min(color.B + factor, 1)
	return Color3.new(newR, newG, newB)
end


local function checkTableForName(list, name)
	for name1, colour in pairs(list) do
		if name1 == name then
			return true
		end
	end
end

function increaseSaturation(color3, amount)
	local h, s, v = color3:ToHSV()
	s = math.min(s + amount, 1)
	return Color3.fromHSV(h, s, v)
end

local function setAverageColour(item)

	local totalWeight = 0
	local weightedColourR, weightedColourG, weightedColourB = 0, 0, 0 

	for _, part in pairs(item:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.Transparency < 1 then
				local partSize = part.Size
				local partVolume = partSize.X * partSize.Y * partSize.Z 

				local partColor = part.Color
				weightedColourR = weightedColourR + partColor.R * partVolume
				weightedColourG = weightedColourG + partColor.G * partVolume
				weightedColourB = weightedColourB + partColor.B * partVolume
				totalWeight = totalWeight + partVolume
			end
		end
	end

	local averageColour = totalWeight > 0 and Color3.new(weightedColourR / totalWeight, weightedColourG / totalWeight, weightedColourB / totalWeight) or Color3.new(0, 0, 0)

	while isColorTooSimilar(indicatorBackgroundColour, averageColour, 0.25) do
		averageColour = lightenColor(averageColour, 0.25)
		wait()
	end
	
	averageColour = increaseSaturation(averageColour, 0.01)

	local alreadyExists = checkTableForName(colourValues:GetAttributes(), item.Name)
	if not alreadyExists then
		colourValues:SetAttribute(string.gsub(item.Name, " ", "_"), averageColour)
	end

end

for _, item in pairs(items) do -- loops through all parts and gets average colour of all parts in the item
	setAverageColour(item)
end

