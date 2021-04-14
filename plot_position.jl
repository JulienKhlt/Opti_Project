using Plots

function start_ycoord(i::Int64)
	if i<2 || i>13
		error("A column index must be between 2 and 12")
	elseif i<7
		-i+8
	else
		i-6
	end
end

function end_ycoord(i::Int64)
	if i<2 || i>13
		error("A column index must be between 2 and 12")
	elseif i<7
		6+i
	else
		20-i
	end
end



function plot_empty_board()
 	v=[i for i in 2:1:12]
 	v3=[i for i in 3:1:11]
 	v4=[i for i in 4:1:10]
 	v5=[i for i in 5:1:9]
 	v6=[i for i in 6:1:8]
 	plot!(aspect_ratio=:1)
	scatter!(v,start_ycoord.(v),color=:black,legend=false)
	scatter!(v,start_ycoord.(v)+ones(11),color=:black,legend=false)
	scatter!(v,start_ycoord.(v)+2*ones(11),color=:black,legend=false)
	scatter!(v3,start_ycoord.(v3)+3*ones(9),color=:black,legend=false)
	scatter!(v3,start_ycoord.(v3)+4*ones(9),color=:black,legend=false)
	scatter!(v4,start_ycoord.(v4)+5*ones(7),color=:black,legend=false)
	scatter!(v4,start_ycoord.(v4)+6*ones(7),color=:black,legend=false)
	scatter!(v5,start_ycoord.(v5)+7*ones(5),color=:black,legend=false)
	scatter!(v5,start_ycoord.(v5)+8*ones(5),color=:black,legend=false)
	scatter!(v6,start_ycoord.(v6)+9*ones(3),color=:black,legend=false)
	scatter!(v6,start_ycoord.(v6)+10*ones(3),color=:black,legend=false)
	scatter!([7,7],[12,13],color=:black,legend=false)
	for i in 2:1:12
		plot!([i,i],[start_ycoord(i),end_ycoord(i)],color=:black,legend=false,axis=nothing)
		annotate!([(i,start_ycoord(i)-1,text(i,10,:black,:center))])
	end
 end

#After running plot_position(gs)
 function plot_position(gs::game_state)
 	plot()
 	plot_empty_board()
 	for j in 2:1:12
 		if gs.players_position[1,j]==gs.players_position[2,j]
 			scatter!([j-1/20],[start_ycoord(j)-1+gs.players_position[1,j]],markershape =:square,color=:red)
 			scatter!([j+1/20],[start_ycoord(j)-1+gs.players_position[2,j]],markershape =:square,color=:red)
 			for i in 3:1:gs.nb_player
		 		if gs.players_position[i,j]!=0
			 		if i==3
			 			scatter!([j],[start_ycoord(j)-1+gs.players_position[i,j]],markershape =:square,color=:green)
			 		else
			 			scatter!([j],[start_ycoord(j)-1+gs.players_position[i,j]],markershape =:square,color=:yellow)
			 		end
			 	end
		 	end
 		else
		 	for i in 1:1:gs.nb_player
		 		if gs.players_position[i,j]!=0
			 		if i==1
			 			scatter!([j],[start_ycoord(j)-1+gs.players_position[i,j]],markershape =:square,color=:red)
			 		elseif i==2
			 			scatter!([j],[start_ycoord(j)-1+gs.players_position[i,j]],markershape =:square,color=:blue)
			 		elseif i==3
			 			scatter!([j],[start_ycoord(j)-1+gs.players_position[i,j]],markershape =:square,color=:green)
			 		else
			 			scatter!([j],[start_ycoord(j)-1+gs.players_position[i,j]],markershape =:square,color=:yellow)
			 		end
			 	end
		 	end
		end
	end
	i=gs.active_player
	for j in gs.open_columns
		scatter!([j],[gs.players_position[i,j] + gs.tentitative_position[j]],markershape =:hexagon)
	end
 end
