--// Orion Universal Hub
--// Works in most Roblox games
--// UI Library
local OrionLib = loadstring(game:HttpGet(("https://raw.githubusercontent.com/shlexware/Orion/main/source")))()

--// Window
local Window = OrionLib:MakeWindow({
	Name = "Universal Orion Hub",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "UniversalOrion"
})

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Character vars
local function getChar()
	return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

--// =========================
--// MAIN TAB
--// =========================
local MainTab = Window:MakeTab({
	Name = "Main",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

MainTab:AddSlider({
	Name = "WalkSpeed",
	Min = 16,
	Max = 200,
	Default = 16,
	Color = Color3.fromRGB(0,255,255),
	Increment = 1,
	ValueName = "Speed",
	Callback = function(Value)
		getChar():FindFirstChildOfClass("Humanoid").WalkSpeed = Value
	end
})

MainTab:AddSlider({
	Name = "JumpPower",
	Min = 50,
	Max = 300,
	Default = 50,
	Color = Color3.fromRGB(255,0,255),
	Increment = 5,
	ValueName = "Power",
	Callback = function(Value)
		getChar():FindFirstChildOfClass("Humanoid").JumpPower = Value
	end
})

MainTab:AddButton({
	Name = "Reset Character",
	Callback = function()
		getChar():BreakJoints()
	end
})

--// =========================
--// MOVEMENT TAB
--// =========================
local MovementTab = Window:MakeTab({
	Name = "Movement",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- Fly
local flying = false
local FlySpeed = 2

MovementTab:AddToggle({
	Name = "Fly",
	Default = false,
	Callback = function(Value)
		flying = Value
		local char = getChar()
		local hrp = char:WaitForChild("HumanoidRootPart")
		local bv = Instance.new("BodyVelocity", hrp)
		local bg = Instance.new("BodyGyro", hrp)

		bv.Velocity = Vector3.new(0,0,0)
		bv.MaxForce = Vector3.new(9e9,9e9,9e9)
		bg.MaxTorque = Vector3.new(9e9,9e9,9e9)

		while flying do
			RunService.RenderStepped:Wait()
			bg.CFrame = Camera.CFrame
			bv.Velocity = Camera.CFrame.LookVector * (FlySpeed * 25)
		end

		bv:Destroy()
		bg:Destroy()
	end
})

MovementTab:AddSlider({
	Name = "Fly Speed",
	Min = 1,
	Max = 10,
	Default = 2,
	Increment = 1,
	ValueName = "Speed",
	Callback = function(Value)
		FlySpeed = Value
	end
})

-- Noclip
local noclip = false
MovementTab:AddToggle({
	Name = "Noclip",
	Default = false,
	Callback = function(Value)
		noclip = Value
	end
})

RunService.Stepped:Connect(function()
	if noclip then
		for _,v in pairs(getChar():GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

--// =========================
--// VISUALS TAB
--// =========================
local VisualTab = Window:MakeTab({
	Name = "Visuals",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local ESPEnabled = false
local ESPColor = Color3.fromRGB(255,0,0)

VisualTab:AddToggle({
	Name = "Player ESP",
	Default = false,
	Callback = function(Value)
		ESPEnabled = Value
	end
})

RunService.RenderStepped:Connect(function()
	if not ESPEnabled then return end

	for _,player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			if not player.Character.Head:FindFirstChild("ESP") then
				local billboard = Instance.new("BillboardGui", player.Character.Head)
				billboard.Name = "ESP"
				billboard.Size = UDim2.new(0,100,0,40)
				billboard.AlwaysOnTop = true

				local text = Instance.new("TextLabel", billboard)
				text.Size = UDim2.new(1,0,1,0)
				text.BackgroundTransparency = 1
				text.Text = player.Name
				text.TextColor3 = ESPColor
				text.TextStrokeTransparency = 0
				text.TextScaled = true
			end
		end
	end
end)

--// =========================
--// MISC TAB
--// =========================
local MiscTab = Window:MakeTab({
	Name = "Misc",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- Anti AFK
MiscTab:AddButton({
	Name = "Anti AFK",
	Callback = function()
		local vu = game:GetService("VirtualUser")
		LocalPlayer.Idled:Connect(function()
			vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
			wait(1)
			vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		end)
	end
})

-- Rejoin
MiscTab:AddButton({
	Name = "Rejoin Server",
	Callback = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
	end
})

--// Init
OrionLib:Init()
