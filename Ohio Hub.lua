-- Ohio Hub | Stable Version
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
        -- Disconnect all active connections on close
        if speedConn then speedConn:Disconnect() speedConn = nil end
        if jumpConn then jumpConn:Disconnect() jumpConn = nil end
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if espConn then espConn:Disconnect() espConn = nil end

        -- Remove all ESP drawings
        for _, drawing in pairs(ESPDrawings) do
            drawing:Remove()
        end
        ESPDrawings = {}

        -- Reset walk/jump speed
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
            -- Reset CanCollide for noclip parts
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
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

-- Main Tab
mainTab:AddLabel("Ohio Hub • Version v1.1.0")
mainTab:AddParagraph("Credits", "Created by Dustin using Orion Library")

-- PLAYER TAB VARIABLES
local speedConn, jumpConn, noclipConn
local DesiredSpeed = 16
local DesiredJump = 50
local noclipEnabled = false

-- SPEED SLIDER
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
            -- Reset speed to 16
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
})

-- JUMP BOOST SLIDER
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
            -- Reset jump to 50
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = 50
            end
        end
    end
})

-- HEAL BUTTON
playerTab:AddButton({
    Name = "Heal",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local hm = char.Humanoid
            hm.Health = hm.MaxHealth
        end
    end
})

-- NOCLIP TOGGLE
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
            -- Reset CanCollide to true when noclip off
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

-- COMBAT TAB VARIABLES
local espConn
local ESPDrawings = {}

-- ESP TOGGLE
combatTab:AddToggle({
    Name = "ESP",
    Default = false,
    Save = true,
    Flag = "esp",
    Callback = function(enabled)
        if espConn then
            espConn:Disconnect()
            espConn = nil
            -- Remove all drawings
            for _, drawing in pairs(ESPDrawings) do
                drawing:Remove()
            end
            ESPDrawings = {}
        end

        if enabled then
            espConn = RunService.RenderStepped:Connect(function()
                -- debounce to reduce FPS load
                task.wait(0.05)

                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
                        local head = player.Character.Head
                        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            if not ESPDrawings[player] then
                                -- Create new Drawing objects
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

-- WALLBANG TOGGLE (Placeholder, no real bypass)
combatTab:AddToggle({
    Name = "Wallbang",
    Default = false,
    Save = true,
    Flag = "wallbang",
    Callback = function(enabled)
        -- No functional code because actual wallbang bypass needs exploit specifics
        print("Wallbang toggled:", enabled)
    end
})

-- UTILITY TAB QUIT BUTTON
utilityTab:AddButton({
    Name = "Quit",
    Callback = function()
        LocalPlayer:Kick("You quit Ohio Hub.")
    end
})

-- Init UI
OrionLib:Init()
