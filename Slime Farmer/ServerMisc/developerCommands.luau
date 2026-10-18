
local function verifyUser(user)	
	local verifiedUsers = {
		"DianiteShadow",
		"Player1",
		"Player2",
		"ekrm1"
	}	
	for _, value in pairs(verifiedUsers) do
		if value == user then
			return true
		end
	end
	return false	
end

local function tpCommand(text, player)
	
	local samples = string.split(text, " ")
	
	if samples[2] == "me" or samples[2] == "self" then
		samples[2] = player.Name
	end
	if samples[3] == "me" or samples[3] == "self" then
		samples[3] = player.Name
	end
	
	if not (#samples == 3) then
		return
	end

	if game.Players:FindFirstChild(samples[2]) and game.Players:FindFirstChild(samples[3]) then
		game.Players[samples[2]].Character:MoveTo(game.Players[samples[3]].Character:FindFirstChild("HumanoidRootPart").Position)
		return
	end

	if string.sub(samples[3],1,1) == "(" and string.sub(samples[3],-1,-1) == ")" and game.Players:FindFirstChild(samples[2]) then
		local vectorValues = string.sub(samples[3], 2, -2)   
		vectorValues = string.split(vectorValues, ",")     
		local vector = Vector3.new(vectorValues[1], vectorValues[2], vectorValues[3])
		game.Players:FindFirstChild(samples[2]).Character:MoveTo(vector)
	end
	
	game.ReplicatedStorage.Misc.alertEvent:FireClient(player, "Teleported " .. samples[2] .. " to " .. samples[3], 2)
	
end

local function speedCommand(text, player)
	
	local samples = string.split(text, " ")
	local value = nil
	
	if not (#samples == 3) then
		return
	end

	
	if samples[2] == "me" or samples[2] == "self" then
		samples[2] = player.Name
	elseif samples[3] == "me" or samples[3] == "self" then
		samples[3] = player.Name
	end
	
	if samples[3] == "reset" or samples[3] == "clear" then
		game.Players:FindFirstChild(samples[2]).Character:FindFirstChild("Humanoid").WalkSpeed = 16
		game.ReplicatedStorage.Misc.alertEvent:FireClient(player, samples[2] ..  " Speed reset", 2)
		return
	end	
	
	local success, responce = pcall(function()	
		value = tonumber(samples[3])	
	end)
	
	if not value or not success then
		return
	end
	
	if game.Players:FindFirstChild(samples[2]) then
		game.Players:FindFirstChild(samples[2]).Character:FindFirstChild("Humanoid").WalkSpeed = value
		game.ReplicatedStorage.Misc.alertEvent:FireClient(player, samples[2] .. " Speed set to : " .. tostring(value), 2)
		return
	end
	
end

local function killCommand(text, player)
	
	local samples = string.split(text, " ")
	
	if not (#samples == 2) then
		return
	end
	
	if samples[2] == "me" or samples[2] == "self" then
		samples[2] = player.Name
	end
		
	if not game.Players:FindFirstChild(samples[2]) then
		return
	end
		
	local targetPlayer = game.Players:FindFirstChild(samples[2])
	
	targetPlayer.Character:FindFirstChild("Humanoid").Health = 0
	
	game.ReplicatedStorage.Misc.alertEvent:FireClient(player, "Killed Player: " .. targetPlayer.Name, 2)
	
end

local function summonCommand(text, player) -- /summon (player) (item) (quantity)
	
	local samples = string.split(text, " ")

	if not (#samples == 4) then
		return
	end
	if samples[2] == "me" or samples[2] == "self" then
		samples[2] = player.Name
	end
	
	if tonumber(samples[4]) > 100 then
		return
	end
	
	local item = game.ServerStorage.GameItems:FindFirstChild(samples[3])
	if not item then return end
	local pos = player.Character.PrimaryPart.Position + Vector3.new(0,10,0)
	for i = 1,tonumber(samples[4]),1 do
		local itemClone = item:Clone()
		itemClone.PrimaryPart.Position = pos
		itemClone.Parent = workspace
		wait(0.1)
	end
	
--	game.ReplicatedStorage.Misc.alertEvent:FireClient(player, "Summoned: " .. samples[4] .. " " .. samples[3], 2)
	
end

local function giveCommand(text, player) -- /summon (player) (item) (quantity)

	local samples = string.split(text, " ")

	if not (#samples == 3) then
		return
	end
	
	if samples[2] == "SlimeBucks" then
		game.ServerStorage.ServerValues.slotSlimeBucks.Value += tonumber(samples[3])
	elseif samples[2] == "EXP" then
		game.ServerStorage.ServerValues.slotExp.Value += tonumber(samples[3])
	elseif samples[2] == "SlimeKeys" then
		game.ServerStorage.ServerValues.slotSlimeKeys.Value += tonumber(samples[3])
	end


	

	--game.ReplicatedStorage.Misc.alertEvent:FireClient(player, "Given: " .. samples[3] .. " " .. samples[2], 2)

end
	


game.Players.PlayerAdded:Connect(function(player)	
	player.Chatted:Connect(function(text)	
		if string.sub(text, 1, 1) == "/" and verifyUser(player.Name) then
			if string.sub(text, 1, 3) == "/tp" then				
				tpCommand(text, player)
			elseif string.sub(text, 1, 6) == "/speed" then
				speedCommand(text, player)
			elseif string.sub(text, 1, 5) == "/kill" then
				killCommand(text, player)
			elseif string.sub(text, 1, 7) == "/summon" then
				summonCommand(text, player)
			elseif string.sub(text, 1, 5) == "/give" then
				giveCommand(text, player)
			end
		end		
	end)	
end)