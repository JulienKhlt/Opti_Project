module CantStop

export column_length, game_state, simulate_turn!, simulate_game!, test_policy

global column_length = Dict(2=>3,3=>5,4=>7,5=>9,6=>11,7=>13,
8=>11,9=>9,10=>7,11=>5,12=>3)

mutable struct game_state
    players_position :: Array{Int,2} # definitive position at start of turn
    tentitative_movement:: Array{Int,1} # tentitative position for active player
    non_terminated_columns :: Array{Int,1} #column that have not been claimed yet
    nb_player :: Int # number of player in the game
    open_columns :: Array{Int,1} #columns open during this turn (up to 3)
    active_player :: Int
    game_end :: Bool
    winner :: Int
    n_turn :: Int

    game_state(players_position :: Array{Int,2}, # definitive position at start of turn
    tentitative_movement:: Array{Int,1}, # tentitative position for active player
    non_terminated_columns :: Array{Int,1} ,#column that have not been claimed yet
    nb_player :: Int, # number of player in the game
    open_columns :: Array{Int,1}, #columns open during this turn (up to 3)
    active_player :: Int) = new(players_position, # definitive position at start of turn
    tentitative_movement, # tentitative position for active player
    non_terminated_columns , #column that have not been claimed yet
    nb_player , # number of player in the game
    open_columns , #columns open during this turn (up to 3)
    active_player,
    false,
    0,
    0 )
end

"""
create_non_terminated_columns(players_position :: Array,
tentitative_movement:: Array,
active_player ::Int)

determine which columns are not terminated for the given players_position, tentitative_movement
    and active player.
"""
function create_non_terminated_columns(players_position :: Array,
tentitative_movement:: Array,
active_player ::Int)
pos = convert.(Int,players_position)
tentitative = convert.(Int,tentitative_movement)
n = size(players_position)[1]
non_terminated_columns = []
    for j in 2:12
        not_terminated = true
        for i in 1:n
            not_terminated &= (pos[i,j] < column_length[j])
        end
        not_terminated &= (pos[active_player,j] + tentitative[active_player] < column_length[j])
        not_terminated && push!(non_terminated_columns,j)
    end
return non_terminated_columns
end
function create_non_terminated_columns(gs::game_state)
    return create_non_terminated_columns(gs.players_position,gs.tentitative_movement,gs.active_player)
end

"""
game_state constructors
"""
function game_state(players_position :: Array,
tentitative_movement:: Array = zeros(12),active_player ::Int = 1)
n = size(players_position)[1]
non_terminated_columns = create_non_terminated_columns(players_position,tentitative_movement,active_player)
return game_state(
    convert.(Int,players_position), #players_position
    convert.(Int,tentitative_movement), #tentitavive_position for player "active_player"
    convert.(Int,non_terminated_columns), #non_terminated_columns
    n, # nb_player
    Int[],#open_columns
    active_player #active_player
)
end
function game_state(n::Int)
    return game_state(zeros(n,12))
end





"""
check_game_state(game::game_state)

check if a current game position is admissible
"""
function check_game_state(game::game_state)
    n = game.nb_player
    for i in 1:n
        for j in 2:12
            if game.players_position[i,j] > column_length[j]
                error("player $i position $j above column length")
            elseif game.players_position[i,j] == column_length[j] && j in game.non_terminated_columns
                error("column $j should be terminated")
            end
        end
    end
    for j in 2:12
        i = game.active_player
        if game.players_position[i,j] + game.tentitative_movement[j] > column_length[j]
            error("Active player have a non legal tentitative movement at column $j")
        end
    end

    if length(game.open_columns) > 3
        error("Currently more than 3 open columns")
    end
    if game.active_player > game.nb_player
        error("active player number higher than number of player")
    end
    return true
end


########## DRAWING DICES AND OFFERING CHOICES ##################################

"""
create_key(D)

from a vector of 4 dices return the ordered choice
as a tuple of three tuple of two integer
"""
function create_key(D)
    length(D)!=4 && error("wrong number of dices thrown")
    sort!(D)
    if D[1]+D[4] <= D[2]+D[3]
        return ((D[1]+D[2],D[3]+D[4]),(D[1]+D[3],D[2]+D[4]),(D[1]+D[4],D[2]+D[3]))
    else
        return ((D[1]+D[2],D[3]+D[4]),(D[1]+D[3],D[2]+D[4]),(D[2]+D[3],D[1]+D[4]))
    end
end

"""
throw()

throw three possible dice coupling
"""
function throw()
    dices = rand(1:6,4)
    return create_key(dices)
end

"""
column_gap(j,gs)

test if column j can be pushed by testing if it is not terminated
and if there is enough gap to the top.
"""
function column_gap(j,gs)
    if !(j in gs.non_terminated_columns)
        return 0
    end
    i = gs.active_player
    gap = column_length[j] - (gs.players_position[i,j] + gs.tentitative_movement[j])

    if gap > 1
        return 2
    else
        return gap
    end
end


"""
add_gap_valid_movement!(adm_movement,gs,moves)

test, in a tuple of at most 2 moves, if there is enough gap
to add the moves
"""
function add_gap_valid_movement!(adm_movement,gs,moves)
    if (length(moves) == 1) && (column_gap(moves[1],gs) > 0)
        push!(adm_movement,moves)
    elseif (length(moves) == 2)
        if (moves[1]==moves[2])
            if column_gap(moves[1],gs) > 1
                push!(adm_movement,moves)
            elseif column_gap(moves[1],gs) == 1
                push!(adm_movement,(moves[1]))
            end
        else
            g1 = column_gap(moves[1],gs)
            g2 = column_gap(moves[2],gs)
            if (g1 > 0) && (g2>0)
                push!(adm_movement,moves)
            elseif (g1>0) && (g2==0)
                push!(adm_movement,(moves[1]))
            elseif (g1==0) && (g2>0)
                push!(adm_movement,(moves[2]))
            end
        end
    end
end

"""
add_admissible_movement!(adm_movement,gs,pair)

given a pair of column index return either
a tuple with both movement, two tuple with one movement,
one tuple with one movement or nothing depending on the gap
remaining and the open columns
"""
function add_admissible_movement!(adm_movement,gs,pair)
    if length(gs.open_columns ) < 2 # add the pair
        add_gap_valid_movement!(adm_movement,gs,pair)
    elseif length(gs.open_columns ) == 2
        if (pair[1] in gs.open_columns) || (pair[2] in gs.open_columns)
            add_gap_valid_movement!(adm_movement,gs,pair)
        else # add each movement separately
            add_gap_valid_movement!(adm_movement,gs,(pair[1]))
            add_gap_valid_movement!(adm_movement,gs,(pair[2]))
        end
    elseif length(gs.open_columns)  == 3
        if (pair[1] in gs.open_columns) && (pair[2] in gs.open_columns)
            add_gap_valid_movement!(adm_movement,gs,pair)
        elseif pair[1] in gs.open_columns
            add_gap_valid_movement!(adm_movement,gs,(pair[1]))
        elseif pair[2] in gs.open_columns
            add_gap_valid_movement!(adm_movement,gs,(pair[2]))
        end
    else
        l = length(gs.open_columns)
        error("$l open columns")
    end
end

"""
throw_admissible(gs::game_state)

throw for dices, and return all admissible movement for the current game_state
"""
function throw_admissible(gs::game_state)
    adm_movement = []
    key = throw()
    for pair in key
        add_admissible_movement!(adm_movement,gs,pair)
    end
    return adm_movement
end


################# UPDATING GAME STATE ##########################################

""" end_game(gs::game_state,verbose = 0)

 update gs.game_end ans gs.winner
"""
function end_game(gs::game_state,verbose = 0)
    for i in 1:gs.nb_player
        count = 0
        for j in 2:12
            gs.players_position[i,j] == column_length[j] && (count = count + 1)
        end
        if count > 2
            n = gs.n_turn
            verbose > 0 && println("player $i win the game in $n turns")
            gs.game_end = true
            gs.winner = i
        end
    end
end

"""
next_turn!(gs::game_state)

reset open_columns and tentitative_movement
change active player
"""
function next_turn!(gs::game_state)
    gs.open_columns=Int[]
    gs.tentitative_movement=convert.(Int,zeros(12))
    i = gs.active_player + 1
    i > gs.nb_player ? (gs.active_player = 1) : (gs.active_player = i)
    check_game_state(gs)
    gs.n_turn +=1
end

"""
next_turn_with_update!(gs::game_state)

turn tentitative movement into definite movement
reset open_columns and tentitative_movement
change active player
"""
function next_turn_with_update!(gs::game_state)
    gs.players_position[gs.active_player,:] += gs.tentitative_movement
    gs.non_terminated_columns = Int[]
    if !gs.game_end
        for j in 2:12 # updating non_terminated_columns
            maximum(gs.players_position[:,j]) < column_length[j] && push!(gs.non_terminated_columns,j)
        end
        next_turn!(gs)
    end
end

"""
move_tentitative_by_one!(gs::game_state,j)

tentitatively move one along column j
"""
function move_tentitative_by_one!(gs::game_state,j)
    gs.tentitative_movement[j] == 0 && push!(gs.open_columns,j)
    gs.tentitative_movement[j] += 1
end

"""
update_game_state!(gs::game_state,movement)

update the tentitative move or end
the turn resetting  if movement is empty
"""
function update_game_state!(gs::game_state,movement)
    if isempty(movement)
        next_turn!(gs)
    else
        i = gs.active_player
        for j in movement
            move_tentitative_by_one!(gs,j)
        end
    end

end


############ TURN AND GAME SIMULATION ##########################################

"""
simulate_turn!(gs::game_state,policy, verbose = 0)

simulate one turn according to a given policy
"""
function simulate_turn!(gs::game_state,policy, verbose = 0)
    verbose > 1 && println("player position :", gs.players_position)
    stop = false

    while(!stop)
        adm_movement = throw_admissible(gs::game_state)
        verbose > 4 && println("admissible movement",adm_movement)

        if length(adm_movement) > 0 # There is at least one admissible adm_movement
            i = policy(gs,adm_movement)
            if i <= length(adm_movement)
                move = adm_movement[i]
            else
                player = gs.active_player
                println("illegal movement by player $player")
                i = 1
            end
            verbose > 4 && println("movement chosen ",move)
            update_game_state!(gs,move)
            stop = policy(gs)
            verbose > 4 && println("do we stop: ", stop)
            if stop
                next_turn_with_update!(gs)
                verbose > 2 && println("stopping according to policy")
                #verbose > 1 && println("player position ",gs.players_position)
            end
        else
            next_turn!(gs)
            verbose > 2 && println("failed throw")
            break
        end
        verbose > 3 && println("tentitative movement :", gs.tentitative_movement)
        #verbose > 3 && println("open columns :", gs.open_columns)
    end

end
function simulate_turn!(gs::game_state,policies::Array, verbose = 0)
    simulate_turn!(gs,policies[gs.gs.active_player],verbose)
end

"""
simulate_game!(gs::game_state,policies,verbose = 0)

simulate a full game starting with game state gs, and using policies
(given as a vector of policy)
"""
function simulate_game!(gs::game_state,policies,verbose = 0)
    while (!gs.game_end) && (gs.n_turn < 1000)
        verbose > 1 && println(gs.n_turn)
        simulate_turn!(gs::game_state,policies[gs.active_player], verbose)
        verbose > 0 && println(gs.players_position)
        end_game(gs,verbose)
    end
    if verbose > 0
        n = gs.n_turn
        println("game ended in $n turns")
        for i in 1:gs.nb_player
            closed = [j for j in 2:12 if gs.players_position[i,j]==column_length[j]]
            println("Player $i closed ",closed)
        end
    end
end

"""
test_policy(policies,Nmc=1000)

policies is a vector of policy, one per player

the function simulate Nmc games returning
    nb_turns (a vector of the number of turns required for each game to end)
    winner (a vector giving the number of game won by each player)
"""
function test_policy(policies,Nmc=1000)
    nb_players = length(policies)
    nb_turns = []
    winner = zeros(nb_players)
    for i in 1:Nmc
        gs = game_state(nb_players)
        simulate_game!(gs,policies)
        push!(nb_turns,gs.n_turn)
        i = gs.winner
        i > 0 && (winner[i]+=1)
    end
    return nb_turns, winner
end
end #end of module

#### Testing

#column_length = Dict(2=>3,3=>5,4=>7,5=>9,6=>11,7=>13, 8=>11,9=>9,10=>7,11=>5,12=>3)
# pos = [ 0 0 0 0 5 10 10 10 0 0 0 0 ]
# gs = game_state(pos)
# check_game_state(gs)

#gs = game_state(1)
#simulate_game!(gs,[dummy_policy],1)

# nb_turns, winner = test_policy([dummy_policy,dummy_policy])
# println(winner)
# println(throw_admissible(gs::game_state))


# function dummy_policy(gs::game_state, adm_movement)
#     return 1
# end
# function dummy_policy(gs::game_state)
#     return (sum(gs.tentitative_movement) > 2)
# end
#
# #Initialising a one player game
# gs = game_state(1)
# #Simulating a game with the dummy policy
# #verbose define the printing level
# simulate_game!(gs,[dummy_policy], 3)

#using .CantStop
