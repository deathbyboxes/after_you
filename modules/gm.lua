local fsm = require "modules.statemachine"

local M = {}

M.turn_state = fsm.create({
	initial = 'player1',
	events = {
		{ name = 'rotate', 		from = 'player1', 						to = 'player2'		},
		{ name = 'rotate', 		from = 'player2', 						to = 'player1'		},
		{ name = 'end_match', 	from = { 'player1', 'player2' }, 		to = 'match_end'	},
		{ name = 'end_game', 	from = 'match_end', 					to = 'game_end'		},
		{ name = 'resume1', 	from = 'match_end', 					to = 'player1'		},
		{ name = 'resume2', 	from = 'match_end', 					to = 'player2'		},
		{ name = 'new_game', 	from = 'game_end', 						to = 'player1'		},
	},
	callbacks = {
		onrotate = function(self, event, from, to, message) 
			for _,player in pairs(M.players) do
				msg.post(player.ids[hash("/body")], "cycle_turn")
			end
		end,
		onend_match = function(self, event, from, to, message)
			M.score[M.match] = message
			M.players[message].points = M.players[message].points + 1
			M.match = M.match + 1
			msg.post("game:/gm_go", "update_score")
			for _,player in pairs(M.players) do
				msg.post(player.ids[hash("/body")], "end_match", {last_player = from})
			end
		end,
		onleavematch_end = function(self, event, from, to)
			if to ~= "game_end" then
				msg.post("main:/loader", "restart_game")
			end
		end,
		onend_game = function(self, event, from, to, message)
			msg.post("game:/gm_go", "end_game", { winner = message })
		end
	},
})

M.players = {
	{num = 1, points = 0},
	{num = 2, points = 0}
}

M.match = 1

M.score = { 0,0,0,0,0 }

M.door_loc = 0

M.player_depth = {
	bg = { y = 288, z = -0.005 },
	fg = { y = 275, z =  0.005 },
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
	if M.players[1].gamepad == nil then
		M.players[1].gamepad = action.gamepad
		return true
	elseif M.players[2].gamepad == nil and M.players[1].gamepad ~= action.gamepad then
		M.players[2].gamepad = action.gamepad
		return true
	end
	return false
end

function M.set_player_loc(player_num, location)
	M.players[player_num].location = location
end

function M.check_locs()
	local cur_player = {}
	local oth_player = {}
	for i,player in pairs(M.players) do
		if M.turn_state:is("player".. i) then
			cur_player = player
		else
			oth_player = player
		end
	end

	if cur_player.location.x > M.door_loc or cur_player.location.x < oth_player.location.x then
		M.turn_state:end_match(oth_player.num)
	else 
		M.turn_state:rotate()
	end
end

function M.check_score()
	for _,player in pairs(M.players) do
		if player.points > 2 then
			return player.num
		end
	end
end

function M.full_reset()
	for _,player in pairs(M.players) do
		player.points = 0
	end
	M.score = {0,0,0,0,0}
	M.match = 1
	M.door_loc = 0
	M.turn_state:new_game()
end

return M