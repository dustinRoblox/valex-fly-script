-- Universal Hub | Streamlined & Enhanced (v2.2)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Window Setup
local Window = OrionLib:MakeWindow({
    Name = "Universal Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "UniversalHubConfig",
    IntroEnabled = true,
    IntroText = "Universal Hub • v2.2",
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998"
})

-- Tabs
local mainTab    = Window:MakeTab({Name = "Main",    Icon = "rbxassetid://4483345998"})
local playersTab = Window:MakeTab({Name = "Players", Icon = "rbxassetid://4483345998"})
local combatTab  = Window:MakeTab({Name = "Combat",  Icon = "rbxassetid://4483345998"})
local utilityTab = Window:MakeTab({Name = "Utility", Icon = "rbxassetid://4483345998"})
local trollTab   = Window:MakeTab({Name = "Troll",   Icon = "rbxassetid://4483345998"})

--[===========[ Main Tab ]===========]--
mainTab:AddLabel("Universal Hub v2.2")
mainTab:AddParagraph("Developer", "<font color='rgb(255,0,255)'>VoidSyn</font>")

--[===========[ Players Tab ]===========]--
-- Speed Boost Slider
playersTab:AddSlider({
    Name = "Speed Boost",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    Save = true,
    Flag = "speed",
    Callback = function(v)
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = char:WaitForChild("Humanoid")
        humanoid.WalkSpeed = v
    end
})

-- Jump Power Slider
playersTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 100,
    Default = 50,
    Increment = 1,
    Save = true,
    Flag = "jump",
    Callback = function(v)
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = char:WaitForChild("Humanoid")
        humanoid.JumpPower = v
    end
})

-- Noclip Toggle
local noclipConn
playersTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Save = true,
    Flag = "noclip",
    Callback = function(state)
        if noclipConn then noclipConn:Disconnect() end
        if state then
            noclipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

--[===========[ Combat Tab ]===========]--
-- Charms ESP: lines from local to others
local charmsConn
combatTab:AddToggle({
    Name = "Charms ESP",
    Default = false,
    Save = true,
    Flag = "charms",
    Callback = function(enabled)
        if charmsConn then charmsConn:Disconnect() end
        -- Remove existing drawings
        for _, d in pairs(combatTab.Flags or {}) do end
        if enabled then
            charmsConn = RunService.RenderStepped:Connect(function()
                -- Clear old lines
                for _, draw in pairs(_G.CharmDrawings or {}) do draw:Remove() end
                _G.CharmDrawings = {}
                -- Draw new
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local from = Camera:WorldToViewportPoint(LocalPlayer.Character.HumanoidRootPart.Position)
                        local to   = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                        if to.Z > 0 then
                            local line = Drawing.new("Line")
                            line.From = Vector2.new(from.X, from.Y)
                            line.To   = Vector2.new(to.X, to.Y)
                            line.Color = Color3.fromRGB(255, 0, 255)
                            line.Thickness = 2
                            _G.CharmDrawings[#_G.CharmDrawings+1] = line
                        end
                    end
                end
            end)
        else
            for _, draw in pairs(_G.CharmDrawings or {}) do draw:Remove() end
            _G.CharmDrawings = {}
        end
    end
})

--[===========[ Utility Tab ]===========]--
-- Teleport Dropdown
local tpDropdown = utilityTab:AddDropdown({
    Name = "Teleport to Player",
    Default = "",
    Options = (function()
        local t = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Name ~= LocalPlayer.Name then table.insert(t, plr.Name) end
        end
        return t
    end)(),
    Callback = function(name)
        local target = Players:FindFirstChild(name)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:PivotTo(target.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0))
        end
    end
})
Players.PlayerAdded:Connect(function(plr)
    tpDropdown:Refresh(table.concat({tpDropdown.Options, plr.Name}, ","))
end)
Players.PlayerRemoving:Connect(function(plr)
    local opts = tpDropdown.Options
    for i, name in ipairs(opts) do if name == plr.Name then table.remove(opts, i) break end end
    tpDropdown:Refresh(opts)
end)

--[===========[ Troll Tab ]===========]--
-- Cleaned: No content per instructions

-- Init UI
OrionLib:Init()
