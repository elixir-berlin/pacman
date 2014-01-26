defmodule Pacman.Engine do

	@doc "the main animation loop changes states of the pacman's world"
	def main(world // Pacman.World.new) do
		catch_exit
		event = fetch_event
		IO.puts "received: #{inspect(event)}"
		world = react_on_event(world, event)
		world = Pacman.World.move_pacmans(world)
		# TODO:
		# world = World.eat_food(world)
		Pacman.World.represent(world)
		# NOTE: should be rather run on 24/frames sec
		:timer.sleep 200
		main(world)
	end

	def catch_exit do
		receive do
			:quit -> Process.exit(self, :kill)			
		after
			0 -> "no exit signal"
		end
	end

	@doc "this ensures we process just
		    one shared event per cycle in a non-blocking fashion"
	def fetch_event do
		send :events, :pop_event
		receive do
			{:event, event} -> event
		after
			# NOTE: we could even use this as sleep time...
			0 -> nil
		end
	end

	@doc "changes the world's state based on incoming shared event"
	def react_on_event(world, [type: :register_pacman, name: name]) do
	  Pacman.World.register_pacman(world, name)
	end

	def react_on_event(world, _) do
		world
	end
end
