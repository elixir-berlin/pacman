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
    event_loop_pid = spawn_link(Pacman.SharedEvents, :events_loop, [])
		Process.register event_loop_pid, :events
		engine_pid = spawn_link(Pacman.Engine, :main, [])
		Process.register engine_pid, :engine
		add :default
		IO.puts "started"
	end

	def event(event) do
		:events <- {:queue_event, event}
	end

	def turn(direction, pacman // :default) do
		pacman <- {:turn, direction}
	end

	def add(name) do
		event [type: :register_pacman, name: name]
	end

	# NOTE: what happens to linked children if parent crashes/is killed? 
	#       could we just kill the parent?
	def exit do
		:engine <- :quit
		:events <- :quit
	end
end
