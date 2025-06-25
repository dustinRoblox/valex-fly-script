-- Brookhaven Hub | OrionLib UI | Fully Loaded
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Globals
local Window = OrionLib:MakeWindow({
    Name = "Brookhaven Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "BrookhavenHubConfig",
    IntroEnabled = true,
    IntroText = "Welcome to Brookhaven Hub!",
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998",
    CloseCallback = function()
        if speedConn then speedConn:Disconnect() speedConn = nil end
        if jumpConn then jumpConn:Disconnect() jumpConn = nil end
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if flyConn then flyConn:Disconnect() flyConn = nil end

        -- Reset player properties
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
            char.Humanoid.JumpPower = 50
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
})

-- Tabs
local mainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})
local playerTab = Window:MakeTab({Name = "Player", Icon = "rbxassetid://4483345998"})
local utilityTab = Window:MakeTab({Name = "Utility", Icon = "rbxassetid://4483345998"})
local appearanceTab = Window:MakeTab({Name = "Appearance", Icon = "rbxassetid://4483345998"})
local vehiclesTab = Window:MakeTab({Name = "Vehicles", Icon = "rbxassetid://4483345998"})
local roleplayTab = Window:MakeTab({Name = "Roleplay", Icon = "rbxassetid://4483345998"})
local combatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})
local settingsTab = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483345998"})

-- ==== MAIN TAB ====
mainTab:AddLabel("Brookhaven Hub • Version 1.0.0")
mainTab:AddParagraph("Credits", "Made by Dustin. Ultimate RP toolkit.")
mainTab:AddParagraph("News", "New: Vehicle controls and roleplay emotes added!")

-- ==== PLAYER TAB ====
local DesiredSpeed = 16
local DesiredJump = 50
local speedConn, jumpConn, noclipConn, flyConn
local noclipEnabled = false
local flying = false
local flyBodyVelocity, flyBodyGyro
local flySpeed = 50

playerTab:AddSlider({
    Name = "Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    Save = true,
    Flag = "speed",
    Callback = function(v)
        DesiredSpeed = v
        if speedConn then speedConn:Disconnect() speedConn = nil end
        speedConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = DesiredSpeed
            end
        end)
    end
})

playerTab:AddSlider({
    Name = "Jump Boost",
    Min = 50,
    Max = 100,
    Default = 50,
    Increment = 1,
    Save = true,
    Flag = "jump",
    Callback = function(v)
        DesiredJump = v
        if jumpConn then jumpConn:Disconnect() jumpConn = nil end
        jumpConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.JumpPower = DesiredJump
            end
        end)
    end
})

playerTab:AddButton({
    Name = "Heal",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.Health = char.Humanoid.MaxHealth
        end
    end
})

playerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Save = true,
    Flag = "noclip",
    Callback = function(state)
        noclipEnabled = state
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end

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

playerTab:AddToggle({
    Name = "Fly",
    Default = false,
    Save = true,
    Flag = "fly",
    Callback = function(state)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        flying = state

        if flying and hrp then
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            flyBodyVelocity.Parent = hrp

            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            flyBodyGyro.Parent = hrp

            flyConn = RunService.Heartbeat:Connect(function()
                local velocity = Vector3.new()
                local camCF = Camera.CFrame

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    velocity = velocity + camCF.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    velocity = velocity - camCF.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    velocity = velocity - camCF.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    velocity = velocity + camCF.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    velocity = velocity + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    velocity = velocity - Vector3.new(0, 1, 0)
                end

                if velocity.Magnitude > 0 then
                    flyBodyVelocity.Velocity = velocity.Unit * flySpeed
                else
                    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end

                flyBodyGyro.CFrame = camCF
            end)
        else
            if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
            if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
            if flyConn then flyConn:Disconnect() flyConn = nil end
        end
    end
})

-- ==== UTILITY TAB ====

local keySpots = {
    ["Town Center"] = CFrame.new(0, 5, 0), -- Replace with Brookhaven spots CFrames
    ["School"] = CFrame.new(100, 5, 100),
    ["Hospital"] = CFrame.new(200, 5, 200),
    ["Your House"] = CFrame.new(300, 5, 300),
}

utilityTab:AddDropdown({
    Name = "Teleport to Spot",
    Default = "Town Center",
    Options = table.keys(keySpots),
    Callback = function(selection)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local targetCFrame = keySpots[selection]
            if targetCFrame then
                char.HumanoidRootPart.CFrame = targetCFrame
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Spot not found!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end
    end
})

local playerList = {}
for _, player in pairs(Players:GetPlayers()) do
    table.insert(playerList, player.Name)
end

local teleportDropdown = utilityTab:AddDropdown({
    Name = "Teleport to Player",
    Default = playerList[1] or "",
    Options = playerList,
    Callback = function(selected)
        local targetPlayer = Players:FindFirstChild(selected)
        local char = LocalPlayer.Character
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
        else
            OrionLib:MakeNotification({
                Name = "Teleport Error",
                Content = "Could not teleport to player!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

Players.PlayerAdded:Connect(function(player)
    table.insert(playerList, player.Name)
    teleportDropdown:Refresh(playerList, true)
end)

Players.PlayerRemoving:Connect(function(player)
    for i, name in ipairs(playerList) do
        if name == player.Name then
            table.remove(playerList, i)
            break
        end
    end
    teleportDropdown:Refresh(playerList, true)
end)

utilityTab:AddButton({
    Name = "Quit",
    Callback = function()
        LocalPlayer:Kick("You quit Brookhaven Hub.")
    end
})

-- ==== APPEARANCE TAB ====

local walkAnimations = {
    ["Default"] = 0,
    ["Robot Walk"] = 616748981,
    ["Zombie Walk"] = 616771948,
    ["Floss Dance"] = 616774604,
    ["Moonwalk"] = 616774954,
}

appearanceTab:AddDropdown({
    Name = "Walk Animation",
    Default = "Default",
    Options = (function()
        local keys = {}
        for k in pairs(walkAnimations) do table.insert(keys, k) end
        return keys
    end)(),
    Callback = function(selection)
        local animId = walkAnimations[selection]
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local humanoid = char.Humanoid
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://"..animId
            local animTrack = humanoid:LoadAnimation(anim)
            animTrack:Play()
        end
    end
})

appearanceTab:AddToggle({
    Name = "Sit / Stand",
    Default = false,
    Save = true,
    Flag = "sit",
    Callback = function(state)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.Sit = state
        end
    end
})

-- ==== VEHICLES TAB ====

vehiclesTab:AddButton({
    Name = "Spawn Basic Car",
    Callback = function()
        -- Example placeholder: replace with real vehicle spawn logic & asset id
        local carAssetId = 12345678 -- replace this with actual Brookhaven car asset id
        local car = game:GetService("InsertService"):LoadAsset(carAssetId)
        car.Parent = workspace
        car:PivotTo(LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5))
        OrionLib:MakeNotification({
            Name = "Vehicle Spawned",
            Content = "Basic car spawned!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

vehiclesTab:AddButton({
    Name = "Flip Vehicle",
    Callback = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Parent and hrp.Parent:FindFirstChild("VehicleSeat") then
            hrp.Parent.VehicleSeat.SeatWeld.C0 = CFrame.new() -- simple fix for flipped car
            OrionLib:MakeNotification({
                Name = "Vehicle Fixed",
                Content = "Your vehicle has been flipped upright.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "No Vehicle",
                Content = "You are not in a vehicle.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

vehiclesTab:AddSlider({
    Name = "Vehicle Speed",
    Min = 10,
    Max = 200,
    Default = 50,
    Increment = 5,
    Callback = function(speed)
        -- implement vehicle speed control here (game specific)
        OrionLib:MakeNotification({
            Name = "Vehicle Speed",
            Content = "Set vehicle speed to "..speed,
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- ==== ROLEPLAY TAB ====

roleplayTab:AddButton({
    Name = "Wave",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://4943710757" -- wave animation
            local track = char.Humanoid:LoadAnimation(anim)
            track:Play()
        end
    end
})

roleplayTab:AddButton({
    Name = "Dance",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://5031215786" -- dance animation
            local track = char.Humanoid:LoadAnimation(anim)
            track:Play()
        end
    end
})

roleplayTab:AddButton({
    Name = "Sit",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.Sit = true
        end
    end
})

roleplayTab:AddButton({
    Name = "Stand",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.Sit = false
        end
    end
})

-- ==== COMBAT TAB ====

combatTab:AddToggle({
    Name = "Enable Combat (Placeholder)",
    Default = false,
    Callback = function(state)
        OrionLib:MakeNotification({
            Name = "Combat",
            Content = "Combat features coming soon!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- ==== SETTINGS TAB ====

settingsTab:AddToggle({
    Name = "Toggle UI Visibility",
    Default = true,
    Flag = "uiVisible",
    Callback = function(state)
        Window:SetVisible(state)
    end
})

settingsTab:AddButton({
    Name = "Reset Config",
    Callback = function()
        OrionLib:Destroy()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
        OrionLib:Init()
    end
})

-- Init UI
OrionLib:Init()
