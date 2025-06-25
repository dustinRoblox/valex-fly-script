-- Universal Hub | OrionLib UI with Game Auto-Detection for All Games
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

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
local speedConn, jumpConn, noclipConn, infJumpConn

playerTab:AddSlider({
    Name = "Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(v)
        if speedConn then speedConn:Disconnect() end
        speedConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").WalkSpeed = v
            end
        end)
    end
})

playerTab:AddSlider({
    Name = "Jump Boost",
    Min = 50,
    Max = 100,
    Default = 50,
    Callback = function(v)
        if jumpConn then jumpConn:Disconnect() end
        jumpConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").JumpPower = v
            end
        end)
    end
})

local noclipEnabled = false
playerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
        noclipEnabled = state
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

playerTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(state)
        if infJumpConn then infJumpConn:Disconnect() end
        if state then
            infJumpConn = UserInputService.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChildOfClass("Humanoid") then
                    char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end
})

playerTab:AddTextbox({
    Name = "Teleport to Player",
    Default = "",
    TextDisappear = true,
    Callback = function(name)
        local plr = Players:FindFirstChild(name)
        if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:MoveTo(plr.Character.HumanoidRootPart.Position + Vector3.new(0,5,0))
        end
    end
})

-- Combat Tab
local combatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"})
local espConn
local espBoxes = {}

combatTab:AddToggle({
    Name = "ESP Boxes",
    Default = false,
    Callback = function(state)
        if espConn then espConn:Disconnect() end
        for _, box in pairs(espBoxes) do box:Remove() end
        espBoxes = {}
        if state then
            espConn = RunService.RenderStepped:Connect(function()
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                        local head = plr.Character.Head
                        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            if not espBoxes[plr] then
                                local box = Drawing.new("Square")
                                box.Color = Color3.fromRGB(0, 255, 0)
                                box.Thickness = 2
                                box.Filled = false
                                espBoxes[plr] = box
                            end
                            local box = espBoxes[plr]
                            box.Size = Vector2.new(50, 50)
                            box.Position = Vector2.new(pos.X - 25, pos.Y - 25)
                            box.Visible = true
                        elseif espBoxes[plr] then
                            espBoxes[plr].Visible = false
                        end
                    elseif espBoxes[plr] then
                        espBoxes[plr]:Remove()
                        espBoxes[plr] = nil
                    end
                end
            end)
        end
    end
})

combatTab:AddParagraph("Future Features", "More combat features coming soon!")

-- Utility Tab
local utilityTab = Window:MakeTab({Name = "Utility", Icon = "rbxassetid://4483345998"})
utilityTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(placeId, LocalPlayer)
    end
})

utilityTab:AddButton({
    Name = "Reset Character",
    Callback = function()
        LocalPlayer:LoadCharacter()
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
