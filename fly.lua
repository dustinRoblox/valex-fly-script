local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer

-- Replace this with the actual RemoteEvent path you find in the game's ReplicatedStorage or wherever
local giveSeedEvent = game:GetService("ReplicatedStorage"):WaitForChild("GiveSeedEvent")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.T then
        -- Fire the event to give the seed "Candy Blossom"
        giveSeedEvent:FireServer("Candy Blossom")
        print("T pressed - fired GiveSeedEvent with Candy Blossom")
    end
end)
