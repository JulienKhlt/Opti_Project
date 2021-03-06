include("CantStop.jl")
module Policies_42 # Replace 42 by your groupe number
using ..CantStop # to access function exported from CantStop
using Distributions

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
    return 1 # choose the first admissible movement offered
end
function policy_q1(gs::game_state)
    return (sum(gs.tentitative_movement) > 2)
end

function best_policy(p)
    """function that gives you the best policy in the push your luck game with probability p of wining"""
    k = 1 / log(1 / p)
    part_ent = floor(k)
    if part_ent > p / (1 - p)
        return part_ent
    else
        return part_ent + 1
    end
end
# Question 2
function policy_q2(gs::game_state, adm_movement)
    return 1
end
function policy_q2(gs::game_state)
    return (sum(gs.tentitative_movement) > 2)
end

function find_best(G, p)
     """function that gives you the best policy in the push your luck game to obtain the number G when your probability of winning is p"""
    turn = [1 / p]
    policy = [[1]]
    for k in 2:G
        best = min(minimum([turn[i] + turn[k - i] for i in 1:length(turn)]), 1 / (p^k))
        if best == 1 / (p^k)
            push!(policy, [k])
        else
            
            poli = argmin([turn[i] + turn[k - i] for i in 1:length(turn)])
            push!(policy, vcat(policy[poli], policy[k - poli]))
        end
        push!(turn, best)
    end
    return turn, policy
end

# println(find_best(7, 3/4))

function throw(nb, p)
    d = Binomial(1, p)
    for _ in 1:nb
        if rand(d, 1)[1] == 0
            return false
        end
    end
    return true
end

function test(G, p)
    policy = find_best(G, p)[2]
    Throw = policy[length(policy)]
    turn = 0
    for t in 1:length(Throw)
        turn += 1
        while throw(Throw[t], p) != true
            turn += 1
        end
    end
    return turn
end

function Esp_test(G, p, nb)
    mean = 0
    for i in 1:nb
        mean += test(G, p)
    end
    return mean / nb
end

# println(test(7, 3/4))
# println(Esp_test(7, 3/4, 1000))

# Question 3
function policy_q3(gs::game_state, adm_movement)
    return 1
end
function policy_q3(gs::game_state)
    return (sum(gs.tentitative_movement) > 2)
end

function proba(i, j, k)
    """function that computes the exact proba of having either i, j or k"""
    p = 0
    l = []
    for a in 1:6
        for b in 1:6
            for c in 1:6
                for d in 1:6
                    if ((a + b == i) || (a + b == j) || (a + b == k) || (a + c == i)
                        || (a + c == j) || (a + c == k) || (a + d == i) || (a + d == j)
                        || (a + d == k) || (b + c == i) || (c + b == j) || (c + b == k)
                        || (c + d == i) || (c + d == j) || (d + c == k)
                        || (b + d == i) || (b + d == j) || (d + b == k))
                        p += 1
                    end
                end
            end
        end
    end
    return p / 6^4
end

function proba2(i, j, k)
    """function that computes the exact proba of having either i, j or k and i, j or k"""
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
    return (a + b == i || a + b == j || a + b == k)
end


# println(proba(6, 7, 8))
# println(proba2(6, 7, 8))


# Question 4
function policy_q4(gs::game_state, adm_movement)
    return 1
end
function policy_q4(gs::game_state)
    return (sum(gs.tentitative_movement) > 2)
end

function throw_multiple()
    """function that simulates a normal throw"""
    return rand(1:6), rand(1:6), rand(1:6), rand(1:6) 
end

function get_possibilities(a, b, c, d)
    """function that given a throw return the possible columns"""
    return [[a + b, c + d], [a + c, b + d], [a + d, b + c]]
end

function count(l, i, j, k)
    sum([l[n] == i for n in 1:length(l)]), sum([l[n] == j for n in 1:length(l)]), sum([l[n] == k for n in 1:length(l)])
end

function finish(V, i, j, k, ki, kj, kk)
    turn = 0
    ni = ki
    nj = kj
    nk = kk
    while ni != 1 || nj != 1 || nk != 1
        a, b, c, d = throw_multiple()
        l = get_possibilities(a, b, c, d)
        best = 10000
        ind = -1
        for n in 1:length(l)
            gi, gj, gk = count(l[n], i, j, k)
            if ni < gi + 1
                gi = ni - 1
            end
            if nj < gj + 1
                gj = nj - 1
            end
            if nk < gk + 1
                gk = nk - 1
            end
            if best > V[ni - gi, nj - gj, nk - gk] && (gi != 0 || gj != 0 || gk != 0)
                ind = n
                best = V[ni - gi, nj - gj, nk - gk]
            end
        end
        if ind == -1
            turn += 1
        else 
            gi, gj, gk = count(l[ind], i, j, k)
            if ni < gi + 1
                gi = ni - 1
            end
            if nj < gj + 1
                gj = nj - 1
            end
            if nk < gk + 1
                gk = nk - 1
            end
            ni -= gi
            nj -= gj
            nk -= gk
        end
    end
    return turn    
end

function mean(V, i, j, k, ki, kj, kk, nb)
    turn = 0
    for _ in 1:nb
        turn += finish(V, i, j, k, ki, kj, kk)
        
    end
    return turn / nb
end

function find_direct_game(i, j, k, ki, kj, kk, nb)
    V = zeros(ki, kj, kk)
    for n in 1:ki
        for m in 1:kj
            for o in 1:kk
                V[n, m, o] = mean(V, i, j, k, n, m, o, nb)
            end
        end
    end
    return V
end

function find_best_game(i, j, k, ki, kj, kk, nb)
    V = find_direct_game(i, j, k, ki, kj, kk, nb)
    S = zeros(CartesianIndex{3}, ki, kj, kk)
    for n in 1:ki
        for m in 1:kj
            for o in 1:kk
                B = [V[a, b, c] + V[n + 1 - a, m + 1 - b, o + 1 - c] for a in 1:n, b in 1:m, c in 1:o]
                V[n, m, o] = minimum(B)
                S[n, m, o] = findall(isequal(V[n, m, o]), B)[1]
            end
        end
    end
    return V, S
end

# println(find_direct_game(2, 3, 3, 4, 3, 3, 1000)[:, 1, 1])
# V, S = find_best_game(2, 7, 12, 2, 6, 2, 1000)
# println(V[2, 6, 2])



# Question 4 V2


function q4_dynamic(i, j, k, ri0, rj0, rk0, T)
    Vtplus1 = fill(0., (ri0 + 1, rj0 + 1, rk0 + 1, ri0 + 1, rj0 + 1, rk0 + 1))
    
    # (di,dj,dk,ri,rj,rk)
    # (avanc??e ?? ce tour sur i,j et k, cases restantes sur i,j et k)
    # index 1 correspond ?? ri = 0

    # Vtplus1[:,:,:,:,:,:] .= 0 # Initialisation "?? l'infini"
    Vt = fill(10000., (ri0 + 1, rj0 + 1, rk0 + 1, ri0 + 1, rj0 + 1, rk0 + 1))
    S = fill(false, (ri0 + 1, rj0 + 1, rk0 + 1, ri0 + 1, rj0 + 1, rk0 + 1))

    intermed = fill(10000., (ri0 + 1, rj0 + 1, rk0 + 1, ri0 + 1, rj0 + 1, rk0 + 1))

    for t in T - 1:-1:1
        # print(t, " ")
        compute_Vt(Vt, Vtplus1, t, i, j, k, ri0, rj0, rk0, S, t==1)
        intermed = Vtplus1
        Vtplus1 = Vt # On ne stocke pas tout pour pas trop saturer la ram et on utilise intermed pour eviter les copies.
        Vt = intermed
    end

    res = Vt[1, 1, 1, ri0 + 1, rj0 + 1, rk0 + 1]
    # println(res)
    Vt = nothing
    Vtplus1 = nothing
    return S[:, :, :, ri0+1, rj0+1, rk0+1]
end

function compute_Vt(Vt, Vtp1, t, i, j, k, ri0, rj0, rk0, S, strat)
    for ri in 0:ri0
        for rj in 0:rj0
            for rk in 0:rk0
                for di in 0:ri
                    for dj in 0:rj
                        for dk in 0:rk
                            @inbounds compute_min_actions(Vt, Vtp1, t, i, j, k, di, dj, dk, ri, rj, rk, S, strat)
                        end
                    end
                end
            end
        end
    end
end

function get_possibilities_and_legality(a, b, c, d, i, j, k)
    combis = [[a + b, c + d],[a + c, b + d],[a + d, b + c]]
    for x in 1:3
        for y in 1:2
            val = combis[x][y]
            if val == i || val == j || val == k
                return combis, true
            end
        end
    end
    return combis, false
end

function compute_min_actions(Vt, Vtp1, t, i, j, k, di, dj, dk, ri, rj, rk, S, strat)

    if ri == 0 && rj == 0 && rk == 0
        Vt[di + 1, dj + 1, dk + 1, ri + 1, rj + 1, rk + 1] = 0
        return
    end

    if_i_stop = 1 + Vtp1[1, 1, 1, ri - di + 1, rj - dj + 1, rk - dk + 1]

    nb_fail = 0
    if_i_throw_success_sum = 0
    
    nb_throws_tot = 6^4
    
    # for throw in 0:nb_throws_tot - 1
        # (a, b, c, d) = digits(throw, base=6, pad=4) .+ 1
    for a in 1:6
        for b in a:6
            for c in b:6
                for d in c:6
                    combis, legal = get_possibilities_and_legality(a, b, c, d, i, j, k)
                    fact = 0
                    if a == b && b == c && c == d
                        fact = 1
                    elseif a != b && b != c && c != d
                        fact = 24
                    elseif (a == b && c == d && a != c) || (a == c && b == d && a != b) || (a == d && c == b && a != c)
                        fact = 6
                    elseif (a == b && b == c && c != d) || (a == b && b == d && a != c) || (d == b && b == c && c != a) || (a == d && d == c && c != b)
                        fact = 4
                    elseif (a == b && a != c && a != d && c != d) || (a == c && a != b && a != d && b != d) || (a == d && a != c && a != b && c != b) || (b == c && b != a && b != d && a != d) || (b == d && b != a && b != c && a != c) || (c == d && b != a && b != c && a != c)
                        fact = 12
                    end
                    if legal
                        mini_val_combi = 10000
                        for (s1, s2) in combis
                            di_new, dj_new, dk_new = di, dj, dk
                            has_changed = false
                            
                            if s1 == i && ri > di_new
                                di_new += 1
                                has_changed = true
                            elseif s1 == j && rj > dj_new
                                dj_new += 1
                                has_changed = true
                            elseif s1 == k && rk > dk_new
                                dk_new += 1
                                has_changed = true
                            end
                            
                            if s2 == i && ri > di_new
                                di_new += 1
                                has_changed = true
                            elseif s2 == j && rj > dj_new
                                dj_new += 1
                                has_changed = true
                            elseif s2 == k && rk > dk_new
                                dk_new += 1
                                has_changed = true
                            end
                            
                            if has_changed
                                val_combi = Vtp1[di_new + 1,dj_new + 1,dk_new + 1,ri + 1,rj + 1,rk + 1]
                                if val_combi < mini_val_combi
                                    mini_val_combi = val_combi
                                end
                            end
                        end
                        if mini_val_combi < 10000
                            if_i_throw_success_sum += mini_val_combi * fact
                        else
                            nb_fail += 1 * fact
                        end
                    else
                        nb_fail += 1 * fact
                    end
                end
            end
        end
    end
        
    if_i_throw_fail_sum = nb_fail * (1 + Vtp1[1, 1, 1,ri + 1,rj + 1,rk + 1])
    if_i_throw = (if_i_throw_fail_sum + if_i_throw_success_sum) / (nb_throws_tot)

    # println(if_i_stop," ",if_i_throw)
    mini = min(if_i_stop, if_i_throw)

    Vt[di + 1,dj + 1,dk + 1,ri + 1,rj + 1,rk + 1] = mini
    if strat
        # if (ri == 3 && rj == 3 && rk == 3)
        #     # println("i ", di + 1)
        #     # println("j ", dj + 1)
        #     # println("k ", dk + 1)
        #     # println("eq ", (mini == if_i_stop))
        #     # println("mini ", mini)
        #     # println("if_i_stop ", if_i_stop)
        # end
        S[di + 1,dj + 1,dk + 1,ri + 1,rj + 1,rk + 1] = (mini == if_i_stop)
    end
end

# @time println(q4_dynamic(6, 7, 8, 3, 3, 3, 100))
# @time S = q4_dynamic(2, 7, 12, 3, 3, 3, 100)
# println()
# for i in 1:3
#     for j in 1:3
#         for k in 1:3
#             print(S[i, j, k])
#             print(" ")
#         end
#         println()
#     end
#     println()
#     println()
#     println()
# end
# @time S = q4_dynamic(6, 7, 9, 3, 3, 3, 100)
# println()
# for i in 1:3
#     for j in 1:3
#         for k in 1:3
#             print(S[i, j, k])
#             print(" ")
#         end
#         println()
#     end
#     println()
#     println()
#     println()
# end

function parser(lines)
    first_line = split(lines[1])
    ri, rj, rk = parse(Int, first_line[4]), parse(Int, first_line[5]), parse(Int, first_line[6])
    S = zeros(ri+1, rj+1, rk+1)
    for i ??? 1:ri+1
        for j ??? 1:rj+1
            line = split(lines[j+(i-1)*(4+rj)+1], ";")
            for k ??? 1:rk+1
                S[i, j, k] = parse(Int, line[k])
            end
        end
    end
    return S
end

function create_file(file, S, i, j, k, ri, rj, rk)
    write(file, "$(i) $(j) $(k) $(ri) $(rj) $(rk)\n")
    for ni in 1:ri+1
        for nj in 1:rj+1
            for nk in 1:rk+1
                write(file, "$(1*S[ni, nj, nk]);")
            end
            write(file, "\n")
        end
        write(file, "\n")
        write(file, "\n")
        write(file, "\n")
    end
end

function get_result_turn(i, j, k, ri, rj, rk)
    if isfile("matrix.txt")
        open("matrix.txt", "r") do file
            lines = readlines(file)
            first_line = split(lines[1])
            n = [parse(Int, first_line[1]), parse(Int, first_line[2]), parse(Int, first_line[3])]
            if i in n && j in n && k in n
                S = parser(lines)
                return S
            else
                open("matrix.txt", "w") do file
                    S = q4_dynamic(i, j, k, ri, rj, rk, 100)
                    create_file(file, S, i, j, k, ri, rj, rk)
                    return S
                end
            end
        end
    else
        open("matrix.txt", "w") do file
            S = q4_dynamic(i, j, k, ri, rj, rk, 100)
            create_file(file, S, i, j, k, ri, rj, rk)
            return S
        end
    end
end

# println(get_result_turn(3, 5, 4, 3, 3, 3))

function two_equal(column1, column2, column3)
    return (column1 == column2 || column1 == column3 || column2 == column3)
end

function reorder_two_equal(column1, column2, column3)
    if (column1 == column2)
        return column1, column2, column3, 2, 0
    elseif (column1 == column3)
        return column1, column3, column2, 1, 1
    elseif (column2 == column3)
        return column2, column3, column1, 1, 1
    end
end

function get_result_movement(movement, gs, i)
    if length(movement) == 1
        if i == 2
            column1 = gs.open_columns[1]
            column2 = gs.open_columns[2]
            column3 = movement[1]
            return get_score(column1, column2, column3, 0, 0, 1, gs)
        elseif i == 1
            column1 = gs.open_columns[1]
            column2 = movement[1]
            if column1 == column2
                return get_prev_score(column1, 1, gs)
            else
                return get_prev_score(column1, column2, 0, 1, gs)
            end
        else
            column1 = movement[1]
            return get_prev_score(column1, 1, gs)
        end
    elseif length(movement) == 2
        if i == 0
            column1 = movement[1]
            column2 = movement[2]
            if column1 != column2
                return get_prev_score(column1, column2, 1, 1, gs)
            else
                return get_prev_score(column1, 2, gs)
            end
        elseif i == 1
            column1 = movement[1]
            column2 = movement[2]
            column3 = gs.open_columns[1]
            if column1 == column2 && column2 == column3
                get_prev_score(column1, 2, gs)
            elseif column1 != column2 && column2 != column3 && column1 != column3
                return get_score(column1, column2, column3, 1, 1, 0, gs)
            elseif two_equal(column1, column2, column3)
                column1, column2, column3, move1, move2 = reorder_two_equal(column1, column2, column3)
                return get_prev_score(column1, column3, move1, move2, gs)
            end
        elseif i == 2
            column1 = movement[1]
            column2 = movement[2]
            column3 = gs.open_columns[1]
            column4 = gs.open_columns[2]
            if column1 == column2
                if column1 == column3
                    return get_prev_score(column1, column4, 2, 0, gs)
                elseif column1 == column4
                    return get_prev_score(column1, column3, 2, 0, gs)
                else
                    return get_score(column1, column4, column3, 2, 0, 0, gs)    
                end
            else
                if (column1 == column3 && column2 == column4) || (column1 == column4 && column2 == column3)
                    return get_prev_score(column1, column2, 1, 1, gs)
                elseif two_equal(column1, column3, column4) || two_equal(column2, column3, column4)
                    if two_equal(column1, column3, column4)
                        column1, column3, column4, move1, move2 = reorder_two_equal(column1, column3, column4)
                        return get_score(column1, column2, column4, 1, 1, 0, gs)
                    else
                        column2, column3, column4, move1, move2 = reorder_two_equal(column2, column3, column4)
                        return get_score(column1, column2, column4, 1, 1, 0, gs)
                    end
                end
            end
        end
    end
end

function get_score(column1, column2, column3, move1, move2, move3, gs)
    V, S = find_best_game(column1, column2, column3, column_length[column1] - gs.players_position[1, column1] - move1+1, column_length[column2] - gs.players_position[1, column2] - move2+1, column_length[column3] - gs.players_position[1, column3] - move3+1, 100)
    return V[column_length[column1] - gs.players_position[1, column1] - move1+1, column_length[column2] - gs.players_position[1, column2] - move2+1, column_length[column3] - gs.players_position[1, column3] - move3+1]                    
end

function get_prev_score(column1, column2, move1, move2, gs)
    T = 0.
    for i in 2:12
        if i != column1 && i != column2
            column3 = i
            V, S = find_best_game(column1, column2, column3, column_length[column1] - gs.players_position[1, column1] - move1+1, column_length[column2] - gs.players_position[1, column2] - move2+1, column_length[column3] - gs.players_position[1, column3]+1, 100)
            T += V[column_length[column1] - gs.players_position[1, column1] - move1+1, column_length[column2] - gs.players_position[1, column2] - move2+1, column_length[column3] - gs.players_position[1, column3]+1]
        end
    end
    return T/10
end

function get_prev_score(column1, move, gs)
    T = 0.
    for i in 2:12
        for j in 2:12
            if i != column1 && i != j && j != column1
                column2 = j
                column3 = i
                V, S = find_best_game(column1, column2, column3, column_length[column1] - gs.players_position[1, column1] - move+1, column_length[column2] - gs.players_position[1, column2]+1, column_length[column3] - gs.players_position[1, column3]+1, 100)
                T += V[column_length[column1] - gs.players_position[1, column1] - move+1, column_length[column2] - gs.players_position[1, column2]+1, column_length[column3] - gs.players_position[1, column3]+1]
            end
        end
    end
    return T/110
end

function find_best(adm_movement, gs, i)
    best = 1e9
    move = 0
    for m in 1:length(adm_movement)
        turn = get_result_movement(adm_movement[m], gs, i)
        if best > turn
            best = turn
            move = m
        end
    end
    return move
end

function which_column(adm_movement, gs)
    opened_column = gs.open_columns
    for i in 0:2
        if length(opened_column) == i
            return find_best(adm_movement, gs, i)
        end
    end
end

function get_i_j_k(move, column1, column2, column3)
    if length(move) == 2
        return move[1]==column1 + move[2]==column1, move[1]==column2 + move[2]==column2, move[1]==column3 + move[2]==column3
    else
        return move[1]==column1, move[1]==column2, move[1]==column3
    end
end

function which_dice(adm_movement, gs)
    column1 = gs.open_columns[1]
    column2 = gs.open_columns[2]
    column3 = gs.open_columns[3]
    best_move = 1
    nb_turns = 1e10
    V, S = find_best_game(column1, column2, column3, column_length[column1] - gs.players_position[1, column1], column_length[column2] - gs.players_position[1, column2], column_length[column3] - gs.players_position[1, column3], 100)
    for (m, move) in enumerate(adm_movement)
        i, j, k = get_i_j_k(move, column1, column2, column3)
        if nb_turns > V[gs.tentitative_movement[column1]+i, gs.tentitative_movement[column2]+j, gs.tentitative_movement[column3]+k]
            nb_turns = V[gs.tentitative_movement[column1]+i, gs.tentitative_movement[column2]+j, gs.tentitative_movement[column3]+k]
            best_move = m
        end
    end
    return best_move
end

# Question 5
# function policy_q5(gs::game_state, adm_movement)
#     println(adm_movement)
#     if length(gs.open_columns) < 3
#         return which_column(adm_movement, gs)
#     else
#         return which_dice(adm_movement, gs)
#     end
# end
# function policy_q5(gs::game_state)
#     column1 = gs.open_columns[1]
#     if length(gs.open_columns) == 2
#         column2 = gs.open_columns[2]
#         # S = get_result_turn(column1, column2, 2, min(3, column_length[column1] - gs.players_position[1, column1]), min(3, column_length[column2] - gs.players_position[1, column2]), 0)
#         S = q4_dynamic(column1, column2, 2, gs.tentitative_movement[column1] + 1, gs.tentitative_movement[column2] + 1, 1, 100)
#         return Bool(S[gs.tentitative_movement[column1] + 1, gs.tentitative_movement[column2] + 1, 1])
#     elseif length(gs.open_columns) == 3
#         column2 = gs.open_columns[2]
#         column3 = gs.open_columns[3]
#         # S = get_result_turn(column1, column2, column3, min(3, column_length[column1] - gs.players_position[1, column1]), min(3, column_length[column2] - gs.players_position[1, column2]), min(3, column_length[column3] - gs.players_position[1, column3]))
#         # println(gs.tentitative_movement)
#         # println(gs.players_position)
#         S = q4_dynamic(column1, column2, column3, gs.tentitative_movement[column1] + 1, gs.tentitative_movement[column2] + 1, gs.tentitative_movement[column3] + 1, 100)
#         return Bool(S[gs.tentitative_movement[column1] + 1, gs.tentitative_movement[column2] + 1, gs.tentitative_movement[column3] + 1])
#     else
#         return false
#     end
# end

function policy_q5(gs::game_state)
    if length(gs.open_columns) < 3
        return false
    else
        column1 = gs.open_columns[1]
        column2 = gs.open_columns[2]
        column3 = gs.open_columns[3]
        if (gs.tentitative_movement[column1] + gs.players_position[1, column1]) == column_length[column1]
            return true
        elseif (gs.tentitative_movement[column2] + gs.players_position[1, column2]) == column_length[column2]
            return true
        elseif (gs.tentitative_movement[column3] + gs.players_position[1, column3]) == column_length[column3]
            return true
        else
            return sum(gs.tentitative_movement) > best_policy(proba(column1, column2, column3))*1.5
        end
    end
end

function policy_q5(gs::game_state, adm_movement)
    best = 0
    indicateur = 0
    for m in 1:length(adm_movement)
        if length(adm_movement[m]) == 2 && adm_movement[m][1] == adm_movement[m][2]
            return m
        end
        ind = 0
        for move in adm_movement[m]
            ind += (gs.tentitative_movement[move] + gs.players_position[1, move]) / column_length[move]
        end
        if ind > indicateur
            best = m
            indicateur = ind
        end
    end
    if best == 0
        return 1
    else
        return best
    end
end

# function policy_q5(gs::game_state, adm_movement)
#     # println(adm_movement)
#     best = 10
#     best_i = 0
#     for m in 1:length(adm_movement)
#         indicateur = abs(7 - sum(adm_movement[m])/length(adm_movement[m]))
#         if indicateur < best
#             best = indicateur
#             best_i = m
#         elseif indicateur == best
#             if maximum(adm_movement[m]) - minimum(adm_movement[m]) < maximum(adm_movement[best_i]) - minimum(adm_movement[best_i])
#                 best_i = m
#             end
#         end
#     end
#     # println(best_i)
#     return best_i
# end

# Question 6
function policy_q6(gs::game_state, adm_movement)
    return 1
end
function policy_q6(gs::game_state)
    return (sum(gs.tentitative_movement) > 2)
end

# Question 7
function policy_q7(gs::game_state, adm_movement)
    return 1
end
function policy_q7(gs::game_state)
    return (sum(gs.tentitative_movement) > 2)
end

# Question 8
function policy_q8(gs::game_state, adm_movement)
    return 1
end
function policy_q8(gs::game_state)
    return (sum(gs.tentitative_movement) > 2)
end

end # end of module
