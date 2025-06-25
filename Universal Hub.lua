-- Universal Hub using OrionLib --

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Connections
local speedConn, jumpConn, noclipConn, espConn = nil, nil, nil, nil
local noclipEnabled = false
local ESPDrawings = {}

local function cleanup()
    if speedConn then speedConn:Disconnect() speedConn = nil end
    if jumpConn then jumpConn:Disconnect() jumpConn = nil end
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if espConn then espConn:Disconnect() espConn = nil end

    for _, box in pairs(ESPDrawings) do
        box:Remove()
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

local Window = OrionLib:MakeWindow({
    Name = "Universal Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "UniversalHubConfig",
    IntroEnabled = true,
    IntroText = "Universal Hub Loaded!",
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998",
    CloseCallback = cleanup
})

-- Tabs
local mainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})
local playerTab = Window:MakeTab({Name = "Players", Icon = "rbxassetid://4483345998"})
local combatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})
local utilityTab = Window:MakeTab({Name = "Utility", Icon = "rbxassetid://4483345998"})

-- Main Tab
mainTab:AddLabel("Universal Hub v1.0")
mainTab:AddParagraph("Credits", "Made by Dustin with OrionLib")

-- Player Tab
playerTab:AddSlider({
    Name = "Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    Save = true,
    Flag = "speed",
    Callback = function(v)
        if speedConn then speedConn:Disconnect() end
        speedConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = v
            end
        end)
    end
})

playerTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 100,
    Default = 50,
    Increment = 1,
    Save = true,
    Flag = "jump",
    Callback = function(v)
        if jumpConn then jumpConn:Disconnect() end
        jumpConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.JumpPower = v
            end
        end)
    end
})

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
            for _, box in pairs(ESPDrawings) do
                box:Remove()
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
                                box.Color = Color3.fromRGB(0, 255, 0)
                                box.Thickness = 1
                                box.Filled = false
                                ESPDrawings[player] = box
                            end
                            local size = 50
                            ESPDrawings[player].Size = Vector2.new(size, size)
                            ESPDrawings[player].Position = Vector2.new(pos.X - size / 2, pos.Y - size / 2)
                            ESPDrawings[player].Visible = true
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

-- Utility Tab
utilityTab:AddTextbox({
    Name = "Teleport to Player",
    Default = "",
    Callback = function(input)
        local playerName = input:lower()
        local target = nil
        for _, player in pairs(Players:GetPlayers()) do
            if player.Name:lower():find(playerName) then
                target = player
                break
            end
        end

        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:MoveTo(target.Character.HumanoidRootPart.Position)
        else
            OrionLib:MakeNotification({
                Name = "Teleport Failed",
                Content = "Player not found or not in game.",
                Time = 3,
                Image = "rbxassetid://4483345998"
            })
        end
    end
})

utilityTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId)
    end
})

utilityTab:AddButton({
    Name = "Reset Character",
    Callback = function()
        if LocalPlayer.Character then
            LocalPlayer.Character:BreakJoints()
        end
    end
})

utilityTab:AddButton({
    Name = "Quit Hub",
    Callback = function()
        LocalPlayer:Kick("You have exited the Universal Hub.")
    end
})

-- Initialize UI
OrionLib:Init()
