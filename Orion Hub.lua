-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

-- Create the Window
local Window = OrionLib:MakeWindow({
    Name = "Orion Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OrionHubConfig",
    IntroEnabled = true,
    IntroText = "Welcome to Orion Hub!",
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

-- Create Section
local Section = Tab:AddSection({
    Name = "Section"
})

-- Notification
OrionLib:MakeNotification({
    Name = "Orion Hub Loaded",
    Content = "Everything is working 🔥",
    Image = "rbxassetid://4483345998",
    Time = 5
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

-- Reset Speed Button
Tab:AddButton({
    Name = "Reset Speed to 16",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
        end
        SpeedSlider:Set(16)
    end
})

-- Button
Tab:AddButton({
    Name = "Button!",
    Callback = function()
        print("button pressed")
    end
})

-- Toggle
Tab:AddToggle({
    Name = "This is a toggle!",
    Default = false,
    Callback = function(Value)
        print(Value)
    end
})

-- Color Picker
Tab:AddColorpicker({
    Name = "Colorpicker",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        print(Value)
    end
})

-- Slider (bananas)
Tab:AddSlider({
    Name = "Slider",
    Min = 0,
    Max = 20,
    Default = 5,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "bananas",
    Callback = function(Value)
        print(Value)
    end
})

-- Label
local CoolLabel = Tab:AddLabel("Label")
CoolLabel:Set("Label New!")

-- Paragraph
local CoolParagraph = Tab:AddParagraph("Paragraph", "Paragraph Content")
CoolParagraph:Set("Paragraph New!", "New Paragraph Content!")

-- Textbox
Tab:AddTextbox({
    Name = "Textbox",
    Default = "default box input",
    TextDisappear = true,
    Callback = function(Value)
        print(Value)
    end
})

-- Keybind
Tab:AddBind({
    Name = "Bind",
    Default = Enum.KeyCode.E,
    Hold = false,
    Callback = function()
        print("press")
    end
})

-- Dropdown
local Dropdown = Tab:AddDropdown({
    Name = "Dropdown",
    Default = "1",
    Options = {"1", "2"},
    Callback = function(Value)
        print(Value)
    end
})

-- Flags Example
Tab:AddToggle({
    Name = "Flag Toggle",
    Default = true,
    Save = true,
    Flag = "toggle"
})
print(OrionLib.Flags["toggle"].Value)

-- Final Init (required)
OrionLib:Init()

-- Destroy the UI
-- OrionLib:Destroy()
