--In character model!
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DialogueManager = require(ReplicatedStorage.DialogueSystem.DialogueManager)
local character = script.Parent
local proximityPrompt = character:WaitForChild("ProximityPrompt")

-- Track players in dialogue
local inDialogue = {}

proximityPrompt.Triggered:Connect(function(player)
	if inDialogue[player] then return end
	inDialogue[player] = true
	proximityPrompt.Enabled = false

	-- Start dialogue with completion callback
	DialogueManager.StartDialogue(player, character, function()
		proximityPrompt.Enabled = true
		inDialogue[player] = nil
	end)
end)
