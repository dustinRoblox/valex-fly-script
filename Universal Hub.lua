-- Universal Hub | NovaRise Studios
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local Window = OrionLib:MakeWindow({
    Name = "Universal Hub | NovaRise Studios",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "UniversalHubConfig",
    IntroEnabled = true,
    IntroText = "NovaRise Studios Presents...",
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998"
})

-- Tabs
local mainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})
local playerTab = Window:MakeTab({Name = "Players", Icon = "rbxassetid://4483345998"})
local combatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})
local utilityTab = Window:MakeTab({Name = "Utility", Icon = "rbxassetid://4483345998"})

-- Main Tab
mainTab:AddLabel("Welcome to Universal Hub")
mainTab:AddLabel("Powered by NovaRise Studios")
mainTab:AddLabel("Version: v1.0.0")

-- Player Tab
local DesiredSpeed = 16
local DesiredJump = 50
local noclipConn
local speedConn, jumpConn

playerTab:AddSlider({
    Name = "Speed Boost",
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

playerTab:AddSlider({
    Name = "Jump Power",
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

playerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
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

-- Combat Tab
local tracerConn = nil
local tracerLines = {}

combatTab:AddToggle({
    Name = "Charms ESP",
    Default = false,
    Callback = function(state)
        if tracerConn then tracerConn:Disconnect() end
        for _, line in pairs(tracerLines) do line:Remove() end
        tracerLines = {}

        if state then
            tracerConn = RunService.RenderStepped:Connect(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local rootPart = player.Character.HumanoidRootPart
                        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                        if onScreen then
                            if not tracerLines[player] then
                                local line = Drawing.new("Line")
                                line.Color = Color3.fromRGB(0, 255, 255)
                                line.Thickness = 2
                                line.Transparency = 1
                                tracerLines[player] = line
                            end
                            local line = tracerLines[player]
                            local localPos = Camera:WorldToViewportPoint(LocalPlayer.Character.HumanoidRootPart.Position)
                            line.From = Vector2.new(localPos.X, localPos.Y)
                            line.To = Vector2.new(screenPos.X, screenPos.Y)
                            line.Visible = true
                        end
                    elseif tracerLines[player] then
                        tracerLines[player].Visible = false
                    end
                end
            end)
        else
            for _, line in pairs(tracerLines) do line:Remove() end
            tracerLines = {}
        end
    end
})

-- Utility Tab
local playerDropdown
local allNames = {}
for _, p in pairs(Players:GetPlayers()) do
    if p.Name ~= LocalPlayer.Name then
        table.insert(allNames, p.Name)
    end
end

playerDropdown = utilityTab:AddDropdown({
    Name = "Teleport to Player",
    Default = "",
    Options = allNames,
    Callback = function(name)
        local target = Players:FindFirstChild(name)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
})

Players.PlayerAdded:Connect(function(p)
    table.insert(allNames, p.Name)
    playerDropdown:Refresh(allNames, true)
end)

Players.PlayerRemoving:Connect(function(p)
    for i, v in ipairs(allNames) do
        if v == p.Name then
            table.remove(allNames, i)
            break
        end
    end
    playerDropdown:Refresh(allNames, true)
end)

utilityTab:AddButton({
    Name = "Quit",
    Callback = function()
        LocalPlayer:Kick("You have exited Universal Hub | NovaRise Studios.")
    end
})

OrionLib:Init()
