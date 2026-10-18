
local rs = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

game.Players.PlayerAdded:Connect(function(player)	
	player.Chatted:Connect(function(text)	
		if string.sub(text, 1, 1) == "/" then
			if string.sub(text, 1, 12) == "/lowgraphics" then				
				rs.Misc.playerCommand:FireClient(player, "lowgraphics")
			end		
		end		
	end)	
end)