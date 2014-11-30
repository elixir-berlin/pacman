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

  def remove_output pid do
    event [type: :remove_output, pid: pid]
  end

  def turn(pacman, direction) do
    send pacman, {:turn, direction}
  end

  def add(id, metadata \\ []) do
    event [type: :register_pacman, name: id]
  end

  def remove(name) do
    event [type: :remove_pacman, name: name]
  end

  def event(event) do
    send :engine, {:event, event}
  end

  def exit do
    send :engine, :quit
  end

  defmodule StdOut do
    def write do
      receive do
        {:state, json}->
          IO.puts inspect(json)
          write
      end
    end
  end

  def log do
    log_pid = spawn StdOut, :write, []
    register_output log_pid
  end

end
