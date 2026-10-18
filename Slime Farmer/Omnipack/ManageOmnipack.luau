
local player = game.Players.LocalPlayer
local OmniPackSlots = script.Parent.ContainerFrame.OmniPackSlots
local omnipack = player:WaitForChild("Omnipack")
local slots = {}

local vacantSlotId = "rbxassetid://113459960333466"
local imageIDs = game.ReplicatedStorage.ItemInformation.ItemImageIDs

local colourValues = game.ReplicatedStorage.ItemInformation.ItemColours
local fallbackColour = Color3.fromRGB(103, 114, 217)
local emptySelectedColour = Color3.fromRGB(26, 26, 26)

local UIS = game:GetService("UserInputService")

script.Parent.Enabled = true

for _, slot in pairs(OmniPackSlots:GetChildren()) do
	if slot:IsA("Frame") or slot:IsA("CanvasGroup") then
		table.insert(slots, slot)
	end
end

local slot1 = OmniPackSlots:FindFirstChild("Slot1")
local slot2 = OmniPackSlots:FindFirstChild("Slot2")
local slot3 = OmniPackSlots:FindFirstChild("Slot3")
local slot4 = OmniPackSlots:FindFirstChild("Slot4")
local slot5 = OmniPackSlots:FindFirstChild("Slot5")
local slot_water = OmniPackSlots:FindFirstChild("Slot_Water")

player:SetAttribute("selectedSlot", "None")

local function IndicatorSize(quantity, capacity)
	local sf = quantity / capacity
	sf *= 2 -- (the way the frame is, an size.x of 1 would be half the bar)
	local size = UDim2.new(sf, 0, 0.9, 0)
	return size
end

local function setNormalTransparency()
	for _, slot in pairs(slots) do
		slot.BackgroundTransparency = 0.2
		slot.UIStroke.Thickness = 3
		slot.UIStroke.Color = Color3.fromRGB(35, 35, 35)
		slot.UIStroke.LineJoinMode = Enum.LineJoinMode.Round
	end
end

local function getColour(slot)
	local item = omnipack:GetAttribute("Slot" .. slot)
	item = string.gsub(item, " ", "_")
	local colour = colourValues:GetAttribute(item)
	if colour then
		return colour
	else
		return emptySelectedColour
	end
end

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.One then	
			setNormalTransparency()
			if player:GetAttribute("selectedSlot") == "Slot1" then
				player:SetAttribute("selectedSlot", "None")
			else
				slot1.BackgroundTransparency = 0.3
				player:SetAttribute("selectedSlot", "Slot1")
				slot1.UIStroke.Thickness = 5
				slot1.UIStroke.Color = getColour(1)
				getColour(1)
				slot1.UIStroke.LineJoinMode = Enum.LineJoinMode.Round
			end		
		elseif input.KeyCode == Enum.KeyCode.Two then
			setNormalTransparency()
			if player:GetAttribute("selectedSlot") == "Slot2" then
				player:SetAttribute("selectedSlot", "None")
			else
				slot2.BackgroundTransparency = 0.3
				player:SetAttribute("selectedSlot", "Slot2")
				slot2.UIStroke.Thickness = 5
				slot2.UIStroke.Color = getColour(2)
				slot2.UIStroke.LineJoinMode = Enum.LineJoinMode.Round
			end
		elseif input.KeyCode == Enum.KeyCode.Three then
			setNormalTransparency()
			if player:GetAttribute("selectedSlot") == "Slot3" then
				player:SetAttribute("selectedSlot", "None")
			else
				slot3.BackgroundTransparency = 0.3
				player:SetAttribute("selectedSlot", "Slot3")
				slot3.UIStroke.Thickness = 5
				slot3.UIStroke.Color = getColour(3)
				slot3.UIStroke.LineJoinMode = Enum.LineJoinMode.Round
			end
		elseif input.KeyCode == Enum.KeyCode.Four then
			setNormalTransparency()
			if player:GetAttribute("selectedSlot") == "Slot4" then
				player:SetAttribute("selectedSlot", "None")
			else
				slot4.BackgroundTransparency = 0.3
				player:SetAttribute("selectedSlot", "Slot4")
				slot4.UIStroke.Thickness = 5
				slot4.UIStroke.Color = getColour(4)
				slot4.UIStroke.LineJoinMode = Enum.LineJoinMode.Round
			end
		elseif input.KeyCode == Enum.KeyCode.Five and omnipack:GetAttribute("FifthSlotUnlocked") then
			setNormalTransparency()
			if player:GetAttribute("selectedSlot") == "Slot5" then
				player:SetAttribute("selectedSlot", "None")
			else
				slot5.BackgroundTransparency = 0.3
				player:SetAttribute("selectedSlot", "Slot5")
				slot5.UIStroke.Thickness = 5
				slot5.UIStroke.Color = getColour(5)
				slot5.UIStroke.LineJoinMode = Enum.LineJoinMode.Round
			end
		elseif input.KeyCode == Enum.KeyCode.Q then
			setNormalTransparency()
			if player:GetAttribute("selectedSlot") == "Slot_Water" then
				player:SetAttribute("selectedSlot", "None")
			else
				slot_water.BackgroundTransparency = 0.3
				player:SetAttribute("selectedSlot", "Slot_Water")
				slot_water.UIStroke.Thickness = 5
				slot_water.UIStroke.Color = Color3.fromRGB(30, 88, 97)
				slot_water.UIStroke.LineJoinMode = Enum.LineJoinMode.Round
			end
		--else
			--setNormalTransparency()
			--player:SetAttribute("selectedSlot", "None")
		end
	end
	
end)



local function updateSlot()
	for i, slot in pairs(slots) do
		if not (slot.Name == "Slot_Water") then
			local slotNumber = string.sub(slot.Name, -1)
			if slotNumber == 5 and not omnipack:GetAttribute("FifthSlotUnlocked") then
				break
			end
			local itemQuantity = omnipack:GetAttribute("Quantity" .. tostring(slotNumber))
			if itemQuantity == 0 then
				slot.SlotItem.Image = vacantSlotId
				slot.ItemAmount.Text = "EMPTY"
				slot.ItemName.Text = ""
				slot.QuantityIndicator.Full_Indicator.Size = UDim2.new(0,0,0.9,0)
				slot.UIStroke.Color = emptySelectedColour
			else
				local itemName = omnipack:GetAttribute("Slot" .. tostring(slotNumber))
				slot.ItemAmount.Text = "x" .. tostring(itemQuantity)
				slot.ItemName.Text = itemName
				if imageIDs:GetAttribute(string.gsub(itemName, " ", "_")) then
					slot.SlotItem.Image = imageIDs:GetAttribute(string.gsub(itemName, " ", "_"))
				else
					slot.SlotItem.Image = "rbxassetid://15668939723"
				end
				slot.QuantityIndicator.Full_Indicator.Size = IndicatorSize(itemQuantity, omnipack:GetAttribute("Capacity"))
				if colourValues:GetAttribute(string.gsub(itemName, " ", "_")) then
					slot.QuantityIndicator.Full_Indicator.BackgroundColor3 = colourValues:GetAttribute(string.gsub(itemName, " ", "_"))
				else
					slot.QuantityIndicator.Full_Indicator.BackgroundColor3 = fallbackColour
				end
				if player:GetAttribute("selectedSlot") == "Slot" .. tostring(slotNumber) then
					slot.UIStroke.Color = getColour(slotNumber)
				end
			end	
		else
			local waterIndicator = slot.Full_Indicator
			local waterQuantity = omnipack:GetAttribute("WaterQuantity")
			local sf = waterQuantity / omnipack:GetAttribute("Capacity")
			sf *= 2 -- (the way the frame is, an size.x of 1 would be half the bar)
			local size = UDim2.new(1, 0, sf, 0)
			waterIndicator.Size = size
		end
	end
end

omnipack.AttributeChanged:Connect(function(attribute)
	updateSlot()
end)