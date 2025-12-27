local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera
print("[CharacterController] Movement controller initialized")
RunService.Heartbeat:Connect(function()
	local moveVector = Vector3.zero
		local _isMovingBackward = false
	
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		moveVector = moveVector + Vector3.new(0, 0, -1)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		moveVector = moveVector + Vector3.new(0, 0, 1)
		_isMovingBackward = true
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		moveVector = moveVector + Vector3.new(-1, 0, 0)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		moveVector = moveVector + Vector3.new(1, 0, 0)
	end
	
	local cameraCFrame = camera.CFrame
	local cameraLookVector = cameraCFrame.LookVector
	local flatCameraLook = Vector3.new(cameraLookVector.X, 0, cameraLookVector.Z).Unit
	
	humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + flatCameraLook)
	
	if moveVector.Magnitude > 0 then
		moveVector = moveVector.Unit
		
		local cameraRightVector = cameraCFrame.RightVector
		local flatRightVector = Vector3.new(cameraRightVector.X, 0, cameraRightVector.Z).Unit
		
		local worldMoveDirection = (flatCameraLook * -moveVector.Z) + (flatRightVector * moveVector.X)
		
		humanoid:Move(worldMoveDirection, false)
	end
end)
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	print("[CharacterController] Character respawned, controller reattached")
end)

