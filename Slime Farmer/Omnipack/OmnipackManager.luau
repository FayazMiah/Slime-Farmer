
local players = game:GetService("Players")
local OmniPackMethods = require(script.Parent.OmnipackMethods)

players.PlayerAdded:Connect(function(player)
	OmniPackMethods.CreateNewOmnipack(player)
end)