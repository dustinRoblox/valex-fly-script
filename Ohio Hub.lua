-- Ohio Hub | Stable Version w/ Heal Fix & Infinite Money
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

local speedConn, jumpConn, noclipConn, infMoneyConn
local DesiredSpeed = 16
local DesiredJump = 50
local noclipEnabled = false
local ESPDrawings = {}

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

local infMoneyEnabled = false
playerTab:AddToggle({
    Name = "Infinite Money",
    Default = false,
    Save = true,
    Flag = "infmoney",
    Callback = function(state)
        infMoneyEnabled = state
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
