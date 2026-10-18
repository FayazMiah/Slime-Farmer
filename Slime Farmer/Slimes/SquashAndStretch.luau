

local stretchEvent = game.ReplicatedStorage:WaitForChild("SlimeEvents"):WaitForChild("SlimeStretch")
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local simulationDistance = game.ReplicatedStorage.GameValuesReplica.SimulationDistance
local animatingSlimes = game.ReplicatedStorage.GameValuesReplica.AnimatingSlimes

local TweenService = game:GetService("TweenService")

function StretchSlime(slime)
	if not slime or not slime.PrimaryPart then return end
	if not animatingSlimes.Value then return end
	if (slime.PrimaryPart.Position - char.HumanoidRootPart.Position).Magnitude > simulationDistance.Value then return end

	if not slime or not slime:IsA("Model") or slime:GetAttribute("Stretching") then return end
	
	local finalTween = nil
	slime:SetAttribute("Stretching", true)
	
	for _, part in ipairs(slime:GetDescendants()) do
		if part:IsA("BasePart") then
			
			if part.Name == "Eye" or string.sub(part.Parent.Name, -5) == "Mouth" then
				local originalSize = part.Size
				local stretchedSize = Vector3.new(originalSize.X * 1.5, originalSize.Y * 1.2, originalSize.Z * 1.5)
				local squishTween = TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true), {Size = stretchedSize})
				squishTween:Play()
				finalTween = squishTween
			else
				local originalSize = part.Size
				local stretchedSize = Vector3.new(originalSize.X * 1.1, originalSize.Y * 0.8, originalSize.Z * 1.1)
				local squishTween = TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true), {Size = stretchedSize})
				squishTween:Play()
				finalTween = squishTween
			end
		end
		
	end
	
	finalTween.Completed:Wait()
	slime:SetAttribute("Stretching", false)
	
end

stretchEvent.OnClientEvent:Connect(function(slime)
	StretchSlime(slime)
end)
