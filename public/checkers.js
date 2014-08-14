var nrows, ncols, rectHeight, rectWidth, board, pieces, srow, scol;

function drawRectangle(row, col, style) {
	board.drawRect({
		fillStyle : style,
		y : rectHeight * (row+0.5),
		x : rectWidth * (col+0.5),
		width : rectWidth,
		height : rectHeight
	})
}

function drawCircle(row, col, style) {
	board.drawEllipse({
		fillStyle : style,
		y : rectHeight * (row+0.5),
		x : rectWidth * (col+0.5),
		width : rectWidth * 0.75,
		height : rectHeight * 0.75
	})
}

function drawBoard() {
	for (r = 0; r < nrows; r++) {
		for (c = 0; c < ncols; c++) {
			
			var style = (
				(r == srow && c == scol) ? '#aa0' :
				((r+c)%2 == 0) ? '#02A' : '#500')
			drawRectangle(r, c, style)
		}
	}
}

function drawPieces() {
	for (r = 0; r < nrows; r++) {
		for (c = 0; c < ncols; c++) {
			piece = pieces[r][c]
			if (piece != null) {
				var style = piece[0]
				drawCircle(r, c, style)
			}
		}
	}
}

function drawAll() {
	drawBoard()
	drawPieces()
}

function updateBoard() {
	$.get("board/0", function (data) {
		pieces = JSON.parse(data)
		drawAll()
	})
}

function clickedSquare(row, col) {
	if ((row+col)%2 == 0) {
		console.log("clicked: " + row + " " + col)
		if (srow == -1) {
			// If there is no selection, set this click as selection
			srow = row
			scol = col
			drawAll()
		} else {
			// There is a previous selection
			var move = [[srow,scol], [row, col]]
			
			$.post("move/0", {move : move}, function(data) {
				debugger
				console.log("recieved back from server: " + data)
				srow = -1
				updateBoard()
			})
		}
	} else {
		// If you click on invalid square,
		// just reset previous selection
		srow = -1
		drawAll()
	}
	
}

$(document).ready(function() {
	// hardcoded for now
	nrows = 8
	ncols = 8
	
	// initialize some global variables
	board = $("#board")
	rectHeight = board.height() / nrows
	rectWidth = board.width() / ncols
	
	// srow == -1 implies there is nothing selected
	srow = -1
	scol = -1
	
	// Set handler on board so that we take action when clicked.
	board.click(function(e) {
		var x = e.pageX - board.offset().left
		var y = e.pageY - board.offset().top
		var row = Math.floor(y / rectHeight)
		var col = Math.floor(x / rectWidth)
		clickedSquare(row, col)
	})
	
	// Get and print the state of the board
	updateBoard()
})