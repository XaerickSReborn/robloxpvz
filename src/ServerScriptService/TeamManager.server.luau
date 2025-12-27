local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local plantTeam = Instance.new("Team")
plantTeam.Name = "Plants"
plantTeam.TeamColor = BrickColor.new("Bright green")
plantTeam.AutoAssignable = false
plantTeam.Parent = Teams
local zombieTeam = Instance.new("Team")
zombieTeam.Name = "Zombies"
zombieTeam.TeamColor = BrickColor.new("Bright red")
zombieTeam.AutoAssignable = false
zombieTeam.Parent = Teams
print("[TeamManager] Teams created: Plants (Green) and Zombies (Red)")
Players.PlayerAdded:Connect(function(player)
	local plantCount = #plantTeam:GetPlayers()
	local zombieCount = #zombieTeam:GetPlayers()
	
	if plantCount <= zombieCount then
		player.Team = plantTeam
		print("[TeamManager]", player.Name, "assigned to Plants")
	else
		player.Team = zombieTeam
		print("[TeamManager]", player.Name, "assigned to Zombies")
	end
end)