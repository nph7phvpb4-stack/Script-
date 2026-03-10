-- ================================================
--  COMBINED ADMIN SCRIPT
--
--  SETUP INSTRUCTIONS:
--  1. Create a Script in ServerScriptService
--     → Paste PART 1 (everything up to the PART 2 marker)
--  2. Create a LocalScript in StarterPlayerScripts
--     → Paste PART 2 (everything after the PART 2 marker)
--
--  No Gist, no HTTP loader, no MainModule needed.
-- ================================================


-- ████████████████████████████████████████████████
--  PART 1 — SERVER SCRIPT  (ServerScriptService)
-- ████████████████████████████████████████████████

local Admin = {}

-- ── CONFIG ──────────────────────────────────────
Admin.Config = {
	Prefix = "!",            -- Command prefix (e.g. !kick PlayerName)
	Admins = {
		"YourUsernameHere",   -- Add your Roblox username
		-- "FriendUsername",
	},
	AdminUserIds = {
		-- 123456789,         -- Or use UserIds for security (recommended)
	},
	BanList = {},             -- Usernames banned from the game
	LogCommands = true,       -- Print commands to output
	AnnounceCommands = false, -- Show command usage in chat
}
-- ────────────────────────────────────────────────

local Players  = game:GetService("Players")
local Lighting = game:GetService("Lighting")

-- ── UTILITIES ───────────────────────────────────

local function isAdmin(player)
	for _, name in ipairs(Admin.Config.Admins) do
		if name:lower() == player.Name:lower() then return true end
	end
	for _, id in ipairs(Admin.Config.AdminUserIds) do
		if id == player.UserId then return true end
	end
	return false
end

local function isBanned(player)
	for _, name in ipairs(Admin.Config.BanList) do
		if name:lower() == player.Name:lower() then return true end
	end
	return false
end

local function notify(player, msg)
	local re = player:FindFirstChild("AdminNotify")
	if re then re:FireClient(player, msg) end
end

local function findPlayer(query, sender)
	query = query:lower()
	if query == "me"     then return {sender} end
	if query == "all"    then return Players:GetPlayers() end
	if query == "others" then
		local list = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= sender then table.insert(list, p) end
		end
		return list
	end
	local results = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name:lower():sub(1, #query) == query then
			table.insert(results, p)
		end
	end
	return results
end

local function log(admin, cmd, args)
	if Admin.Config.LogCommands then
		print(("[Admin] %s ran: %s %s"):format(admin.Name, cmd, table.concat(args, " ")))
	end
end

-- ── COMMANDS ────────────────────────────────────

Admin.Commands = {}

-- !kick <player> [reason]
Admin.Commands["kick"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	local reason  = table.concat(args, " ", 2) or "Kicked by admin."
	for _, p in ipairs(targets) do
		if p ~= sender then p:Kick(reason) end
	end
end

-- !ban <player>
Admin.Commands["ban"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	for _, p in ipairs(targets) do
		if p ~= sender then
			table.insert(Admin.Config.BanList, p.Name)
			p:Kick("You have been banned from this game.")
		end
	end
end

-- !kill <player>
Admin.Commands["kill"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	for _, p in ipairs(targets) do
		local char = p.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.Health = 0 end
		end
	end
end

-- !respawn <player>
Admin.Commands["respawn"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	for _, p in ipairs(targets) do p:LoadCharacter() end
end

-- !speed <player> <number>
Admin.Commands["speed"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	local val     = tonumber(args[2]) or 16
	for _, p in ipairs(targets) do
		local char = p.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = val end
		end
	end
end

-- !jump <player> <number>
Admin.Commands["jump"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	local val     = tonumber(args[2]) or 50
	for _, p in ipairs(targets) do
		local char = p.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.JumpPower = val end
		end
	end
end

-- !heal <player>
Admin.Commands["heal"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	for _, p in ipairs(targets) do
		local char = p.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.Health = hum.MaxHealth end
		end
	end
end

-- !god <player>
Admin.Commands["god"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	for _, p in ipairs(targets) do
		local char = p.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.MaxHealth = math.huge; hum.Health = math.huge end
		end
	end
end

-- !ungod <player>
Admin.Commands["ungod"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	for _, p in ipairs(targets) do
		local char = p.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.MaxHealth = 100; hum.Health = 100 end
		end
	end
end

-- !tp <player1> <player2>
Admin.Commands["tp"] = function(sender, args)
	local from = findPlayer(args[1] or "", sender)
	local to   = findPlayer(args[2] or "", sender)
	if #from == 0 or #to == 0 then return end
	local dest = to[1].Character and to[1].Character:FindFirstChild("HumanoidRootPart")
	if not dest then return end
	for _, p in ipairs(from) do
		local char = p.Character
		local hrp  = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = dest.CFrame + Vector3.new(0, 3, 0) end
	end
end

-- !bring <player>
Admin.Commands["bring"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	local sChar   = sender.Character
	local sHRP    = sChar and sChar:FindFirstChild("HumanoidRootPart")
	if not sHRP then return end
	for _, p in ipairs(targets) do
		local char = p.Character
		local hrp  = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = sHRP.CFrame + Vector3.new(0, 3, 0) end
	end
end

-- !goto <player>
Admin.Commands["goto"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	if #targets == 0 then return end
	local sChar = sender.Character
	local sHRP  = sChar and sChar:FindFirstChild("HumanoidRootPart")
	local dest  = targets[1].Character and targets[1].Character:FindFirstChild("HumanoidRootPart")
	if sHRP and dest then
		sHRP.CFrame = dest.CFrame + Vector3.new(0, 3, 0)
	end
end

-- !give <player> <toolName>
Admin.Commands["give"] = function(sender, args)
	local targets  = findPlayer(args[1] or "", sender)
	local toolName = args[2]
	if not toolName then return end
	local tool = game:GetService("ServerStorage"):FindFirstChild(toolName)
	if not tool then
		warn("[Admin] Tool not found in ServerStorage: " .. toolName)
		return
	end
	for _, p in ipairs(targets) do
		tool:Clone().Parent = p.Backpack
	end
end

-- !ff <player>
Admin.Commands["ff"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	for _, p in ipairs(targets) do
		local char = p.Character
		if char then Instance.new("ForceField", char) end
	end
end

-- !unff <player>
Admin.Commands["unff"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	for _, p in ipairs(targets) do
		local char = p.Character
		if char then
			for _, ff in ipairs(char:GetChildren()) do
				if ff:IsA("ForceField") then ff:Destroy() end
			end
		end
	end
end

-- !freeze <player>
Admin.Commands["freeze"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	for _, p in ipairs(targets) do
		local char = p.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = 0; hum.JumpPower = 0 end
		end
	end
end

-- !thaw <player>
Admin.Commands["thaw"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	for _, p in ipairs(targets) do
		local char = p.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
		end
	end
end

-- !fly <player> [speed]
Admin.Commands["fly"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	local speed   = tonumber(args[2]) or 50
	for _, p in ipairs(targets) do
		local re = p:FindFirstChild("AdminFly")
		if re then re:FireClient(p, true, speed) end
	end
end

-- !unfly <player>
Admin.Commands["unfly"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	for _, p in ipairs(targets) do
		local re = p:FindFirstChild("AdminFly")
		if re then re:FireClient(p, false, 0) end
	end
end

-- !time <0-24>
Admin.Commands["time"] = function(sender, args)
	local t = tonumber(args[1])
	if t then Lighting.TimeOfDay = ("%02d:00:00"):format(t % 24) end
end

-- !fog <distance>
Admin.Commands["fog"] = function(sender, args)
	local d = tonumber(args[1])
	if d then Lighting.FogEnd = d end
end

-- !ambient <r> <g> <b>
Admin.Commands["ambient"] = function(sender, args)
	local r = (tonumber(args[1]) or 128) / 255
	local g = (tonumber(args[2]) or 128) / 255
	local b = (tonumber(args[3]) or 128) / 255
	Lighting.Ambient = Color3.new(r, g, b)
end

-- !shutdown
Admin.Commands["shutdown"] = function(sender, args)
	for _, p in ipairs(Players:GetPlayers()) do
		p:Kick("The server is shutting down. Please rejoin.")
	end
end

-- !pm <player> <message>
Admin.Commands["pm"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	local msg     = table.concat(args, " ", 2)
	for _, p in ipairs(targets) do
		notify(p, "[PM from " .. sender.Name .. "] " .. msg)
	end
end

-- !announce <message>
Admin.Commands["announce"] = function(sender, args)
	local msg = table.concat(args, " ")
	for _, p in ipairs(Players:GetPlayers()) do
		notify(p, "[Announcement] " .. msg)
	end
end

-- !cmds
Admin.Commands["cmds"] = function(sender, args)
	local list = {}
	for cmd in pairs(Admin.Commands) do table.insert(list, Admin.Config.Prefix .. cmd) end
	table.sort(list)
	notify(sender, "Commands: " .. table.concat(list, "  |  "))
	print("[Admin] Commands: " .. table.concat(list, ", "))
end

-- ── BAN CHECK + REMOTE SETUP ON JOIN ────────────

Players.PlayerAdded:Connect(function(player)
	if isBanned(player) then
		player:Kick("You are banned from this game.")
		return
	end

	local re = Instance.new("RemoteEvent")
	re.Name = "AdminNotify"
	re.Parent = player

	local flyRe = Instance.new("RemoteEvent")
	flyRe.Name = "AdminFly"
	flyRe.Parent = player

	player.Chatted:Connect(function(msg)
		if not isAdmin(player) then return end

		local prefix = Admin.Config.Prefix
		if msg:sub(1, #prefix):lower() ~= prefix:lower() then return end

		local parts = {}
		for word in msg:sub(#prefix + 1):gmatch("%S+") do
			table.insert(parts, word)
		end
		if #parts == 0 then return end

		local cmd  = parts[1]:lower()
		local args = {}
		for i = 2, #parts do table.insert(args, parts[i]) end

		log(player, cmd, args)

		if Admin.Commands[cmd] then
			Admin.Commands[cmd](player, args)
		else
			notify(player, 'Unknown command: "' .. cmd .. '". Try ' .. prefix .. 'cmds')
		end
	end)
end)

print("[Admin] Universal Admin loaded. Prefix: " .. Admin.Config.Prefix)


-- ████████████████████████████████████████████████
--  PART 2 — LOCAL SCRIPT  (StarterPlayerScripts)
--  Copy everything below into a new LocalScript
-- ████████████████████████████████████████████████

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local flyRE = player:WaitForChild("AdminFly", 30)
if not flyRE then warn("[AdminFly] RemoteEvent not found") return end

local flying, flySpeed, bv, bg, conn = false, 50, nil, nil, nil

local function getHRP()
	local char = player.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
	local char = player.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function cleanUp()
	if bv and bv.Parent then bv:Destroy() end
	if bg and bg.Parent then bg:Destroy() end
	bv, bg = nil, nil
	if conn then conn:Disconnect(); conn = nil end
end

local function getInput()
	local dir = Vector3.new(0, 0, 0)
	if UserInputService:IsKeyDown(Enum.KeyCode.W)           or UserInputService:IsKeyDown(Enum.KeyCode.Up)    then dir += Vector3.new(0,0,-1) end
	if UserInputService:IsKeyDown(Enum.KeyCode.S)           or UserInputService:IsKeyDown(Enum.KeyCode.Down)  then dir += Vector3.new(0,0,1)  end
	if UserInputService:IsKeyDown(Enum.KeyCode.A)           or UserInputService:IsKeyDown(Enum.KeyCode.Left)  then dir += Vector3.new(-1,0,0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.D)           or UserInputService:IsKeyDown(Enum.KeyCode.Right) then dir += Vector3.new(1,0,0)  end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space)       or UserInputService:IsKeyDown(Enum.KeyCode.E)     then dir += Vector3.new(0,1,0)  end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.Q)     then dir += Vector3.new(0,-1,0) end
	return dir
end

local function startFly(speed)
	local hrp = getHRP()
	local hum = getHumanoid()
	if not hrp then return end
	flySpeed = speed or flySpeed
	cleanUp()
	if hum then hum.PlatformStand = true end

	bv = Instance.new("BodyVelocity")
	bv.Velocity = Vector3.new(0,0,0)
	bv.MaxForce = Vector3.new(1e5,1e5,1e5)
	bv.P = 1e4
	bv.Parent = hrp

	bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
	bg.P = 1e4
	bg.D = 500
	bg.CFrame = hrp.CFrame
	bg.Parent = hrp

	flying = true

	conn = RunService.RenderStepped:Connect(function()
		local hrp2 = getHRP()
		if not hrp2 or not bv or not bv.Parent then cleanUp(); flying = false; return end

		local inputDir = getInput()
		if inputDir.Magnitude > 0 then
			local camCF     = camera.CFrame
			local flatLook  = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
			local flatRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
			local worldDir  = flatLook * -inputDir.Z + flatRight * inputDir.X + Vector3.new(0, inputDir.Y, 0)
			bv.Velocity = worldDir.Unit * flySpeed
			if math.abs(inputDir.X) > 0 or math.abs(inputDir.Z) > 0 then
				bg.CFrame = CFrame.lookAt(hrp2.Position, hrp2.Position + Vector3.new(worldDir.X, 0, worldDir.Z))
			end
		else
			bv.Velocity = Vector3.new(0,0,0)
		end
	end)
end

local function stopFly()
	local hum = getHumanoid()
	cleanUp()
	flying = false
	if hum then hum.PlatformStand = false end
end

player.CharacterAdded:Connect(function()
	if flying then task.wait(0.5); startFly(flySpeed) end
end)

flyRE.OnClientEvent:Connect(function(enable, speed)
	if enable then
		startFly(speed)
		local hint = Instance.new("Hint")
		hint.Text = "Flying! WASD = move  |  Space/E = up  |  Q/Ctrl = down"
		hint.Parent = workspace
		game:GetService("Debris"):AddItem(hint, 4)
	else
		stopFly()
	end
end)

print("[AdminFly] Client fly script ready.")
