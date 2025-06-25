-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- WINDOW
local Window = OrionLib:MakeWindow({
    Name = "Ohio Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OhioHubConfig",
    IntroEnabled = true,
    IntroText = "Welcome to Ohio Hub!",
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998"
})

-- MAIN TAB
local mainTab = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://4483345998" })
mainTab:AddLabel("Ohio Hub • Version v1.1.0")
mainTab:AddParagraph("Credits", "Created by Dustin using Orion Library")

-- PLAYERS TAB
local playerTab = Window:MakeTab({ Name = "Players", Icon = "rbxassetid://4483345998" })

-- Speed Bypass
local DesiredSpeed = 16
local speedConn
playerTab:AddSlider({
    Name = "Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    Callback = function(v)
        DesiredSpeed = v
        if v > 16 and not speedConn then
            speedConn = RunService.Heartbeat:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = DesiredSpeed
                end
            end)
        elseif v == 16 and speedConn then
            speedConn:Disconnect()
            speedConn = nil
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
})

-- Jump Boost
local DesiredJump = 50
local jumpConn
playerTab:AddSlider({
    Name = "Jump Boost",
    Min = 50,
    Max = 100,
    Default = 50,
    Increment = 1,
    Callback = function(v)
        DesiredJump = v
        if v > 50 and not jumpConn then
            jumpConn = RunService.Heartbeat:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.JumpPower = DesiredJump
                end
            end)
        elseif v == 50 and jumpConn then
            jumpConn:Disconnect()
            jumpConn = nil
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = 50
            end
        end
    end
})

-- Heal
playerTab:AddButton({
    Name = "Heal",
    Callback = function()
        local hm = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hm then
            hm.Health = hm.MaxHealth
        end
    end
})

-- Noclip
local noclipConn
playerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
        if state and not noclipConn then
            noclipConn = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        elseif not state and noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
    end
})

-- COMBAT TAB
local combatTab = Window:MakeTab({ Name = "Combat", Icon = "rbxassetid://4483345998" })

-- ESP
local ESPConn
local function createESP()
    if ESPConn then return end
    ESPConn = RunService.RenderStepped:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    -- draw boxes/text here or use Drawing API
                end
            end
        end
        wait(0.05)
    end)
end

local function destroyESP()
    if ESPConn then
        ESPConn:Disconnect()
        ESPConn = nil
    end
end

combatTab:AddToggle({
    Name = "ESP",
    Default = false,
    Callback = function(val)
        if val then
            createESP()
        else
            destroyESP()
        end
    end
})

-- Wallbang (placeholder for raycast editing or remote trigger bypass)
combatTab:AddToggle({
    Name = "Wallbang",
    Default = false,
    Callback = function(enabled)
        print("Wallbang toggled:", enabled)
        -- integrate with actual raycast or hitbox bypass if possible
    end
})

-- UTILITY TAB
local utilTab = Window:MakeTab({ Name = "Utility", Icon = "rbxassetid://4483345998" })
utilTab:AddButton({
    Name = "Quit",
    Callback = function()
        LocalPlayer:Kick("Quit button pressed from Ohio Hub.")
    end
})

-- INIT
OrionLib:Init()

-- CLEANUP
Window:MakeNotification({
    Name = "Ohio Hub Loaded",
    Content = "Script ready!",
    Time = 4
})
