-- Universal Hub | Enhanced Features
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- UI Setup
local Window = OrionLib:MakeWindow({
    Name = "Universal Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "UniversalHubConfig",
    IntroEnabled = true,
    IntroText = "⚡Universal Hub v1.0⚡",
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998"
})

-- Tabs
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})
local PlayersTab = Window:MakeTab({Name = "Players", Icon = "rbxassetid://4483345998"})
local CombatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})
local UtilityTab = Window:MakeTab({Name = "Utility", Icon = "rbxassetid://4483345998"})
local TrollTab = Window:MakeTab({Name = "Troll", Icon = "rbxassetid://4483345998"})

-- Main Tab
MainTab:AddLabel("✨ Universal Hub ✨")
MainTab:AddParagraph("Credits", "✨ Made by Dustin | Script maintained by ChatGPT ✨")

-- Players Tab
PlayersTab:AddSlider({Name="Speed Boost", Min=16, Max=100, Default=16, Callback=function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end})

PlayersTab:AddSlider({Name="Jump Boost", Min=50, Max=150, Default=50, Callback=function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = v
    end
end})

PlayersTab:AddToggle({Name="Fly", Default=false, Callback=function(state)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local flyVel, flyGyro, conn
    if state and humanoid and hrp then
        flyVel = Instance.new("BodyVelocity", hrp)
        flyGyro = Instance.new("BodyGyro", hrp)
        flyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
        flyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
        conn = RunService.Heartbeat:Connect(function()
            local cam = workspace.CurrentCamera.CFrame
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
            flyVel.Velocity = dir.Unit * 50
            flyGyro.CFrame = cam
        end)
    else
        if flyVel then flyVel:Destroy() end
        if flyGyro then flyGyro:Destroy() end
        if conn then conn:Disconnect() end
    end
end})

-- Combat Tab
local ESPBoxes, ESPNames = {}, {}
CombatTab:AddToggle({Name="ESP Boxes", Default=false, Callback=function(state)
    if state then
        RunService.RenderStepped:Connect(function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr~=LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    local pos, on = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.Head.Position)
                    if on then
                        if not ESPBoxes[plr] then
                            local box=Drawing.new("Square") ESPBoxes[plr]=box
                            box.Color=Color3.new(1,0,0);box.Thickness=2;box.Filled=false
                        end
                        local b=ESPBoxes[plr]
                        b.Position=Vector2.new(pos.X-25,pos.Y-25);b.Size=Vector2.new(50,50);b.Visible=true
                    elseif ESPBoxes[plr] then ESPBoxes[plr].Visible=false end
                end
            end
        end)
    else
        for _,b in pairs(ESPBoxes) do b:Remove() end; ESPBoxes={}
    end
end})

CombatTab:AddToggle({Name="ESP Names", Default=false, Callback=function(state)
    if state then
        RunService.RenderStepped:Connect(function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr~=LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    local pos,on=workspace.CurrentCamera:WorldToViewportPoint(plr.Character.Head.Position+Vector3.new(0,2,0))
                    if on then
                        if not ESPNames[plr] then
                            local text=Drawing.new("Text") ESPNames[plr]=text
                            text.Color=Color3.new(1,1,0);text.Size=18;text.Center=true;text.Outline=true
                        end
                        local t=ESPNames[plr]
                        t.Position=Vector2.new(pos.X,pos.Y);t.Text=plr.Name;t.Visible=true
                    elseif ESPNames[plr] then ESPNames[plr].Visible=false end
                end
            end
        end)
    else
        for _,t in pairs(ESPNames) do t:Remove() end; ESPNames={}
    end
end})

-- Utility Tab
local playerList={}
for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(playerList,p.Name) end end
local tpDropdown = UtilityTab:AddDropdown({Name="Teleport to Player", Default=playerList[1] or "", Options=playerList, Callback=function(name)
    local target=Players:FindFirstChild(name)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character:PivotTo(target.Character.HumanoidRootPart.CFrame * CFrame.new(0,5,0))
    end
end})
Players.PlayerAdded:Connect(function(p) tpDropdown:Refresh(table.concat(playerList,p.Name),true) end)
Players.PlayerRemoving:Connect(function(p) for i,n in ipairs(playerList) do if n==p.Name then table.remove(playerList,i) break end end tpDropdown:Refresh(playerList,true) end)
UtilityTab:AddButton({Name="Quit Hub", Callback=function() LocalPlayer:Kick("Goodbye from Universal Hub!") end})

-- Troll Tab
TrollTab:AddDropdown({Name="Admin Tag Type",Options={"Owner","Admin","Mod","VIP"},Default="Admin",Callback=function(choice)
    local char=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if char.Head:FindFirstChild("AdminTag") then char.Head.AdminTag:Destroy() end
    local gui=Instance.new("BillboardGui",char.Head);gui.Name="AdminTag" gui.Size=UDim2.new(0,100,0,40);gui.StudsOffset=Vector3.new(0,2.5,0);gui.AlwaysOnTop=true
    local lbl=Instance.new("TextLabel",gui);lbl.Size=UDim2.new(1,0,1,0);lbl.BackgroundTransparency=1;lbl.Text="["..choice.."]";lbl.TextColor3=Color3.new(1,0,0);lbl.TextScaled=true;lbl.Font=Enum.Font.GothamBold
end})
TrollTab:AddDropdown({Name="Explode Player",Options=playerList,Default=playerList[1] or "",Callback=function(name)
    local victim=Players:FindFirstChild(name)
    if victim and victim.Character and victim.Character:FindFirstChild("Humanoid") then
        victim.Character.Humanoid.Health=0
    end
end})
TrollTab:AddButton({Name="Reset Me",Callback=function() LocalPlayer:LoadCharacter() end})

-- Launch
OrionLib:Init()
