--ServerScriptService/PhysicsClassActivities
local module = {}

-- Cache services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local SEAT_PREFIX = "PhysicsSeat"
local PREP_TIME = 10  -- Time to sit down
local GAME_TIME = 60  -- Time to complete puzzle
local BASE_XP = 50
local QUESTIONS = {
	{
		answer = {4,4,4,3,3,3,3,1,3},
		image = "rbxassetid://131942420537737"
	},
	{
		answer = {4,4,4,3,1,3,1,2,1},
		image = "rbxassetid://104360910126803"
	},
	{
		answer = {4,4,4,1,3,1,3,3,2},
		image = "rbxassetid://106029376056466"
	}
}

-- Remote events management
local function setupRemotes()
	local PhysicRemotes = Instance.new("Folder")
	PhysicRemotes.Name = "PhysicRemotes"
	PhysicRemotes.Parent = ReplicatedStorage

	local UpdatePhysicsUI = Instance.new("RemoteEvent")
	UpdatePhysicsUI.Name = "UpdatePhysicsUI"
	UpdatePhysicsUI.Parent = PhysicRemotes

	local PhysicsSymbolChange = Instance.new("RemoteEvent")
	PhysicsSymbolChange.Name = "PhysicsSymbolChange"
	PhysicsSymbolChange.Parent = PhysicRemotes

	local ClosePhysicsUIEvent = Instance.new("RemoteEvent")
	ClosePhysicsUIEvent.Name = "ClosePhysicsUIEvent"
	ClosePhysicsUIEvent.Parent = PhysicRemotes

	return {
		UpdatePhysicsUI = UpdatePhysicsUI,
		PhysicsSymbolChange = PhysicsSymbolChange,
		ClosePhysicsUIEvent = ClosePhysicsUIEvent
	}
end

function module.startPhysicsClass(whiteboard)
	local PhysicRemotes = setupRemotes()
	local cleanupTasks = {}
	local surfaceGui = whiteboard:FindFirstChild("SurfaceGui")
	local reminderText = surfaceGui and surfaceGui:FindFirstChild("ReminderText")

	-- Track players during preparation phase
	local activePlayers = {}
	local connections = {}

	-- Find and prepare seats
	local seats = {}
	for _, seat in ipairs(workspace:GetDescendants()) do
		if seat:IsA("Seat") and seat.Name:find(SEAT_PREFIX) then
			seat.Disabled = false
			seat.Anchored = true
			table.insert(seats, seat)
		end
	end

	-- Create seat listeners
	local function handleSeat(seat)
		local connection = seat:GetPropertyChangedSignal("Occupant"):Connect(function()
			local occupant = seat.Occupant
			if not occupant then return end

			local player = Players:GetPlayerFromCharacter(occupant.Parent)
			if player and not activePlayers[player] then
				local humanoid = occupant.Parent:FindFirstChildOfClass("Humanoid")
				if not humanoid then return end

				humanoid.JumpPower = 0
				humanoid.WalkSpeed = 0

				activePlayers[player] = {
					symbols = table.create(9, 3),
					question = QUESTIONS[math.random(#QUESTIONS)],
					seat = seat,
					humanoid = humanoid
				}
			end
		end)
		table.insert(connections, connection)
	end

	for _, seat in ipairs(seats) do
		handleSeat(seat)
	end

	local function resetPlayerMovement(player)
		if activePlayers[player] then
			pcall(function()
				activePlayers[player].humanoid.JumpPower = 50
				activePlayers[player].humanoid.WalkSpeed = 16
			end)
			activePlayers[player] = nil
		end
		PhysicRemotes.ClosePhysicsUIEvent:FireClient(player)
	end

	-- Phase 3: Run preparation countdown
	if reminderText then
		for i = PREP_TIME, 1, -1 do
			reminderText.Text = `Sit down now! Class starts in {i} seconds...`
			task.wait(1)
		end
		reminderText.Text = "Good luck, students!"
	end

	-- Cleanup listeners
	for _, conn in ipairs(connections) do
		conn:Disconnect()
	end

	-- Start minigame for seated players
	for player in pairs(activePlayers) do
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			local question = activePlayers[player].question
			PhysicRemotes.UpdatePhysicsUI:FireClient(player, {
				type = "start",
				questionImage = question.image,
				timeLeft = GAME_TIME
			})
		end
	end

	-- Minigame logic
	local symbolChangeConnection = PhysicRemotes.PhysicsSymbolChange.OnServerEvent:Connect(function(player, buttonIndex, newValue)
		local playerData = activePlayers[player]
		if not playerData then return end

		playerData.symbols[buttonIndex] = newValue

		if table.concat(playerData.symbols) == table.concat(playerData.question.answer) then
			resetPlayerMovement(player)
			PhysicRemotes.ClosePhysicsUIEvent:FireClient(player, "Completed! +50 XP")

			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				local xp = leaderstats:FindFirstChild("XP")
				if xp then xp.Value += BASE_XP end
			end
		end
	end)

	-- Auto-close after timeout
	local timeoutTask = task.delay(GAME_TIME + 5, function()
		for player in pairs(activePlayers) do
			PhysicRemotes.ClosePhysicsUIEvent:FireClient(player, "Time's up!")
			resetPlayerMovement(player)
		end
	end)

	-- Cleanup function (modified to return cleanupTasks)
	cleanupTasks.close = function()
		symbolChangeConnection:Disconnect()
		task.cancel(timeoutTask)
		PhysicRemotes:Destroy()
		activePlayers = nil
	end

	return function()
		for _, task in pairs(cleanupTasks) do
			task()
		end
	end
end

return module
