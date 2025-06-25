-- Ohio Hub | Complete Stable Script w/ Flying
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Window = OrionLib:MakeWindow({
    Name = "Ohio Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OhioHubConfig",
    IntroEnabled = true,
    IntroText = "Welcome to Ohio Hub!",
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998",
    CloseCallback = function()
        if speedConn then speedConn:Disconnect() speedConn = nil end
        if jumpConn then jumpConn:Disconnect() jumpConn = nil end
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if espConn then espConn:Disconnect() espConn = nil end
        if infMoneyConn then infMoneyConn:Disconnect() infMoneyConn = nil end
        if flyConn then flyConn:Disconnect() flyConn = nil end

        for _, drawing in pairs(ESPDrawings) do
            drawing:Remove()
        end
        ESPDrawings = {}

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
})

local mainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})
local playerTab = Window:MakeTab({Name = "Players", Icon = "rbxassetid://4483345998"})
local combatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})
local utilityTab = Window:MakeTab({Name = "Utility", Icon = "rbxassetid://4483345998"})

mainTab:AddLabel("Ohio Hub • Version v1.1.0")
mainTab:AddParagraph("Credits", "Created by Dustin using Orion Library")

local speedConn, jumpConn, noclipConn, infMoneyConn, espConn, flyConn
local DesiredSpeed = 16
local DesiredJump = 50
local noclipEnabled = false
local ESPDrawings = {}
local flying = false
local flyBodyVelocity
local flyBodyGyro

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
        if v > 16 then
            speedConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = DesiredSpeed
                end
            end)
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
        end
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
        if v > 50 then
            jumpConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.JumpPower = DesiredJump
                end
            end)
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = 50
            end
        end
    end
})

-- Heal Button
playerTab:AddButton({
    Name = "Heal",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local hm = char.Humanoid
            hm.Health = hm.MaxHealth
            spawn(function()
                local endTime = tick() + 5
                while tick() < endTime do
                    if hm.Health < hm.MaxHealth then
                        hm.Health = hm.MaxHealth
                    end
                    wait(0.5)
                end
            end)
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
        if noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
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

-- Infinite Money Toggle
playerTab:AddToggle({
    Name = "Infinite Money",
    Default = false,
    Save = true,
    Flag = "infmoney",
    Callback = function(state)
        if infMoneyConn then
            infMoneyConn:Disconnect()
            infMoneyConn = nil
        end
        if state then
            infMoneyConn = RunService.Heartbeat:Connect(function()
                local stats = LocalPlayer:FindFirstChild("leaderstats")
                if stats then
                    local cash = stats:FindFirstChild("Cash")
                    if cash and cash.Value < 1e9 then
                        cash.Value = 1e9
                    end
                end
            end)
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
            flyBodyVelocity.Velocity = Vector3.new(0,0,0)
            flyBodyVelocity.Parent = hrp

            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            flyBodyGyro.Parent = hrp

            local userInputService = game:GetService("UserInputService")

            local function flyLoop()
                local velocity = Vector3.new()
                local camCF = workspace.CurrentCamera.CFrame
                local speed = flySpeed

                if userInputService:IsKeyDown(Enum.KeyCode.W) then
                    velocity = velocity + camCF.LookVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.S) then
                    velocity = velocity - camCF.LookVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.A) then
                    velocity = velocity - camCF.RightVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.D) then
                    velocity = velocity + camCF.RightVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.Space) then
                    velocity = velocity + Vector3.new(0,1,0)
                end
                if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    velocity = velocity - Vector3.new(0,1,0)
                end

                if velocity.Magnitude > 0 then
                    flyBodyVelocity.Velocity = velocity.Unit * flySpeed
                else
                    flyBodyVelocity.Velocity = Vector3.new(0,0,0)
                end

                flyBodyGyro.CFrame = camCF
            end

            flyConn = RunService.Heartbeat:Connect(flyLoop)
        else
            if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
            if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
            if flyConn then flyConn:Disconnect() flyConn = nil end
        end
    end
})

-- Combat Tab

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
                task.wait(0.05)
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
                        local head = player.Character.Head
                        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            if not ESPDrawings[player] then
                                local box = Drawing.new("Square")
                                box.Visible = true
                                box.Color = Color3.new(1, 0, 0)
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
        print("Wallbang toggled:", enabled)
        -- Placeholder: needs exploit-specific bypass
    end
})

-- Utility Tab

utilityTab:AddButton({
    Name = "Quit",
    Callback = function()
        LocalPlayer:Kick("You quit Ohio Hub.")
    end
})

OrionLib:Init()
