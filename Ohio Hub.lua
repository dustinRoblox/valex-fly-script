-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Create Window
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
        -- Reset player to normal on close
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
        -- Stop bypass loop if exists
        if SpeedBypassConnection then
            SpeedBypassConnection:Disconnect()
            SpeedBypassConnection = nil
        end
        print("Ohio Hub closed, player reset")
    end
})

-- ==== MAIN TAB ====
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
MainTab:AddSection({Name = "Info"})
MainTab:AddLabel("Ohio Hub Version: v1.0.0")
MainTab:AddParagraph("Credits", "Made by Dustin | Powered by Orion Library")

-- ==== PLAYERS TAB ====
local PlayerTab = Window:MakeTab({
    Name = "Players",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
PlayerTab:AddSection({Name = "Player Mods"})

-- Speed slider variables
local DesiredSpeed = 16
local SpeedBypassConnection

PlayerTab:AddSlider({
    Name = "Speed",
    Min = 16,
    Max = 250,
    Default = 16,
    Increment = 1,
    Color = Color3.fromRGB(0, 255, 0),
    ValueName = "WalkSpeed",
    Callback = function(value)
        DesiredSpeed = value
        -- Apply speed instantly
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
        -- If bypass loop not running, start it
        if not SpeedBypassConnection then
            SpeedBypassConnection = RunService.Heartbeat:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = DesiredSpeed
                end
            end)
        end
    end
})

-- Jump boost slider
PlayerTab:AddSlider({
    Name = "Jump Boost",
    Min = 50,
    Max = 200,
    Default = 50,
    Increment = 5,
    Color = Color3.fromRGB(255, 255, 0),
    ValueName = "JumpPower",
    Callback = function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end
})

-- ==== UTILITY TAB ====
local UtilityTab = Window:MakeTab({
    Name = "Utility",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
UtilityTab:AddSection({Name = "Game Controls"})

UtilityTab:AddButton({
    Name = "Quit Game",
    Callback = function()
        print("Quitting game...")
        -- Kick the player to simulate quitting game
        LocalPlayer:Kick("Quit button pressed. Goodbye!")
    end
})

-- Initialize UI
OrionLib:Init()
