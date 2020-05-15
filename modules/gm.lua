local fsm = require "modules.statemachine"

local M = {}

local turn_state = new fsm.create({
	initial = 'all_turn'
	events = {
		{ name = 'evaluate', 	from = {'player_turn', 'all_turn'}, 	to = 'evaluating' 	},
		{ name = 'rotate', 		from = 'evaluating', 					to = 'player_turn'	},
		{ name = 'end_match', 	from = 'evaluating', 					to = 'match_end'	}	
	},
})

function M.init()

end

return M