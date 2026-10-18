local module = {}

function module.CreateNewOmnipack(player)
	local omnipack = Instance.new("Configuration")
	omnipack.Name = "Omnipack"
	for i = 1,5,1 do
		omnipack:SetAttribute("Slot" .. tostring(i), "Empty")
	end
	for i = 1,5,1 do
		omnipack:SetAttribute("Quantity" .. tostring(i), 0)
	end
	omnipack:SetAttribute("FifthSlotUnlocked", false)
	omnipack:SetAttribute("Capacity", 10)
	
	omnipack:SetAttribute("WaterQuantity", 0)
	
	omnipack.Parent = player
end

local function FindVacancyForItem(player, item)
	local omnipack = player:FindFirstChild("Omnipack")
	for i = 1,5,1 do
		local slotItem = omnipack:GetAttribute("Slot" .. tostring(i))
		local slotQuantity = omnipack:GetAttribute("Quantity" .. tostring(i))
		local capacity = omnipack:GetAttribute("Capacity")
		if i == 5 and not omnipack:GetAttribute("FifthSlotUnlocked") then
			break
		end
		if slotItem == item then
			if slotQuantity + 1 <= capacity then
				return i -- return first existing slot that already has the item but can hold more
			end
		end
	end
	for i = 1,5,1 do
		local slotItem = omnipack:GetAttribute("Slot" .. tostring(i))
		if i == 5 and not omnipack:GetAttribute("FifthSlotUnlocked") then
			break
		end
		if slotItem == "Empty" then
			return i -- if couldnt find existing slot, return first empty slot.
		end
	end
	return false -- if no empty slot then return
end

local function InsertItemToSlot(player, item, slotNumber)
	local omnipack = player:FindFirstChild("Omnipack")
	local slotItemName = omnipack:GetAttribute("Slot" .. tostring(slotNumber))
	local itemQuantity = omnipack:GetAttribute("Quantity" .. tostring(slotNumber))
	local capacity = omnipack:GetAttribute("Capacity")
	
	if slotItemName == "Empty" then
		omnipack:SetAttribute("Slot" .. tostring(slotNumber), item)
		omnipack:SetAttribute("Quantity" .. tostring(slotNumber), 1)
		
		spawn(function()
			local sound = player.Character.HumanoidRootPart.OmnipackPickup:Clone()
			sound.Parent = player.Character.HumanoidRootPart
			sound.PlaybackSpeed = math.random(800,1200) / 1000
			sound:Play()
			sound.Ended:Wait()
			sound:Destroy()
		end)
		
		return true
		
	elseif slotItemName == item then
		if itemQuantity + 1 <= capacity then
			omnipack:SetAttribute("Quantity" .. tostring(slotNumber), itemQuantity + 1)
			spawn(function()
				local sound = player.Character.HumanoidRootPart.OmnipackPickup:Clone()
				sound.Parent = player.Character.HumanoidRootPart
				sound.PlaybackSpeed = math.random(800,1200) / 1000
				sound:Play()
				sound.Ended:Wait()
				sound:Destroy()
			end)
			return true
			
		else
			return false
		end
	else
		return false
	end
end

function module.ModifyWaterQuantity(player, changeAmount)
	local playerOmnipack = player:FindFirstChild("Omnipack")
	if playerOmnipack then
		local currentWaterQuantity = playerOmnipack:GetAttribute("WaterQuantity")
		if currentWaterQuantity + changeAmount > playerOmnipack:GetAttribute("Capacity") then
			return
		end
		playerOmnipack:SetAttribute("WaterQuantity", currentWaterQuantity + changeAmount)
		if changeAmount > 0 then
			spawn(function()
				local sound = player.Character.HumanoidRootPart.OmnipackPickup:Clone()
				sound.Parent = player.Character.HumanoidRootPart
				sound.PlaybackSpeed = math.random(800,1200) / 1000
				sound:Play()
				sound.Ended:Wait()
				sound:Destroy()
			end)
		end
	end
end

function module.RemoveItemFromSlot(player, slotNumber)
	--print(slotNumber)
	local omnipack = player:FindFirstChild("Omnipack")
	local slotItemName = omnipack:GetAttribute("Slot" .. tostring(slotNumber))
	local itemQuantity = omnipack:GetAttribute("Quantity" .. tostring(slotNumber))
	local capacity = omnipack:GetAttribute("Capacity")
	if slotItemName == "Empty" or itemQuantity == 0 then
		return
	end
	local newQuantity = itemQuantity - 1
	omnipack:SetAttribute("Quantity" .. tostring(slotNumber), newQuantity)
	if newQuantity == 0 then
		omnipack:SetAttribute("Slot" .. tostring(slotNumber), "Empty")
	end
end

function module.AddItemToOmnipack(player, itemName) -- itemName is like "Frost Slime" no underscores
	local slot = FindVacancyForItem(player, itemName)
	if slot then
		InsertItemToSlot(player, itemName, slot)
		--print("a")
		return true
	else
	--print("b")
		return false
	end
end

function module.SetSlotFive(bool)
	for _, player in (game.Players:GetPlayers()) do
		local omnipack = player:FindFirstChild("Omnipack")
		omnipack:SetAttribute("FifthSlotUnlocked", bool)
		player.PlayerGui.UserInformationGUI.ContainerFrame.OmniPackSlots.Slot5.Visible = bool
	end
end

return module
