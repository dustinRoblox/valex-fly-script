-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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
        -- Reset player on close
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
            -- Turn off noclip
            _G.NoclipEnabled = false
            -- Remove ESP highlights
            removeESP()
            -- Stop speed bypass
            if SpeedBypassConnection then SpeedBypassConnection:Disconnect() SpeedBypassConnection = nil end
        end
        print("Ohio Hub closed, cleaned up.")
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

-- ==== PLAYER TAB ====
local PlayerTab = Window:MakeTab({
    Name = "Players",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

PlayerTab:AddSection({Name = "Player Mods"})

-- Speed Bypass
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
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
        if not SpeedBypassConnection then
            SpeedBypassConnection = RunService.Heartbeat:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = DesiredSpeed
                end
            end)
        end
    end
})

-- Jump Boost
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

-- Heal Button
PlayerTab:AddButton({
    Name = "Heal",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
            OrionLib:MakeNotification({
                Name = "Heal",
                Content = "You have been healed!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Noclip Toggle
_G.NoclipEnabled = false

local function noclipLoop()
    RunService.Stepped:Connect(function()
        if _G.NoclipEnabled and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

noclipLoop()

PlayerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
        _G.NoclipEnabled = state
        if not state and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
})

-- ==== COMBAT TAB ====
local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

CombatTab:AddSection({Name = "Combat Mods"})

-- Wallbang toggle (basic simulation)
-- Note: Actual wallbang usually requires exploiting gun scripts or raycasts, so here's a placeholder flag.
_G.WallbangEnabled = false

CombatTab:AddToggle({
    Name = "Wallbang (Simulated)",
    Default = false,
    Callback = function(state)
        _G.WallbangEnabled = state
        OrionLib:MakeNotification({
            Name = "Wallbang",
            Content = state and "Wallbang Enabled (Simulated)" or "Wallbang Disabled",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
        -- Add your game's specific wallbang exploit code here
    end
})

-- ESP toggle
local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "OhioHubESP"

local ESPBoxes = {}
local ESPTexts = {}

local function createESPForPlayer(player)
    if ESPBoxes[player] or player == LocalPlayer then return end
    local box = Drawing and Drawing.new and Drawing.new("Square") or nil
    local nameText = Drawing and Drawing.new and Drawing.new("Text") or nil
    local healthText = Drawing and Drawing.new and Drawing.new("Text") or nil
    if not (box and nameText and healthText) then return end
    
    box.Visible = false
    box.Color = Color3.new(1, 0, 0)
    box.Thickness = 2
    box.Filled = false

    nameText.Visible = false
    nameText.Color = Color3.new(1, 1, 1)
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true

    healthText.Visible = false
    healthText.Color = Color3.new(0, 1, 0)
    healthText.Size = 14
    healthText.Center = true
    healthText.Outline = true

    ESPBoxes[player] = box
    ESPTexts[player] = {nameText, healthText}
end

local function removeESP()
    for player, box in pairs(ESPBoxes) do
        box:Remove()
    end
    for player, texts in pairs(ESPTexts) do
        for _, text in pairs(texts) do
            text:Remove()
        end
    end
    ESPBoxes = {}
    ESPTexts = {}
end

local function updateESP()
    for player, box in pairs(ESPBoxes) do
        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if head and humanoid and humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local size = Vector3.new(4, 6, 1) -- box size approx

                local screenPos = Vector2.new(pos.X, pos.Y)

                box.Visible = true
                box.Position = Vector2.new(screenPos.X - 20, screenPos.Y - 40)
                box.Size = Vector2.new(40, 80)

                local nameText, healthText = unpack(ESPTexts[player])
                nameText.Visible = true
                nameText.Text = player.Name
                nameText.Position = Vector2.new(screenPos.X, screenPos.Y - 50)

                healthText.Visible = true
                healthText.Text = "HP: " .. math.floor(humanoid.Health)
                healthText.Position = Vector2.new(screenPos.X, screenPos.Y - 35)
            else
                box.Visible = false
                for _, txt in pairs(ESPTexts[player]) do
                    txt.Visible = false
                end
            end
        else
            box.Visible = false
            for _, txt in pairs(ESPTexts[player]) do
                txt.Visible = false
            end
        end
    end
end

local ESPEnabled = false
local ESPConnection

CombatTab:AddToggle({
    Name = "ESP",
    Default = false,
    Callback = function(state)
        ESPEnabled = state
        if state then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    createESPForPlayer(player)
                end
            end
            ESPConnection = RunService.RenderStepped:Connect(updateESP)
        else
            if ESPConnection then
                ESPConnection:Disconnect()
                ESPConnection = nil
            end
            removeESP()
        end
    end
})

-- Update ESP when players join or leave
Players.PlayerAdded:Connect(function(player)
    if ESPEnabled and player ~= LocalPlayer then
        createESPForPlayer(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPBoxes[player] then
        if ESPBoxes[player] then
            ESPBoxes[player]:Remove()
            ESPBoxes[player] = nil
        end
        if ESPTexts[player] then
            for _, txt in pairs(ESPTexts[player]) do
                txt:Remove()
            end
            ESPTexts[player] = nil
        end
    end
end)

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
        LocalPlayer:Kick("Quit button pressed. Goodbye!")
    end
})

-- Initialize UI
OrionLib:Init()
