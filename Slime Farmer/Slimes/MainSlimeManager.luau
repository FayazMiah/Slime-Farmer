local module = {}

local StretchEvent = game.ReplicatedStorage.SlimeEvents.SlimeStretch

local CS = game:GetService("CollectionService")

local PathfindingService = game:GetService("PathfindingService")

local mouths = {
	normal = game.ServerStorage.SlimeRecourses.slimeObjects.normalMouth,
	scared = game.ServerStorage.SlimeRecourses.slimeObjects.scaredMouth,
	excited = game.ServerStorage.SlimeRecourses.slimeObjects.excitedMouth,
	eating = game.ServerStorage.SlimeRecourses.slimeObjects.eatingMouth
}

local function moveSlimeToTarget(slime, targetPosition)
	
	local humanoid = slime:FindFirstChild("Humanoid")
	local slimeHRP = slime:FindFirstChild("HumanoidRootPart")
	if not humanoid then
		print("No humanoid found!")
		return
	end
	--[[local path = PathfindingService:CreatePath({
		AgentRadius = 3, 
		AgentHeight = 3,
		AgentCanJump = true,
		AgentCanClimb = false,
		AgentMaxSlope = 15
	})
	path:ComputeAsync(slime.HumanoidRootPart.Position, targetPosition)
	local timeElapsed = 0
	spawn(function()
		while timeElapsed < 7 do
			wait(1)
			timeElapsed += 1
		end
	end)
	if path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
		for _, waypoint in pairs(waypoints) do
			slimeHRP.CFrame = CFrame.new(slimeHRP.Position, waypoint.Position)
			humanoid:MoveTo(waypoint.Position)
			if timeElapsed >= 7 then
				humanoid:MoveTo(slimeHRP.Position)
				break
			end
			humanoid.MoveToFinished:Wait()
		end
	end]]
	
	slimeHRP.CFrame = CFrame.new(slimeHRP.Position, targetPosition)
	humanoid:MoveTo(targetPosition)
	humanoid.MoveToFinished:Wait()
	
	for _, v in pairs(slimeHRP:GetTouchingParts()) do
		if CS:HasTag(v.Parent, "Food") then
			module.EatFood(slime, v.Parent)
		end
	end
end


function module.JumpSlime(slime) 
	if not slime or not slime.PrimaryPart then return end
	local Humanoid = slime:FindFirstChild("Humanoid")

	StretchEvent:FireAllClients(slime)
	
	wait(0.5)
	if not slime or not slime.PrimaryPart then return end

	local force = Instance.new("VectorForce")
	force.Force = Vector3.new(3000,0,0)

	force.Attachment0 = slime.PrimaryPart:FindFirstChild("CollectableAttachment")
	force.Parent = slime.PrimaryPart
	force.Enabled = true
	Humanoid.Jump = true
	wait(1)
	force:Destroy()
end

function module.MoveToNearestFood(slime)
	if not slime or not slime.PrimaryPart then return end
	local foods = CS:GetTagged("Food")
	local slimeHRP = slime.PrimaryPart
	local dist = math.huge 
	local diet = slime:GetAttribute("Diet")
	local nearestFood = nil
	for _, food in pairs(foods) do
		if food:IsDescendantOf(workspace) and (food:GetAttribute("foodType") == diet) then
			local foodPosition = food.PrimaryPart.Position
			local distance = (foodPosition - slimeHRP.Position).Magnitude
			if distance < dist then
				dist = distance
				nearestFood = food
			end
		end
	end
	if not nearestFood then
		return false
	end
	local foodPosition = nearestFood.PrimaryPart.Position
	if (foodPosition - slimeHRP.Position).Magnitude < 45 then
		slimeHRP.CFrame = CFrame.new(slimeHRP.Position, foodPosition)
		moveSlimeToTarget(slime, foodPosition)
		wait(1)
		return true
	else
		return false
	end
end

function module.EatFood(slime, food)
	if not slime or not slime.PrimaryPart then return end
	if not food or not food.PrimaryPart then return end
	if food:GetAttribute("foodType") == slime:GetAttribute("Diet") then
	if not slime:GetAttribute("isHungry") then return end
		
		local flortCount = 1
		if (slime:GetAttribute("Favourite") == food.Name) then
			flortCount = 2
		end
	
		food:Destroy()
		
		for i = 1, flortCount, 1 do
			local flortCopy = game.ServerStorage.GameItems[slime.Name:gsub("Slime", "") .. "Flort"]:Clone()
			if slime then
				if slime.PrimaryPart then
					flortCopy.Parent = workspace
					flortCopy:MoveTo(slime.HumanoidRootPart.CFrame * (slime.HumanoidRootPart.CFrame.lookVector.Unit * -i * 2) + Vector3.new(0,0.5,0))
					--flortCopy.PrimaryPart.Position = slime.HumanoidRootPart.CFrame * (slime.HumanoidRootPart.CFrame.lookVector.Unit * -i * 2) + Vector3.new(0,0.5,0)
				end
			end
		end
		spawn(function()
			slime:SetAttribute("isHungry", false)
			slime:SetAttribute("SlimeState", "excited")
			wait(script.EatCooldown.Value)
			slime:SetAttribute("isHungry", true)
			slime:SetAttribute("SlimeState", "normal")
		end)
	end
end
local function getSlimeDirection(slime)
	local deviationAngle = math.rad(90) 
	local currentLookVector = slime.PrimaryPart.CFrame.LookVector
	local randomAngle = math.random() * 2 * deviationAngle - deviationAngle 
	local rotation = CFrame.Angles(0, randomAngle, 0) 
	local biasedDirection = (rotation * currentLookVector).Unit 
	return biasedDirection
end

function module.IdleSlime(slime)
	if not slime or not slime.PrimaryPart then return end
	local slimeHRP = slime:FindFirstChild("HumanoidRootPart")
	local direction = getSlimeDirection(slime)
	local lookAtPoint = slimeHRP.Position + direction * 10 
	slimeHRP.CFrame = CFrame.new(slimeHRP.Position, lookAtPoint)
	module.JumpSlime(slime)
	wait(1)
end

local function removeSlimeMouth(slime)

	if slime:FindFirstChild("excitedMouth") then
		slime:FindFirstChild("excitedMouth"):Destroy()
		return
	end
	if slime:FindFirstChild("normalMouth") then
		slime:FindFirstChild("normalMouth"):Destroy()
		return
	end
	if slime:FindFirstChild("scaredMouth") then
		slime:FindFirstChild("scaredMouth"):Destroy()
		return
	end
	if slime:FindFirstChild("eatingMouth") then
		slime:FindFirstChild("eatingMouth"):Destroy()
		return
	end

end

function module.RenewFace(slime)
	removeSlimeMouth(slime)

	if not (slime.Parent == workspace) then return end

	local slimeState = slime:GetAttribute("SlimeState")
	--print(slimeState, slime.Name)
	if not slimeState then
		wait()
		module.renewFace(slime)
		return
	end
	local slimeMouthNode = slime:FindFirstChild("mouthNode")
	if not slimeMouthNode then return end 
	local newMouth = mouths[slimeState]:Clone()
	for _, part in newMouth:GetDescendants() do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Slimes"
		end
	end
	newMouth.Parent = workspace
	local newMouthCentralPart = newMouth.PrimaryPart
	local WeldConstaint = Instance.new("WeldConstraint")
	WeldConstaint.Part0 = slimeMouthNode
	WeldConstaint.Part1 = newMouthCentralPart

	if slimeState == "scared" then
		--newMouth:SetPrimaryPartCFrame(slimeMouthNode.CFrame)
		local newCF = slimeMouthNode.CFrame * CFrame.Angles(0,0,math.rad(180))
		newMouth:SetPrimaryPartCFrame(newCF)
	end
	if slimeState == "normal" then
		newMouth:SetPrimaryPartCFrame(slimeMouthNode.CFrame)
	end
	if slimeState == "excited" then
		--newMouth:SetPrimaryPartCFrame(slimeMouthNode.CFrame)
		local newCF = slimeMouthNode.CFrame * CFrame.Angles(math.rad(90),0,0)
		newMouth:SetPrimaryPartCFrame(newCF)
	end
	if slimeState == "eating" then
		newMouth:SetPrimaryPartCFrame(slimeMouthNode.CFrame)
	end

	newMouth.Parent = slime
	WeldConstaint.Parent = slimeMouthNode
end


return module
