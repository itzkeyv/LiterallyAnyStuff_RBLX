-- ReplicatedStorage.DialogueSystem.DialogueData
local DialogueData = {}

-- Sample NPC dialogue with 4 options
DialogueData.NPCDialogues = {
	["TheKiwi"] = {
		{ -- Index 1
			Text = "Hello! I'm Kiwi, the creator!",
			Next = 2
		},
		{ -- Index 2
			Text = "How may I help you?",
			IsQuestion = true,
			Options = {
				{
					Text = "How can I start playing this game?",
					Responses = {
						"Just like another Danganronpa RP games, you wait for a host",
						"If there's no host, check out our dizzy server and wait until there's a host",
						"If you wanna be a host, fill out the application!"
					},
					Next = 3
				},
				{
					Text = "Any new updates?",
					Responses = {
						"[24/9] Well, after completing class trial system, I'm now building the map",
						"You may take a look by touching the green pad at the exit of this lobby, its a free model teleporter that I'll remove later",
						"...You don't have to worry about the lag because I'm using a potato pc to make this game",
						"I use max quality when I test the game out, so if I don't lag, you are supposed to be fine too xd",
					},
					Next = 4
				},
				{
					Text = "Who built all of these stuff in the game?",
					Responses = {
						"I coded everything and built the school map with some free models",
						"However, this lobby was actually built by me and @hwv00 in 2021 with some minor changes (+ texture & optimization / lag reduce)",
						"We tried to a DR hosting game, but at that time I was only 15~16 high school kid with almost 0 coding experience",
						"So, to be honest, making this game kind of making my dream came true~",
					},
					Next = 5
				},
				{
					Text = "No questions",
					Responses = {"Come back anytime~"},
					Next = nil
				}
			}
		},
		{ -- Index 3
			Text = "... But if the game is already hosting, pray that the Host will allow late-joiners like you lol",
			Next = 6
		},
		{ -- Index 4
			Text = "... Right now, I'm still working on the game, thank you for trying this game out :3",
			Next = 6
		},
		{ -- Index 5
			Text = "I hope you like my game",
			Next = 6
		},
		{ -- Index 6
			Text = "Need anything else?",
			IsQuestion = true,
			Options = {
				{
					Text = "Yes",
					Responses = {"Ask away..."},
					Next = 2
				},
				{
					Text = "No",
					Responses = {"See you around!"},
					Next = nil
				}
			}
		}
	}
}

return DialogueData
