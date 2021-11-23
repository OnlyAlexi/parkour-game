local TweenSerivce = game:GetService("TweenService")

local ParkourModule = {}

ParkourModule.FOVTweenInfo = TweenInfo.new(1.5)

ParkourModule.LastPart = workspace.SpawnLocation -- really just used to communicate between scripts what the player should be doing (sliding, rolling)
ParkourModule.DefaultFOV = 80
ParkourModule.SlideSprintFOV = 110

ParkourModule.FOVTween = TweenSerivce:Create(workspace.CurrentCamera, ParkourModule.FOVTweenInfo, {FieldOfView = ParkourModule.SlideSprintFOV})
ParkourModule.FOVTween2 = TweenSerivce:Create(workspace.CurrentCamera, ParkourModule.FOVTweenInfo, {FieldOfView = ParkourModule.DefaultFOV})

ParkourModule.Sliding = false


function ParkourModule.SprintTween() -- for easy use in other scripts, effect is used multiple times
	ParkourModule.FOVTween:Play()
end

function ParkourModule.UnTween() 
	ParkourModule.FOVTween2:Play()
end

function ParkourModule.CalculateSlideVelocity(Normal)  -- calculates the velocity in which a player should slide down a slope
	local X,Y,Z = Normal.X,Normal.Y,Normal.Z
	local normHLength = math.sqrt(X^2+Z^2) -- calculate horizontal length of normal returned by raycast
	if(normHLength < 1e-5) then -- all hell breaks loose if we dont check for this
		return Vector3.new(0,0,0)
	end
	local XDirection = X/normHLength*Y
	local ZDirection = Z/normHLength*Y
	local YDirection = -normHLength
	local TotalDirection = Vector3.new(XDirection, YDirection, ZDirection)
	local TotalAngle = math.atan2(YDirection, Y)
	return TotalDirection*(math.sin(-TotalAngle)*80)
end



function ParkourModule.AddVelocity(Player,Vel) -- used to apply the force given by the previous function, among other things
	--print(Vel)
	if(Vel.Z ~= 0 and Vel.X ~= 0) then
		Player.Humanoid.WalkSpeed = 0
		ParkourModule.FOVTween:Play()
		local Velocity = Instance.new("BodyVelocity", Player.HumanoidRootPart)
		Velocity.MaxForce = Vector3.new(1e9,1e9,1e9)
		local RootPart = Player.HumanoidRootPart
		local FixedLookVector = Vector3.new(RootPart.CFrame.LookVector.x, -0.4, RootPart.CFrame.LookVector.z)
		Velocity.Velocity = FixedLookVector * 15 + Vel
	end
end


function ParkourModule.ResetVelocity(Character) -- just to kill the players velocity, changed their FOV back to normal
	if(Character.HumanoidRootPart:FindFirstChild("BodyVelocity")) then
		Character.Humanoid.WalkSpeed = 16
		ParkourModule.FOVTween2:Play()
		Character.HumanoidRootPart:FindFirstChild("BodyVelocity"):Destroy()
	end
end



return ParkourModule
