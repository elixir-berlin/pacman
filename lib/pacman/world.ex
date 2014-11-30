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
  defmodule Grid do
    defstruct pacmans: HashDict.new,
              food: [],
              phantoms: []

    def replace_pacmans(grid, new_pacmans) do
      %Grid{grid | pacmans: new_pacmans}
    end

    # def update_pacmans(grid, function) do
    #   Map.update! grid, :pacmans, function
    # end
  end

  defmodule User do
    defstruct direction: {1,0},
              color: "#FFF",
              position: {
                div(Module.get_attribute(Pacman.World, :size), 2),
                div(Module.get_attribute(Pacman.World, :size), 2)
              },
              score: 0
  end

  def new do
    %Grid{}
  end

  def spawn_user_events(name) do
    pid = spawn_link(Pacman.UserEvents, :events_loop, [name])
    Process.register pid, name
  end

  @doc "register a new pacman user process under its name and updates the grid"
  def register_pacman(%Grid{} = grid, name) do
    new_pacmans = HashDict.put_new grid.pacmans, name, %User{}
    spawn_user_events(name)
    Grid.replace_pacmans grid, new_pacmans
  end

  @doc "removes pacman"
  def remove_pacman(%Grid{} = grid, name) do
    new_pacmans = HashDict.delete grid.pacmans, name
    if name_pid = Process.whereis(name) do
      IO.puts "exiting PID: #{name}"
      Process.exit name_pid, :normal
    end
    Grid.replace_pacmans grid, new_pacmans
  end

  def move_pacmans(grid) do
    new_pacmans = grid.pacmans |>
      Enum.map(&displace/1) |>
      Enum.into(HashDict.new)
    Grid.replace_pacmans grid, new_pacmans
  end

  def displace({name, pcm}) do
    {dx, dy} = ask_direction(name, pcm.direction)
    {x, y}  = pcm.position
    new_x = wrap_position(x, dx)
    new_y = wrap_position(y, dy)
    new_position = {new_x, new_y}
    new_pcm = %User{pcm | position: new_position, direction: {dx, dy}}
    {name, new_pcm}
  end

  @doc "again a 'synchronous call' to ask the direction to the user's process which falls back to the old direction"
  def ask_direction(name, old_dir) do
    send name, :fetch_direction
    receive do
      {:new_direction, ^name, dir} ->
        # IO.puts "#{name} receives new direction #{inspect(dir)}!"
        translate_direction(dir)
    after
      1 ->
        # IO.puts "#{name} gets current direction #{inspect(old_dir)}"
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
  def represent(%Grid{} = grid) do
    represent_one = fn({name, pcm}) ->
                      {x, y} = pcm.position
                      [name: name, position: [x: x, y: y]]
                    end
    representation = Enum.map(grid.pacmans, represent_one)
    {:ok, json_str} = JSON.encode representation
    json_str
  end
end
