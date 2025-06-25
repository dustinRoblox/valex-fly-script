local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Window = OrionLib:MakeWindow({
    Name = "Minecraft Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MinecraftHubConfig",
    IntroEnabled = true,
    IntroText = "Welcome to Minecraft Hub!",
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998",
    CloseCallback = function()
        if speedConn then speedConn:Disconnect() speedConn = nil end
        if jumpConn then jumpConn:Disconnect() jumpConn = nil end
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if espConn then espConn:Disconnect() espConn = nil end
        if flyConn then flyConn:Disconnect() flyConn = nil end

        for _, drawing in pairs(ESPDrawings) do
            drawing:Remove()
        end
        ESPDrawings = {}

        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
            char.Humanoid.JumpPower = 50
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
})

-- Tabs
local mainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})
local playerTab = Window:MakeTab({Name = "Players", Icon = "rbxassetid://4483345998"})
local combatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})
local utilityTab = Window:MakeTab({Name = "Utility", Icon = "rbxassetid://4483345998"})

-- Main tab content
mainTab:AddLabel("Minecraft Hub • Version v1.0.0")
mainTab:AddParagraph("Credits", "Made by Dustin. Inspired by Minecraft mechanics.")

-- Player tab variables
local DesiredSpeed = 16
local DesiredJump = 50
local speedConn, jumpConn, noclipConn, flyConn, espConn
local noclipEnabled = false
local flying = false
local flyBodyVelocity
local flyBodyGyro
local ESPDrawings = {}
local flySpeed = 50

-- Speed Slider
playerTab:AddSlider({
    Name = "Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    Save = true,
    Flag = "speed",
    Callback = function(v)
        DesiredSpeed = v
        if speedConn then speedConn:Disconnect() speedConn = nil end
        speedConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = DesiredSpeed
            end
        end)
    end
})

-- Jump Boost Slider
playerTab:AddSlider({
    Name = "Jump Boost",
    Min = 50,
    Max = 100,
    Default = 50,
    Increment = 1,
    Save = true,
    Flag = "jump",
    Callback = function(v)
        DesiredJump = v
        if jumpConn then jumpConn:Disconnect() jumpConn = nil end
        jumpConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.JumpPower = DesiredJump
            end
        end)
    end
})

-- Heal Button
playerTab:AddButton({
    Name = "Heal",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.Health = char.Humanoid.MaxHealth
        end
    end
})

-- Noclip Toggle
playerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Save = true,
    Flag = "noclip",
    Callback = function(state)
        noclipEnabled = state
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end

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

-- Fly Toggle
playerTab:AddToggle({
    Name = "Fly",
    Default = false,
    Save = true,
    Flag = "fly",
    Callback = function(state)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        flying = state

        if flying and hrp then
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            flyBodyVelocity.Parent = hrp

            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            flyBodyGyro.Parent = hrp

            flyConn = RunService.Heartbeat:Connect(function()
                local velocity = Vector3.new()
                local camCF = Camera.CFrame

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    velocity = velocity + camCF.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    velocity = velocity - camCF.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    velocity = velocity - camCF.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    velocity = velocity + camCF.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    velocity = velocity + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    velocity = velocity - Vector3.new(0, 1, 0)
                end

                if velocity.Magnitude > 0 then
                    flyBodyVelocity.Velocity = velocity.Unit * flySpeed
                else
                    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end

                flyBodyGyro.CFrame = camCF
            end)
        else
            if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
            if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
            if flyConn then flyConn:Disconnect() flyConn = nil end
        end
    end
})

-- Combat Tab --

combatTab:AddToggle({
    Name = "ESP",
    Default = false,
    Save = true,
    Flag = "esp",
    Callback = function(enabled)
        if espConn then
            espConn:Disconnect()
            espConn = nil
            for _, drawing in pairs(ESPDrawings) do
                drawing:Remove()
            end
            ESPDrawings = {}
        end

        if enabled then
            espConn = RunService.RenderStepped:Connect(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
                        local head = player.Character.Head
                        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            if not ESPDrawings[player] then
                                local box = Drawing.new("Square")
                                box.Visible = true
                                box.Color = Color3.fromRGB(0, 255, 0) -- Minecraft green vibe
                                box.Thickness = 2
                                box.Filled = false
                                ESPDrawings[player] = box
                            end
                            local box = ESPDrawings[player]
                            local size = 50
                            box.Size = Vector2.new(size, size)
                            box.Position = Vector2.new(pos.X - size / 2, pos.Y - size / 2)
                            box.Visible = true
                        else
                            if ESPDrawings[player] then
                                ESPDrawings[player].Visible = false
                            end
                        end
                    else
                        if ESPDrawings[player] then
                            ESPDrawings[player]:Remove()
                            ESPDrawings[player] = nil
                        end
                    end
                end
            end)
        end
    end
})

combatTab:AddToggle({
    Name = "Wallbang",
    Default = false,
    Save = true,
    Flag = "wallbang",
    Callback = function(enabled)
        -- Wallbang needs game/exploit-specific implementation
        print("Wallbang toggled:", enabled)
    end
})

-- Utility Tab --

utilityTab:AddButton({
    Name = "Quit",
    Callback = function()
        LocalPlayer:Kick("You quit Minecraft Hub.")
    end
})

OrionLib:Init()
