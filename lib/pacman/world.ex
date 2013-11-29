defmodule Pacman.World do
	@size 20
	@directions [right: {1,0}, up: {0, -1}, left: {-1, 0}, down: {0, 1}]

	@moduledoc """
Keeps track of instant state of the Grid
has two record definitions:
Grid and Pacman.

Grid#pacmans is a hash of :name => Pacman records

Stores 'Class instance variables':

- @size (of the grid)

- @directions human -> vector translations

### NOTE
  
World should rather implement a protocol for the Grid
in the sense of http://elixir-lang.org/getting_started/4.html
or maybe something like @impl
"""
	
	defrecord Grid, pacmans: HashDict.new, food: [], phantoms: []
	defrecord Pacman, direction: {1,0}, position: {div(@size, 2), div(@size, 2)}, score: 0 

	def new do
		Grid.new
	end

	def spawn_user_events(name) do
		# FIXME: why do I need to namespace from root?
		pid = spawn_link(Elixir.Pacman.UserEvents, :events_loop, [name])
		Process.register pid, name
	end

	@doc "register a new pacman user process under its name and updates the grid"
	def register_pacman(Grid[] = grid, name) do
		pacmans = grid.pacmans
		pacmans = HashDict.put_new pacmans, name, Pacman.new
		spawn_user_events(name)
		grid.update(pacmans: pacmans)
	end

	def move_pacmans(Grid[] = grid) do
		grid.update_pacmans fn(pacmans) -> HashDict.new(Enum.map(pacmans, displace)) end
	end

	def displace do
		fn({name, pcm}) ->
				{dx, dy} = ask_direction(name, pcm.direction)
				{x, y}  = pcm.position
				new_x = wrap_position(x, dx)
				new_y = wrap_position(y, dy)
				new_position = {new_x, new_y}
				new_pcm = pcm.update(position: new_position)
				{name, new_pcm}
		end
	end
	
	@doc "again a 'synchronous call' to ask the direction to the user's process which falls back to the old direction"
	def ask_direction(name, old_dir) do
		name <- :fetch_direction
		receive do
			{:new_direction, dir} -> translate_direction(dir) 
		after
			0 -> 
				IO.puts "missed!"
				old_dir
		end
	end

	def translate_direction(name) do
		@directions[name]
	end

	def wrap_position(value, delta) do
		rem(@size + value + delta, @size)
	end
							
	@doc "a Grid's instantaneous representation"
	def represent(Grid[] = grid) do
		represent_one = fn({name, pcm}) ->
												"#{name}: #{inspect(pcm.position)} -- score: #{pcm.score}"
										end
		IO.puts(Enum.map_join(grid.pacmans, "\n", represent_one))
	end
end
