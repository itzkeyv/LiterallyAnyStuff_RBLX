local DialogueManager = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DialogueData = require(script.Parent.DialogueData)

-- Get SampleOption template safely
local DialogueSystem = ReplicatedStorage:WaitForChild("DialogueSystem")
local SampleOption = DialogueSystem.DialogueData:WaitForChild("SampleOption")

local function setText(textLabel, message)
	textLabel.Text = ""
	for i = 1, #message do
		textLabel.Text = string.sub(message, 1, i)
		task.wait(0.025)
	end
	-- Return a function to wait for completion
	return function()
		while textLabel.Text ~= message do
			task.wait()
		end
	end
end

function DialogueManager.StartDialogue(player, npc, onEnd)
	
	local completionEvent = Instance.new("BindableEvent")

	-- Early exit checks
	local npcName = npc.Name
	local dialogueTable = DialogueData.NPCDialogues[npcName]
	if not dialogueTable then
		if onEnd then task.defer(onEnd) end
		return
	end

	local character = player.Character
	if not character then
		if onEnd then task.defer(onEnd) end
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		if onEnd then task.defer(onEnd) end
		return
	end

	local dialogueGUI = player.PlayerGui:FindFirstChild("DialogueGui")
	if not dialogueGUI then
		if onEnd then task.defer(onEnd) end
		return
	end

	local dialogueFrame = dialogueGUI:FindFirstChild("DialogueFrame")
	if not dialogueFrame then
		if onEnd then task.defer(onEnd) end
		return
	end

	-- Get UI elements
	local characterName = dialogueFrame.CharacterName.Title
	local optionScroller = dialogueFrame.OptionScroller
	local message = dialogueFrame.Message
	local nextButton = dialogueFrame.NextButton

	-- Freeze player
	humanoid.WalkSpeed = 0
	humanoid.JumpHeight = 0

	-- Initialize dialogue
	dialogueGUI.Enabled = true
	characterName.Text = npcName
	dialogueFrame.Visible = true  -- Ensure frame is visible

	local currentIndex = 1
	local connections = {}

	local function cleanup()
		-- Disconnect all connections
		for _, conn in ipairs(connections) do
			if type(conn) == "userdata" and conn.Connected then
				conn:Disconnect()
			end
		end

		-- Restore player movement
		if humanoid and humanoid.Parent then
			humanoid.WalkSpeed = 16
			humanoid.JumpHeight = 7.2
		end

		-- Hide dialogue GUI
		dialogueGUI.Enabled = false

		-- Call completion callback
		if onEnd then
			task.defer(onEnd)
		end
	end
	
	-- Player leaving safety
	local playerLeaving = Players.PlayerRemoving:Connect(function(leavingPlayer)
		if leavingPlayer == player then
			cleanup()
		end
	end)
	table.insert(connections, playerLeaving)

	local function showDialogue(index)
		currentIndex = index
		local dialogue = dialogueTable[currentIndex]
		if not dialogue then
			cleanup()
			return
		end

		-- Clear existing options
		for _, child in ipairs(optionScroller:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		-- Reset UI state
		message.Text = ""
		nextButton.Visible = false
		optionScroller.Visible = false

		if dialogue.IsQuestion and dialogue.Options then
			-- Handle question with options
			setText(message, dialogue.Text or "")

			-- Create dynamic options
			optionScroller.Visible = true
			local yPosition = 0

			for i, optionData in ipairs(dialogue.Options) do
				-- Clone from verified template
				local option = SampleOption:Clone()
				option.Name = "Option"..i
				option.Text = optionData.Text
				option.Position = UDim2.new(0, 0, 0, yPosition)
				option.Parent = optionScroller

				connections["option"..i] = option.MouseButton1Click:Connect(function()
					optionScroller.Visible = false
					nextButton.Visible = false

					local function showResponseChain(idx)
						if idx > #optionData.Responses then
							-- After all responses, show NextButton for next dialogue
							nextButton.Visible = true
							connections.next = nextButton.MouseButton1Click:Once(function()
								if optionData.Next then
									showDialogue(optionData.Next)
								else
									cleanup()
								end
							end)
							return
						end

						-- Show current response
						setText(message, optionData.Responses[idx])()

						if idx < #optionData.Responses then
							-- Show NextButton for next response
							nextButton.Visible = true
							connections.next = nextButton.MouseButton1Click:Once(function()
								nextButton.Visible = false
								showResponseChain(idx + 1)
							end)
						else
							-- Last response - show NextButton for next dialogue
							nextButton.Visible = true
							connections.next = nextButton.MouseButton1Click:Once(function()
								if optionData.Next then
									showDialogue(optionData.Next)
								else
									cleanup()
								end
							end)
						end
					end

					showResponseChain(1)
				end)

				yPosition += option.Size.Y.Offset + 15
			end
		else
			-- Regular dialogue handling
			setText(message, dialogue.Text)()

			nextButton.Visible = true
			connections.next = nextButton.MouseButton1Click:Once(function()
				if dialogue.Next then
					showDialogue(dialogue.Next)
				else
					cleanup()
				end
			end)
		end

		-- Modify cleanup to fire completion event
		local originalCleanup = cleanup
		cleanup = function()
			-- Run original cleanup
			if originalCleanup then
				originalCleanup()
			end

			-- Cleanup player leaving connection
			if playerLeaving and playerLeaving.Connected then
				playerLeaving:Disconnect()
			end

			-- Fire completion event
			completionEvent:Fire()
			completionEvent:Destroy()
		end

		return completionEvent
	end

	showDialogue(1)
end

return DialogueManager
