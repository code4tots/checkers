require_relative 'piece'
require_relative 'board'

class Game
	attr_accessor :board
	def initialize
		@player = :black
		@board = Board.new
	end
	
	def possible_moves
		board.pieces_of_color(@player).flat_map do |piece|
			piece.possible_moves.map do |move|
				[piece, move]
			end
		end
	end
end

b = Board.new

puts b

b[[2,0]].perform_moves([[3,1]])
puts '-----------------------'
puts b

b[[5,1]].perform_moves([[4,2]])
puts '-----------------------'
puts b

p b[[4,2]].possible_moves


b[[4,2]].perform_moves([[2,0]])
puts '-----------------------'
puts b
