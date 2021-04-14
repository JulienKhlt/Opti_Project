include("CantStop.jl")
using .CantStop

include("Policies_42.jl") #replace 42 by your group number
include("Policies_666.jl") #replace 666 by your adversary number
using .Policies_42 , .Policies_666

policy1 = Policies_42.policy_q1
policy2 = Policies_666.policy_q1



#Simulating a game with player1 policy

gs = CantStop.game_state(1) #Initialising a one player game
CantStop.simulate_game!(gs,[policy1], 3) # the third argument is a verbosity level

#Simulating 1000 games with policy1
nb_turns, winner = test_policy([policy1],1000)
println(winner)

#Simulating a game with player1 and player 2 policy
gs = game_state(2)
simulate_game!(gs,[policy1,policy2], 2)

# plotting a game
include("plot_position.jl")
plot_position(gs)
plot!()
