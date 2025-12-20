local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getRequestBlockToolEvent(): RemoteEvent
	local existing = ReplicatedStorage:FindFirstChild("RequestBlockTool")
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = "RequestBlockTool"
	remote.Parent = ReplicatedStorage
	return remote
end

local function createBlockTool()
	local tool = Instance.new("Tool")
	tool.Name = "Bloque"
	tool.RequiresHandle = true

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(2, 2, 2)
	handle.Color = Color3.fromRGB(255, 170, 0)
	handle.Material = Enum.Material.SmoothPlastic
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool

	return tool
end

local function giveBlockTool(player: Player)
	local backpack = player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack")
	if backpack:FindFirstChild("Bloque") then
		return
	end

	local tool = createBlockTool()
	tool.Parent = backpack
end

local function createPart(props: { [string]: any })
	local className = props.ClassName or "Part"
	local part = Instance.new(className)
	part.Name = props.Name or className
	part.Anchored = props.Anchored ~= false
	part.CanCollide = props.CanCollide ~= false
	part.Color = props.Color or Color3.fromRGB(163, 162, 165)
	part.Material = props.Material or Enum.Material.SmoothPlastic
	part.Size = props.Size or Vector3.new(4, 1, 2)
	part.CFrame = props.CFrame or CFrame.new()
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth

	if props.Transparency ~= nil then
		part.Transparency = props.Transparency
	end

	if props.Reflectance ~= nil then
		part.Reflectance = props.Reflectance
	end

	return part
end

local function buildHouse(origin: CFrame)
	local workspaceRef = game:GetService("Workspace")

	local existing = workspaceRef:FindFirstChild("House")
	if existing then
		if existing:IsA("Model") then
			existing:ClearAllChildren()
		else
			existing:Destroy()
			existing = nil
		end
	end

	local house = (existing :: Model?) or Instance.new("Model")
	house.Name = "House"
	house.Parent = workspaceRef

	local floorSize = Vector3.new(40, 1, 30)
	local wallThickness = 1
	local wallHeight = 20
	local roofHeight = 8

	local floor = createPart({
		Name = "Floor",
		Size = floorSize,
		CFrame = origin * CFrame.new(0, floorSize.Y / 2, 0),
		Color = Color3.fromRGB(105, 64, 40),
		Material = Enum.Material.WoodPlanks,
	})
	floor.Parent = house

	local halfX = floorSize.X / 2
	local halfZ = floorSize.Z / 2
	local wallCenterY = floorSize.Y + wallHeight / 2

	local backWall = createPart({
		Name = "BackWall",
		Size = Vector3.new(floorSize.X, wallHeight, wallThickness),
		CFrame = origin * CFrame.new(0, wallCenterY, -(halfZ + wallThickness / 2)),
		Color = Color3.fromRGB(205, 205, 205),
		Material = Enum.Material.Brick,
	})
	backWall.Parent = house

	local sideWallLeft = createPart({
		Name = "LeftWall",
		Size = Vector3.new(wallThickness, wallHeight, floorSize.Z),
		CFrame = origin * CFrame.new(-(halfX + wallThickness / 2), wallCenterY, 0),
		Color = Color3.fromRGB(205, 205, 205),
		Material = Enum.Material.Brick,
	})
	sideWallLeft.Parent = house

	local sideWallRight = createPart({
		Name = "RightWall",
		Size = Vector3.new(wallThickness, wallHeight, floorSize.Z),
		CFrame = origin * CFrame.new(halfX + wallThickness / 2, wallCenterY, 0),
		Color = Color3.fromRGB(205, 205, 205),
		Material = Enum.Material.Brick,
	})
	sideWallRight.Parent = house

	local doorWidth = 8
	local doorHeight = 12
	local frontZ = halfZ + wallThickness / 2

	local leftWidth = (floorSize.X - doorWidth) / 2
	local leftWall = createPart({
		Name = "FrontWallLeft",
		Size = Vector3.new(leftWidth, wallHeight, wallThickness),
		CFrame = origin * CFrame.new(-(doorWidth / 2 + leftWidth / 2), wallCenterY, frontZ),
		Color = Color3.fromRGB(205, 205, 205),
		Material = Enum.Material.Brick,
	})
	leftWall.Parent = house

	local rightWall = createPart({
		Name = "FrontWallRight",
		Size = Vector3.new(leftWidth, wallHeight, wallThickness),
		CFrame = origin * CFrame.new(doorWidth / 2 + leftWidth / 2, wallCenterY, frontZ),
		Color = Color3.fromRGB(205, 205, 205),
		Material = Enum.Material.Brick,
	})
	rightWall.Parent = house

	local lintelHeight = wallHeight - doorHeight
	local lintel = createPart({
		Name = "FrontWallTop",
		Size = Vector3.new(doorWidth, lintelHeight, wallThickness),
		CFrame = origin * CFrame.new(0, floorSize.Y + doorHeight + lintelHeight / 2, frontZ),
		Color = Color3.fromRGB(205, 205, 205),
		Material = Enum.Material.Brick,
	})
	lintel.Parent = house

	local door = createPart({
		Name = "Door",
		Size = Vector3.new(doorWidth - 0.5, doorHeight, 0.5),
		CFrame = origin * CFrame.new(0, floorSize.Y + doorHeight / 2, frontZ - 0.25),
		Color = Color3.fromRGB(124, 92, 70),
		Material = Enum.Material.Wood,
	})
	door.Parent = house

	local clickDetector = Instance.new("ClickDetector")
	clickDetector.Name = "DoorClickDetector"
	clickDetector.MaxActivationDistance = 20
	clickDetector.Parent = door

	local closedCFrame = door.CFrame
	local hingeOffset = CFrame.new(-door.Size.X / 2, 0, 0)
	local openCFrame = closedCFrame * hingeOffset * CFrame.Angles(0, math.rad(-95), 0) * CFrame.new(door.Size.X / 2, 0, 0)

	local isOpen = false
	local isTweening = false
	local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function setDoor(open: boolean)
		if isTweening or isOpen == open then
			return
		end

		isTweening = true
		isOpen = open

		local tween = TweenService:Create(door, tweenInfo, {
			CFrame = if open then openCFrame else closedCFrame,
		})

		tween.Completed:Connect(function()
			isTweening = false
		end)

		tween:Play()
	end

	clickDetector.MouseClick:Connect(function(_player: Player)
		setDoor(not isOpen)
	end)

	local windowSize = Vector3.new(6, 6, 0.5)
	local windowY = floorSize.Y + 10

	local window1 = createPart({
		Name = "WindowLeft",
		Size = windowSize,
		CFrame = origin * CFrame.new(-(halfX + wallThickness / 2) + 0.25, windowY, -6) * CFrame.Angles(0, math.rad(90), 0),
		Color = Color3.fromRGB(175, 221, 255),
		Material = Enum.Material.Glass,
		Transparency = 0.35,
		CanCollide = false,
	})
	window1.Parent = house

	local window2 = createPart({
		Name = "WindowRight",
		Size = windowSize,
		CFrame = origin * CFrame.new((halfX + wallThickness / 2) - 0.25, windowY, -6) * CFrame.Angles(0, math.rad(90), 0),
		Color = Color3.fromRGB(175, 221, 255),
		Material = Enum.Material.Glass,
		Transparency = 0.35,
		CanCollide = false,
	})
	window2.Parent = house

	local roofY = floorSize.Y + wallHeight + roofHeight / 2
	local roofLength = floorSize.Z + 2
	local roofHalfWidth = floorSize.X / 2
	local roofWedgeSize = Vector3.new(roofHalfWidth, roofHeight, roofLength)

	local roofLeft = createPart({
		ClassName = "WedgePart",
		Name = "RoofLeft",
		Size = roofWedgeSize,
		CFrame = origin * CFrame.new(-roofHalfWidth / 2, roofY, 0) * CFrame.Angles(0, math.rad(180), 0),
		Color = Color3.fromRGB(196, 40, 28),
		Material = Enum.Material.Slate,
	})
	roofLeft.Parent = house

	local roofRight = createPart({
		ClassName = "WedgePart",
		Name = "RoofRight",
		Size = roofWedgeSize,
		CFrame = origin * CFrame.new(roofHalfWidth / 2, roofY, 0),
		Color = Color3.fromRGB(196, 40, 28),
		Material = Enum.Material.Slate,
	})
	roofRight.Parent = house

	local chimney = createPart({
		Name = "Chimney",
		Size = Vector3.new(3, 10, 3),
		CFrame = origin * CFrame.new(-8, floorSize.Y + wallHeight + 5, -6),
		Color = Color3.fromRGB(99, 95, 98),
		Material = Enum.Material.Brick,
	})
	chimney.Parent = house

	house.PrimaryPart = floor
end

buildHouse(CFrame.new(0, 0, 40))

local requestBlockTool = getRequestBlockToolEvent()
requestBlockTool.OnServerEvent:Connect(function(player: Player)
	giveBlockTool(player)
end)

Players.PlayerAdded:Connect(function(player: Player)
	task.defer(function()
		if player.Parent ~= nil then
			giveBlockTool(player)
		end
	end)
end)