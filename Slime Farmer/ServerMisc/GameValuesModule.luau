local module = {}
local GameValues = game.ServerStorage.GameValues
local expValue = GameValues.Exp
local slotLevelValue = GameValues.Level

local RS = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local maxStamina = game.ServerStorage.GameValues.MaxStamina

local function calculateXPRequirement(level)
	local requirementIncreaseRate = 20  -- adjust multiplier as needed (how quick requirement increases)
	local experienceGrowthRate = 1.05 -- exponent for experience growth (usually between 1.5 to 2) controls the growth rate
	return math.floor(requirementIncreaseRate * math.pow(level, experienceGrowthRate))
end

function module.UpdateExpAndLevel()
	local currentEXP = expValue.Value
	local slotLevel = slotLevelValue.Value
	local expRequired = calculateXPRequirement(slotLevel + 1)
	while currentEXP >= expRequired do
		wait()
		--print(currentEXP, expRequired)
		currentEXP -= expRequired
		slotLevel += 1
		expRequired = calculateXPRequirement(slotLevel + 1)
	end
	expValue.Value = currentEXP
	slotLevelValue.Value = slotLevel

end

function module.AlterValue(statName, adjustment)
	if not GameValues:FindFirstChild(statName) then return end
	GameValues:FindFirstChild(statName).Value = GameValues:FindFirstChild(statName).Value + adjustment

	if statName == "Exp" then
		module.UpdateExpAndLevel()
	end
	if statName == "SlimeBucks" then
		RS.StatsEvents.NewMoneyEvent:FireAllClients(adjustment)
	end
end


return module
