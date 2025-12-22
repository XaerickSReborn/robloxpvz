local function createPart(props)
	local part = Instance.new("Part")
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	
	for k, v in pairs(props) do
		part[k] = v
	end
	
	return part
end

local function buildBeach()
	local workspace = game:GetService("Workspace")
	local terrain = workspace.Terrain
	
	-- Clean up previous beach model (trees/details)
	local existing = workspace:FindFirstChild("Beach")
	if existing then
		existing:Destroy()
	end

	local beachModel = Instance.new("Model")
	beachModel.Name = "Beach"
	beachModel.Parent = workspace

	-- Offset to not overlap with the house at 0,0,40
	local origin = CFrame.new(100, 0, 0)
	
	-- --- Terrain Generation ---
	-- Using FillBlock to create voxels instead of Parts
	
	-- Sand Area
	-- Size: 100x12x100 (Thicker Y to ensure it fills well)
	local sandSize = Vector3.new(100, 12, 100)
	-- Shift Y down slightly so surface is around Y=0 or slightly above
	local sandCFrame = origin * CFrame.new(0, -2, 0)
	
	terrain:FillBlock(sandCFrame, sandSize, Enum.Material.Sand)

	-- Water Area
	local waterSize = Vector3.new(100, 12, 100)
	-- Shift Z by 100 to be adjacent
	local waterCFrame = origin * CFrame.new(0, -4, 100) 
	
	terrain:FillBlock(waterCFrame, waterSize, Enum.Material.Water)

	-- --- Decoration ---

	-- Simple Palm Tree Generator
	local function spawnPalmTree(pos: CFrame)
		local tree = Instance.new("Model")
		tree.Name = "PalmTree"
		tree.Parent = beachModel

		-- Trunk (Cylinder is rotated)
		local trunk = createPart({
			Name = "Trunk",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(15, 2, 2), 
			CFrame = pos * CFrame.new(0, 7.5, 0) * CFrame.Angles(0, 0, math.rad(90)),
			Color = Color3.fromRGB(139, 69, 19),
			Material = Enum.Material.Wood,
			Parent = tree
		})
		
		-- Leaves
		for i = 1, 5 do
			local angle = math.rad(i * (360/5))
			-- Leaf position
			local leafCFrame = pos * CFrame.new(0, 15, 0) 
				* CFrame.Angles(0, angle, 0) 
				* CFrame.new(3, 0, 0) 
				* CFrame.Angles(0, 0, math.rad(-20))
			
			local leaf = createPart({
				Name = "Leaf",
				Size = Vector3.new(8, 0.5, 3),
				CFrame = leafCFrame,
				Color = Color3.fromRGB(75, 151, 75),
				Material = Enum.Material.Grass,
				Parent = tree
			})
		end
	end

	-- Spawn trees on the terrain surface
	-- Since we know sand top is roughly at origin Y + (Size.Y/2) - 2... wait.
	-- sandCFrame Y is -2. Size Y is 12. Top is -2 + 6 = 4.
	-- Let's spawn trees at Y=4 roughly.
	local treeY = 4
	
	spawnPalmTree(origin * CFrame.new(-30, treeY, -20))
	spawnPalmTree(origin * CFrame.new(20, treeY, 10))
	spawnPalmTree(origin * CFrame.new(-15, treeY, 35))
end

buildBeach()
