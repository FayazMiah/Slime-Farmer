
local RS = game:GetService("ReplicatedStorage")
local omnipackMethods = require(game.ServerScriptService.OmniPackScripts.OmnipackMethods)
local gameItems = game.ServerStorage.GameItems
local CS = game:GetService("CollectionService")

local waterBall = game.ServerStorage.AeroVacRecourses.WaterBall
local waterPuddle = game.ServerStorage.AeroVacRecourses.Puddle
local puddleSound  = RS.Sounds.PuddleSound

local function makeAOSlime(slime)
	local aoSlime = Instance.new("AlignOrientation")
	aoSlime.Name = "AOSlime"
	aoSlime.Attachment0 = slime:WaitForChild("CollectableAttachment")
	aoSlime.MaxAngularVelocity = 100
	aoSlime.Responsiveness = 10
	aoSlime.MaxTorque = 100
	aoSlime.Enabled = false
	aoSlime.Parent = slime.PrimaryPart
	aoSlime.RigidityEnabled = true
	aoSlime.AlignType = Enum.AlignType.PrimaryAxisLookAt
end

local function makeTrail(item)

	if item.PrimaryPart then
		local colour = RS.ItemInformation.ItemColours:GetAttribute(item.Name:gsub(" ", "_"))
	--	print(item.Name)
		local trail = Instance.new("Trail")
		trail.Lifetime = 0.1
		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4, 0),
			NumberSequenceKeypoint.new(0.5, 0.4, 0),
			NumberSequenceKeypoint.new(1, 0, 0)
		})
		trail.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, colour),
			ColorSequenceKeypoint.new(1, colour)
		}
		local att1 = Instance.new("Attachment")
		local att2 = Instance.new("Attachment")
		att1.Position = Vector3.new(0.25,0,0)
		att2.Position = Vector3.new(-0.25,0,0)
		trail.Attachment0 = att1
		trail.Attachment1 = att2

		local tempItems = {trail, att1, att2}

		trail.Parent = item.PrimaryPart
		att1.Parent = item.PrimaryPart
		att2.Parent = item.PrimaryPart

		return tempItems
	end

	return false
end

local function checkForBlacklist(part)
	local banned = {"Flower", "Puddle", "Bush", "AeroVac", "Water Shot", "Handle"} 
	for _, v in pairs(banned) do
		if part.Name == v or part.Parent.Name == v then
			return true
		end
	end
	return false
end

local function findHitPosition(newWaterBall)
	local rayOrigin = newWaterBall.Position
	local rayDirection = Vector3.new(0, -100, 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {newWaterBall}
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	
	if not raycastResult then
		local rayOrigin = newWaterBall.Position
		local rayDirection = Vector3.new(0, 100, 0) -- Raycast downward reattempt
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {newWaterBall}

		local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	end
	
	return raycastResult
end

local function shootWaterBall(player, AeroVac, direction)
	local startPart = AeroVac:FindFirstChild("suctionNode")

	local newWaterBall = waterBall:Clone()
	newWaterBall.Name = "Water Shot"
	newWaterBall.Position = startPart.Position
	newWaterBall.Anchored = false
	newWaterBall.Parent = workspace
	
	newWaterBall.VectorForce.Force = direction * AeroVac:GetAttribute("EjectPower") * 40
	wait(0.065)
	newWaterBall.VectorForce:Destroy()

	newWaterBall.Touched:Connect(function(hit)
		
		if (not (newWaterBall:GetAttribute("isSplashed")) and not checkForBlacklist(hit)) or (not (newWaterBall:GetAttribute("isSplashed")) and hit.Name == "Terrain") then
			
			newWaterBall:SetAttribute("isSplashed", true)
			--newWaterBall.Anchored = true
			newWaterBall.Main1.Enabled = false
			newWaterBall.Main2.Enabled = false
			
			local raycastResult = findHitPosition(newWaterBall)

			if raycastResult then
				local splashPos = raycastResult.Position 
				local puddle = waterPuddle:Clone()
				
				local sound = puddleSound:Clone()
				sound.Parent = puddle
				local newPlaybackSpeed = math.random(750, 1250) / 1000
				sound.PlaybackSpeed = newPlaybackSpeed
				sound:Play()

				puddle.Anchored = true
				puddle.Position = splashPos
				puddle.Parent = workspace

				spawn(function()
					for i = 1, 10 do
						wait(0.25)
						puddle.Transparency = puddle.Transparency + 0.1
						if puddle.Transparency >= 1 then
							puddle:Destroy()
							break
						end
					end
				end)
			end

			wait(0.5)
			newWaterBall:Destroy()
		end
	end)
end

RS.ActionEvents.AeroVacRightDown.OnServerEvent:Connect(function(player, parts)
	
	if parts == "Water" then
		omnipackMethods.ModifyWaterQuantity(player, 1)
		return
	end
	
	for _, part in pairs(parts) do
		local collectableItem = part.Parent
		if collectableItem then
			if not collectableItem:GetAttribute("beingSucked") then
				local char = player.Character
				local AeroVac = char:FindFirstChild("AeroVac")

				local AlignPosition = Instance.new("AlignPosition")
				AlignPosition.Name = "SuctionAligner"
				AlignPosition.ApplyAtCenterOfMass = true
				AlignPosition.Parent = AeroVac.suctionNode

				local att = collectableItem.PrimaryPart:FindFirstChild("CollectableAttachment")
				AlignPosition.Attachment0 = att
				AlignPosition.Attachment1 = AeroVac.suctionNode.AeroVacAttachment

				collectableItem:SetAttribute("beingSucked", true)
				if CS:HasTag(collectableItem, "Slime") then
					collectableItem:SetAttribute("SlimeState", "scared")
					local ao = collectableItem.PrimaryPart:FindFirstChild("AOSlime")
					ao.Attachment1 = AeroVac.suctionNode.AeroVacAttachment
					ao.Enabled = true
				end
			end
		end
	end
end)

RS.ActionEvents.AeroVacRightRelease.OnServerEvent:Connect(function(player)
	local char = player.Character or player.CharacterAdded:Wait()
	local AeroVac = char:FindFirstChild("AeroVac")
	local suctionNode = AeroVac:FindFirstChild("suctionNode")
	for _, v in pairs(suctionNode:GetChildren()) do
		if v:IsA("AlignPosition") then
			if v.Attachment0 then
				if v.Attachment0.Parent then
					local item = v.Attachment0.Parent.Parent
					item:SetAttribute("beingSucked", false)
					if CS:HasTag(item, "Slime") then
						if item:GetAttribute("isHungry") then
							item:SetAttribute("SlimeState", "normal")
						else
							item:SetAttribute("SlimeState", "excited")
						end
						local ao = item.PrimaryPart:FindFirstChild("AOSlime")
						ao.Attachment1 = nil
						ao.Enabled = false
					end
				end
			end
			v:Destroy()
		end
	end
end)

RS.ActionEvents.AeroVacEject.OnServerEvent:Connect(function(player, selectedSlot, direction)
	local playerOmnipack = player:FindFirstChild("Omnipack")
	if not (selectedSlot == "Water") then
		local item = playerOmnipack:GetAttribute("Slot" .. selectedSlot)
		omnipackMethods.RemoveItemFromSlot(player, selectedSlot)
		local clone = gameItems:FindFirstChild(item):Clone()
		local AeroVac = player.Character:FindFirstChild("AeroVac")
		local head = player.Character.Head
		local node = player.Character.HumanoidRootPart.Position + Vector3.new(0,1,0)
		local pos 
		local dir

		pos = node + (head.CFrame.LookVector * 4)

		clone.Parent = workspace
		clone:MoveTo(pos)

		local baseEjectPower = AeroVac:GetAttribute("EjectPower")
		local scalingFactor = math.log(baseEjectPower)

		local impulseStrength = math.abs(baseEjectPower * scalingFactor)
		clone.PrimaryPart.AssemblyRootPart:ApplyImpulse(direction * impulseStrength * 60)

		spawn(function()
			local trailTemps = makeTrail(clone)
			wait(1)
			if not trailTemps then return end 
			for _, instance in trailTemps do
				instance:Destroy()
			end
		end)
	else
		local AeroVac = player.Character:FindFirstChild("AeroVac")
		if AeroVac then
			omnipackMethods.ModifyWaterQuantity(player, -1)
			shootWaterBall(player, AeroVac, direction)
		end
	end
end)