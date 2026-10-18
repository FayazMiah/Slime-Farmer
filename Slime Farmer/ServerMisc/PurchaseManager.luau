
local RS = game:GetService("ReplicatedStorage")
local gameValues = game.ServerStorage.GameValues
local gamevalsmodule = require(gameValues.GameValuesModule)

RS.MiscEvents.PurchaseEvent.OnServerEvent:Connect(function(plr, productName, section)
	if section == "UpgradeStation" then
		local productInfo = gameValues.UpgradeInfo:FindFirstChild(productName)
		if productInfo:GetAttribute("Level") <= gameValues.Level.Value and productInfo:GetAttribute("Price") <= gameValues.SlimeBucks.Value and productInfo:GetAttribute("Advancement") < 10 then
			
			gamevalsmodule.AlterValue("SlimeBucks", productInfo:GetAttribute("Price") * -1)
			productInfo:SetAttribute("Advancement", productInfo:GetAttribute("Advancement") + 1)
			local newprice = math.floor(((productInfo:GetAttribute("Price") * 1.75)) / 500) * 500
			productInfo:SetAttribute("Price", newprice)
			productInfo:SetAttribute("Level", productInfo:GetAttribute("Level") + 5)
			
			if productName == "AeroVacPower" then
				gameValues.AeroVacPower.Value = 10 + (productInfo:GetAttribute("Advancement") * 2)
			end
			
		end
	end
end)