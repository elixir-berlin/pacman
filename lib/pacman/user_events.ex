defmodule Pacman.UserEvents do
  # NOTE: maybe move data from the grid's pacmans to this state
  #       there might be synchronization issues
  defmodule State do
    defstruct direction: :right
  end

  def events_loop(name, user_state \\ %State{}) do
    receive do
      {:turn, direction} ->
        IO.puts "#{name} receives turn: #{direction}"
        events_loop name, %State{user_state | direction: direction}
      :fetch_direction ->
        send :engine, {:new_direction, name, user_state.direction}
        events_loop name, user_state
    end
  end
end
