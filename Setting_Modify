local isConsole = game:GetService("UserInputService").GamepadEnabled
local isdesktop = game:GetService('UserInputService').KeyboardEnabled

-- set ShiftLock to left Ctrl

if isConsole == true then
	script.Parent:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController"):WaitForChild("BoundKeys").Value = "ButtonY"
elseif isdesktop == true then
	script.Parent:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController"):WaitForChild("BoundKeys").Value = "LeftControl"
end

-- turn off the chat history
local TextChatService = game:GetService("TextChatService")

local chatWindowConfiguration = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
chatWindowConfiguration.Enabled = false

-- disable reset button
local Gui = game:GetService("StarterGui")
Gui:SetCore("ResetButtonCallback" ,false)

task.wait(1)
script:Destroy() --buh bye no one needs you anymore
