-- Fly Script for Valex (toggle with F)
local lp = game.Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local flying = false
local speed = 50
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local ctrl = {f = 0, b = 0, l = 0, r = 0}

local bg, bv

function startFly()
    flying = true
    bg = Instance.new("BodyGyro", hrp)
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = hrp.CFrame

    bv = Instance.new("BodyVelocity", hrp)
    bv.velocity = Vector3.new(0, 0, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

    rs.RenderStepped:Connect(function()
        if not flying then return end
        bg.cframe = workspace.CurrentCamera.CFrame
        local moveDir = Vector3.new()
        moveDir = moveDir + (workspace.CurrentCamera.CFrame.LookVector * (ctrl.f - ctrl.b))
        moveDir = moveDir + (workspace.CurrentCamera.CFrame.RightVector * (ctrl.r - ctrl.l))
        bv.velocity = moveDir.unit * speed
    end)
end

function stopFly()
    flying = false
    if bg then bg:Destroy() end
    if bv then bv:Destroy() end
end

uis.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F then
        flying = not flying
        if flying then startFly() else stopFly() end
    elseif input.KeyCode == Enum.KeyCode.W then ctrl.f = 1
    elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = 1
    elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = 1
    elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 1
    end
end)

uis.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then ctrl.f = 0
    elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = 0
    elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = 0
    elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 0
    end
end)

print("✅ Fly script ready. Press F to toggle flying.")
