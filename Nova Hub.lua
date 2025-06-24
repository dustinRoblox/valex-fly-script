-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

-- Create the Window
local Window = OrionLib:MakeWindow({
    Name = "Nova Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SpeedHubConfig",
    IntroEnabled = true,
    IntroText = "Welcome to Nova Hub!",
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998",
    CloseCallback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
            player.Character.Humanoid.JumpPower = 50
        end
        if InfiniteJumpConnection then
            InfiniteJumpConnection:Disconnect()
            InfiniteJumpConnection = nil
        end
        _G.InfiniteJumpEnabled = false
        _G.SilentAimbotEnabled = false
        print("UI Closed")
    end
})

-- Create Main Tab (empty)
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Create Player Tab
local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

PlayerTab:AddSection({
    Name = "Player Controls"
})

-- Speed Slider
PlayerTab:AddSlider({
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
PlayerTab:AddSlider({
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

-- Infinite Jump
_G.InfiniteJumpEnabled = false
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local InfiniteJumpConnection

PlayerTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(enabled)
        _G.InfiniteJumpEnabled = enabled

        if enabled and not InfiniteJumpConnection then
            InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                if _G.InfiniteJumpEnabled then
                    local player = Players.LocalPlayer
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        elseif not enabled and InfiniteJumpConnection then
            InfiniteJumpConnection:Disconnect()
            InfiniteJumpConnection = nil
        end
    end
})

-- Silent Aimbot
_G.SilentAimbotEnabled = false
PlayerTab:AddToggle({
    Name = "Silent Aimbot",
    Default = false,
    Callback = function(state)
        _G.SilentAimbotEnabled = state
    end
})

local Camera = workspace.CurrentCamera
local Mouse = Players.LocalPlayer:GetMouse()

local function getClosestToCrosshair()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local pos = player.Character.HumanoidRootPart.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if onScreen and dist < shortestDistance then
                closestPlayer = player
                shortestDistance = dist
            end
        end
    end
    return closestPlayer
end

local mt = getrawmetatable(game)
local backup = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if _G.SilentAimbotEnabled and tostring(self) == "Hit" and method == "FireServer" then
        local target = getClosestToCrosshair()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            args[1] = target.Character.Head.Position
            return backup(self, unpack(args))
        end
    end
    return backup(self, ...)
end)

setreadonly(mt, true)

-- Destroy UI
PlayerTab:AddButton({
    Name = "Destroy UI",
    Callback = function()
        OrionLib:Destroy()
    end
})

-- Init
OrionLib:Init()
