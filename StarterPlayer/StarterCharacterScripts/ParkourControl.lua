local RStorage = game:GetService("ReplicatedStorage")
local ParkourInfo = require(RStorage.ParkourModule)

local RenderStepped = game:GetService("RunService").RenderStepped
local SoundService = game:GetService("SoundService")
local Character = script.Parent
local RootPart,Humanoid = Character.HumanoidRootPart,Character.Humanoid

local vaultAnimation = Humanoid:LoadAnimation(workspace.VaultAnim)
local vaultAnimation1 = Humanoid:LoadAnimation(workspace.VaultAnim1)
local fallAnimation = Humanoid:LoadAnimation(workspace.FallAnim)
local rollAnim = Humanoid:LoadAnimation(workspace.RollAnimation)
local slideAnim = Humanoid:LoadAnimation(workspace.SlideAnim)



vaultAnimation.Priority = Enum.AnimationPriority.Action; rollAnim.Priority = Enum.AnimationPriority.Action ; slideAnim.Priority = Enum.AnimationPriority.Action ; fallAnimation.Priority = Enum.AnimationPriority.Action


vaultAnimation.Looped = false

local Sliding = false
local canJump = true


local lastVault = workspace.Baseplate -- probably should move to the module

math.randomseed(tick())

function fakeJump() -- function is used to automatically vault over objects that have been designated as "vaultable"
	local animC = math.random(1,2)
	local chosenAnim = nil
	if(animC == 1) then
		chosenAnim = vaultAnimation -- cheap way of changing up animations so its not as stagnant
	else chosenAnim = vaultAnimation1 end
	if(canJump) then
		canJump = false
		local BodyVelocity = Instance.new("BodyVelocity", RootPart)
		BodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		BodyVelocity.Velocity = RootPart.CFrame.LookVector * 20 + Vector3.new(0,25,0) -- "jump"
		chosenAnim:Play()
		SoundService.Vault.Pitch = math.random(7,10)*.1
		SoundService.Vault:Play() ; wait(0.2)
		BodyVelocity:Destroy()
		vaultAnimation:Stop()
	end
end

local DB = 0
while RenderStepped:wait() do -- there is admittedly a lot done in this loop, and admittedly there probably shouldn't be so much
	local RayC = Ray.new(RootPart.Position, RootPart.CFrame.LookVector*5 + RootPart.CFrame.UpVector * -5) -- used to time when the player should auto-vault
	local ClimbPart = workspace:FindPartOnRay(RayC, Character)
	if(ClimbPart and canJump) then
		if(ClimbPart:FindFirstChild("Vaultable") and ClimbPart.Size.Y < 5.8) then
			fakeJump()
			lastVault = ClimbPart
		end
	else 
		if(Humanoid.FloorMaterial == Enum.Material.Pavement and DB == 0) then
			local slopeRay = Ray.new(RootPart.Position + Vector3.new(0,0,0), Vector3.new(0, -1, 0)*100) -- ray aimed down from the player to detect if theyre on a slope
			local part,position,normal = workspace:FindPartOnRayWithIgnoreList(slopeRay, Character:GetChildren())
			local slideAngle = ParkourInfo.CalculateSlideVelocity(normal)
			print(ParkourInfo.CalculateSlideVelocity(normal))
			if(slideAngle ~= Vector3.new(0,0,0)) then
				local p = Instance.new("Part", workspace)
				p.CanCollide = false ; p.Anchored = true
				p.Transparency = 0.5 ; p.Position = position ; p.Size = Vector3.new(5.462, 0.05, 4.73)
				p.CFrame = CFrame.new(p.Position, position + normal)
				wait(1)
			end
			
		else if(Humanoid.FloorMaterial == Enum.Material.Grass and canJump == false) then
				rollAnim:Play()
				DB = 0
				canJump = true ; slideAnim:Stop()
				Sliding = false ; SoundService.Wind:Stop()
				ParkourInfo.ResetVelocity(Character)
		else if (not ParkourInfo.LastPart:FindFirstChild("Slide"))then 
				if(not ParkourInfo.LastPart:FindFirstChild("Vaultable")) then
					canJump = true
					if(ParkourInfo.LastPart.Position.Y > lastVault.Position.Y) then
						rollAnim:Play()
					end
				end
			else if (ParkourInfo.LastPart:FindFirstChild("Slide") and canJump == false) then
					rollAnim:Play() ; canJump = true
				end
			end
		end
		end
		end
	
	local distanceFromHookshot = (RootPart.Position - workspace["Hollow Circle / Ring"].Position).magnitude
	if (distanceFromHookshot < 220) then -- if player is in range to hookshot, it shines green!
		workspace["Hollow Circle / Ring"].BrickColor = BrickColor.new("Bright green")
	else 
		workspace["Hollow Circle / Ring"].BrickColor = BrickColor.new("Really red")
	end
	
	local slopeRay = Ray.new(RootPart.Position + Vector3.new(0,0,0), Vector3.new(0, -3, 0)) -- ray aimed down from the player to detect if theyre on a slope
	local part,position,normal = workspace:FindPartOnRayWithIgnoreList(slopeRay, Character:GetChildren())
	
	if(part) then
		if(part:FindFirstChild("Slide")) then -- if player is on a designated slope, then pass the rays "normal" to calculateslidevelocity
			print(ParkourInfo.CalculateSlideVelocity(normal))
		end
	end
	
	if(ParkourInfo.LastPart) then
		if(ParkourInfo.LastPart:FindFirstChild("Slide")) then
			slideAnim.Looped = true  ;  slideAnim:Play()
			Sliding = true ; SoundService.Wind:Play()
			canJump = false
			ParkourInfo.AddVelocity(Character, ParkourInfo.CalculateSlideVelocity(normal)) -- applying the velocity
		else 
			SoundService.Wind:Stop() ; Sliding = false ; slideAnim:Stop() ; ParkourInfo.Sliding = false
		end
	end
	
	if(not ParkourInfo.LastPart:FindFirstChild("Slide")) then
		ParkourInfo.ResetVelocity(Character)
	end
	
	 if (Humanoid.FloorMaterial == Enum.Material.Air)  then
		SoundService.Wind:Play()
		fallAnimation:Play()
	else 
		fallAnimation:Stop()
	end
end



	
		



