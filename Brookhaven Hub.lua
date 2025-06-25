-- Brookhaven Hub | OrionLib UI | Tabs: Utility, Appearance, Vehicles, Roleplay, Combat, Settings
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Window = OrionLib:MakeWindow({
    Name = "Brookhaven Hub",
    SaveConfig = true,
    ConfigFolder = "BrookhavenHub",
})

-- Utility Tab
local utilityTab = Window:MakeTab({Name = "Utility", Icon = "rbxassetid://4483345998"})
local keySpots = {
    ["Town Hall"] = CFrame.new(0, 5, 0),
    ["School"] = CFrame.new(100, 5, 100),
    ["Hospital"] = CFrame.new(200, 5, 200),
}

utilityTab:AddDropdown({
    Name = "Teleport to Spot",
    Options = table.keys(keySpots),
    Callback = function(selection)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = keySpots[selection]
        end
    end
})

local playerList = {}
for _, p in pairs(Players:GetPlayers()) do table.insert(playerList, p.Name) end

utilityTab:AddDropdown({
    Name = "Teleport to Player",
    Options = playerList,
    Callback = function(selected)
        local target = Players:FindFirstChild(selected)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
        end
    end
})

utilityTab:AddButton({
    Name = "Quit",
    Callback = function()
        LocalPlayer:Kick("You quit Brookhaven Hub.")
    end
})

-- Appearance Tab
local appearanceTab = Window:MakeTab({Name = "Appearance", Icon = "rbxassetid://4483345998"})
local walkAnimations = {
    ["Default"] = 0,
    ["Robot"] = 616748981,
    ["Zombie"] = 616771948,
}

appearanceTab:AddDropdown({
    Name = "Walk Animation",
    Options = table.keys(walkAnimations),
    Callback = function(selection)
        local id = walkAnimations[selection]
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. id
        local track = LocalPlayer.Character.Humanoid:LoadAnimation(anim)
        track:Play()
    end
})

appearanceTab:AddToggle({
    Name = "Sit/Stand",
    Default = false,
    Callback = function(state)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Sit = state
        end
    end
})

-- Vehicles Tab
local vehiclesTab = Window:MakeTab({Name = "Vehicles", Icon = "rbxassetid://4483345998"})

vehiclesTab:AddButton({
    Name = "Spawn Car (Placeholder)",
    Callback = function()
        print("Car would spawn here (add logic)")
    end
})

vehiclesTab:AddButton({
    Name = "Flip Car (Placeholder)",
    Callback = function()
        print("Car would flip here (add logic)")
    end
})

vehiclesTab:AddSlider({
    Name = "Vehicle Speed",
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(v)
        print("Set vehicle speed to", v)
    end
})

-- Roleplay Tab
local roleplayTab = Window:MakeTab({Name = "Roleplay", Icon = "rbxassetid://4483345998"})

roleplayTab:AddButton({ Name = "Wave", Callback = function()
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://4943710757"
    LocalPlayer.Character.Humanoid:LoadAnimation(anim):Play()
end })

roleplayTab:AddButton({ Name = "Dance", Callback = function()
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://5031215786"
    LocalPlayer.Character.Humanoid:LoadAnimation(anim):Play()
end })

roleplayTab:AddButton({ Name = "Sit", Callback = function()
    LocalPlayer.Character.Humanoid.Sit = true
end })

roleplayTab:AddButton({ Name = "Stand", Callback = function()
    LocalPlayer.Character.Humanoid.Sit = false
end })

-- Combat Tab
local combatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})

combatTab:AddToggle({
    Name = "Enable Combat (Placeholder)",
    Default = false,
    Callback = function(state)
        print("Combat Enabled:", state)
    end
})

-- Settings Tab
local settingsTab = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483345998"})

settingsTab:AddToggle({
    Name = "Toggle UI",
    Default = true,
    Callback = function(state)
        Window:SetVisible(state)
    end
})

settingsTab:AddButton({
    Name = "Reset Config",
    Callback = function()
        OrionLib:Destroy()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))():Init()
    end
})

OrionLib:Init()
