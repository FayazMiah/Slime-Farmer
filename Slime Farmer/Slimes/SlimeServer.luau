
local CS = game:GetService("CollectionService")
local SlimeModule = require(game.ServerStorage.SlimeRecourses.MainSlimeManager)
local slimes = CS:GetTagged("Slime")

local function makeAOSlime(slime)
	local aoSlime = Instance.new("AlignOrientation")
	aoSlime.Name = "AOSlime"
	aoSlime.Attachment0 = slime.PrimaryPart:FindFirstChild("CollectableAttachment")
	aoSlime.MaxAngularVelocity = 100
	aoSlime.Responsiveness = 10
	aoSlime.MaxTorque = 100
	aoSlime.Enabled = false
	aoSlime.Parent = slime.PrimaryPart
	aoSlime.RigidityEnabled = true
	aoSlime.AlignType = Enum.AlignType.PrimaryAxisLookAt
end

local function manageSlime(slime)
	if slime:GetAttribute("SlimeInitialised") then return end
	slime:SetAttribute("SlimeInitialised", true)
	
	repeat
		wait(0.1)
	until slime:GetAttribute("Initialised")
	
	slime:SetAttribute("isHungry", true)
	slime:SetAttribute("SlimeState", "normal")
	
	slime.PrimaryPart.Touched:Connect(function(incidentPart) -- manage eat (also in the pathfinding bit in mainsliemmanager)
		if CS:HasTag(incidentPart.Parent, "Food") then
			SlimeModule.EatFood(slime, incidentPart.Parent)
		end
	end)
	
	SlimeModule.RenewFace(slime) -- initialise a  
	slime:GetAttributeChangedSignal("SlimeState"):Connect(function() -- renew faces for slime
		SlimeModule.RenewFace(slime)
	end)
	
	makeAOSlime(slime)
	
	while slime and slime.PrimaryPart do
		if not slime:GetAttribute("isHungry") and not slime:GetAttribute("beingSucked") then
			SlimeModule.IdleSlime(slime)
		elseif not slime:GetAttribute("beingSucked") then
			local foodInRange = SlimeModule.MoveToNearestFood(slime)
			if not foodInRange then
				SlimeModule.IdleSlime(slime)
			end
		else
			wait(0.75)
		end
	end
end

for _, slime in pairs(slimes) do
	spawn(function()
		if slime:IsDescendantOf(workspace) then
			manageSlime(slime)
		end
	end)
end
CS:GetInstanceAddedSignal("Slime"):Connect(function(slime)
	spawn(function()
		manageSlime(slime)
	end)
end)