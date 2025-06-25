--// Universal Hub - Polished Version (Dark Theme + Sound FX)

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Sound FX Helper
local function playSound(id)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. id
	sound.Volume = 1
	sound.Parent = SoundService
	sound:Play()
	game.Debris:AddItem(sound, 3)
end

-- Cleanup Trackers
local speedConn, jumpConn, noclipConn, espConn
local ESPDrawings = {}

-- Hub Window
local Window = OrionLib:MakeWindow({
	Name = "Universal Hub",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "UniversalHub",
	IntroText = "Universal Hub • v1.0",
	IntroIcon = "rbxassetid://4483345998",
	Icon = "rbxassetid://4483345998",
	Theme = {
		Main = Color3.fromRGB(20, 20, 20),
		TabBackground = Color3.fromRGB(30, 30, 30),
		SectionBackground = Color3.fromRGB(25, 25, 25),
		Text = Color3.fromRGB(200, 200, 200),
		Accent = Color3.fromRGB(0, 120, 255)
	},
	CloseCallback = function()
		if speedConn then speedConn:Disconnect() end
		if jumpConn then jumpConn:Disconnect() end
		if noclipConn then noclipConn:Disconnect() end
		if espConn then espConn:Disconnect() end
		for _, box in pairs(ESPDrawings) do box:Remove() end
	end
})

-- Tabs
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})
local PlayersTab = Window:MakeTab({Name = "Players", Icon = "rbxassetid://4483345998"})
local CombatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})
local UtilityTab = Window:MakeTab({Name = "Utility", Icon = "rbxassetid://4483345998"})

-- Main Tab
MainTab:AddLabel("Universal Hub • v1.0")
MainTab:AddParagraph("Credits", "Scripted by ChatGPT & Dustin")

-- Players Tab
PlayersTab:AddSlider({
	Name = "Speed Boost",
	Min = 16,
	Max = 100,
	Default = 16,
	Callback = function(v)
		playSound("9118823102")
		if speedConn then speedConn:Disconnect() end
		speedConn = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("Humanoid") then
				char.Humanoid.WalkSpeed = v
			end
		end)
	end
})

PlayersTab:AddSlider({
	Name = "Jump Boost",
	Min = 50,
	Max = 100,
	Default = 50,
	Callback = function(v)
		playSound("9118823102")
		if jumpConn then jumpConn:Disconnect() end
		jumpConn = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("Humanoid") then
				char.Humanoid.JumpPower = v
			end
		end)
	end
})

PlayersTab:AddToggle({
	Name = "Noclip",
	Default = false,
	Callback = function(state)
		playSound("9118823102")
		if noclipConn then noclipConn:Disconnect() end
		if state then
			noclipConn = RunService.Stepped:Connect(function()
				local char = LocalPlayer.Character
				if char then
					for _, part in pairs(char:GetChildren()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
				end
			end)
		else
			local char = LocalPlayer.Character
			if char then
				for _, part in pairs(char:GetChildren()) do
					if part:IsA("BasePart") then
						part.CanCollide = true
					end
				end
			end
		end
	end
})

-- Combat Tab
CombatTab:AddToggle({
	Name = "ESP",
	Default = false,
	Callback = function(state)
		playSound("9118823102")
		if espConn then espConn:Disconnect() end
		for _, d in pairs(ESPDrawings) do d:Remove() end
		ESPDrawings = {}

		if state then
			espConn = RunService.RenderStepped:Connect(function()
				for _, p in pairs(Players:GetPlayers()) do
					if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
						local head = p.Character.Head
						local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
						if onScreen then
							if not ESPDrawings[p] then
								local box = Drawing.new("Square")
								box.Color = Color3.new(1, 0, 0)
								box.Thickness = 2
								box.Filled = false
								ESPDrawings[p] = box
							end
							local box = ESPDrawings[p]
							box.Position = Vector2.new(pos.X - 25, pos.Y - 25)
							box.Size = Vector2.new(50, 50)
							box.Visible = true
						else
							if ESPDrawings[p] then ESPDrawings[p].Visible = false end
						end
					end
				end
			end)
		end
	end
})

-- Utility Tab
UtilityTab:AddDropdown({
	Name = "Teleport To Player",
	Options = {},
	Callback = function(name)
		playSound("12222005")
		local target = Players:FindFirstChild(name)
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character:PivotTo(target.Character.HumanoidRootPart.CFrame)
		end
	end
})

UtilityTab:AddButton({
	Name = "Invisibility",
	Callback = function()
		playSound("138186576")
		local char = LocalPlayer.Character
		if char then
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") or v:IsA("Decal") then
					v.Transparency = 1
				end
			end
			char.Head.face.Transparency = 1
		end
	end
})

UtilityTab:AddButton({
	Name = "Quit Hub",
	Callback = function()
		playSound("12222005")
		LocalPlayer:Kick("You left Universal Hub.")
	end
})

-- Auto-refresh dropdown names
spawn(function()
	while task.wait(5) do
		local names = {}
		for _, p in pairs(Players:GetPlayers()) do
			table.insert(names, p.Name)
		end
		pcall(function()
			UtilityTab.Flags["Teleport To Player"]:Refresh(names)
		end)
	end
end)

OrionLib:Init()
