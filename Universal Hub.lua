-- Universal Hub | OrionLib Menu
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- UI Setup
local Window = OrionLib:MakeWindow({
    Name = "Universal Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "UniversalHub",
    IntroEnabled = true,
    IntroText = "Universal Hub • v1.0",
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998"
})

-- Tab Definitions
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})
local PlayersTab = Window:MakeTab({Name = "Players", Icon = "rbxassetid://4483345998"})
local CombatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})
local UtilityTab = Window:MakeTab({Name = "Utility", Icon = "rbxassetid://4483345998"})
local TrollTab = Window:MakeTab({Name = "Troll", Icon = "rbxassetid://4483345998"})

-- Main Tab Content
MainTab:AddLabel("Universal Hub • Version 1.0")
MainTab:AddParagraph("Credits", "Created by Dustin | OrionLib")

-- Variables
local speedConnection, jumpConnection, noclipConnection, espConnection
local ESPDrawings = {}
local noclipActive = false

-- Players Tab Features
PlayersTab:AddSlider({
    Name = "Speed Boost",
    Min = 16, Max = 100, Default = 16,
    Callback = function(value)
        if speedConnection then speedConnection:Disconnect() end
        speedConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = value end
        end)
    end
})

PlayersTab:AddSlider({
    Name = "Jump Boost",
    Min = 50, Max = 100, Default = 50,
    Callback = function(value)
        if jumpConnection then jumpConnection:Disconnect() end
        jumpConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.JumpPower = value end
        end)
    end
})

-- Improved Noclip Toggle
PlayersTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
        noclipActive = state
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
        if state then
            noclipConnection = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            -- restore collisions once
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

-- Combat Tab: Basic ESP
CombatTab:AddToggle({
    Name = "ESP Boxes",
    Default = false,
    Callback = function(enabled)
        if espConnection then espConnection:Disconnect() end
        for _, box in pairs(ESPDrawings) do box:Remove() end
        ESPDrawings = {}
        if enabled then
            espConnection = RunService.RenderStepped:Connect(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                        local head = player.Character.Head
                        local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            if not ESPDrawings[player] then
                                local box = Drawing.new("Square")
                                box.Color = Color3.new(1, 0, 0)
                                box.Thickness = 2
                                box.Filled = false
                                ESPDrawings[player] = box
                            end
                            local box = ESPDrawings[player]
                            box.Position = Vector2.new(pos.X - 25, pos.Y - 25)
                            box.Size = Vector2.new(50, 50)
                            box.Visible = true
                        elseif ESPDrawings[player] then
                            ESPDrawings[player].Visible = false
                        end
                    end
                end
            end)
        end
    end
})

-- Utility Tab: Teleport Dropdown
local function refreshTeleportOptions(dropdown)
    local options = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then table.insert(options, player.Name) end
    end
    dropdown:Refresh(options, true)
end

local tpDropdown = UtilityTab:AddDropdown({
    Name = "Teleport to Player",
    Options = {},
    Callback = function(selection)
        local target = Players:FindFirstChild(selection)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:PivotTo(target.Character.HumanoidRootPart.CFrame * CFrame.new(0,5,0))
        end
    end
})
refreshTeleportOptions(tpDropdown)
Players.PlayerAdded:Connect(function() refreshTeleportOptions(tpDropdown) end)
Players.PlayerRemoving:Connect(function() refreshTeleportOptions(tpDropdown) end)

UtilityTab:AddButton({Name = "Quit Hub", Callback = function() LocalPlayer:Kick("Exited Universal Hub.") end})

-- Troll Tab: Fake Admin & Explode
local function addFakeAdminTag()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if char.Head:FindFirstChild("FakeAdminTag") then char.Head.FakeAdminTag:Destroy() end
    local tag = Instance.new("BillboardGui", char.Head)
    tag.Name = "FakeAdminTag"; tag.Size = UDim2.new(0,100,0,40)
    tag.StudsOffset = Vector3.new(0,2.5,0); tag.AlwaysOnTop = true
    local label = Instance.new("TextLabel", tag)
    label.Size = UDim2.new(1,0,1,0); label.BackgroundTransparency = 1
    label.Text = "[ADMIN]"; label.TextColor3 = Color3.new(1,0,0)
    label.Font = Enum.Font.GothamBold; label.TextScaled = true
end

trollTab:AddButton({Name = "Fake Admin Tag", Callback = addFakeAdminTag})
trollTab:AddButton({Name = "Explode Me", Callback = function()
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part:BreakJoints()
                part.Velocity = Vector3.new(math.random(-100,100),math.random(50,150),math.random(-100,100))
            end
        end
    end
end})

-- Initialize UI
OrionLib:Init()
