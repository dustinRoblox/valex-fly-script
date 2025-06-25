-- Universal Hub with Clean Teleport Dropdown
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Initialize UI
local Window = OrionLib:MakeWindow({
    Name = "Universal Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "UniversalHubConfig",
    IntroEnabled = true,
    IntroText = "Universal Hub v1.0"
})

-- Tabs
local MainTab = Window:MakeTab({Name="Main", Icon="rbxassetid://4483345998"})
local PlayersTab = Window:MakeTab({Name="Players", Icon="rbxassetid://4483345998"})
local CombatTab = Window:MakeTab({Name="Combat", Icon="rbxassetid://4483345998"})
local UtilityTab = Window:MakeTab({Name="Utility", Icon="rbxassetid://4483345998"})
local TrollTab = Window:MakeTab({Name="Troll", Icon="rbxassetid://4483345998"})

-- Main Tab
MainTab:AddLabel("Universal Hub • v1.0.0")
MainTab:AddParagraph("Credits","Made by Dustin with OrionLib")

-- Players Tab
PlayersTab:AddSlider({Name="Speed Boost",Min=16,Max=100,Default=16,Callback=function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end})
PlayersTab:AddSlider({Name="Jump Boost",Min=50,Max=100,Default=50,Callback=function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = v
    end
end})
PlayersTab:AddToggle({Name="Noclip",Default=false,Callback=function(state)
    RunService.Stepped:Connect(function()
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = not state end
        end
    end)
end})

-- Combat Tab
CombatTab:AddToggle({Name="ESP",Default=false,Callback=function(state)
    -- Implement actual ESP here
    print("ESP toggled",state)
end})

-- Utility Tab: Teleport Dropdown & Quit
local playerNames = {}
for _, p in pairs(Players:GetPlayers()) do
    if p.Name~=LocalPlayer.Name then table.insert(playerNames,p.Name) end
end
local tpDropdown = UtilityTab:AddDropdown({Name="Teleport to Player",Default="",Options=playerNames,Callback=function(name)
    local target = Players:FindFirstChild(name)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,5,0)
    end
end})
Players.PlayerAdded:Connect(function(p)
    table.insert(playerNames,p.Name)
    tpDropdown:Refresh(playerNames,true)
end)
Players.PlayerRemoving:Connect(function(p)
    for i,name in ipairs(playerNames) do
        if name==p.Name then table.remove(playerNames,i); break end
    end
    tpDropdown:Refresh(playerNames,true)
end)
UtilityTab:AddButton({Name="Quit Hub",Callback=function() LocalPlayer:Kick("Exited Universal Hub") end})

-- Troll Tab
local function createAdminTag()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if char.Head:FindFirstChild("FakeAdminTag") then char.Head.FakeAdminTag:Destroy() end
    local tag = Instance.new("BillboardGui",char.Head)
    tag.Name="FakeAdminTag";tag.Size=UDim2.new(0,100,0,40);tag.StudsOffset=Vector3.new(0,2.5,0);tag.AlwaysOnTop=true
    local label=Instance.new("TextLabel",tag)
    label.Size=UDim2.new(1,0,1,0);label.BackgroundTransparency=1;label.Text="[ADMIN]";
    label.TextColor3=Color3.fromRGB(255,0,0);label.TextScaled=true;label.Font=Enum.Font.GothamBold
end
TrollTab:AddButton({Name="Fake Admin Tag",Callback=createAdminTag})
TrollTab:AddButton({Name="Explode Me",Callback=function()
    local char=LocalPlayer.Character
    for _,part in pairs(char:GetChildren()) do if part:IsA("BasePart") then part.Velocity=Vector3.new(math.random(-100,100),math.random(50,100),math.random(-100,100)) end end
end})

-- Init UI
OrionLib:Init()
