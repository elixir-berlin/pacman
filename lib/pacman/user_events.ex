defmodule Pacman.UserEvents do

	# NOTE: maybe move data from the grid's pacmans to this state
	#       there might be synchronization issues
	defrecord State, direction: :right

	def events_loop(name, state // State.new) do
		receive do
			:fetch_direction ->
				send :engine, {:new_direction, state.direction}
			  events_loop name, state
			{:turn, direction} ->
				events_loop name, state.update(direction: direction)
		end
	end
end
