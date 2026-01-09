d"""
Module for chess game analysis.
"""

enum Pieces {
    w_pawn,
    w_rook,
    w_knight,
    w_bishop,
    w_queen,
    w_king,
    b_pawn,
    b_rook,
    b_knight,
    b_bishop,
    b_queen,
    b_king
}

fun is_white(piece:Pieces) {
    return piece in [Pieces.w_pawn, Pieces.w_rook, Pieces.w_knight, Pieces.w_bishop, Pieces.w_queen, Pieces.w_king]
}

fun piece2str(p:Pieces, p_for_pawn:Bool=true) {
    color = is_white(p) ? "\q033[37;100m" : "\q033[30;100m"
    switch(p) {
        case Pieces.w_pawn, Pieces.b_pawn: {
            if (p_for_pawn)
                return f"{color}p\q033[0m"
            return ""
        }
        case Pieces.w_rook, Pieces.b_rook: return f"{color}R\q033[0m"
        case Pieces.w_knight, Pieces.b_knight: return f"{color}N\q033[0m"
        case Pieces.w_bishop, Pieces.b_bishop: return f"{color}B\q033[0m"
        case Pieces.w_queen, Pieces.b_queen: return f"{color}Q\q033[0m"
        case Pieces.w_king, Pieces.b_king: return f"{color}K\q033[0m"
        default: {
            assert(false, "missing case")
            return "?"
        }
    }
}

class Move {
    fun Move(from:List, to:List, piece:Pieces, notation:String, check:Bool, mate:Bool, promotion_piece:[NilType,Pieces]=nil) {
        assert(from.length() == 2, "move starting position has to be 2d array of ints")
        assert(to.length() == 2, "move ending position has to be 2d array of ints")
        this.from = from
        this.to = to
        this.piece = piece
        this.notation = notation
        this.castle = false
        this.check = check
        this.mate = mate
        this.promotion_piece = promotion_piece
    }

    fun __String() {
        return piece2str(this.piece) ++ [this.from, this.to]
    }
}

class CastleMove : Move {
    fun CastleMove(short:Bool, white:Bool, notation:String, check:Bool, mate:Bool) {
        this.castle = true
        this.short = short
        this.white = white
        this.notation = notation
        this.check = check
        this.mate = mate
        this.promotion_piece = nil
    }

    fun __String() {
        return this.short ? "[short castle]" : "[long castle]"
    }
}

class Game {

    enum Result {
        NOT_FINISHED
        DRAW
        WHITE_WIN
        BLACK_WIN
    }

    fun Game(moves:List, result:Result=Result.NOT_FINISHED) {
        this.moves = moves
        this.result = result
    }

    fun __String() {
        mnum = 1
        i = 0
        txt = ""
        while (i < this.moves.length()) {
            txt ++= mnum ++ ". " ++ this.moves[i]
            i += 1
            if (i < this.moves.length()) {
                txt ++= ", " ++ this.moves[i]
                i += 1
            }
            txt ++= "\n"
            mnum += 1
        }
        txt ++= f"Result: {this.result}\n"
        return txt
    }
}

class Board {
    
    fun Board(game:Game) {
        this.game = game
        this.index = 0
        this.board = [
            [Pieces.w_rook, Pieces.w_knight, Pieces.w_bishop, Pieces.w_queen, Pieces.w_king, Pieces.w_bishop, Pieces.w_knight, Pieces.w_rook],
            [Pieces.w_pawn, Pieces.w_pawn,   Pieces.w_pawn,   Pieces.w_pawn,  Pieces.w_pawn, Pieces.w_pawn,   Pieces.w_pawn,   Pieces.w_pawn],
            [nil,         nil,           nil,           nil,          nil,         nil,           nil,           nil                        ],
            [nil,         nil,           nil,           nil,          nil,         nil,           nil,           nil                        ],
            [nil,         nil,           nil,           nil,          nil,         nil,           nil,           nil                        ],
            [nil,         nil,           nil,           nil,          nil,         nil,           nil,           nil                        ],
            [Pieces.b_pawn, Pieces.b_pawn,   Pieces.b_pawn,   Pieces.b_pawn,  Pieces.b_pawn, Pieces.b_pawn,   Pieces.b_pawn,   Pieces.b_pawn],
            [Pieces.b_rook, Pieces.b_knight, Pieces.b_bishop, Pieces.b_queen, Pieces.b_king, Pieces.b_bishop, Pieces.b_knight, Pieces.b_rook],
        ]
    }

    fun apply_move(move:Move) {
        if (move.castle) {
            if (move.short and move.white) {
                this.board[0][6] = Pieces.w_king
                this.board[0][4] = nil
                this.board[0][5] = Pieces.w_rook
                this.board[0][7] = nil
            } else if (not move.short and move.white) {
                this.board[0][2] = Pieces.w_king
                this.board[0][4] = nil
                this.board[0][3] = Pieces.w_rook
                this.board[0][0] = nil
            } else if (move.short and not move.white) {
                this.board[7][6] = Pieces.b_king
                this.board[7][4] = nil
                this.board[7][5] = Pieces.b_rook
                this.board[7][7] = nil
            } else {
                this.board[7][2] = Pieces.b_king
                this.board[7][4] = nil
                this.board[7][3] = Pieces.b_rook
                this.board[7][0] = nil
            }   
        } else {
            if (move.promotion_piece != nil) {
                this.board[move.to[1]][move.to[0]] = move.promotion_piece
            } else {
                this.board[move.to[1]][move.to[0]] = this.board[move.from[1]][move.from[0]]
            }
            this.board[move.from[1]][move.from[0]] = nil
        }
    }

    fun move(num:Int=1) {
        moves = this.game.moves
        while (num > 0 && this.index < moves.length()) {
            ~this.apply_move(moves[this.index])
            this.index += 1
            num -= 1
        }
    }

    fun __String() {
        txt = ""
        for (row: this.board[-1..-this.board.length()-1]) {
            for (p: row) {
                if (p == nil)
                    txt ++= "  "
                else
                    txt ++= piece2str(p, true) ++ " "
            }
            txt ++= "\n"
        }
        return txt
    }
}

space pgn {

enum TokenType {
    MOVE_NUMBER,
    COLUMN,
    ROW,
    PIECE,
    CHECK,
    MATE,
    RESULT,
    TAKES,
    PROMOTION,
    SHORT_CASTLE,
    LONG_CASTLE,
    WS,
    END
}

class PGNScanner {
    
    class PGNToken {
        fun PGNToken(type:TokenType, value:String) {
            this.type = type
            this.value = value
        }

        fun __String() {
            return "(" ++ this.type ++ ")" ++ this.value
        }
    }

    fun PGNScanner(txt:String) {
        this.txt = txt
        this.tokens = []
        this.curr_token = 0
        ~this.tokenize(txt)
    }

    fun tokenize(txt:String) {
        i = 0
        while (i < txt.length()) {
            c = txt[i]
            token = nil
            if (ord(c) >= 48 and ord(c) <= 57) { // "0" - "9"
                if (i+4 < txt.length() && txt[i..i+5] == "0-0-0") {
                    token = PGNToken(TokenType.LONG_CASTLE, "0-0-0")
                    i += 4
                } else if (i+2 < txt.length() && txt[i..i+3] == "0-0") {
                    token = PGNToken(TokenType.SHORT_CASTLE, "0-0")
                    i += 2
                } else if (i+1 < txt.length() && (txt[i+1] == "." || (ord(txt[i+1]) >= 48 && ord(txt[i+1]) <= 57))) {
                    num = c
                    i += 1
                    while (ord(txt[i]) >= 48 and ord(txt[i]) <= 57) {
                        num ++= txt[i]
                        i += 1
                    }
                    assert(txt[i] == ".", "Expected '.' after move number")
                    token = PGNToken(TokenType.MOVE_NUMBER, num++".")
                } else if (i+1 < txt.length() && txt[i+1] == "-") { // 1-0, 0-1
                    assert(i + 2 < txt.length(), "Incorrect result")
                    res = txt[i..i+3]
                    assert(res == "1-0" or res == "0-1", "Incorrect result value")
                    token = PGNToken(TokenType.RESULT, res)
                    i += 2
                } else if (i+1 < txt.length() && txt[i+1] == "/") { // 1/2-1/2
                    assert(i + 6 < txt.length(), "Incorrect draw result")
                    res = txt[i..i+7]
                    assert(res == "1/2-1/2", "Incorrect draw result value")
                    token = PGNToken(TokenType.RESULT, res)
                    i += 6
                } else {
                    assert(c != "9" and c != "0", "Rows are 1 to 9, but found: "++c)
                    token = PGNToken(TokenType.ROW, c)
                }
            } else if (ord(c) >= 97 and ord(c) <= 104) { // a-h
                token = PGNToken(TokenType.COLUMN, c)
            } else if (i+4 < txt.length() && txt[i..i+5] == "O-O-O") {
                token = PGNToken(TokenType.LONG_CASTLE, "O-O-O")
                i += 4
            } else if (i+2 < txt.length() && txt[i..i+3] == "O-O") {
                token = PGNToken(TokenType.SHORT_CASTLE, "O-O")
                i += 2
            } else {
                type = nil
                switch(c) {
                    case " ", "\t", "\n": type = TokenType.WS
                    case "K", "Q", "R", "B", "N": type = TokenType.PIECE
                    case "+": type = TokenType.CHECK
                    case "#": type = TokenType.MATE
                    case "x": type = TokenType.TAKES
                    case "*": type = TokenType.RESULT
                    case "=": type = TokenType.PROMOTION
                    default: assert(false, "Unknown symbol: " ++ c)
                }
                token = PGNToken(type, c)
            }
            ~this.tokens.append(token)
            i += 1
        }
    }

    fun advance() {
        if (this.curr_token >= this.tokens.length()) {
            return PGNToken(TokenType.END, "")
        }
        t = this.tokens[this.curr_token]
        this.curr_token += 1
        return t
    }

    fun check(type:TokenType) {
        if (this.curr_token >= this.tokens.length()) {
            return type == TokenType.END
        }
        return this.tokens[this.curr_token].type == type
    }

    fun expect(type:TokenType, msg:String) {
        t = this.advance()
        assert(t.type == type, msg)
        return t.value
    }

    fun skip_ws() {
        while(this.check(TokenType.WS)) {
            ~this.advance()
        }
    }

    fun __String() {
        txt = "["
        first = true
        for (t: this.tokens) {
            if (not first)
                txt ++= ", "
            txt ++= t
            first = false
        }
        txt ++= "]"
        return txt
    }
}

space {

fun letter2piece(l:String, white:Bool) {
    switch(l) {
        case "p": return white ? Pieces.w_pawn : Pieces.b_pawn
        case "K": return white ? Pieces.w_king : Pieces.b_king
        case "Q": return white ? Pieces.w_queen : Pieces.b_queen
        case "B": return white ? Pieces.w_bishop : Pieces.b_bishop
        case "R": return white ? Pieces.w_rook : Pieces.b_rook
        case "N": return white ? Pieces.w_knight : Pieces.b_knight
        default: assert(false, f"Unknown piece: '{l}'")
    }
    return nil
}

fun piece2letter(piece:Pieces) {
    switch(piece) {
        case Pieces.w_pawn, Pieces.b_pawn: return "p"
        case Pieces.w_king, Pieces.b_king: return "K"
        case Pieces.w_queen, Pieces.b_queen: return "Q"
        case Pieces.w_bishop, Pieces.b_bishop: return "B"
        case Pieces.w_rook, Pieces.b_rook: return "R"
        case Pieces.w_knight, Pieces.b_knight: return "N"
        default: assert(false, f"Unknown piece: '{piece}'")
    }
    return nil
}

fun get_piece_dst(board:Board, piece:Pieces) {
    squares = []
    brd = board.board
    row_num = 0
    for (r: brd) {
        col_num = 0
        for (p: r) {
            if (p == piece) {
                switch (p) {
                    // TODO: Dont add impossible moves
                    case Pieces.w_pawn: {
                        ~squares.append([[col_num, row_num + 1], [col_num, row_num]])
                        if (row_num == 1)
                            ~squares.append([[col_num, row_num + 2], [col_num, row_num]])
                        // No need to add take move as it has to have 'x'
                    }
                    case Pieces.b_pawn: {
                        ~squares.append([[col_num, row_num - 1], [col_num, row_num]])
                        if (row_num == 6)
                            ~squares.append([[col_num, row_num - 2], [col_num, row_num]])
                    }
                    case Pieces.w_rook, Pieces.b_rook: {
                        for (d : [[1, 0], [-1, 0], [0, -1], [0, 1]]) {
                            dx, dy = d
                            for (i : 1 .. 8) {
                                x = col_num + dx * i
                                y = row_num + dy * i
                                // Skip if out of board bounds
                                if (x < 0 or x >= 8 or y < 0 or y >= 8) {
                                    break
                                }

                                target = brd[y][x]

                                if (target == nil) {
                                    ~squares.append([[x, y], [col_num, row_num]])
                                } else {
                                    // Stop if the piece is the same color
                                    if (is_white(p) == is_white(target))
                                        break
                                    ~squares.append([[x, y], [col_num, row_num]])
                                    break
                                }
                            }
                        }
                    }
                    case Pieces.w_knight, Pieces.b_knight: {
                        ~squares.append([[col_num + 2, row_num + 1], [col_num, row_num]])
                        ~squares.append([[col_num + 2, row_num - 1], [col_num, row_num]])
                        ~squares.append([[col_num - 2, row_num + 1], [col_num, row_num]])
                        ~squares.append([[col_num - 2, row_num - 1], [col_num, row_num]])
                        ~squares.append([[col_num + 1, row_num + 2], [col_num, row_num]])
                        ~squares.append([[col_num + 1, row_num - 2], [col_num, row_num]])
                        ~squares.append([[col_num - 1, row_num + 2], [col_num, row_num]])
                        ~squares.append([[col_num - 1, row_num - 2], [col_num, row_num]])
                        // No need to not add squares if it is occupied by same color piece as this is used to
                        // decide which knight to move and then it has to be specified in the notation
                    }
                    case Pieces.w_bishop, Pieces.b_bishop: {
                        for (d : [[1, 1], [-1, 1], [1, -1], [-1, -1]]) {
                            dx, dy = d
                            for (i : 1 .. 8) {
                                x = col_num + dx * i
                                y = row_num + dy * i
                                // Skip if out of board bounds
                                if (x < 0 or x >= 8 or y < 0 or y >= 8) {
                                    break
                                }

                                target = brd[y][x]

                                if (target == nil) {
                                    ~squares.append([[x, y], [col_num, row_num]])
                                } else {
                                    // Stop if the piece is the same color
                                    if (is_white(p) == is_white(target))
                                        break
                                    ~squares.append([[x, y], [col_num, row_num]])
                                    break
                                }
                            }
                        }
                    }
                    case Pieces.w_queen, Pieces.b_queen: {
                        // bishop moves
                        for (d : [[1, 1], [-1, 1], [1, -1], [-1, -1], [1, 0], [-1, 0], [0, -1], [0, 1]]) {
                            dx, dy = d
                            for (i : 1 .. 8) {
                                x = col_num + dx * i
                                y = row_num + dy * i
                                // Skip if out of board bounds
                                if (x < 0 or x >= 8 or y < 0 or y >= 8) {
                                    break
                                }

                                target = brd[y][x]

                                if (target == nil) {
                                    ~squares.append([[x, y], [col_num, row_num]])
                                } else {
                                    // Stop if the piece is the same color
                                    if (is_white(p) == is_white(target))
                                        break
                                    ~squares.append([[x, y], [col_num, row_num]])
                                    break
                                }
                            }
                        }
                    }
                    case Pieces.w_king, Pieces.b_king: {
                        ~squares.append([[col_num + 1, row_num], [col_num, row_num]])     // right
                        ~squares.append([[col_num - 1, row_num], [col_num, row_num]])     // left
                        ~squares.append([[col_num, row_num + 1], [col_num, row_num]])     // up
                        ~squares.append([[col_num, row_num - 1], [col_num, row_num]])     // down
                        ~squares.append([[col_num + 1, row_num + 1], [col_num, row_num]]) // up-right
                        ~squares.append([[col_num - 1, row_num + 1], [col_num, row_num]]) // up-left
                        ~squares.append([[col_num + 1, row_num - 1], [col_num, row_num]]) // down-right
                        ~squares.append([[col_num - 1, row_num - 1], [col_num, row_num]]) // down-left
                    }
                }
            }
            col_num += 1
        }
        row_num += 1
    }
    return squares
}

fun find_source(board:Board, to:List, piece:Pieces, col, row) {
    brd = board.board
    possible = []
    row_num = 0
    for (r: brd) {
        col_num = 0
        for (p: r) {
            if (p == piece)
                ~possible.append([col_num, row_num])
            col_num += 1
        }
        row_num += 1
    }

    assert(possible.length() >= 1, f"Impossible move '{to}'")
    if (possible.length() == 1)
        return possible[0]
    filtered = []
    for (pos: possible) {
        if (col != nil && pos[0] == col) {
            ~filtered.append(pos)
        }
        if (row != nil && pos[1] == row) {
            ~filtered.append(pos)
        }
    }
    if (filtered.length() == 1) {
        return filtered[0]
    } else if (filtered.length() > 1) {
        assert(filtered.length() != 0, "0 length of filtered")
        highest = nil
        for (pos: filtered) {
            if (highest == nil) {
                highest = pos
                continue
            }
            if (is_white(piece)) {
                if (pos[1] > highest[1])
                    highest = pos
            } else {
                if (pos[1] < highest[1])
                    highest = pos
            }
        }
        assert(highest != nil, "nothing matched")
        return highest
    }

    dsts = get_piece_dst(board, piece)
    for (d: dsts) {
        if (to == d[0]) {
            return d[1]
        }
    }

    assert(false, f"Incorrectly specified move to: '{to}', piece: {piece}, col: {col}, row: {row}")
}

fun parse_move(scanner:PGNScanner, white:Bool, board:Board) {
    move = nil
    if (scanner.check(TokenType.SHORT_CASTLE)) {
        ~scanner.advance()
        // TODO: Add check and mate check
        move = CastleMove(true, white, "0-0", false, false)
    }
    else if (scanner.check(TokenType.LONG_CASTLE)) {
        ~scanner.advance()
        // TODO: Add check and mate check
        move = CastleMove(false, white, "0-0-0", false, false)
    } else {
        piece = nil
        column1 = nil
        column2 = nil
        row1 = nil
        row2 = nil
        takes = false
        promotion_piece = nil
        check = false
        mate = false
        if (scanner.check(TokenType.PIECE)) {
            t = scanner.advance()
            assert(t.value != "p", "p should not be in PGN")
            piece = letter2piece(t.value, white)
        }
        if (scanner.check(TokenType.COLUMN)) {
            column1 = scanner.advance().value
            if (scanner.check(TokenType.COLUMN)) {
                assert(piece != nil, "Piece specification without piece")
                column2 = scanner.advance().value
            }
        }
        if (scanner.check(TokenType.ROW)) {
            if (column1 == nil) {
                assert(piece != nil, "Piece specification without piece")
                row1 = scanner.advance().value
                column2 = scanner.expect(TokenType.COLUMN, "Expected target square (column) after piece specification")
                row2 = scanner.expect(TokenType.ROW, "Expected target square (row) after piece specification")
            } else if (column2 == nil) {
                row1 = scanner.advance().value
            } else
                row2 = scanner.advance().value
        }
        if (scanner.check(TokenType.TAKES)) {
            assert(column1 != nil or row1 != nil or piece != nil, "takes without specifying who")
            ~scanner.advance()
            takes = true
            column2 = scanner.expect(TokenType.COLUMN, "Expected target square (column) after 'x'")
            row2 = scanner.expect(TokenType.ROW, "Expected target square (row) after 'x'")
        }
        if (scanner.check(TokenType.PROMOTION)) {
            assert(column1 != nil or row1 != nil or piece != nil, "promotes without specifying who")
            ~scanner.advance()
            promotion_piece = scanner.expect(TokenType.PIECE, "Expecting piece name after promotion")
        }
        if (scanner.check(TokenType.CHECK)) {
            ~scanner.advance()
            check = true
        }
        if (scanner.check(TokenType.MATE)) {
            ~scanner.advance()
            mate = true
        }
        notation = ""
        notation ++= piece != nil ? piece2letter(piece) : ""
        notation ++= column1 != nil ? column1 : ""
        notation ++= row1 != nil ? row1 : ""
        notation ++= takes ? "x" : ""
        notation ++= column2 != nil ? column2 : ""
        notation ++= row2 != nil ? row2 : ""
        if (promotion_piece != nil) {
            notation ++= "="++promotion_piece
        }
        notation ++= check ? "+" : ""
        notation ++= mate ? "#" : ""
        
        from = nil
        to = nil
        if (piece == nil)
            piece = white ? Pieces.w_pawn : Pieces.b_pawn
        if (row1 != nil)
            row1 = Int(row1) - 1
        if (column1 != nil)
            column1 = ord(column1) - 97
        if (row2 != nil)
            row2 = Int(row2) - 1
        if (column2 != nil)
            column2 = ord(column2) - 97

        if (column2 != nil && row2 != nil) {
            to = [column2, row2]
            if (column1 != nil && row1 != nil) {
                from = [column1, row1]
            } else {
                from = find_source(board, to, piece, column1, row1)
            }
        } else {
            to = [column1, row1]
            from = find_source(board, to, piece, nil, nil)
        }

        promo_piece = nil
        if (promotion_piece != nil) {
            promo_piece = letter2piece(promotion_piece, white)
        }
        move = Move(from, to, piece, notation, check, mate, promo_piece)
    }
    ~board.apply_move(move)
    return move
}

}

fun parse_pgn(game:String) {
    // TODO: Remove tags
    // TODO: Remove comments
    scanner = pgn.PGNScanner(game)
    moves = []
    result = Game.Result.NOT_FINISHED
    game = Game([], Game.Result.NOT_FINISHED)
    board = Board(game)
    // Parse tokens
    while (not scanner.check(TokenType.END)) {
        ~scanner.skip_ws()
        if (scanner.check(TokenType.MOVE_NUMBER)) {
            // Assert move number?
            ~scanner.advance()
            ~scanner.skip_ws()
            ~moves.append(parse_move(scanner, true, board))
            ~scanner.expect(TokenType.WS, "Expected white space after move")
            ~scanner.skip_ws()
            if (scanner.check(TokenType.END))
                break
            if (scanner.check(TokenType.RESULT))
                continue
            ~moves.append(parse_move(scanner, false, board))
        } else if (scanner.check(TokenType.RESULT)) {
            t = scanner.advance()
            switch(t.value) {
                case "*": result = Game.Result.NOT_FINISHED
                case "1-0": result = Game.Result.WHITE_WIN
                case "0-1": result = Game.Result.BLACK_WIN
                case "1/2-1/2": result = Game.Result.DRAW
                default: assert(false, "Incorrect result in RESULT")
            }
        } else {
            assert(false, "Misplaced token: "++scanner.advance())
        }
    }
    return Game(moves, result)
}

}