-- StarterPlayer/StarterPlayerScrtips/PhysicsClassUIHandler
local player = game:GetService("Players").LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local physicsUI = gui:WaitForChild("PhysicClassUI")
local MainFrame = physicsUI:WaitForChild("MainFrame")
local AnswerFrame = MainFrame:WaitForChild("AnswerFrame")
local ReminderText = MainFrame:WaitForChild("ReminderText")

-- Configuration
local SYMBOL_DATA = {
	[1] = {name = "Lightbulb", image = "rbxassetid://123972680563939"},
	[2] = {name = "Switch", image = "rbxassetid://126844909849375"},
	[3] = {name = "Wire", image = "rbxassetid://120111046993915"},
	[4] = {name = "Battery", image = "rbxassetid://81228430971338"}
}

-- Main loop to handle class sessions
while true do
	-- Wait for the Physics class to start (remotes created)
	local PhysicRemotes = game:GetService("ReplicatedStorage"):WaitForChild("PhysicRemotes")

	-- Initialize RemoteEvents
	local UpdatePhysicsUI = PhysicRemotes:WaitForChild("UpdatePhysicsUI")
	local PhysicsSymbolChange = PhysicRemotes:WaitForChild("PhysicsSymbolChange")
	local ClosePhysicsUIEvent = PhysicRemotes:WaitForChild("ClosePhysicsUIEvent")

	-- Track connections for this session
	local connections = {}
	local symbolButtons = {}

	-- Initialize buttons and events
	for i = 1, 9 do
		local button = AnswerFrame:WaitForChild("Symbol"..i)
		local currentSymbol = button:WaitForChild("CurrentSymbol")
		currentSymbol.Value = 3
		button.Image = SYMBOL_DATA[3].image

		local conn = button.MouseButton1Click:Connect(function()
			local newValue = (currentSymbol.Value % 4) + 1
			currentSymbol.Value = newValue
			button.Image = SYMBOL_DATA[newValue].image
			PhysicsSymbolChange:FireServer(i, newValue)
		end)
		table.insert(connections, conn)
	end

	-- UI Event Handlers
	local updateConn = UpdatePhysicsUI.OnClientEvent:Connect(function(data)
		-- Existing UI update logic
		if data.type == "start" then
			physicsUI.Enabled = true
		end
	end)
	table.insert(connections, updateConn)

	local closeConn = ClosePhysicsUIEvent.OnClientEvent:Connect(function(message)
		ReminderText.Text = message or ""
		task.wait(2)
		physicsUI.Enabled = false
	end)
	table.insert(connections, closeConn)

	-- Wait until class ends
	PhysicRemotes.Destroying:Wait()

	-- Cleanup
	for _, conn in ipairs(connections) do
		conn:Disconnect()
	end
	physicsUI.Enabled = false
end
