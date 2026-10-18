local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local newDayEvent = game.ServerStorage.ServerEvents.StatisticEvents.NewDayEvent

local lastTime = Lighting.ClockTime
local newDayThreshold = 6

Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
	local currentTime = Lighting.ClockTime
	if lastTime > newDayThreshold and currentTime <= newDayThreshold then
		newDayEvent:Fire()
		game.ReplicatedStorage.Sounds.NewDay:Play()
		game.ServerStorage.GameValues.Day.Value = game.ServerStorage.GameValues.Day.Value + 1
	end
	lastTime = currentTime
end)



local dayLength = 12 -- time for a full day night cycle (in minutes)
local cycleLength = 24 -- number of hours (dont change)
local increment = cycleLength / (dayLength * 10)

local tweenInfo = TweenInfo.new(
	6,
	Enum.EasingStyle.Linear, 
	Enum.EasingDirection.InOut,
	0, 
	false, 
	0
)


local function tweenClockTime(targetTime)
	local currentTime = Lighting.ClockTime
	local timeDifference = targetTime - currentTime
	if timeDifference < 0 then
		timeDifference = timeDifference + 24
	end
	local timeTween = TweenService:Create(
		Lighting,
		tweenInfo,
		{ ClockTime = targetTime }
	)
	timeTween:Play()
	timeTween.Completed:Wait() 
end


while true do
	tweenClockTime((Lighting.ClockTime + increment) % 24)
end