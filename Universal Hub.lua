-- Universal Hub with Troll Tab
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Create Window
local Window = OrionLib:MakeWindow({
    Name = "Universal Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "UniversalHubConfig",
    IntroEnabled = true,
    IntroText = "Welcome to Universal Hub!",
    IntroIcon = "rbxassetid://4483345998",
    Icon = "rbxassetid://4483345998"
})

-- Troll Tab
local trollTab = Window:MakeTab({
    Name = "Troll",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Fake Admin Tag
local function createFakeAdminTag()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not char:FindFirstChild("Head") then return end

    if char.Head:FindFirstChild("FakeAdminTag") then
        char.Head.FakeAdminTag:Destroy()
    end

    local tag = Instance.new("BillboardGui", char.Head)
    tag.Name = "FakeAdminTag"
    tag.Size = UDim2.new(0, 100, 0, 40)
    tag.StudsOffset = Vector3.new(0, 2.5, 0)
    tag.AlwaysOnTop = true

    local label = Instance.new("TextLabel", tag)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "[ADMIN]"
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold

    OrionLib:MakeNotification({
        Name = "Troll Activated",
        Content = "You now have a fake [ADMIN] tag.",
        Image = "rbxassetid://4483345998",
        Time = 4
    })
end

-- Add Admin Tag Button
trollTab:AddButton({
    Name = "Fake Admin Overhead Tag",
    Callback = createFakeAdminTag
})

-- Explode Yourself
trollTab:AddButton({
    Name = "Explode Yourself",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part:BreakJoints()
                    part.Velocity = Vector3.new(math.random(-50,50), math.random(50,100), math.random(-50,50))
                end
            end
        end
    end
})

-- Fake Ban UI
trollTab:AddButton({
    Name = "Fake Ban UI",
    Callback = function()
        local screen = Instance.new("ScreenGui", game.CoreGui)
        screen.Name = "FakeBanScreen"

        local frame = Instance.new("Frame", screen)
        frame.Size = UDim2.new(0.5, 0, 0.3, 0)
        frame.Position = UDim2.new(0.25, 0, 0.35, 0)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BorderSizePixel = 0

        local text = Instance.new("TextLabel", frame)
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = "\u26a0\ufe0f You've been BANNED from Roblox\nReason: Trolling too hard \ud83d\ude40"
        text.TextColor3 = Color3.fromRGB(255, 0, 0)
        text.Font = Enum.Font.GothamBold
        text.TextScaled = true
        text.TextWrapped = true

        wait(5)
        screen:Destroy()
    end
})

-- Flop Mode (ragdoll spam)
trollTab:AddToggle({
    Name = "Flop Mode",
    Default = false,
    Callback = function(state)
        if state then
            while state do
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
                end
                wait(1)
                state = trollTab.Flags["Flop Mode"].Value
            end
        end
    end
})

-- Finalize UI
OrionLib:Init()
