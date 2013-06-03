Code.require_file "test_helper.exs", __DIR__

defmodule BishopTest do
  use ExUnit.Case

  import Bishop

  @size {10, 10}

  test "move diagonally unbounded" do
    assert move(:nw, {2, 2}, @size) == {1, 1}
    assert move(:ne, {2, 2}, @size) == {3, 1}
    assert move(:sw, {2, 2}, @size) == {1, 3}
    assert move(:se, {2, 2}, @size) == {3, 3}
  end

  test "move diagonally on top side" do
    assert move(:nw, {2, 0}, @size) == {1, 0}
    assert move(:ne, {2, 0}, @size) == {3, 0}
  end

  test "move diagonally on left side" do
    assert move(:nw, {0, 2}, @size) == {0, 1}
    assert move(:sw, {0, 2}, @size) == {0, 3}
  end

  test "move diagonally on right side" do
    assert move(:ne, {9, 2}, @size) == {9, 1}
    assert move(:se, {9, 2}, @size) == {9, 3}
  end

  test "move diagonally on bottom side" do
    assert move(:sw, {2, 9}, @size) == {1, 9}
    assert move(:se, {2, 9}, @size) == {3, 9}
  end

  test "bump against corners" do
    assert move(:nw, {0, 0}, @size) == {0, 0}
    assert move(:ne, {9, 0}, @size) == {9, 0}
    assert move(:se, {9, 9}, @size) == {9, 9}
    assert move(:sw, {0, 9}, @size) == {0, 9}
  end

  test "pick random atoms from list" do
    :random.seed 1000,2000,3000
    assert random_direction == :se
    assert random_direction == :ne
    assert random_direction == :se
    assert random_direction == :sw
    assert random_direction == :ne
    assert random_direction == :nw
    assert random_direction == :ne
  end

  test "parse hex" do
    assert hexstring_to_directions("d4d3")  == [:nw, :ne, :ne, :se, :se, :nw, :ne, :se]
    assert hexstring_to_directions("D4:d3") == [:nw, :ne, :ne, :se, :se, :nw, :ne, :se]
  end
end
