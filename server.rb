require 'sinatra'
require 'json'
require_relative 'game'

games = Hash.new
games['0'] = Game.new

get '/' do
	redirect '/game.html'
end

get '/board/:game_id' do |game_id|
	games[game_id].board.to_json
end

post '/move/:game_id' do |game_id|
	move = params['move']
	from = move['0'].map(&:to_i)
	to = move['1'].map(&:to_i)
	begin
		games[game_id].move(from, to)
	rescue CheckersError => e
		p e
		e.inspect
	else
		'ok'
	end
end

