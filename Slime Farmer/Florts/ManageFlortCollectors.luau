

local CollectionService = game:GetService("CollectionService")
local CollectorModule = require(game.ServerStorage.FlortModules.FlortCollecterModule)


for _, collector in pairs(CollectionService:GetTagged("CollectorStation")) do
	CollectorModule.InitialiseCollector(collector)
end

CollectionService:GetInstanceAddedSignal("CollectorStation"):Connect(function(collector)
	CollectorModule.InitialiseCollector(collector)
	CollectorModule.UpdateBoardValues(collector)
end)

CollectorModule.CreateInitialFlortSellCounts()
CollectorModule.CreateInitialFlortPrices()


for _, collector in pairs(CollectionService:GetTagged("CollectorStation")) do
	CollectorModule.UpdateBoardValues(collector)
end

local newDayEvent = game.ServerStorage.ServerEvents.StatisticEvents.NewDayEvent
newDayEvent.Event:Connect(function()
	for _, collector in pairs(CollectionService:GetTagged("CollectorStation")) do
		CollectorModule.UpdatePrices()
		CollectorModule.UpdateBoardValues(collector)
	end
end)