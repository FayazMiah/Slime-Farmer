local module = {}

local CollectionService = game:GetService("CollectionService")

local alreadyFoundItems = {}
local RS = game:GetService("ReplicatedStorage")
local FlortSound = RS.Sounds.FlortNoise

local comboCount = 0
local lastPlayTime = 0
local comboResetTime = 1

local GameValuesModule = require(game.ServerStorage.GameValues.GameValuesModule)

local flortSoldQuantity = game.ServerStorage.GameValues.FlortValues.FlortSoldCount
local flortPrices = game.ServerStorage.GameValues.FlortValues.FlortPrices

local FlortPrices = game.ServerStorage.GameValues.FlortValues.FlortPrices
local PreviousFlortPrices = game.ServerStorage.GameValues.FlortValues.PreviousDayFlortPrices

local FlortSoldCount = game.ServerStorage.GameValues.FlortValues.FlortSoldCount

local flortRangeTable = game.ServerStorage.GameValues.FlortValues.FlortPriceRanges:GetAttributes()
local florts = game.ServerStorage.GameValues.FlortValues.FlortNames:GetAttributes()

local ranges = game.ServerStorage.GameValues.FlortValues.FlortPriceRanges

local newsAffectedFlort = game.ServerStorage.GameValues.FlortValues.NewsAffectedFlort

local newsOptions = {
	{"Peachy_Flort", "The local fruit trees stop producing due to an unexpected drought, these fruits were the Peachy slimes favourite. Peachy flort prices increased."},
	{"Bubble_Flort", "A powerful storm disrupts the ecosystem, Bubble slimes hide due to their vulnerability to wind. Bubble flort prices increased."},
	{"Rocky_Flort", "A massive rockslide occurs in the cliff region, making it dangerous to access the Rocky slimes habitat. Rock flort prices increased."},
	{"Frost_Flort","A famous jeweler discovers that Frost florts can be turned into valuable gems, triggering a jewelry market boom. Frost flort prices increased."},
	{"Volt_Flort", "A large yellow mouse with a lightning bolt-shaped tail fought the Volt slimes. Its attacks were ineffective against the electric type slime and it lost the battle. Volt flort prices increased."},
	{"Willow_Flort", "A group of alchemists discover that Willow florts can be used as an ingredient in powerful healing potions. Willow flort prices increased."},
	{"Moss_Flort", "A mysterious fungal infection spreads in the swamp region, threatening  Moss slimes. Moss flort prices increased."},
	{"Fae_Flort", "A rare lunar eclipse causes Fae slimes to glow brighter than ever, attracting the attention of mystics and collectors. Fae flort prices increased."}
}

local newsChoices = {}
local currentNews = nil

function playPlortSound(part)
	local currentTime = tick()

	if currentTime - lastPlayTime <= comboResetTime then
		comboCount = math.clamp(comboCount + 1, 0.7, 5)
	else
		comboCount = 1 
	end

	lastPlayTime = currentTime

	spawn(function()
		local sound = FlortSound:Clone()
		sound.Parent = part
		sound.PlaybackSpeed = 1 + (comboCount * 0.1) -- Increase speed per combo
		sound:Play()
		wait(1)
		sound:Destroy()
	end)
end

function module.SellFlort(flort)
	if flort:GetAttribute("Sold", true) then
		return
	end
	local flortPrice = flortPrices:GetAttribute(flort.Name:gsub(" ", ""))
	spawn(function()
		flort:SetAttribute("Sold", true)
		wait(0.2)
		flort:Destroy()
	end)
	GameValuesModule.AlterValue("SlimeBucks", flortPrice)
	local currentSoldCount = flortSoldQuantity:GetAttribute(flort.Name:gsub(" ", ""))
	flortSoldQuantity:SetAttribute(flort.Name:gsub(" ", ""), currentSoldCount + 1)
end

function module.CalculatePriceIncrease(flort)

	local currentPrice = FlortPrices:GetAttribute(flort)
	local range = ranges:GetAttribute(flort)
	local upperBoundary = range.Y
	local lowerBoundary = range.X
	local rangeSpan = upperBoundary - lowerBoundary

	local randomPercent = math.random(40, 70) / 100

	local coefficient = rangeSpan / (upperBoundary + lowerBoundary)

	local increase = currentPrice * randomPercent * coefficient
	local newPrice = math.min(currentPrice + increase, upperBoundary)

	return newPrice, increase
end


local function resetChoices()
	table.clear(newsChoices)
	for _, option in pairs(newsOptions) do
		table.insert(newsChoices, option)
	end
end

function module.UpdateNews(FlortNews, PriceChange, Percentage, indicatorUp, indicatorDown, currentPrice, effectedFlort)
	if currentNews then
		table.remove(newsChoices, table.find(newsChoices, currentNews))
	end
	if #newsChoices <= 0 then
		resetChoices()
	end
	local newsChoice = newsChoices[math.random(1, #newsChoices)]
	currentNews = newsChoice
	return currentNews
end

function module.UpdateNewsBoard(board, news, increase)
	local FlortNews = board.GUIPart.SurfaceGui.Frame.MainFrame.FlortNews
	--local PriceChange = board.GUIPart.SurfaceGui.Frame.PriceLabels.PriceChange
	--local Percentage = board.GUIPart.SurfaceGui.Frame.PriceLabels.Percentage
	--local indicatorUp = board.GUIPart.SurfaceGui.Frame.PriceLabels.IndicatorUp
	--local indicatorDown = board.GUIPart.SurfaceGui.Frame.PriceLabels.IndicatorDown
	local currentPrice = board.GUIPart.SurfaceGui.Frame.PriceLabels.CurrentPrice
	local effectedFlort = board.GUIPart.SurfaceGui.Frame.PriceLabels.EffectedFlort
	local flort = newsAffectedFlort:GetAttribute("CurrentFlort")

	local currentPriceVal = math.round(FlortPrices:GetAttribute(flort:gsub("_", "")))

	FlortNews.Text = news
	effectedFlort.Image = game.ReplicatedStorage.ItemInformation.ItemImageIDs:GetAttribute(flort)
	currentPrice.Text = tostring(currentPriceVal)
end


function module.InitialiseCollector(collector)
	local collectionRegionPart = collector.collectionRegion
	collectionRegionPart.Touched:Connect(function(collidedPart) -- collidedPart.Parent is item
		
		if collidedPart.Parent and collidedPart.Parent:GetAttribute("Sold", true) then
			return
		end

		if table.find(CollectionService:GetTagged("Flort"), collidedPart.Parent) then 
			if collidedPart.Parent.PrimaryPart == collidedPart and not (table.find(alreadyFoundItems, collidedPart.Parent)) then -- only accept the primary part collision
				if (collidedPart.Position - collidedPart.Position).Magnitude <= 1 then -- boundary from the inside node

					module.SellFlort(collidedPart.Parent)
					table.insert(alreadyFoundItems, collidedPart.Parent)
					playPlortSound(collectionRegionPart)
					local index = table.find(alreadyFoundItems, collidedPart)
					table.remove(alreadyFoundItems, index)

				end
			end
		end
	end)
end


function module.UpdateBoardValues(collector)
	local FlortDisplays = collector.Parent.flortValues:GetChildren()
	for _, displayPart in pairs(FlortDisplays) do
		local flortName = displayPart.Name
		local flortValue = FlortPrices:GetAttribute(flortName)
		if flortValue then
			--print(flortName, flortValue .. "asdasdasdasdasd")
			local valueText = displayPart.SurfaceGui.FlortValue:Clone()
			valueText.Text = flortValue
			displayPart.SurfaceGui.FlortValue:Destroy()
			valueText.Parent = displayPart.SurfaceGui
			
			local PriceLabelsFrame = displayPart.SurfaceGui.PriceLabels
			local previousDayPrice = PreviousFlortPrices:GetAttribute(flortName)
		
			if previousDayPrice then
				local percentChange = ((flortValue - previousDayPrice) / previousDayPrice) * 100
				PriceLabelsFrame.Percentage.Text = "(" .. tostring(math.floor(percentChange)) .. "%)"
				if percentChange > 0 then
					PriceLabelsFrame.DownIndicator.Visible = false
					PriceLabelsFrame.UpIndicator.Visible = true
					PriceLabelsFrame.Percentage.TextColor3 = Color3.fromRGB(39, 255, 75)
				elseif percentChange < 0 then
					PriceLabelsFrame.DownIndicator.Visible = true
					PriceLabelsFrame.UpIndicator.Visible = false
					PriceLabelsFrame.Percentage.TextColor3 = Color3.fromRGB(255, 67, 70)
				else
					PriceLabelsFrame.DownIndicator.Visible = false
					PriceLabelsFrame.UpIndicator.Visible = false
					PriceLabelsFrame.Percentage.TextColor3 = Color3.fromRGB(98, 98, 98)
				end
			else
				PriceLabelsFrame.DownIndicator.Visible = false
				PriceLabelsFrame.UpIndicator.Visible = false
				PriceLabelsFrame.Percentage.TextColor3 = Color3.fromRGB(98, 98, 98)
				PriceLabelsFrame.Percentage.Text = "(0%)"
			end
		end
	end
	
	if game.ServerStorage.GameValues.FlortValues.CurrentNews:GetAttribute("News") then
		local news = game.ServerStorage.GameValues.FlortValues.CurrentNews:GetAttribute("News")
		for _, board in pairs(CollectionService:GetTagged("FlortNewsBoard")) do
			module.UpdateNewsBoard(board, news, game.ServerStorage.GameValues.FlortValues.NewsIncrease:GetAttribute("increase"))
		end
	end
	
end


function module.CreateInitialFlortSellCounts()
	for i, flort in pairs(florts) do
		FlortSoldCount:SetAttribute(flort, 0)
	end
end


function module.CreateInitialFlortPrices()
	for name, range in pairs(flortRangeTable) do
		local minPrice = range.X
		local maxPrice = range.Y
		--local fluctuationRange = maxPrice - minPrice
		--local t = os.time() / 1000 
		--local noise = perlinNoise(t, game.Lighting.ClockTime)
		--local normalizedNoise = (noise + 1) / 2
		local initialPrice = math.random(minPrice, maxPrice)--minPrice + normalizedNoise * fluctuationRange
		local price = math.clamp(math.ceil(initialPrice), minPrice, maxPrice)

		FlortPrices:SetAttribute(name, price)
	end
end

local function getPriceRange(flort)
	for _, range in flortRangeTable do
		if range[1] == flort then
			return {range[2], range[3]}
		end
	end
end


function module.UpdatePrices()
	local totalSales = 0
	local flortSales = {}
	
	local news = module.UpdateNews()
	local flort = news[1]:gsub("_", "")
	newsAffectedFlort:SetAttribute("CurrentFlort", news[1])
	game.ServerStorage.GameValues.FlortValues.CurrentNews:SetAttribute("News", news[2])
	
	local priceRange = game.ServerStorage.GameValues.FlortValues.FlortPriceRanges:GetAttribute(flort)
	local newPrice, increase = module.CalculatePriceIncrease(flort)
	
	local newPrice = math.round(math.clamp(newPrice, priceRange.X, priceRange.Y))
	--print(newPrice, FlortPrices:GetAttribute(flort), newPrice - increase)
	PreviousFlortPrices:SetAttribute(flort, FlortPrices:GetAttribute(flort))
	FlortPrices:SetAttribute(flort, newPrice)
	
	game.ServerStorage.GameValues.FlortValues.NewsIncrease:SetAttribute("increase", increase)

	for _, flort in pairs(florts) do
		local sellCount = FlortSoldCount:GetAttribute(flort) or 0
		flortSales[flort] = sellCount
		totalSales = totalSales + sellCount
	end

	for _, flort in pairs(florts) do
		if not (flort == newsAffectedFlort:GetAttribute("CurrentFlort"):gsub("_","")) then
			local sellCount = math.min(flortSales[flort], 100)
			local priceRange = game.ServerStorage.GameValues.FlortValues.FlortPriceRanges:GetAttribute(flort)
			local currentPrice = FlortPrices:GetAttribute(flort)
			local rangeSpan = priceRange.Y - priceRange.X
			
			local baseAdjustment = (-sellCount * 0.05) * rangeSpan

			if totalSales > 0 then
				local relativeImpact = flortSales[flort] / totalSales
				baseAdjustment = baseAdjustment * (1 + relativeImpact) 
			end

			local newPrice = math.clamp(math.round(currentPrice + baseAdjustment), priceRange.X, priceRange.Y)

			PreviousFlortPrices:SetAttribute(flort, currentPrice)
			FlortPrices:SetAttribute(flort, newPrice)
		end
	end

	module.CreateInitialFlortSellCounts()
	
end



return module
