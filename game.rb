require_relative 'piece'
require_relative 'board'

class CheckersError < RuntimeError; end
class InvalidMoveError < CheckersError; end
class MissingPieceError < CheckersError; end
class WrongPieceError < CheckersError; end

class Game
	attr_reader :board, :player
	def initialize
		@player = :black
		@board = Board.new
	end
	
	def move(from, to)
		piece = board[from]
		
		# No piece at "from"
		raise MissingPieceError.new(from) if piece.nil?
		
		# Piece picked is of the wrong color
		raise WrongPieceError.new(piece) if piece.color != @player
		
		jump_move = !possible_jump_moves.empty?
		
		# If there is a jump move possible, make sure this move is a jump move
		if jump_move
			raise InvalidMoveError.new([from,to]) unless
				piece.possible_jumps.include?(to)
		end
		
		# Now perform the move
		piece.perform_moves([to])
		
		# Swap the player unless the last move was a jump, and there
		# are more jumps possible.
		swap_player unless jump_move && !piece.possible_jumps.empty?
	end
	
	def swap_player
		@player = player == :white ? :black : :white
	end
	
	def jump_move?(move)
		piece, to = move
		piece.possible_jumps.include?(to)
	end
	
	def possible_jump_moves
		board.pieces_of_color(@player).flat_map do |piece|
			piece.possible_jumps.map do |move|
				[piece, move]
			end
		end
	end
	
	def possible_moves
		board.pieces_of_color(@player).flat_map do |piece|
			piece.possible_moves.map do |move|
				[piece, move]
			end
		end
	end
	
	def game_over?
		possible_moves.empty?
	end
	
	def winner
		return nil if !game_over?
		@player == :white ? :black : :white
	end
end

if __FILE__ == $PROGRAM_NAME
	g = Game.new
	p g.possible_moves
	puts g.board
end