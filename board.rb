class Board
	def initialize
		setup_board
	end
	
	def height
		8
	end
	
	def width
		8
	end
	
	def setup_board
		@rows = Array.new(height) { Array.new(width) }
		[[:white, 0], [:black, width-3]].each do |color, base_row|
			(base_row...(base_row+3)).each do |row|
				(0...width).each do |col|
					if (row+col).even?
						@rows[row][col] = Piece.new(self, [row, col], color)
					end
				end
			end
		end
	end
	
	# Using only arrays and strings so that it may be easily converted
	# to json
	def raw_board
		@rows.map do |row|
			row.map do |piece|
				piece.nil? ? nil : [piece.color, piece.type]
			end
		end
	end
	
	def to_json
		raw_board.to_json
	end
	
	def clear
		(0...height).each do |row|
			(0...width).each do |col|
				@rows[row][col] = nil
			end
		end
	end
	
	def dup
		new_board = Board.new
		new_board.clear
		
		(0...height).each do |row|
			(0...width).each do |col|
				new_board[[row,col]] =
					self[[row,col]].nil? ? nil : self[[row,col]].dup(new_board)
			end
		end
		new_board
	end
	
	def pieces
		@rows.flatten.compact
	end
	
	def pieces_of_color(color)
		pieces.select do |piece|
			piece.color == color
		end
	end
	
	def [](pos)
		row, col = pos
		@rows[row][col]
	end
	
	def []=(pos,val)
		row, col = pos
		@rows[row][col] = val
	end
	
	def open?(pos)
		include?(pos) && !occupied?(pos)
	end
	
	def include?(pos)
		row, col = pos
		(0...height).include?(row) && (0...width).include?(col)
	end
	
	# If 'color' argument is nil, returns whether a piece is occupied by
	# any piece. If color is given, returns whether a piece is occupied
	# by a piece of the given color
	def occupied?(pos, color=nil)
		return false unless include?(pos)
		piece = self[pos]
		if color == nil
			piece != nil
		else
			piece != nil && piece.color == color
		end
	end
	
	def to_s
		@rows.each_with_index.map do |pieces, row|
			pieces.each_with_index.map do |piece, col|
				# (row+col).odd? ? "\u25A0".encode('utf-8') * 2 :
				# 	piece.nil? ? '  ' : piece.to_s
				(row+col).odd? ? '  ': piece.nil? ? '  ' : piece.to_s
			end.join
		end.join("\n") + "\n"
	end
end
