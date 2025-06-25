local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Game Detection Setup
local placeId = game.PlaceId
local gameName = "Unknown Game"
pcall(function()
    gameName = MarketplaceService:GetProductInfo(placeId).Name
end)

local Window = OrionLib:MakeWindow({
    Name = "Universal Hub - " .. gameName,
    SaveConfig = true,
    ConfigFolder = "UniversalHub"
})

-- Main Tab
local mainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})
mainTab:AddLabel("Game Detected: " .. gameName)
mainTab:AddParagraph("Credits", "Made with OrionLib • Hub auto-adapts to all games")

-- Players Tab
local playerTab = Window:MakeTab({Name = "Players", Icon = "rbxassetid://4483345998"})
playerTab:AddSlider({
    Name = "Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(v)
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = v
        end
    end
})

playerTab:AddSlider({
    Name = "Jump Boost",
    Min = 50,
    Max = 100,
    Default = 50,
    Callback = function(v)
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.JumpPower = v
        end
    end
})

playerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
        if state then
            RunService.Stepped:Connect(function()
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        else
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
})

local infJumpConnection
playerTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(state)
        if infJumpConnection then
            infJumpConnection:Disconnect()
            infJumpConnection = nil
        end
        if state then
            infJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end
})

playerTab:AddButton({
    Name = "Teleport to Random Player",
    Callback = function()
        local others = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(others, plr)
            end
        end
        if #others > 0 then
            local randomPlayer = others[math.random(1, #others)]
            LocalPlayer.Character:MoveTo(randomPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
        end
    end
})

playerTab:AddTextbox({
    Name = "Teleport to Player (Exact Name)",
    Default = "",
    TextDisappear = true,
    Callback = function(name)
        local target = Players:FindFirstChild(name)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:MoveTo(target.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
        end
    end
})

-- Combat Tab
local combatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})
combatTab:AddToggle({
    Name = "ESP (Box)",
    Default = false,
    Callback = function(state)
        print("ESP toggled: ", state)
        -- Placeholder: ESP logic can be implemented per-game
    end
})

-- Utility Tab
local utilityTab = Window:MakeTab({Name = "Utility", Icon = "rbxassetid://4483345998"})
utilityTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(placeId, LocalPlayer)
    end
})

utilityTab:AddButton({
    Name = "Quit",
    Callback = function()
        LocalPlayer:Kick("You quit Universal Hub.")
    end
})

-- Settings Tab
local settingsTab = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483345998"})
settingsTab:AddButton({
    Name = "Reset Config",
    Callback = function()
        OrionLib:Destroy()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))():Init()
    end
})

mainTab:AddParagraph("Note", "Universal Hub loaded. Adapted for: " .. gameName)
OrionLib:Init()
