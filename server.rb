require 'sinatra'
require 'json'
require 'uri'
require_relative 'game'

games = Hash.new
(0...100).each do |i|
	games[i.to_s] = Game.new
end

get '/' do
	send_file File.join(settings.public_folder, 'index.html')
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
	end
end

