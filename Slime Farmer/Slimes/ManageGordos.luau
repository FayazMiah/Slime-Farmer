
local CS = game:GetService("CollectionService")
local Gordos = CS:GetTagged("GordoSlimes")
--local Florts = CS:GetTagged("Flort")

local debounceItems = {}
local StretchEvent = game.ReplicatedStorage.SlimeEvents.SlimeStretch

local function manageGordo(gordo)
	local mouthHitbox = gordo.MouthHitbox
	mouthHitbox.Touched:Connect(function(hit)
		if not hit.Parent then return end
		if not hit.Parent:GetAttribute("isEdible") then return end
		if (string.sub(hit.Parent.Name, -5) == "Flort") or not (hit.Parent:GetAttribute("foodType") == gordo:GetAttribute("Diet")) then return end

		if hit.Parent.Name == gordo:GetAttribute("Favourite") and not table.find(debounceItems, hit.Parent) then
			hit.Parent:Destroy()
			spawn(function()
				local a = hit.Parent
				table.insert(debounceItems, a)
				wait(1)
				table.remove(debounceItems, a)
			end)
			gordo:SetAttribute("popThreshold", gordo:GetAttribute("popThreshold") - 2)
		else
			hit.Parent:Destroy()
			gordo:SetAttribute("popThreshold", gordo:GetAttribute("popThreshold") - 1)
		end
		
		StretchEvent:FireAllClients(gordo)

		if gordo:GetAttribute("popThreshold") <= 0 then

			local crates = {}

			for i = 1, math.random(1,3), 1 do
				local slimeCrate = game.ServerStorage.GameItems.SlimeCrate:Clone()
				slimeCrate.PrimaryPart.Position = gordo.PrimaryPart.Position + Vector3.new(0,4,0)
				table.insert(crates, slimeCrate)
			end

			local slimeKey = game.ServerStorage.GameItems.SlimeKey:Clone()

			local id = gordo:GetAttribute("GordoID")	
			game.ServerStorage.GameValues.GordosCompleted:SetAttribute(id, true)

			local pos = gordo.PrimaryPart.Position + Vector3.new(0,4,0)
			gordo:Destroy()
			
			slimeKey.Parent = workspace
			slimeKey:MoveTo(pos)
			
			wait(0.5)
			for _, crate in pairs(crates) do
				crate.Parent = workspace
				wait(0.5)
			end
		end
	end)
end

for _, gordo in pairs(Gordos) do
	manageGordo(gordo)
end

CS:GetInstanceAddedSignal("GordoSlimes"):Connect(manageGordo)
--[[CS:GetInstanceAddedSignal("Flort"):Connect(function(flort)
	table.insert(Florts, flort)
end)
]]--