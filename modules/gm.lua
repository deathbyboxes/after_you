local fsm = require "modules.statemachine"

local M = {}

local turn_state = new fsm.create({
	events = {
		{ name = 'evaluate', 	from = 'player_turn', 	to = 'evaluating' 	},
		{ name = 'rotate', 		from = 'evaluating', 	to = 'player_turn'	},
		{ name = 'end_match', 	from = 'evaluating', 	to = 'match_end'	}	
	},
})

local player_controllers = {
	player1 = nil,
	player2 = nil
}

function M.init()

end

function M.are_players_set()
	for _,player in pairs(player_controllers) do
		if player == nil then return false end
	end
	return true
end

function M.assign_player(action)
	if player_controllers.player1 == nil then
		player_controllers.player1 = action.gamepad
		return
	elseif player_controllers.player2 == nil and player_controllers.player1 ~= action.gamepad then
		player_controllers.player2 = action.gamepad
		return
	end
end

return M