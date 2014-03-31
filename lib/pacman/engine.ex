defmodule Pacman.Engine do

	@doc "the main animation loop changes states of the pacman's world"
	def main(world, outs) do
		catch_exit
		event = fetch_event
		{world, outs} = react_on_event(world, outs, event)
		world = Pacman.World.move_pacmans(world)
		# representation = Pacman.World.represent(world)
		# IO.puts representation
		# send :stream, representation
		outs |> Enum.each fn(out)-> send_state(out, world) end
		:timer.sleep 1000
		main(world, outs)
	end

	def send_state(out, world) do
		send out, {:state, Pacman.World.represent(world)}
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
		receive do
			{:event, event} -> event
		after
			# NOTE: we could even use this as sleep time...
			0 -> nil
		end
	end

	@doc "adds an output channel"
	def react_on_event(world, outs, [type: :register_output, pid: pid]) do
		outs = List.insert_at outs, 0, pid
		{world, outs}
	end

	@doc "changes the world's state based on incoming shared event"
	def react_on_event(world, outs, [type: :register_pacman, name: name]) do
	  world = Pacman.World.register_pacman(world, name)
		{world, outs}
	end

	def react_on_event(world, outs, [type: :fetch_state]) do
		send :stream, {:grid_state, Pacman.World.represent(world)}
		{world, outs}
	end

	def react_on_event(world, outs, [type: :dump_state]) do
		IO.puts Pacman.World.represent(world)
		{world, outs}
	end

	def react_on_event(world, outs, _) do
		{world, outs}
	end
end
