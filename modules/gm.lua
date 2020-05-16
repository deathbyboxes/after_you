local fsm = require "modules.statemachine"

local M = {}

local turn_state = new fsm.create({
	events = {
		{ name = 'evaluate', 	from = 'player_turn', 	to = 'evaluating' 	},
		{ name = 'rotate', 		from = 'evaluating', 	to = 'player_turn'	},
		{ name = 'end_match', 	from = 'evaluating', 	to = 'match_end'	}	
	},
})

M.players = {
	player1 = {},
	player2 = {}
}

function M.init()
	math.randomseed(os.time())
	math.random();math.random();math.random()
end

function M.are_players_set()
	for _,player in pairs(M.players) do
		if player.gamepad == nil then return false end
	end
	return true
end

function M.set_controller(action)
	if M.players.player1.gamepad == nil then
		M.players.player1.gamepad = action.gamepad
		return
	elseif M.players.player2.gamepad == nil and M.players.player1.gamepad ~= action.gamepad then
		M.players.player2.gamepad = action.gamepad
		return
	end
end

return M