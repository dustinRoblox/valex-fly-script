-- Universal Hub | Roblox | Using OrionLib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables
local speedConn, jumpConn, noclipConn, flyConn, espConn, clickTPConn
local ESPDrawings = {}
local DesiredSpeed = 16
local DesiredJump = 50
local noclipEnabled = false
local invisEnabled = false
local clickTPEnabled = false

-- Window
local Window = OrionLib:MakeWindow({
    Name = "Universal Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "UniversalHub",
    IntroEnabled = true,
    IntroText = "Loading Universal Hub...",
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998",
    CloseCallback = function()
        for _, conn in pairs({speedConn, jumpConn, noclipConn, flyConn, espConn, clickTPConn}) do
            if conn then conn:Disconnect() end
        end
        for _, d in pairs(ESPDrawings) do
            d:Remove()
        end
        ESPDrawings = {}
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
            char.Humanoid.JumpPower = 50
        end
    end
})

-- Tabs
local mainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})
local playerTab = Window:MakeTab({Name = "Players", Icon = "rbxassetid://4483345998"})
local combatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})
local utilityTab = Window:MakeTab({Name = "Utility", Icon = "rbxassetid://4483345998"})

-- Main Info
mainTab:AddLabel("Universal Hub v1.0")
mainTab:AddParagraph("Credits", "Made by Dustin ✨")

-- Speed
playerTab:AddSlider({
    Name = "Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    Callback = function(v)
        DesiredSpeed = v
        if speedConn then speedConn:Disconnect() end
        speedConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = DesiredSpeed
            end
        end)
    end
})

-- Jump Boost
playerTab:AddSlider({
    Name = "Jump Boost",
    Min = 50,
    Max = 100,
    Default = 50,
    Increment = 1,
    Callback = function(v)
        DesiredJump = v
        if jumpConn then jumpConn:Disconnect() end
        jumpConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.JumpPower = DesiredJump
            end
        end)
    end
})

-- Invisibility
playerTab:AddToggle({
    Name = "Invisibility",
    Default = false,
    Callback = function(state)
        invisEnabled = state
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = state and 1 or 0
                    part.CanCollide = not state
                end
            end
        end
    end
})

-- Noclip
playerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
        noclipEnabled = state
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

-- ESP
combatTab:AddToggle({
    Name = "ESP (Boxes)",
    Default = false,
    Callback = function(enabled)
        if espConn then
            espConn:Disconnect()
            espConn = nil
            for _, d in pairs(ESPDrawings) do
                d:Remove()
            end
            ESPDrawings = {}
        end

        if enabled then
            espConn = RunService.RenderStepped:Connect(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
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
                    end
                end
            end)
        end
    end
})

-- Click to Teleport
utilityTab:AddToggle({
    Name = "Click To Teleport",
    Default = false,
    Callback = function(state)
        clickTPEnabled = state
        if clickTPConn then clickTPConn:Disconnect() end
        if state then
            clickTPConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mouse = LocalPlayer:GetMouse()
                    local pos = mouse.Hit and mouse.Hit.Position
                    if pos then
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                        end
                    end
                end
            end)
        end
    end
})

-- Quit Button
utilityTab:AddButton({
    Name = "Quit Hub",
    Callback = function()
        LocalPlayer:Kick("You quit Universal Hub.")
    end
})

-- Init UI
OrionLib:Init()
-
