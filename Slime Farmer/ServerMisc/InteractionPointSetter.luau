
local CS = game:GetService("CollectionService")
local PromptGUI = game.ReplicatedStorage.GUIScripts.PromptGUI
local event = game.ReplicatedStorage.ActionEvents.InteractionPointEvent
local GUIModule = require(game.ReplicatedStorage.GUIScripts.GUIModule)


local function applyGUI(interactionPoint)
	local promptGUIClone = PromptGUI:Clone()
	promptGUIClone.Parent = game.StarterGui.PromptGUIs
	promptGUIClone.Adornee = interactionPoint.PrimaryPart
	
	local proximityPrompt = interactionPoint.PrimaryPart:FindFirstChild("ProximityPrompt")
	
	proximityPrompt.Triggered:Connect(function(player)
		event:FireClient(player, proximityPrompt.PromptType)
	end)
	
end

for _, interactionPoint in pairs(CS:GetTagged("InteractionPoint")) do
	applyGUI(interactionPoint)
end

CS:GetInstanceAddedSignal("InteractionPoint"):Connect(function(interactionPoint)
	applyGUI(interactionPoint)
end)


event.OnServerEvent:Connect(function(player, promptType)
	event:FireClient(player, promptType)
end)