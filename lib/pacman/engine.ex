defmodule Pacman.Engine do

  @doc "the main animation loop changes states of the pacman's world"
  def main(world, outs) do
    catch_exit
    event = fetch_event
    {world, outs} = react_on_event(world, outs, event)
    world = Pacman.World.move_pacmans(world)
    Enum.each outs, &(send_state(&1, world))
    :timer.sleep 200
    main(world, outs)
  end

  def send_state(out, world) do
    send out, {:state, Pacman.World.represent(world)}
  end

  @doc "this ensures we process just
        one shared event per cycle in a non-blocking fashion"
  def fetch_event do
    receive do
      {:event, event} -> event
    after
      0 -> nil
    end
  end

  @doc "adds an output channel"
  def react_on_event(world, outs, [type: :register_output, pid: pid]) do
    outs = List.insert_at outs, 0, pid
    {world, outs}
  end

  @doc "removes the specified output channel"
  def react_on_event(world, outs, [type: :remove_output, pid: pid]) do
    outs = List.delete outs, pid
    {world, outs}
  end

  @doc "changes the world's state based on incoming event"
  def react_on_event(world, outs, [type: :register_pacman, name: name]) do
    world = Pacman.World.register_pacman(world, name)
    {world, outs}
  end

  @doc "removed named pacman from the World"
  def react_on_event(world, outs, [type: :remove_pacman, name: name]) do
    world = Pacman.World.remove_pacman(world, name)
    {world, outs}
  end

  def react_on_event(world, outs, [type: :dump_state]) do
    IO.puts Pacman.World.represent(world)
    {world, outs}
  end

  def react_on_event(world, outs, _) do
    {world, outs}
  end

  def catch_exit do
    receive do
      :quit -> Process.exit(self, :kill)
    after
      0 -> "no exit signal"
    end
  end

end
