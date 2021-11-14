using Chess
#include("pgn.jl")


b = fromfen("kbK5/pp6/1P6/8/8/8/8/R7 w - - 0 1") # Morphy's puzzle for white - checkmate in 2

f = fromfen("r1b1k2r/pp3ppp/5b2/3pN3/1qp5/8/P2NQPPP/2R2RK1 w kq - 0 16") # puzzle for winning material: 16. Nc6+ Qe7 17. Nxe7

# One of the ways to assess a chess position is to simply count material gain that can be achieved.
# Pieces are weighted the following way: pawn - 1, bishop & knight - 3, rook - 5, queen - 9
# For this problem let's assume that a mate gives 100

function find_solution(c_board)
    #Return either mating sequence or the sequence of best moves
    board = c_board
    array_of_moves = Move[]
    array_of_moves_algebraic = String[]
    max_moves = 3 # in chess notation 2 moves means -> 1. white black 2. white
    for i = 1:max_moves
        if isterminal(board) # check if the position is terminal
            return array_of_moves
        end
        best_move =findbestmove(board) # find the next best move
        push!(array_of_moves, best_move) # store the best next move
        push!(array_of_moves_algebraic, movetosan(board, best_move)) # store the best next move in the algebraic notation
        board = domove(board, best_move) # update the board

    end
    return array_of_moves_algebraic
end

function findbestmove(board)
    moves_list = moves(board) # list all possible moves_list
    (d, ) = size(moves_list)
    value_of_next_moves = zeros(d) # store the values of next moves
    i = 1
    gamma = 0.7
    for move in moves_list
        value_of_next_moves[i] = best_move(domove(board, move), gamma, 1) # find next best moves
        i = i +1
    end
    if sidetomove(board) == WHITE
        return moves_list[argmax(value_of_next_moves)] # return the move with the highest value for white
    else
        return return moves_list[argmin(value_of_next_moves)] # return the move with the lowest value for black
    end
end


function evaluate_position_white(b)
    if ischeckmate(b)
        return 100.0 #checkmates give the highest reward
    else
        pawns_score = sum(toarray(pawns(b, WHITE)))-sum(toarray(pawns(b, BLACK))) # one white pawn cost 1.0, one black -1.0
        bishop_score = 3*sum(toarray(bishops(b, WHITE)))-3*sum(toarray(bishops(b, BLACK)))# one white bishop cost 3.0, one black -3.0
        knights_score = 3*sum(toarray(knights(b, WHITE)))-3*sum(toarray(knights(b, BLACK)))# one white knight cost 3.0, one black -3.0
        rooks_score = 5*sum(toarray(rooks(b, WHITE)))-5*sum(toarray(rooks(b, BLACK)))# one white rook cost 5.0, one black -5.0
        queens_score = 9*sum(toarray(queens(b, WHITE)))-9*sum(toarray(queens(b, BLACK)))# one white queen cost 9.0, one black -9.0
        return pawns_score+bishop_score+knights_score+rooks_score+queens_score
    end
end

function evaluate_position_black(b)
    if ischeckmate(b)
        return -100.0
    else
        pawns_score = sum(toarray(pawns(b, WHITE)))-sum(toarray(pawns(b, BLACK)))
        bishop_score = 3*sum(toarray(bishops(b, WHITE)))-3*sum(toarray(bishops(b, BLACK)))
        knights_score = 3*sum(toarray(knights(b, WHITE)))-3*sum(toarray(knights(b, BLACK)))
        rooks_score = 5*sum(toarray(rooks(b, WHITE)))-5*sum(toarray(rooks(b, BLACK)))
        queens_score = 9*sum(toarray(queens(b, WHITE)))-9*sum(toarray(queens(b, BLACK)))
        return pawns_score+bishop_score+knights_score+rooks_score+queens_score
    end
end


function best_move(board, gamma, m)
    discount = gamma^m
    moves_list = moves(board)
    (d, ) = size(moves_list)
    value_of_next_moves = zeros(d) # store expected rewards here
    score = (sidetomove(board) == WHITE) ? evaluate_position_black(board) : evaluate_position_white(board) # choose the score
    if isterminal(board) #no more moves left to make
        return score
    end
    if isempty(moves_list) || d == 0 #no more moves left to make
        return score
    end
    if discount > 0.4
        if sidetomove(board) == WHITE
            score = evaluate_position_white(board)
            i = 1
            for move in moves_list
                value_of_next_moves[i] = score + discount*best_move(domove(board, move), gamma, m+1) # iterate further on to find optimal moves
                i = i +1
            end
            return maximum(value_of_next_moves) #return maximum score possible
        elseif sidetomove(board) == BLACK
            score = evaluate_position_black(board)
            i = 1
            for move in moves_list
                value_of_next_moves[i] = score + discount*best_move(domove(board, move), gamma, m+1)
                i = i +1
            end
            return minimum(value_of_next_moves) #return minimal score possible because black want minimize the score
        else
            return 0.0
        end
    else
        if sidetomove(board) == WHITE
            return evaluate_position_white(board)
        else
            return evaluate_position_black(board)
        end
    end
end

@show find_solution(b)
@show find_solution(f)
