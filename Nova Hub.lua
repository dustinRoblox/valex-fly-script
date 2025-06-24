-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

-- Create Window
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
        toggleSnappingAim(false)
        _G.InfiniteJumpEnabled = false
        print("UI Closed, values reset")
    end
})

-- ==== MAIN TAB ====
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local version = "v1.0.0"
local welcomeLabel = MainTab:AddLabel("Welcome to Nova Hub! Version: " .. version)

local newsContent = "No new announcements yet. Stay tuned!"
local newsParagraph = MainTab:AddParagraph("Announcements", newsContent)

function updateAnnouncements(newText)
    newsParagraph:Set("Announcements", newText)
end

-- ==== PLAYER TAB ====
local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Add a section to the Player tab so UI elements show up
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
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
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
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = value
        end
    end
})

-- Infinite Jump Toggle
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

-- Snapping Aim (visible camera snap)
_G.SnappingAimEnabled = false
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character.Humanoid.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)).Magnitude
                if dist < shortestDistance then
                    closestPlayer = player
                    shortestDistance = dist
                end
            end
        end
    end
    return closestPlayer
end

local mouseDown = false

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        mouseDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        mouseDown = false
    end
end)

local snappingConnection

local function onRenderStep()
    if _G.SnappingAimEnabled and mouseDown then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPos = target.Character.Head.Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, headPos)
        end
    end
end

function toggleSnappingAim(state)
    _G.SnappingAimEnabled = state
    if state then
        snappingConnection = RunService:BindToRenderStep("SnappingAim", Enum.RenderPriority.Camera.Value + 1, onRenderStep)
    else
        if snappingConnection then
            RunService:UnbindFromRenderStep("SnappingAim")
            snappingConnection = nil
        end
    end
end

PlayerTab:AddToggle({
    Name = "Snapping Aim",
    Default = false,
    Callback = function(state)
        toggleSnappingAim(state)
    end
})

-- Destroy UI Button
PlayerTab:AddButton({
    Name = "Destroy UI",
    Callback = function()
        OrionLib:Destroy()
    end
})

-- Initialize UI
OrionLib:Init()
