
local GameValues = game.ServerStorage.GameValues
local GameValuesModule = require(GameValues.GameValuesModule)
local RS = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local maxStamina = game.ServerStorage.GameValues.MaxStamina

for _, player in pairs(players:GetPlayers()) do
	player:SetAttribute("Stamina", maxStamina.Value)
end

players.PlayerAdded:Connect(function(Player)
	Player:SetAttribute("Stamina", maxStamina.Value)
end)


local function setter(value, rsReplica)
	if value:IsA("ValueBase") then
		rsReplica.Value = value.Value
	elseif value:IsA("Configuration") then
		local parent = rsReplica.Parent
		rsReplica:Destroy()
		value:Clone().Parent = parent
	end

	local statName = value.Name
	if statName == "MaxStamina" then
		for _, player in pairs(players:GetPlayers()) do
			player:SetAttribute("Stamina", value.Value)
		end
	end
	if statName == "OmnipackCapacity" then
		for _, player in pairs(players:GetPlayers()) do
			player.Omnipack:SetAttribute("Capacity", value.Value)
		end
	end
	if statName == "AeroVacPower" and value:IsA("ValueBase") then
		for _, player in pairs(players:GetPlayers()) do
			local AeroVac = player.Backpack:FindFirstChild("AeroVac")
			if not AeroVac then
				local char = player.Character or player.CharacterAdded:Wait()
				AeroVac = char:FindFirstChild("AeroVac")
			end
			if not AeroVac then return end
			AeroVac:SetAttribute("EjectPower", value.Value)
		end
	end
end

local function onChange(value)
	if value:IsA("ValueBase") then
		value.Changed:Connect(function()
			setter(value, RS.GameValuesReplica:FindFirstChild(value.Name))
		end)
	elseif value:IsA("Configuration") then
		value.AttributeChanged:Connect(function()
			setter(value, RS.GameValuesReplica:FindFirstChild(value.Parent.Name):FindFirstChild(value.Name))
		end)
	end
end


for _, value in pairs(GameValues:GetChildren()) do
	
	if value:IsA("Folder") then
		local folderclone = Instance.new("Folder")
		folderclone.Name = value.Name
		folderclone.Parent = RS.GameValuesReplica

		for _, v in pairs(value:GetChildren()) do
			local valueClone = v:Clone()
			valueClone.Parent = folderclone
			onChange(v, valueClone)
		end
		
		
	elseif value:IsA("ValueBase") or value:IsA("Configuration") then
		local valueClone = value:Clone()
		valueClone.Parent = RS.GameValuesReplica
		onChange(value, valueClone)
	end
end
