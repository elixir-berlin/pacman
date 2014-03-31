require Pacman.SharedEvents # ? just the first is required to mix
# require Pacman.Engine

defmodule Pacman do
	@moduledoc """

## Pacman Module

home of Pacmans. Works as parent process for
the Engine and Shared Events.

## Run

$> iex -S mix

## Usage

Pacman.boot # starts the engine

Pacman.turn :up # changes direction of (default) pacman

Pacman.add :name # adds a player to the grid

Pacman.turn :down, :name # changes direction of :name Pacman
"""

  def boot do
		engine_pid = spawn_link(Pacman.Engine, :main, [Pacman.World.new, []])
		Process.register engine_pid, :engine
	end

	def register_output pid do
		event [type: :register_output, pid: pid]
	end

	def event(event) do
		send :engine, {:event, event}
	end

	def turn(pacman, direction) do
		send pacman, {:turn, direction}
	end

	def add(name) do
		event [type: :register_pacman, name: name]
	end

	def stream do
		# NOTE: wherever I call Pacman.stream from
		#       in this way I am sure to targer the
		#       right home process
		Process.register self, :stream
		next = fn() ->
							 # NOTE: we might need to ask each time
							 #       for state as Stream should be lazily iterated
							 event [type: :fetch_state]
							 receive do
								 {:grid_state, state} ->
									 state
							 end
					 end
		Stream.repeatedly(next)
	end

	def streaming fun do
		stream |> Enum.each(fun)
	end

	def exit do
		send :engine, :quit
	end
end
