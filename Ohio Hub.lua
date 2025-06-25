-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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
    Icon = "rbxassetid://4483345998",
    CloseCallback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
        _G.JumpBoostEnabled = false
        _G.SpeedBypassEnabled = false
        SpeedLoop:Disconnect()
        JumpLoop:Disconnect()
        removeESP()
        print("Ohio Hub closed, reset")
    end
})

-- MAIN TAB
local mainTab = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://4483345998" })
mainTab:AddSection{ Name = "Info" }
mainTab:AddLabel("Ohio Hub • Version v1.1.0")
mainTab:AddParagraph("Credits", "Created by Dustin using Orion Library")

-- PLAYERS TAB
local playerTab = Window:MakeTab({ Name = "Players", Icon = "rbxassetid://4483345998" })
playerTab:AddSection{ Name = "Player Mods" }

-- Speed bypass setup
_G.SpeedBypassEnabled = false
local DesiredSpeed = 16
local SpeedLoop = RunService.Heartbeat:Connect(function()
    if _G.SpeedBypassEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = DesiredSpeed
    end
end)

playerTab:AddSlider({
    Name = "Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    Color = Color3.fromRGB(0,255,0),
    ValueName = "WS",
    Callback = function(v)
        DesiredSpeed = v
        _G.SpeedBypassEnabled = v > 16
    end
})

-- Jump Boost setup
_G.JumpBoostEnabled = false
local DesiredJump = 50
local JumpLoop = RunService.Heartbeat:Connect(function()
    if _G.JumpBoostEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = DesiredJump
    end
end)

playerTab:AddSlider({
    Name = "Jump Boost",
    Min = 50,
    Max = 100,
    Default = 50,
    Increment = 1,
    Color = Color3.fromRGB(255,255,0),
    ValueName = "JP",
    Callback = function(v)
        DesiredJump = v
        _G.JumpBoostEnabled = v > 50
    end
})

-- Heal function
playerTab:AddButton({
    Name = "Heal 🔧",
    Callback = function()
        local hm = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hm then
            hm.Health = hm.MaxHealth
            OrionLib:MakeNotification({
                Name = "Healed",
                Content = "You got full health!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Noclip
_G.NoclipEnabled = false
RunService.Stepped:Connect(function()
    if _G.NoclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)
playerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(s) _G.NoclipEnabled = s end
})

-- COMBAT TAB
local combatTab = Window:MakeTab({ Name = "Combat", Icon = "rbxassetid://4483345998" })
combatTab:AddSection{ Name = "Combat Mods" }

-- Wallbang helper: ignore raycast walls
_G.WallbangEnabled = false
-- Note: Actual effect depends on game gun mechanics
combatTab:AddToggle({
    Name = "Wallbang",
    Default = false,
    Callback = function(s)
        _G.WallbangEnabled = s
        OrionLib:MakeNotification({
            Name = "Wallbang",
            Content = "Wallbang " .. (s and "Enabled" or "Disabled"),
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    end
})

-- ESP
local ESPData = { Boxes = {}, Texts = {} }
local ESPConn

local function createESP(player)
    if player == LocalPlayer or ESPData.Boxes[player] then return end
    local box = Drawing.new("Square")
    box.Color = Color3.new(1,0,0)
    box.Thickness = 2
    box.Filled = false
    local nameT = Drawing.new("Text")
    nameT.Color = Color3.new(1,1,1)
    nameT.Size = 14
    nameT.Center = true
    nameT.Outline = true

    ESPData.Boxes[player] = box
    ESPData.Texts[player] = nameT
end

local function removeESP()
    for p,box in pairs(ESPData.Boxes) do box:Remove() end
    for p,txt in pairs(ESPData.Texts) do txt:Remove() end
    ESPData.Boxes, ESPData.Texts = {}, {}
    if ESPConn then ESPConn:Disconnect() ESPConn = nil end
end

combatTab:AddToggle({
    Name = "ESP",
    Default = false,
    Callback = function(s)
        removeESP()
        if s then
            for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
            ESPConn = RunService.RenderStepped:Connect(function()
                for p,box in pairs(ESPData.Boxes) do
                    local c = p.Character; local h=c and c:FindFirstChild("Head"); local hm=c and c:FindFirstChild("Humanoid")
                    if h and hm and hm.Health > 0 then
                        local sp, ons = Camera:WorldToViewportPoint(h.Position)
                        if ons then
                            box.Visible = true
                            box.Position = Vector2.new(sp.X-20, sp.Y-40)
                            box.Size = Vector2.new(40,80)
                            local t = ESPData.Texts[p]
                            t.Visible = true
                            t.Text = p.Name .. " | " .. math.floor(hm.Health)
                            t.Position = Vector2.new(sp.X, sp.Y - 50)
                        else
                            box.Visible = false
                            ESPData.Texts[p].Visible = false
                        end
                    else
                        box.Visible = false
                        ESPData.Texts[p].Visible = false
                    end
                end
            end)
        end
    end
})

Players.PlayerAdded:Connect(function(p) if ESPData.Boxes then createESP(p) end end)
Players.PlayerRemoving:Connect(function(p)
    if ESPData.Boxes[p] then
        ESPData.Boxes[p]:Remove()
        ESPData.Texts[p]:Remove()
        ESPData.Boxes[p], ESPData.Texts[p] = nil, nil
    end
end)

-- UTILITY TAB
local utilTab = Window:MakeTab({ Name = "Utility", Icon = "rbxassetid://4483345998" })
utilTab:AddSection{ Name = "Game" }
utilTab:AddButton({
    Name = "Quit Game",
    Callback = function() LocalPlayer:Kick("Quit pressed.") end
})

-- 🌟 Initialize
OrionLib:Init()
