defmodule PacmanWorldTest do
  use ExUnit.Case

  test "register_pacman" do
    grid = Pacman.World.new
    grid = Pacman.World.register_pacman grid, :p1
    grid = Pacman.World.register_pacman grid, :p2
    assert grid.pacmans.size == 2
    assert HashDict.has_key? grid.pacmans, :p1
    assert HashDict.has_key? grid.pacmans, :p2
  end

  test "move_pacmans" do
    Process.register self, :engine

    grid = Pacman.World.new
    grid = Pacman.World.register_pacman grid, :pacman1
    grid = Pacman.World.register_pacman grid, :pacman2

    assert grid.pacmans[:pacman1].direction == {1,0}
    assert grid.pacmans[:pacman2].direction == {1,0}
    assert grid.pacmans[:pacman1].position == {10,10}
    assert grid.pacmans[:pacman2].position == {10,10}

    send :pacman2, {:turn, :up}
    send :pacman1, {:turn, :left}
    new_grid = Pacman.World.move_pacmans(grid)

    assert is_map(new_grid)
    assert new_grid.pacmans.size == 2
    assert is_map(new_grid.pacmans[:pacman1])
    assert is_map(new_grid.pacmans[:pacman2])

    assert new_grid.pacmans[:pacman1].direction == {-1,0}
    assert new_grid.pacmans[:pacman2].direction == {0,-1}
    assert new_grid.pacmans[:pacman1].position == {9,10}
    assert new_grid.pacmans[:pacman2].position == {10,9}
  end

end
