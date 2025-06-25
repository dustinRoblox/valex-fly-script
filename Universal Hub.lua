-- // Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ESPDrawings = {}
local speedConn, jumpConn, noclipConn, espConn

-- // Cleanup on Exit
local function Cleanup()
    if speedConn then speedConn:Disconnect() end
    if jumpConn then jumpConn:Disconnect() end
    if noclipConn then noclipConn:Disconnect() end
    if espConn then espConn:Disconnect() end
    for _, box in pairs(ESPDrawings) do
        box:Remove()
    end
end

-- // Create Window
local Window = OrionLib:MakeWindow({
    Name = "Universal Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "UniversalHub",
    IntroText = "Universal Hub • v1.0",
    CloseCallback = Cleanup
})

-- // Tabs
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})
local PlayersTab = Window:MakeTab({Name = "Players", Icon = "rbxassetid://4483345998"})
local CombatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})
local UtilityTab = Window:MakeTab({Name = "Utility", Icon = "rbxassetid://4483345998"})

-- // Main Tab
MainTab:AddLabel("Universal Hub • Version 1.0")
MainTab:AddParagraph("Credits", "Made by Dustin 💻")

-- // Players Tab
PlayersTab:AddSlider({
    Name = "Speed Boost",
    Min = 16, Max = 100, Default = 16,
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

PlayersTab:AddSlider({
    Name = "Jump Boost",
    Min = 50, Max = 100, Default = 50,
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

PlayersTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(toggled)
        if noclipConn then noclipConn:Disconnect() end
        if toggled then
            noclipConn = RunService.Stepped:Connect(function()
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

PlayersTab:AddToggle({
    Name = "Invisible",
    Default = false,
    Callback = function(state)
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = state and 1 or 0
                    if part:FindFirstChildOfClass("Decal") then
                        part:FindFirstChildOfClass("Decal").Transparency = state and 1 or 0
                    end
                end
            end
        end
    end
})

-- // Combat Tab
CombatTab:AddToggle({
    Name = "ESP (Player Box)",
    Default = false,
    Callback = function(state)
        if espConn then espConn:Disconnect() end
        for _, box in pairs(ESPDrawings) do
            box:Remove()
        end
        ESPDrawings = {}

        if state then
            espConn = RunService.RenderStepped:Connect(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                        local head = player.Character.Head
                        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)

                        if onScreen then
                            if not ESPDrawings[player] then
                                local box = Drawing.new("Square")
                                box.Color = Color3.new(1, 0, 0)
                                box.Thickness = 2
                                box.Size = Vector2.new(50, 50)
                                box.Filled = false
                                ESPDrawings[player] = box
                            end
                            ESPDrawings[player].Position = Vector2.new(pos.X - 25, pos.Y - 25)
                            ESPDrawings[player].Visible = true
                        elseif ESPDrawings[player] then
                            ESPDrawings[player].Visible = false
                        end
                    end
                end
            end)
        end
    end
})

-- // Utility Tab — Teleport Dropdown + Quit
local playerNames = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p.Name ~= LocalPlayer.Name then
        table.insert(playerNames, p.Name)
    end
end

local tpDropdown = UtilityTab:AddDropdown({
    Name = "Teleport to Player",
    Default = "",
    Options = playerNames,
    Callback = function(name)
        local target = Players:FindFirstChild(name)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:MoveTo(target.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
        end
    end
})

Players.PlayerAdded:Connect(function(plr)
    table.insert(playerNames, plr.Name)
    tpDropdown:Refresh(playerNames, true)
end)

Players.PlayerRemoving:Connect(function(plr)
    for i, name in ipairs(playerNames) do
        if name == plr.Name then
            table.remove(playerNames, i)
            break
        end
    end
    tpDropdown:Refresh(playerNames, true)
end)

UtilityTab:AddButton({
    Name = "Quit",
    Callback = function()
        LocalPlayer:Kick("Goodbye 👋")
    end
})

-- // Launch UI
OrionLib:Init()
