local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local flying = false
local speed = 30 -- tweak this for faster/slower fly
local acceleration = 0.2

local velocity = Vector3.new()
local bodyGyro
local bodyVelocity

local controls = { forward = false, backward = false, left = false, right = false, up = false, down = false }

local function createBodies()
    bodyGyro = Instance.new("BodyGyro", hrp)
    bodyGyro.P = 5000
    bodyGyro.maxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.cframe = hrp.CFrame

    bodyVelocity = Instance.new("BodyVelocity", hrp)
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
end

local function destroyBodies()
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
end

local function updateVelocity(dt)
    local camCFrame = workspace.CurrentCamera.CFrame
    local moveDir = Vector3.new()

    if controls.forward then
        moveDir = moveDir + camCFrame.LookVector
    end
    if controls.backward then
        moveDir = moveDir - camCFrame.LookVector
    end
    if controls.left then
        moveDir = moveDir - camCFrame.RightVector
    end
    if controls.right then
        moveDir = moveDir + camCFrame.RightVector
    end
    if controls.up then
        moveDir = moveDir + Vector3.new(0, 1, 0)
    end
    if controls.down then
        moveDir = moveDir - Vector3.new(0, 1, 0)
    end

    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit * speed
    else
        moveDir = Vector3.new()
    end

    velocity = velocity:Lerp(moveDir, acceleration)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        flying = not flying
        if flying then
            createBodies()
        else
            destroyBodies()
            velocity = Vector3.new()
        end
    elseif input.KeyCode == Enum.KeyCode.W then
        controls.forward = true
    elseif input.KeyCode == Enum.KeyCode.S then
        controls.backward = true
    elseif input.KeyCode == Enum.KeyCode.A then
        controls.left = true
    elseif input.KeyCode == Enum.KeyCode.D then
        controls.right = true
    elseif input.KeyCode == Enum.KeyCode.E then
        controls.up = true
    elseif input.KeyCode == Enum.KeyCode.Q then
        controls.down = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then
        controls.forward = false
    elseif input.KeyCode == Enum.KeyCode.S then
        controls.backward = false
    elseif input.KeyCode == Enum.KeyCode.A then
        controls.left = false
    elseif input.KeyCode == Enum.KeyCode.D then
        controls.right = false
    elseif input.KeyCode == Enum.KeyCode.E then
        controls.up = false
    elseif input.KeyCode == Enum.KeyCode.Q then
        controls.down = false
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if flying and bodyVelocity and bodyGyro then
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
        updateVelocity(dt)
        bodyVelocity.Velocity = velocity
    end
end)

print("✅ Fly script loaded! Press F to toggle flying. Use WASD + E/Q to move.")
