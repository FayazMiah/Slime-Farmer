
local AeroVac = script.Parent
local suctionNode = AeroVac.suctionNode
local player = game.Players.LocalPlayer
local CollectionService = game:GetService("CollectionService")
local collectableItems = CollectionService:GetTagged("Collectable")
local UserInputService = game:GetService("UserInputService")
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

local isHoldingRMB = false
local isHoldingLMB = false
local AeroVacRightDownEvent = game.ReplicatedStorage.ActionEvents.AeroVacRightDown
local AeroVacRightReleaseEvent = game.ReplicatedStorage.ActionEvents.AeroVacRightRelease
local AeroVacEjectEvent = game.ReplicatedStorage.ActionEvents.AeroVacEject

local shootAnimationTrack = script.Parent.Animations.ShootAnimation
local suctionAnimationTrack = script.Parent.Animations.SuctionAnimation

local fireDelay = false
local mouse = player:GetMouse()

local UserInputService = game:GetService("UserInputService")
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

local suctionSound = suctionNode:WaitForChild("AeroVacSuction")

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isHoldingRMB = false
		for _, v in pairs(suctionNode:GetChildren()) do
			if v:IsA("AlignPosition") and AeroVac.Parent == player.Character then
				AeroVacRightReleaseEvent:FireServer()
				break
			end
		end
		suctionSound:Stop()
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isHoldingLMB = false
	end
end)
CollectionService:GetInstanceAddedSignal("Collectable"):Connect(function(item)
	table.insert(collectableItems, item)
end)

local function isPartNearRayLoci(rayStart, rayDirection, radius)
	local rayLength = rayDirection.Magnitude
	local rayDirectionUnit = rayDirection.Unit


	local halfSize = Vector3.new(radius, radius, rayLength / 2)
	local regionCenter = rayStart + rayDirection / 2
	local region = Region3.new(regionCenter - halfSize, regionCenter + halfSize)
	
	local targetParts = {}

	local potentialParts = workspace:FindPartsInRegion3(region, nil, math.huge)
	for _, part in ipairs(potentialParts) do
		if CollectionService:HasTag(part.Parent, "Collectable") then
			local startToPart = part.Position - rayStart
			local projectionLength = startToPart:Dot(rayDirectionUnit)
			local clampedProjection = math.clamp(projectionLength, 0, rayLength)
			local closestPoint = rayStart + rayDirectionUnit * clampedProjection
			local distance = (part.Position - closestPoint).Magnitude
			if distance <= radius then
				table.insert(targetParts, part)
			end
		end
	end
	
	if #targetParts > 0 then
		return true, targetParts
	end

	return false
end

local function shootRay()
	local startPosition = suctionNode.Position 
	local direction = suctionNode.CFrame.LookVector * AeroVac:GetAttribute("Range")

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {AeroVac} 

	local raycastResult = workspace:Raycast(startPosition, direction, rayParams)

	local success, region = isPartNearRayLoci(startPosition, direction, 5)
	return success, region
end



local function getMouseDir()
	if player.Character and player.Character.PrimaryPart then
		local characterPosition = player.Character.PrimaryPart.Position
		local mousePosition = mouse.Hit.Position 
		local direction = (mousePosition - characterPosition).Unit
		return direction
	end
end


local function checkForWater(player)
	local character = player.Character or player.CharacterAdded:Wait()
	local rayOrigin = character.Head.Position
	--local rayDirection = character.Head.CFrame.lookVector.Unit * 25
	--print(player:GetAttributes())
	local rayDirection = getMouseDir() * 25
	--print(rayDirection)

	local raycastParams = RaycastParams.new()
	local excludeParts = {}
	for _, part in (character:GetDescendants()) do
		if part:IsA("BasePart") then
			table.insert(excludeParts, part)
		end
	end
	raycastParams.FilterDescendantsInstances = excludeParts
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = false

	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	if raycastResult then
		if raycastResult.Instance.Parent:GetAttribute("UseableWater") then
			return true
		elseif raycastResult.Instance:IsA("Terrain") then
			if raycastResult.Material == Enum.Material.Water then
				return true
			end
		end
	end

	return false
end


local function stopAnimation(animator, animName)
	local animationTracks = animator:GetPlayingAnimationTracks()
	for i, track in pairs (animationTracks) do
		if track.Name == animName then
			track:Stop()
		end
	end
end

local function manageAnimation(animationTrack, mouseButton)
	local playAnim = animator:LoadAnimation(animationTrack)

	if isHoldingLMB and isHoldingRMB then
		stopAnimation(animator, "ShootAnimation")
	end

	playAnim.Priority = Enum.AnimationPriority.Action4

	if mouseButton then
		playAnim:Play()
	else
		stopAnimation(animator, "ShootAnimation")
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton2 then
		isHoldingRMB = true
		if isHoldingRMB and not isHoldingLMB and player.Character:FindFirstChild("AeroVac") then
			manageAnimation(suctionAnimationTrack, isHoldingRMB)
		end
		while isHoldingRMB and not isHoldingLMB and player.Character:FindFirstChild("AeroVac") do
			if not suctionSound.Playing then
				suctionSound:Play()
			end

			local hitSuccess, parts = shootRay()
			if hitSuccess then
				AeroVacRightDownEvent:FireServer(parts)
			end
			
			if (player:GetAttribute("selectedSlot") == "Slot_Water") then
				local isWater = checkForWater(player)
				if isWater then
					AeroVacRightDownEvent:FireServer("Water")
				end
			end
			
			task.wait(0.1) 
		end
		stopAnimation(animator, "SuctionAnimation")
	end
end)


UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
		isHoldingLMB = true
		if isHoldingLMB and player.Character:FindFirstChild("AeroVac") and not isHoldingRMB then
			manageAnimation(shootAnimationTrack, isHoldingLMB)
		end
		while isHoldingLMB and player.Character:FindFirstChild("AeroVac") and not isHoldingRMB do
			if not fireDelay then
				local selectedSlot = player:GetAttribute("selectedSlot")
				local omnipack = player:FindFirstChild("Omnipack")
				if not (selectedSlot == "Slot_Water") then
					if not (omnipack:GetAttribute(selectedSlot) == "Empty") and not (selectedSlot == "None") then
						--print((player:FindFirstChild("Omnipack"):GetAttribute(selectedSlot)))
						AeroVacEjectEvent:FireServer(string.sub(selectedSlot, -1), getMouseDir())
						spawn(function()
							local sound = AeroVac.suctionNode.AeroVacShoot:Clone()
							sound.Parent = AeroVac.suctionNode
							sound.PlaybackSpeed = math.random(4300,4700) / 1000
							sound:Play()
							sound.Ended:Wait()
							sound:Destroy()
						end)
						fireDelay = true
						task.wait(AeroVac:GetAttribute("FireRate")) 
						fireDelay = false
					end
				else
					local omnipack = player:FindFirstChild("Omnipack")
					local waterQuantity = omnipack:GetAttribute("WaterQuantity")
					if waterQuantity > 0 then
						AeroVacEjectEvent:FireServer("Water", getMouseDir())
						spawn(function()
							local sound = AeroVac.suctionNode.AeroVacShoot:Clone()
							sound.Parent = AeroVac.suctionNode
							sound.PlaybackSpeed = math.random(4300,4700) / 1000
							sound:Play()
							sound.Ended:Wait()
							sound:Destroy()
						end)
						fireDelay = true
						task.wait(AeroVac:GetAttribute("FireRate")) 
						fireDelay = false
					end
				end
			end
			wait(0.02)
		end
		stopAnimation(animator, "ShootAnimation")
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.F then
			if AeroVac.Parent == player.Backpack then
				AeroVac.Parent = player.Character
			else
				AeroVac.Parent = player.Backpack
				suctionSound:Stop()
			end
		end	
	end
end)
