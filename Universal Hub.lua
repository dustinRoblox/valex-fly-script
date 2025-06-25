-- Universal Hub with Enhanced Teleport Dropdown
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Create Window
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

-- Tabs
local mainTab    = Window:MakeTab({Name = "Main",    Icon = "rbxassetid://4483345998"})
local playersTab = Window:MakeTab({Name = "Players", Icon = "rbxassetid://4483345998"})
local combatTab  = Window:MakeTab({Name = "Combat",  Icon = "rbxassetid://4483345998"})
local utilityTab = Window:MakeTab({Name = "Utility", Icon = "rbxassetid://4483345998"})
local trollTab   = Window:MakeTab({Name = "Troll",   Icon = "rbxassetid://4483345998"})

-- Main
mainTab:AddLabel("Universal Hub • Version 1.0")
mainTab:AddParagraph("Credits", "Made by Dustin | Powered by OrionLib")

-- Players
playersTab:AddSlider({Name="Speed Boost", Min=16, Max=100, Default=16, Callback=function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end})
playersTab:AddSlider({Name="Jump Boost", Min=50, Max=100, Default=50, Callback=function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = v
    end
end})
playersTab:AddToggle({Name="Noclip", Default=false, Callback=function(state)
    RunService.Stepped:Connect(function()
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not state
                end
            end
        end
    end)
end})

-- Combat
combatTab:AddToggle({Name="ESP (Player Box)", Default=false, Callback=function(state)
    OrionLib:MakeNotification({Name="ESP",
        Content = state and "ESP Enabled" or "ESP Disabled",
        Image   = "rbxassetid://4483345998",
        Time    = 2
    })
end})

-- Utility with Enhanced Teleport Dropdown
local playerList = {}
-- Populate initial list
table.foreach(Players:GetPlayers(), function(_, p) table.insert(playerList, p.Name) end)

local tpDropdown = utilityTab:AddDropdown({
    Name    = "Teleport to Player",
    Default = playerList[1] or "",
    Options = playerList,
    Callback = function(selected)
        local target = Players:FindFirstChild(selected)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:PivotTo(target.Character.HumanoidRootPart.CFrame * CFrame.new(0,5,0))
        else
            OrionLib:MakeNotification({
                Name    = "Teleport Failed",
                Content = "Could not find or access player.",
                Image   = "rbxassetid://4483345998",
                Time    = 3
            })
        end
    end
})

-- Update list on join/leave
table.insert = table.insert; table.remove = table.remove
Players.PlayerAdded:Connect(function(plr)
    table.insert(playerList, plr.Name)
    tpDropdown:Refresh(playerList, true)
end)
Players.PlayerRemoving:Connect(function(plr)
    for i, name in ipairs(playerList) do
        if name == plr.Name then
            table.remove(playerList, i)
            break
        end
    end
    tpDropdown:Refresh(playerList, true)
end)

utilityTab:AddButton({Name="Quit Hub", Callback=function()
    LocalPlayer:Kick("Exited Universal Hub.")
end})

-- Troll Tab
local function createFakeAdminTag()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not char:FindFirstChild("Head") then return end
    if char.Head:FindFirstChild("AdminTag") then char.Head.AdminTag:Destroy() end
    local gui = Instance.new("BillboardGui", char.Head)
    gui.Name = "AdminTag" gui.Size = UDim2.new(0,100,0,40)
    gui.StudsOffset = Vector3.new(0,2.5,0) gui.AlwaysOnTop = true
    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.new(1,0,1,0) label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold label.TextScaled = true
    label.Text = "[ADMIN]" label.TextColor3 = Color3.fromRGB(255,0,0)
end

trollTab:AddButton({Name="Fake Admin Tag", Callback=createFakeAdminTag})

-- Init
OrionLib:Init()
