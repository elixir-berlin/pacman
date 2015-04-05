defmodule PacmanTest do
  use ExUnit.Case

  test "the truth" do
    Pacman.boot
    Pacman.add :nero
    Pacman.register_output self
    
    assert_receive {:state, json}, 300
    {:ok, data} = JSON.decode(json)
    [%{"name" => name, "position" => %{}}] = data
    assert name == "nero"
    Pacman.exit
  end
end
