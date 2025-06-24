local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer

-- Wait for the GiveSeed RemoteEvent in ReplicatedStorage (adjust path if needed)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local giveSeedEvent = ReplicatedStorage:WaitForChild("GiveSeed")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.T then
        -- Fire the event with the seed name "Candy Blossom"
        giveSeedEvent:FireServer("Candy Blossom")
        print("Seed 'Candy Blossom' given!")
    end
end)
