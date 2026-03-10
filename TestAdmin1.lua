-- ================================================
--  PART 1 — SERVER SCRIPT  (ServerScriptService)
-- ================================================

local Admin = {}

Admin.Config = {
	Prefix = "!",
	Admins = {
		"YourUsernameHere",
	},
	AdminUserIds = {},
	BanList = {},
	LogCommands = true,
}

local Players  = game:GetService("Players")
local Lighting = game:GetService("Lighting")

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

Admin.Commands = {}

Admin.Commands["kick"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	local reason  = table.concat(args, " ", 2) or "Kicked by admin."
	for _, p in ipairs(targets) do
		if p ~= sender then p:Kick(reason) end
	end
end

Admin.Commands["ban"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	for _, p in ipairs(targets) do
		if p ~= sender then
			table.insert(Admin.Config.BanList, p.Name)
			p:Kick("You have been banned from this game.")
		end
	end
end

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

Admin.Commands["respawn"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	for _, p in ipairs(targets) do p:LoadCharacter() end
end

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

Admin.Commands["give"] = function(sender, args)
	local targets  = findPlayer(args[1] or "", sender)
	local toolName = args[2]
	if not toolName then return end
	local tool = game:GetService("ServerStorage"):FindFirstChild(toolName)
	if not tool then warn("[Admin] Tool not found: " .. toolName); return end
	for _, p in ipairs(targets) do
		tool:Clone().Parent = p.Backpack
	end
end

Admin.Commands["ff"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	for _, p in ipairs(targets) do
		local char = p.Character
		if char then Instance.new("ForceField", char) end
	end
end

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

Admin.Commands["fly"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	local speed   = tonumber(args[2]) or 50
	for _, p in ipairs(targets) do
		local re = p:FindFirstChild("AdminFly")
		if re then re:FireClient(p, true, speed) end
	end
end

Admin.Commands["unfly"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	for _, p in ipairs(targets) do
		local re = p:FindFirstChild("AdminFly")
		if re then re:FireClient(p, false, 0) end
	end
end

Admin.Commands["time"] = function(sender, args)
	local t = tonumber(args[1])
	if t then Lighting.TimeOfDay = ("%02d:00:00"):format(t % 24) end
end

Admin.Commands["fog"] = function(sender, args)
	local d = tonumber(args[1])
	if d then Lighting.FogEnd = d end
end

Admin.Commands["ambient"] = function(sender, args)
	local r = (tonumber(args[1]) or 128) / 255
	local g = (tonumber(args[2]) or 128) / 255
	local b = (tonumber(args[3]) or 128) / 255
	Lighting.Ambient = Color3.new(r, g, b)
end

Admin.Commands["shutdown"] = function(sender, args)
	for _, p in ipairs(Players:GetPlayers()) do
		p:Kick("The server is shutting down.")
	end
end

Admin.Commands["pm"] = function(sender, args)
	local targets = findPlayer(args[1] or "", sender)
	local msg     = table.concat(args, " ", 2)
	for _, p in ipairs(targets) do
		notify(p, "[PM from " .. sender.Name .. "] " .. msg)
	end
end

Admin.Commands["announce"] = function(sender, args)
	local msg = table.concat(args, " ")
	for _, p in ipairs(Players:GetPlayers()) do
		notify(p, "[Announcement] " .. msg)
	end
end

Admin.Commands["cmds"] = function(sender, args)
	local list = {}
	for cmd in pairs(Admin.Commands) do table.insert(list, Admin.Config.Prefix .. cmd) end
	table.sort(list)
	notify(sender, "Commands: " .. table.concat(list, "  |  "))
	print("[Admin] Commands: " .. table.concat(list, ", "))
end

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

	-- RemoteEvent so GUI can fire commands directly
	local cmdRe = Instance.new("RemoteEvent")
	cmdRe.Name = "AdminCmd"
	cmdRe.Parent = player

	cmdRe.OnServerEvent:Connect(function(plr, cmd, args)
		if not isAdmin(plr) then return end
		if Admin.Commands[cmd] then
			log(plr, cmd, args)
			Admin.Commands[cmd](plr, args)
		end
	end)

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
			notify(player, 'Unknown command: "' .. cmd .. '". Try !cmds')
		end
	end)
end)

print("[Admin] Server loaded. Prefix: " .. Admin.Config.Prefix)

-- ================================================
--  PART 2 — LOCAL SCRIPT  (StarterPlayerScripts)
--  Includes: Fly system + Neon Admin GUI
-- ================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local player    = Players.LocalPlayer
local camera    = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

local flyRE  = player:WaitForChild("AdminFly", 30)
local cmdRE  = player:WaitForChild("AdminCmd", 30)
local notifyRE = player:WaitForChild("AdminNotify", 30)

-- ── FLY SYSTEM ──────────────────────────────────

local flying, flySpeed, bv, bg, conn = false, 50, nil, nil, nil

local function getHRP()
	return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
	return player.Character and player.Character:FindFirstChildOfClass("Humanoid")
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

if flyRE then
	flyRE.OnClientEvent:Connect(function(enable, speed)
		if enable then
			startFly(speed)
			local hint = Instance.new("Hint")
			hint.Text = "✈ Flying! WASD=move | Space/E=up | Q/Ctrl=down"
			hint.Parent = workspace
			game:GetService("Debris"):AddItem(hint, 4)
		else
			stopFly()
		end
	end)
end

-- ── FIRE COMMAND (via RemoteEvent to server) ────

local selectedPlayer = "me"

local function fireCmd(cmdStr)
	if not cmdRE then return end
	local parts = {}
	for word in cmdStr:gmatch("%S+") do table.insert(parts, word) end
	if #parts == 0 then return end
	local cmd  = parts[1]:lower()
	local args = {selectedPlayer}
	for i = 2, #parts do table.insert(args, parts[i]) end
	-- for commands that already include the target in the string, don't double-add
	if #parts > 1 then
		args = {}
		for i = 2, #parts do table.insert(args, parts[i]) end
		table.insert(args, 1, selectedPlayer)
	end
	cmdRE:FireServer(cmd, args)
end

-- ── NOTIFY DISPLAY ──────────────────────────────

if notifyRE then
	notifyRE.OnClientEvent:Connect(function(msg)
		local hint = Instance.new("Hint")
		hint.Text = msg
		hint.Parent = workspace
		game:GetService("Debris"):AddItem(hint, 5)
	end)
end

-- ── COLORS ──────────────────────────────────────

local C = {
	BG       = Color3.fromRGB(5, 5, 15),
	Panel    = Color3.fromRGB(10, 10, 25),
	Border   = Color3.fromRGB(0, 255, 255),
	Border2  = Color3.fromRGB(180, 0, 255),
	Text     = Color3.fromRGB(0, 255, 255),
	TextDim  = Color3.fromRGB(100, 200, 220),
	Btn      = Color3.fromRGB(15, 15, 35),
	BtnHover = Color3.fromRGB(0, 255, 255),
	BtnText  = Color3.fromRGB(0, 255, 255),
	BtnHText = Color3.fromRGB(5, 5, 15),
	Red      = Color3.fromRGB(255, 50, 100),
	Purple   = Color3.fromRGB(180, 0, 255),
	Yellow   = Color3.fromRGB(255, 220, 0),
	Green    = Color3.fromRGB(0, 255, 150),
}

local function makeCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = parent
	return c
end

local function makeBorder(parent, color, thickness)
	local b = Instance.new("UIStroke")
	b.Color = color or C.Border
	b.Thickness = thickness or 2
	b.Parent = parent
	return b
end

local function hoverBtn(btn, normalColor, hoverColor, normalText, hoverText)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play()
		btn.TextColor3 = hoverText
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = normalColor}):Play()
		btn.TextColor3 = normalText
	end)
end

-- ── BUILD GUI ───────────────────────────────────

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminPanelGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

-- Main Window
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 520, 0, 560)
Main.Position = UDim2.new(0.5, -260, 0.5, -280)
Main.BackgroundColor3 = C.BG
Main.BorderSizePixel = 0
Main.ZIndex = 2
Main.Parent = ScreenGui
makeCorner(Main, 10)
local mainStroke = makeBorder(Main, C.Border, 2)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = C.Panel
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 3
TitleBar.Parent = Main
makeCorner(TitleBar, 10)

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = C.Panel
TitleFix.BorderSizePixel = 0
TitleFix.ZIndex = 3
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -100, 0, 20)
TitleLabel.Position = UDim2.new(0, 14, 0, 4)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡  ADMIN PANEL  ⚡"
TitleLabel.TextColor3 = C.Border
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 4
TitleLabel.Parent = TitleBar

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(1, -100, 0, 14)
SubLabel.Position = UDim2.new(0, 14, 0, 26)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "CYBERPUNK CONTROL SYSTEM"
SubLabel.TextColor3 = C.Purple
SubLabel.TextSize = 10
SubLabel.Font = Enum.Font.GothamBold
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.ZIndex = 4
SubLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0, 6)
CloseBtn.BackgroundColor3 = C.Red
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 5
CloseBtn.Parent = TitleBar
makeCorner(CloseBtn, 6)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -78, 0, 6)
MinBtn.BackgroundColor3 = C.Yellow
MinBtn.Text = "—"
MinBtn.TextColor3 = C.BtnHText
MinBtn.TextSize = 14
MinBtn.Font = Enum.Font.GothamBold
MinBtn.ZIndex = 5
MinBtn.Parent = TitleBar
makeCorner(MinBtn, 6)

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -54)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.ZIndex = 3
Content.Parent = Main

-- ── PLAYER SELECTOR ─────────────────────────────

local PlayerSection = Instance.new("Frame")
PlayerSection.Size = UDim2.new(1, 0, 0, 70)
PlayerSection.Position = UDim2.new(0, 0, 0, 0)
PlayerSection.BackgroundColor3 = C.Panel
PlayerSection.BorderSizePixel = 0
PlayerSection.ZIndex = 3
PlayerSection.Parent = Content
makeCorner(PlayerSection, 8)
makeBorder(PlayerSection, C.Purple, 1)

local PlayerLabel = Instance.new("TextLabel")
PlayerLabel.Size = UDim2.new(1, -10, 0, 18)
PlayerLabel.Position = UDim2.new(0, 10, 0, 6)
PlayerLabel.BackgroundTransparency = 1
PlayerLabel.Text = "▸ TARGET PLAYER"
PlayerLabel.TextColor3 = C.Purple
PlayerLabel.TextSize = 11
PlayerLabel.Font = Enum.Font.GothamBold
PlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerLabel.ZIndex = 4
PlayerLabel.Parent = PlayerSection

local PlayerDropdown = Instance.new("TextButton")
PlayerDropdown.Size = UDim2.new(1, -20, 0, 32)
PlayerDropdown.Position = UDim2.new(0, 10, 0, 28)
PlayerDropdown.BackgroundColor3 = C.Btn
PlayerDropdown.Text = "  ▾  Select Player..."
PlayerDropdown.TextColor3 = C.TextDim
PlayerDropdown.TextSize = 13
PlayerDropdown.Font = Enum.Font.Gotham
PlayerDropdown.TextXAlignment = Enum.TextXAlignment.Left
PlayerDropdown.ZIndex = 4
PlayerDropdown.Parent = PlayerSection
makeCorner(PlayerDropdown, 6)
makeBorder(PlayerDropdown, C.Border, 1)

local DropList = Instance.new("Frame")
DropList.Size = UDim2.new(1, -20, 0, 0)
DropList.Position = UDim2.new(0, 10, 0, 62)
DropList.BackgroundColor3 = C.Panel
DropList.BorderSizePixel = 0
DropList.ClipsDescendants = true
DropList.ZIndex = 20
DropList.Visible = false
DropList.Parent = PlayerSection
makeCorner(DropList, 6)
makeBorder(DropList, C.Border, 1)
Instance.new("UIListLayout").Parent = DropList

local dropOpen = false

local function refreshDropdown()
	for _, c in ipairs(DropList:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	local options = {"me", "all", "others"}
	for _, p in ipairs(Players:GetPlayers()) do table.insert(options, p.Name) end
	for _, name in ipairs(options) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 30)
		btn.BackgroundColor3 = C.Btn
		btn.BackgroundTransparency = 0.3
		btn.Text = "  " .. name
		btn.TextColor3 = C.Text
		btn.TextSize = 13
		btn.Font = Enum.Font.Gotham
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.ZIndex = 21
		btn.Parent = DropList
		btn.MouseButton1Click:Connect(function()
			selectedPlayer = name
			PlayerDropdown.Text = "  ▾  " .. name
			PlayerDropdown.TextColor3 = C.Text
			dropOpen = false
			TweenService:Create(DropList, TweenInfo.new(0.2), {Size = UDim2.new(1, -20, 0, 0)}):Play()
			task.delay(0.2, function()
				DropList.Visible = false
				PlayerSection.Size = UDim2.new(1, 0, 0, 70)
			end)
		end)
		hoverBtn(btn, C.Btn, C.Border, C.Text, C.BtnHText)
	end
end

PlayerDropdown.MouseButton1Click:Connect(function()
	dropOpen = not dropOpen
	if dropOpen then
		refreshDropdown()
		DropList.Visible = true
		local opts = {"me","all","others"}
		for _, p in ipairs(Players:GetPlayers()) do table.insert(opts, p.Name) end
		local h = math.min(#opts * 30, 150)
		TweenService:Create(DropList, TweenInfo.new(0.2), {Size = UDim2.new(1, -20, 0, h)}):Play()
		PlayerSection.Size = UDim2.new(1, 0, 0, 74 + h)
	else
		TweenService:Create(DropList, TweenInfo.new(0.2), {Size = UDim2.new(1, -20, 0, 0)}):Play()
		task.delay(0.2, function()
			DropList.Visible = false
			PlayerSection.Size = UDim2.new(1, 0, 0, 70)
		end)
	end
end)

-- ── COMMAND INPUT ───────────────────────────────

local InputSection = Instance.new("Frame")
InputSection.Size = UDim2.new(1, 0, 0, 70)
InputSection.Position = UDim2.new(0, 0, 0, 80)
InputSection.BackgroundColor3 = C.Panel
InputSection.BorderSizePixel = 0
InputSection.ZIndex = 3
InputSection.Parent = Content
makeCorner(InputSection, 8)
makeBorder(InputSection, C.Border, 1)

local InputLabel = Instance.new("TextLabel")
InputLabel.Size = UDim2.new(1, -10, 0, 18)
InputLabel.Position = UDim2.new(0, 10, 0, 6)
InputLabel.BackgroundTransparency = 1
InputLabel.Text = "▸ COMMAND INPUT"
InputLabel.TextColor3 = C.Border
InputLabel.TextSize = 11
InputLabel.Font = Enum.Font.GothamBold
InputLabel.TextXAlignment = Enum.TextXAlignment.Left
InputLabel.ZIndex = 4
InputLabel.Parent = InputSection

local CmdRow = Instance.new("Frame")
CmdRow.Size = UDim2.new(1, -20, 0, 32)
CmdRow.Position = UDim2.new(0, 10, 0, 28)
CmdRow.BackgroundTransparency = 1
CmdRow.ZIndex = 4
CmdRow.Parent = InputSection

local CmdInput = Instance.new("TextBox")
CmdInput.Size = UDim2.new(1, -90, 1, 0)
CmdInput.BackgroundColor3 = C.Btn
CmdInput.PlaceholderText = "e.g. speed 200"
CmdInput.PlaceholderColor3 = C.TextDim
CmdInput.Text = ""
CmdInput.TextColor3 = C.Text
CmdInput.TextSize = 13
CmdInput.Font = Enum.Font.Gotham
CmdInput.ClearTextOnFocus = false
CmdInput.ZIndex = 4
CmdInput.Parent = CmdRow
makeCorner(CmdInput, 6)
makeBorder(CmdInput, C.Border, 1)
local CmdPad = Instance.new("UIPadding")
CmdPad.PaddingLeft = UDim.new(0, 8)
CmdPad.Parent = CmdInput

local SendBtn = Instance.new("TextButton")
SendBtn.Size = UDim2.new(0, 82, 1, 0)
SendBtn.Position = UDim2.new(1, -82, 0, 0)
SendBtn.BackgroundColor3 = C.Border
SendBtn.Text = "EXECUTE"
SendBtn.TextColor3 = C.BtnHText
SendBtn.TextSize = 12
SendBtn.Font = Enum.Font.GothamBold
SendBtn.ZIndex = 4
SendBtn.Parent = CmdRow
makeCorner(SendBtn, 6)
hoverBtn(SendBtn, C.Border, C.Purple, C.BtnHText, Color3.fromRGB(255,255,255))

-- ── QUICK COMMAND BUTTONS ───────────────────────

local BtnSection = Instance.new("Frame")
BtnSection.Size = UDim2.new(1, 0, 0, 300)
BtnSection.Position = UDim2.new(0, 0, 0, 160)
BtnSection.BackgroundColor3 = C.Panel
BtnSection.BorderSizePixel = 0
BtnSection.ZIndex = 3
BtnSection.Parent = Content
makeCorner(BtnSection, 8)
makeBorder(BtnSection, C.Purple, 1)

local BtnLabel = Instance.new("TextLabel")
BtnLabel.Size = UDim2.new(1, -10, 0, 18)
BtnLabel.Position = UDim2.new(0, 10, 0, 6)
BtnLabel.BackgroundTransparency = 1
BtnLabel.Text = "▸ QUICK COMMANDS"
BtnLabel.TextColor3 = C.Purple
BtnLabel.TextSize = 11
BtnLabel.Font = Enum.Font.GothamBold
BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
BtnLabel.ZIndex = 4
BtnLabel.Parent = BtnSection

local BtnGrid = Instance.new("Frame")
BtnGrid.Size = UDim2.new(1, -20, 1, -30)
BtnGrid.Position = UDim2.new(0, 10, 0, 28)
BtnGrid.BackgroundTransparency = 1
BtnGrid.ZIndex = 4
BtnGrid.Parent = BtnSection

local BtnGridLayout = Instance.new("UIGridLayout")
BtnGridLayout.CellSize = UDim2.new(0, 112, 0, 36)
BtnGridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
BtnGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
BtnGridLayout.Parent = BtnGrid

local commands = {
	{label="⚡ Kill",     cmd="kill",      color=C.Red},
	{label="💚 Heal",     cmd="heal",      color=C.Green},
	{label="☁ God",      cmd="god",       color=C.Yellow},
	{label="💀 Ungod",    cmd="ungod",     color=C.TextDim},
	{label="✈ Fly",      cmd="fly",       color=C.Border},
	{label="🚫 Unfly",    cmd="unfly",     color=C.TextDim},
	{label="🛡 FF",       cmd="ff",        color=C.Green},
	{label="❌ Unff",     cmd="unff",      color=C.Red},
	{label="❄ Freeze",   cmd="freeze",    color=C.Border},
	{label="🔥 Thaw",     cmd="thaw",      color=C.Yellow},
	{label="🚀 Speed+",   cmd="speed 100", color=C.Purple},
	{label="🐢 Speed-",   cmd="speed 16",  color=C.TextDim},
	{label="↑ Jump+",    cmd="jump 100",  color=C.Purple},
	{label="🔄 Respawn",  cmd="respawn",   color=C.Yellow},
	{label="📢 Announce", cmd="announce",  color=C.Border},
	{label="💬 PM",       cmd="pm",        color=C.Purple},
	{label="🌙 Night",    cmd="time 0",    color=C.TextDim},
	{label="☀ Day",      cmd="time 12",   color=C.Yellow},
	{label="🔇 Shutdown", cmd="shutdown",  color=C.Red},
	{label="📋 Cmds",     cmd="cmds",      color=C.Green},
}

for i, data in ipairs(commands) do
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 112, 0, 36)
	b.BackgroundColor3 = C.Btn
	b.Text = data.label
	b.TextColor3 = data.color
	b.TextSize = 12
	b.Font = Enum.Font.GothamBold
	b.ZIndex = 5
	b.LayoutOrder = i
	b.Parent = BtnGrid
	makeCorner(b, 6)
	makeBorder(b, data.color, 1)
	hoverBtn(b, C.Btn, data.color, data.color, C.BtnHText)
	b.MouseButton1Click:Connect(function()
		CmdInput.Text = data.cmd
		fireCmd(data.cmd)
	end)
end

-- ── INPUT EXECUTE ───────────────────────────────

local function execInput()
	local txt = CmdInput.Text
	if txt ~= "" then
		fireCmd(txt)
		CmdInput.Text = ""
	end
end

SendBtn.MouseButton1Click:Connect(execInput)
CmdInput.FocusLost:Connect(function(enter) if enter then execInput() end end)

-- ── TOGGLE BUTTON ───────────────────────────────

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 44, 0, 44)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -22)
ToggleBtn.BackgroundColor3 = C.BG
ToggleBtn.Text = "⚡"
ToggleBtn.TextSize = 22
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextColor3 = C.Border
ToggleBtn.ZIndex = 15
ToggleBtn.Parent = ScreenGui
makeCorner(ToggleBtn, 8)
makeBorder(ToggleBtn, C.Border, 2)
hoverBtn(ToggleBtn, C.BG, C.Border, C.Border, C.BtnHText)

local guiVisible = true
ToggleBtn.MouseButton1Click:Connect(function()
	guiVisible = not guiVisible
	Main.Visible = guiVisible
	ToggleBtn.Text = guiVisible and "⚡" or "☰"
end)

-- ── DRAGGING ────────────────────────────────────

local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

TitleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		Main.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

-- ── CLOSE / MINIMIZE ────────────────────────────

CloseBtn.MouseButton1Click:Connect(function()
	TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset + 260,
		                     Main.Position.Y.Scale, Main.Position.Y.Offset + 280)
	}):Play()
	task.delay(0.3, function() ScreenGui:Destroy() end)
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		Content.Visible = false
		TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 520, 0, 44)}):Play()
	else
		Content.Visible = true
		TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 520, 0, 560)}):Play()
	end
end)

-- ── NEON PULSE ──────────────────────────────────

local t = 0
RunService.RenderStepped:Connect(function(dt)
	t += dt * 2
	mainStroke.Color = C.Border:Lerp(C.Purple, (math.sin(t) + 1) / 2)
end)

print("[Admin] GUI + Fly loaded.")
