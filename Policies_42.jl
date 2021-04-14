include("CantStop.jl")
module Policies_42 #Replace 42 by your groupe number
using ..CantStop # to access function exported from CantStop

"""
You have to define a policy for each question
    (you can reuse code, or even use the same policy for multiple questions
    by copy-pasting)

A policy is a set of two functions with the same name (arguments described later) :

- The first function is called once the dices are thrown.
It take as argument a game_state called gs and an admissible movements set.
It return the index of the admissible movements chosen as an integer.

- The second function is called to choose to stop the turn or continue with a new throw.
It take as argument a game_state and return a boolean: true if you stop, false if you continue.

A admissible movement sets is given as a vector of tuple. Each of the tuple being
an admissible movement offered by the throw.
Eg : adm_movement = [(4),(6,6),(5,7)]. In this case
returning 1 mean that you move your tentative marker on column 4 by 1;
returning 2 mean that you move twice on column 6;
returning 3 mean that you move on 5 and 7.

A game_state is an "object" defined in the module CantStop.
It has the following useful fields
    players_position :: Array{Int,2} # definitive position at start of turn
    tentitative_movement:: Array{Int,1} # tentitative position for active player
    non_terminated_columns :: Array{Int,1} #columns that have not been claimed yet
    nb_player :: Int #number of players in the game
    open_columns :: Array{Int,1} #columns open during this turn (up to 3)
    active_player :: Int #index of active player


For example:
gs.tentitative_movement is a vector of 12 integer.
gs.tentitative[4] is the number of tentitative move done during this turn in column 4.
gs.players_position[i,j] is the position of the definitive marker of player i in column j
gs.open_column = [2,5] means that, during this turn, there is non-null tentitative
movement in column 2 and 5.

Finally you can access the length of column j by column_length[j].
"""
function policy_q1(gs::game_state, adm_movement)
    return 1 #choose the first admissible movement offered
end
function policy_q1(gs::game_state)
    return (sum(gs.tentitative_movement) > 2)
end

function best_policy(p)
    k = 1/log(1/p)
    part_ent = floor(k)
    if part_ent > p/(1-p)
        return part_ent
    else
        return part_ent + 1
    end
end
#Question 2
function policy_q2(gs::game_state, adm_movement)
    return 1
end
function policy_q2(gs::game_state)
    return (sum(gs.tentitative_movement) > 2)
end

function find_best(G, p)
    turn = [1/p]
    policy = [[1]]
    for k in 2:G
        best = min(minimum([turn[i] + turn[k-i] for i in 1:length(turn)]), 1/(p^k))
        if best == 1/(p^k)
            push!(policy, [k])
        else
            
            poli = argmin([turn[i] + turn[k-i] for i in 1:length(turn)])
            push!(policy, vcat(policy[poli], policy[k-poli]))
        end
        push!(turn, best)
    end
    return turn, policy
end

println(find_best(7, 3/4))

#Question 3
function policy_q3(gs::game_state, adm_movement)
    return 1
end
function policy_q3(gs::game_state)
    return (sum(gs.tentitative_movement) > 2)
end

function proba(i, j, k)
    p = 0
    l = []
    for a in 1:6
        for b in 1:6
            for c in 1:6
                for d in 1:6
                    if ((a+b == i) || (a+b == j) || (a+b == k) || (a+c == i)
                        || (a+c == j) || (a+c == k) || (a+d == i) || (a+d == j)
                        || (a+d == k) || (b+c == i) || (c+b == j) || (c+b == k)
                        || (c+d == i) || (c+d == j) || (d+c == k)
                        || (b+d == i) || (b+d == j) || (d+b == k))
                        p += 1
                    end
                end
            end
        end
    end
    return p / 6^4
end

function proba2(i, j, k)
    p = 0
    for a in 1:6
        for b in 1:6
            for c in 1:6
                for d in 1:6
                    if ((equal(a, b, i, j, k) && equal(c, d, i, j, k)) 
                        || (equal(a, c, i, j, k) && equal(b, d, i, j, k))
                        || (equal(a, d, i, j, k) && equal(b, c, i, j, k)))
                        p += 1
                    end
                end
            end
        end
    end
    return p / 6^4
end

function equal(a, b, i, j, k)
    return (a+b == i || a+b == j || a+b == k)
    
end

println(proba(6, 7, 8))
println(proba2(6, 7, 8))


#Question 4
function policy_q4(gs::game_state, adm_movement)
    return 1
end
function policy_q4(gs::game_state)
    return (sum(gs.tentitative_movement) > 2)
end

function find_best_game(i, j, k, ki, kj, kk)
        
end

#Question 5
function policy_q5(gs::game_state, adm_movement)
    return 1
end
function policy_q5(gs::game_state)
    return (sum(gs.tentitative_movement) > 2)
end

#Question 6
function policy_q6(gs::game_state, adm_movement)
    return 1
end
function policy_q6(gs::game_state)
    return (sum(gs.tentitative_movement) > 2)
end

#Question 7
function policy_q7(gs::game_state, adm_movement)
    return 1
end
function policy_q7(gs::game_state)
    return (sum(gs.tentitative_movement) > 2)
end

#Question 8
function policy_q8(gs::game_state, adm_movement)
    return 1
end
function policy_q8(gs::game_state)
    return (sum(gs.tentitative_movement) > 2)
end

end #end of module
