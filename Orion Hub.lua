-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

-- Create the Window
local Window = OrionLib:MakeWindow({
    Name = "Orion Speed Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SpeedHubConfig",
    IntroEnabled = true,
    IntroText = "Welcome to Orion Speed Hub!",
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998",
    CloseCallback = function()
        print("UI Closed")
    end
})

-- Create Main Tab
local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Create Speed Controls Section
Tab:AddSection({
    Name = "Player Controls"
})

-- Speed Slider (0 to 100)
local SpeedSlider = Tab:AddSlider({
    Name = "Player Speed",
    Min = 0,
    Max = 100,
    Default = 16,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 1,
    ValueName = "WalkSpeed",
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = Value
        end
    end
})

-- Jump Power Slider
Tab:AddSlider({
    Name = "Jump Power",
    Min = 0,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 0),
    Increment = 5,
    ValueName = "JumpPower",
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = Value
        end
    end
})

-- Infinite Jump Toggle
Tab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(enabled)
        local UIS = game:GetService("UserInputService")
        UIS.JumpRequest:Connect(function()
            if enabled then
                local player = game.Players.LocalPlayer
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
})

-- Destroy UI Button
Tab:AddButton({
    Name = "Destroy UI",
    Callback = function()
        OrionLib:Destroy()
    end
})

-- Final Init (required)
OrionLib:Init()
