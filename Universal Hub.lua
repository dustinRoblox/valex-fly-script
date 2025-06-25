-- Universal Hub | Enhanced UI & Features (v2.1)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Helper: Create Billboard Tag
local function createBillboardTag(parent, text, color)
    if parent:FindFirstChild("HeadTag") then parent.HeadTag:Destroy() end
    local gui = Instance.new("BillboardGui", parent)
    gui.Name = "HeadTag"
    gui.Size = UDim2.new(0, 120, 0, 40)
    gui.StudsOffset = Vector3.new(0, 2.5, 0)
    gui.AlwaysOnTop = true
    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.RichText = true
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
end

-- Helper: Explode Player
local function explodePlayer(target)
    if target and target.Character then
        for _, part in pairs(target.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                local explosion = Instance.new("Explosion", workspace)
                explosion.Position = part.Position
                explosion.BlastRadius = 5
                explosion.BlastPressure = 100000
            end
        end
        target:LoadCharacter()
    end
end

-- Window
local Window = OrionLib:MakeWindow({
    Name = "Universal Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "UniversalHubConfig",
    IntroEnabled = true,
    IntroText = "Universal Hub • v2.1",
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998"
})

-- Tabs
local mainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})
local playersTab = Window:MakeTab({Name = "Players", Icon = "rbxassetid://4483345998"})
local combatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})
local utilityTab = Window:MakeTab({Name = "Utility", Icon = "rbxassetid://4483345998"})
local trollTab = Window:MakeTab({Name = "Troll", Icon = "rbxassetid://4483345998"})

-- Main Tab: Polished Credits
mainTab:AddLabel("<b>Universal Hub</b> <i>v2.1</i>")
mainTab:AddParagraph("Credits", [[
<font color='rgb(0,255,255)'>Dustin</font> - Lead Developer
<font color='rgb(255,128,0)'>ChatGPT</font> - AI Support
<font color='rgb(0,255,128)'>OrionLib</font> - UI Framework
]])

-- Players Tab: Speed, Jump, Fly, Noclip
playersTab:AddSlider({Name = "Speed Boost", Min = 16, Max = 100, Default = 16, Callback = function(v)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    char:WaitForChild("Humanoid").WalkSpeed = v
end})
playersTab:AddSlider({Name = "Jump Boost", Min = 50, Max = 100, Default = 50, Callback = function(v)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    char:WaitForChild("Humanoid").JumpPower = v
end})
playersTab:AddToggle({Name = "Fly Mode", Default = false, Callback = function(state)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    if state then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        LocalPlayer:SetAttribute("FlyBV", bv)
        RunService:BindToRenderStep("Fly", Enum.RenderPriority.Camera.Value, function()
            local vel = Vector3.new()
            local camCF = Camera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel += camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel -= camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel -= camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel += camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel -= Vector3.new(0,1,0) end
            bv.Velocity = vel.Unit * 100
        end)
    else
        RunService:UnbindFromRenderStep("Fly")
        local bv = LocalPlayer:GetAttribute("FlyBV")
        if bv then bv:Destroy() end
    end
end})
playersTab:AddToggle({Name = "Noclip", Default = false, Callback = function(state)
    local conn = LocalPlayer:GetAttribute("NoclipConn")
    if conn then conn:Disconnect() end
    if state then
        conn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end)
        LocalPlayer:SetAttribute("NoclipConn", conn)
    end
end})

-- Combat Tab: Charms ESP
local charmLines = {conn=nil}
combatTab:AddToggle({Name = "Charms ESP", Default = false, Callback = function(state)
    if charmLines.conn then charmLines.conn:Disconnect() charmLines.conn = nil end
    for i, l in ipairs(charmLines) do if typeof(l)=="Instance" then l:Remove() end end
    if state then
        charmLines.conn = RunService.RenderStepped:Connect(function()
            -- Clear old lines
            for i=#charmLines,1,-1 do if typeof(charmLines[i])=="Instance" then charmLines[i]:Remove(); table.remove(charmLines,i) end end
            for _, p in ipairs(Players:GetPlayers()) do
                if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local from = Camera:WorldToViewportPoint(LocalPlayer.Character.HumanoidRootPart.Position)
                    local to   = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                    local seg=Drawing.new("Line")
                    seg.From=Vector2.new(from.X, from.Y)
                    seg.To=Vector2.new(to.X, to.Y)
                    seg.Color=Color3.fromRGB(255,0,255)
                    seg.Thickness=2
                    table.insert(charmLines, seg)
                end
            end
        end)
    end
end})

-- Utility Tab: Teleport Dropdown
do
    local names={}
    for _,p in ipairs(Players:GetPlayers()) do table.insert(names,p.Name) end
    local tpDropdown=utilityTab:AddDropdown({Name="Teleport to Player",Options=names,Callback=function(name)
        local t=Players:FindFirstChild(name)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
        end
    end})
    Players.PlayerAdded:Connect(function()tpDropdown:Refresh((function()local t={}for _,x in pairs(Players:GetPlayers())do table.insert(t,x.Name)end return t end)())end)
    Players.PlayerRemoving:Connect(function()tpDropdown:Refresh((function()local t={}for _,x in pairs(Players:GetPlayers())do table.insert(t,x.Name)end return t end)())end)
end

-- Troll Tab: Admin Head Tags & Explode Player

-- Head Tag mapping and toggle
tlocal headTagMapping = {}
local headTagEnabled = false

trollTab:AddToggle({
    Name = "Enable Head Tags",
    Default = true,
    Callback = function(enabled)
        headTagEnabled = enabled
        for _, player in pairs(Players:GetPlayers()) do
            local tagInfo = headTagMapping[player]
            if tagInfo and player.Character and player.Character:FindFirstChild("Head") then
                if enabled then
                    createBillboardTag(player.Character.Head, tagInfo.text, tagInfo.color)
                else
                    local existing = player.Character.Head:FindFirstChild("HeadTag")
                    if existing then existing:Destroy() end
                end
            end
        end
    end
})

-- Admin Head Tag Selector
local adminTags = {"Owner","Admin","Moderator","Helper","Dev"}
trollTab:AddDropdown({
    Name = "Admin Head Tag Selector",
    Options = adminTags,
    Callback = function(tag)
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        headTagMapping[LocalPlayer] = {text = "["..tag.."]", color = Color3.fromRGB(255,128,0)}
        if headTagEnabled then
            createBillboardTag(char.Head, "["..tag.."]", Color3.fromRGB(255,128,0))
        end
    end
})

-- Explode Player Dropdown
local function refreshExplodeOptions(dropdown)
    local opts = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(opts, p.Name) end
    end
    dropdown:Refresh(opts)
end

local explodeDropdown = trollTab:AddDropdown({
    Name = "Explode Player",
    Options = {},
    Callback = function(name)
        local target = Players:FindFirstChild(name)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            -- Explosion effect
            local explosion = Instance.new("Explosion", workspace)
            explosion.Position = target.Character.HumanoidRootPart.Position
            explosion.BlastRadius = 10
            explosion.BlastPressure = 500000
            -- Kill and respawn
            local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.Health = 0 end
        end
    end
})

refreshExplodeOptions(explodeDropdown)
Players.PlayerAdded:Connect(function() refreshExplodeOptions(explodeDropdown) end)
Players.PlayerRemoving:Connect(function() refreshExplodeOptions(explodeDropdown) end)

trollTab:AddDropdown({Name="Admin Head Tag Selector",Options={"Owner","Admin","Moderator","Helper","Dev"},Callback=function(tag)
    local char=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    createBillboardTag(char.Head,string.upper(tag),Color3.fromRGB(255,128,0))
end})
trollTab:AddDropdown({Name="Explode Player",Options=(function()local t={}for _,p in pairs(Players:GetPlayers())do table.insert(t,p.Name)end return t end)(),Callback=function(name)
    explodePlayer(Players:FindFirstChild(name))
end})

-- Init UI
OrionLib:Init()
