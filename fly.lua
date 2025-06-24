local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local flying = false
local speed = 30
local acceleration = 0.2
local velocity = Vector3.new(0,0,0)

local bodyGyro
local bodyVelocity

local controls = { forward = false, backward = false, left = false, right = false, up = false, down = false }

-- GUI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyToggleGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 120, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Text = "Fly: OFF"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextScaled = true
toggleButton.Parent = screenGui

function createBodies()
    bodyGyro = Instance.new("BodyGyro", hrp)
    bodyGyro.P = 5000
    bodyGyro.maxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.cframe = hrp.CFrame

    bodyVelocity = Instance.new("BodyVelocity", hrp)
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Velocity = Vector3.new(0,0,0)
end

function destroyBodies()
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
end

function updateVelocity(dt)
    local camCFrame = workspace.CurrentCamera.CFrame
    local moveDir = Vector3.new(0,0,0)
    if controls.forward then moveDir = moveDir + camCFrame.LookVector end
    if controls.backward then moveDir = moveDir - camCFrame.LookVector end
    if controls.left then moveDir = moveDir - camCFrame.RightVector end
    if controls.right then moveDir = moveDir + camCFrame.RightVector end
    if controls.up then moveDir = moveDir + Vector3.new(0,1,0) end
    if controls.down then moveDir = moveDir - Vector3.new(0,1,0) end

    moveDir = moveDir.Unit * speed
    if moveDir ~= moveDir then -- NaN check
        moveDir = Vector3.new(0,0,0)
    end

    velocity = velocity:Lerp(moveDir, acceleration)
end

-- Toggle fly function
local function toggleFly()
    flying = not flying
    if flying then
        toggleButton.Text = "Fly: ON"
        createBodies()
    else
        toggleButton.Text = "Fly: OFF"
        destroyBodies()
        velocity = Vector3.new(0,0,0)
    end
end

-- Button click event
toggleButton.MouseButton1Click:Connect(toggleFly)

-- Movement keys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then controls.forward = true
    elseif input.KeyCode == Enum.KeyCode.S then controls.backward = true
    elseif input.KeyCode == Enum.KeyCode.A then controls.left = true
    elseif input.KeyCode == Enum.KeyCode.D then controls.right = true
    elseif input.KeyCode == Enum.KeyCode.E then controls.up = true
    elseif input.KeyCode == Enum.KeyCode.Q then controls.down = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then controls.forward = false end
    if input.KeyCode == Enum.KeyCode.S then controls.backward = false end
    if input.KeyCode == Enum.KeyCode.A then controls.left = false end
    if input.KeyCode == Enum.KeyCode.D then controls.right = false end
    if input.KeyCode == Enum.KeyCode.E then controls.up = false end
    if input.KeyCode == Enum.KeyCode.Q then controls.down = false end
end)

RunService.Heartbeat:Connect(function(dt)
    if flying and bodyVelocity and bodyGyro then
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
        updateVelocity(dt)
        bodyVelocity.Velocity = velocity
    end
end)

print("GUI fly toggle loaded! Click the button to toggle flying.")
