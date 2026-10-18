
local RS = game:GetService("ReplicatedStorage")

RS.MiscEvents.HeadMovementEvent.OnServerEvent:Connect(function(player, Neck, Waist, Point, Head, NeckOriginC0, WaistOriginC0, HeadPosition, TorsoLookVector)
	local Distance = (Head.CFrame.p - Point).magnitude
	local Difference = Head.CFrame.Y - Point.Y
	Neck.C0 = Neck.C0:lerp(NeckOriginC0 * CFrame.Angles(-(math.atan(Difference / Distance) * 0.5), (((HeadPosition - Point).Unit):Cross(TorsoLookVector)).Y * 1, 0), 0.5 / 2)
	Waist.C0 = Waist.C0:lerp(WaistOriginC0 * CFrame.Angles(-(math.atan(Difference / Distance) * 0.5), (((HeadPosition - Point).Unit):Cross(TorsoLookVector)).Y * 0.5, 0), 0.5 / 2)
end)
