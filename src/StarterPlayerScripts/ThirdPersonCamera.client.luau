local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

camera.CameraType = Enum.CameraType.Scriptable
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

-- CONFIGURACIÓN DE ESTILO GARDEN WARFARE
local CAMERA_DISTANCE = 8      -- Qué tan lejos está la cámara
local CAMERA_HEIGHT = 2.5      -- Altura respecto al suelo
local CAMERA_OFFSET_RIGHT = 2.5 -- Desplazamiento a la derecha (esto pone al PJ a la izquierda)
local CAMERA_SENSITIVITY = 0.003

local cameraAngleX = 0
local cameraAngleY = 0

print("[ThirdPersonCamera] Modo PvZ Activado")

-- Manejo de ratón
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Delta
		cameraAngleX = cameraAngleX - delta.X * CAMERA_SENSITIVITY
		-- Limitamos el ángulo vertical para que no de la vuelta completa
		cameraAngleY = math.clamp(cameraAngleY - delta.Y * CAMERA_SENSITIVITY, -math.rad(75), math.rad(75))
	end
end)

RunService.RenderStepped:Connect(function()
	if character and humanoidRootPart then
		local rootPosition = humanoidRootPart.Position
		
		-- 1. Creamos la rotación basada en los ángulos del mouse
		local startRotation = CFrame.Angles(0, cameraAngleX, 0) * CFrame.Angles(cameraAngleY, 0, 0)
		
		-- 2. Definimos el desplazamiento relativo (X = Derecha, Y = Arriba, Z = Atrás)
		local relativeOffset = Vector3.new(CAMERA_OFFSET_RIGHT, CAMERA_HEIGHT, CAMERA_DISTANCE)
		
		-- 3. Calculamos la posición final de la cámara transformando el offset al espacio del mundo
		local cameraPosition = rootPosition + (startRotation:VectorToWorldSpace(relativeOffset))
		
		-- 4. Aplicamos la CFrame: Posición + Rotación
		-- Esto hace que la cámara mire hacia adelante según la rotación, manteniendo el offset
		camera.CFrame = startRotation + cameraPosition
		
		-- Opcional: Hacer que el personaje rote con la cámara (como en los shooters)
		humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, cameraAngleX, 0)
	end
end)

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)