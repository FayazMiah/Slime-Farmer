
local CollectionService = game:GetService("CollectionService")
local existingCollectables = CollectionService:GetTagged("Collectable")
local players = game:GetService("Players")
local omnipackMethods = require(game.ServerScriptService.OmniPackScripts.OmnipackMethods)
local GameValuesModule = require(game.ServerStorage.GameValues.GameValuesModule)

local function intialize(item)
	
	if item:GetAttribute("Initialised") then return end
	item:SetAttribute("Initialised", true)
	
	local att1 = Instance.new("Attachment")
	att1.Name = "CollectableAttachment"
	att1.Orientation = Vector3.new(0, 90, 0)
	att1.Parent = item.PrimaryPart
	
	item:SetAttribute("itemActive", true)

	item.PrimaryPart.Touched:Connect(function(part)
		if item:GetAttribute("beingSucked") == true then
			if part.Parent and part.Parent.Name == "AeroVac" and item:GetAttribute("itemActive") then
				item:SetAttribute("itemActive", false)
				local char = part.Parent.Parent
				local player = players:GetPlayerFromCharacter(char)
				
				if CollectionService:HasTag(item, "Special Items") then
					GameValuesModule.AlterValue("Slimekeys", 1)
					item:Destroy()
					return
				end
				
				local success = omnipackMethods.AddItemToOmnipack(player, item.Name)
				if success then
					item:Destroy()
				else
					item:SetAttribute("itemActive", true)
				end
			end
		end
	end)
	
end


for _, item in pairs(existingCollectables) do
	if item:IsDescendantOf(workspace) then
		intialize(item)
	end
end

CollectionService:GetInstanceAddedSignal("Collectable"):Connect(function(item)
	intialize(item)
end)