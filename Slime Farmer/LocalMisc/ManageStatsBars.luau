
local RS = game:GetService("ReplicatedStorage")

local expValue = RS.GameValuesReplica:WaitForChild("Exp")
local levelValue = RS.GameValuesReplica:WaitForChild("Level")
local slimeBucksValue = RS.GameValuesReplica:WaitForChild("SlimeBucks")
local slimekeysValue = RS.GameValuesReplica:WaitForChild("Slimekeys")
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local playerIndicatorsFrame = script.Parent.ContainerFrame.PlayerIndicators
local levelText = playerIndicatorsFrame.LevelIcon.LevelNumber
local expText = playerIndicatorsFrame.LevelBar.LevelState
local slimeBucksText = script.Parent.ContainerFrame.MoneyIndicator.MoneyAmount
local slimeKeysText = script.Parent.ContainerFrame.SlimeKeyIndicator.SlimeKeyAmount

local HealthBar = playerIndicatorsFrame.HealthBar.Status_Indicator
local StaminaBar = playerIndicatorsFrame.StaminaBar.Status_Indicator
local LevelBar = playerIndicatorsFrame.LevelBar.Status_Indicator

local GUIModule = require(RS.GUIScripts.GUIModule)

local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(
	0.5, 
	Enum.EasingStyle.Quad, 
	Enum.EasingDirection.Out
)

local function calculateXPRequirement(level)
	local requirementIncreaseRate = 20  -- adjust multiplier as needed (how quick requirement increases)
	local experienceGrowthRate = 1.05 -- exponent for experience growth (usually between 1.5 to 2) controls the growth rate
	return math.floor(requirementIncreaseRate * math.pow(level, experienceGrowthRate))
end

local dateTime = script.Parent.ContainerFrame.DateTimeIndicator.activateButton.TimeIndicator


----------=-=-----==-=--------==------=----------==---=--
--initialisations to make ui nice reset=oading

expText.Text = tostring(expValue.Value) .. "/" .. tostring(calculateXPRequirement(levelValue.Value + 1))
levelText.Text = tostring(levelValue.Value)
script.Parent.ContainerFrame.MoneyIndicator.MoneyAmount.Text = tostring(slimeBucksValue.Value)
slimeKeysText.Text = tostring(slimekeysValue.Value)

local maxHealth = humanoid.MaxHealth
local ratio = humanoid.Health / humanoid.MaxHealth
ratio *= 2 
HealthBar.Size = UDim2.new(ratio, 0, 1, 0)

local currentEXP = expValue.Value
local expRequired = calculateXPRequirement(levelValue.Value + 1)
expText.Text = tostring(currentEXP) .. "/" .. tostring(expRequired)
local ratio = currentEXP / expRequired
ratio *= 2
LevelBar.Size = UDim2.new(ratio, 0, 1, 0)

dateTime.Text = string.sub(game.Lighting.TimeOfDay, 1, 5)

---=------=-=------=----=----------=------------==

levelValue.Changed:Connect(function()
	levelText.Text = tostring(levelValue.Value)
	GUIModule.CreateAlert(player, "Level " .. tostring(levelValue.Value) .. " Reached", 2)
end)

expValue.Changed:Connect(function()
	local currentEXP = expValue.Value
	local expRequired = calculateXPRequirement(levelValue.Value + 1)
	expText.Text = tostring(currentEXP) .. "/" .. tostring(expRequired)
	local ratio = currentEXP / expRequired
	ratio *= 2
	local targetSize = UDim2.new(ratio, 0, 1, 0)
	local tween = TweenService:Create(LevelBar, tweenInfo, { Size = targetSize })
	tween:Play()
end)

slimeBucksValue.Changed:Connect(function()
	slimeBucksText.Text = tostring(slimeBucksValue.Value)
end)

slimekeysValue.Changed:Connect(function()
	slimeKeysText.Text = tostring(slimekeysValue.Value)
	GUIModule.NewSlimeKeyAlert(player)
end)

RS.StatsEvents.NewMoneyEvent.OnClientEvent:Connect(function(quantityChange)
	GUIModule.NewMoneyAlert(player, tostring(quantityChange))
end)

humanoid.HealthChanged:Connect(function(health)
	local maxHealth = humanoid.MaxHealth
	local ratio = health / maxHealth
	ratio *= 2 
	local targetSize = UDim2.new(ratio, 0, 1, 0)
	local tween = TweenService:Create(HealthBar, tweenInfo, { Size = targetSize })
	tween:Play()
end)

local maxStam = RS.GameValuesReplica:WaitForChild("MaxStamina")

player:GetAttributeChangedSignal("Stamina"):Connect(function()
	local stamina = player:GetAttribute("Stamina")
	if stamina then
		local ratio = stamina / maxStam.Value
		ratio *= 2 

		local targetSize = UDim2.new(ratio, 0, 1, 0)
		local tween = TweenService:Create(StaminaBar, tweenInfo, { Size = targetSize })
		tween:Play()
	end
end)

game.Lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
	dateTime.Text = string.sub(game.Lighting.TimeOfDay, 1, 5)
end)

script.Parent.ContainerFrame.DateTimeIndicator.activateButton.Activated:Connect(function()
	GUIModule.OpenGUI(player.PlayerGui.InGameMenu)
end)