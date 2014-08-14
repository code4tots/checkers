class InvalidMoveError < RuntimeError
end

class Piece
	##### public API #######
	attr_reader :board, :pos, :color, :type
	def initialize(board, pos, color, type=:man)
		@board = board
		@pos = pos
		@color = color
		@type = type
	end
	
	def dup(new_board)
		Piece.new(new_board, pos.dup, color, type)
	end
	
	def flipped_color
		color == :white ? :black : :white
	end
	
	def row
		@pos[0]
	end
	
	def col
		@pos[1]
	end
	
	def possible_moves
		jumps = possible_jumps
		jumps.empty? ? possible_slides : possible_jumps
	end
	
	def perform_moves(moves)
		raise InvalidMoveError if !valid_move_seq?(moves)
		perform_moves!(moves)
	end
	
	def to_s
		color[0] + type[0]
	end
	##### End of public API #######
	
	protected
	
	def possible_slides
		move_diffs.map do |dr, dc|
			[row + dr, col + dc]
		end.select do |new_pos|
			valid_move_seq?([new_pos])
		end
	end
	
	def possible_jumps
		move_diffs.map { |ds| ds.map { |d| d * 2 } }.map do |dr, dc|
			[row + dr, col + dc]
		end.select do |new_pos|
			valid_move_seq?([new_pos])
		end
	end
	
	
	def valid_move_seq?(moves)
		board.dup[pos].perform_moves!(moves)
	end
	
	def perform_moves!(moves)
		if moves.size == 1 && perform_slide(moves[0])
			if at_end?
				@type = :king
			end
			return true
		end
		
		moves.each do |move|
			unless perform_jump(move)
				return false
			end
			if at_end?
				@type = :king
			end
		end
		true
	end
	
	def perform_slide(new_pos)
		dr, dc = get_diffs(new_pos)
		dir = [dr, dc]
		return false unless move_diffs.include?(dir)
		
		new_pos = [row  + dr, col + dc]
		if board.open?(new_pos)
			board[pos] = nil
			board[new_pos] = self
			@pos = new_pos
			true
		else
			false
		end
	end
	
	def perform_jump(new_pos)
		dr, dc = get_diffs(new_pos).map { |d| d / 2 }
		dir = [dr, dc]
		return false unless move_diffs.include?(dir)
		
		jump_pos = [row + dr, col + dc]
		new_pos = [row + 2 * dr, col + 2 * dc]
		if board.occupied?(jump_pos, flipped_color) && board.open?(new_pos)
			board[jump_pos] = nil
			board[pos] = nil
			board[new_pos] = self
			@pos = new_pos
			true
		else
			false
		end
	end
	
	def get_diffs(new_pos)
		new_row, new_col = new_pos
		dr = new_row - row
		dc = new_col - col
		[dr, dc]
	end
	
	# Returns available directions a piece may move in.
	def move_diffs
		case type
		when :man
			[[forward, 1], [forward, -1]]
		when :king
			[-1, 1].product([-1, 1])
		end
	end
	
	# Determines which direction is forward depending on color of piece.
	def forward
		case color
		when :white
			1
		when :black
			-1
		end
	end
	
	# Determines whether this piece has reached the end of the board.
	def at_end?
		case color
		when :white
			row == board.height-1
		when :black
			row == 0
		end
	end
end