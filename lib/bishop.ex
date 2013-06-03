defmodule Bishop do

  @directions {:nw, :ne, :sw, :se}
  @symbols     ' .o+=*BOX@%&#/^'
  @startsymbol 'S'
  @endsymbol   'E'

  @moduledoc """
  This module is an implementation of the drunken bishop algorithm, as
  described in the paper "The drunken bishop" by Dirk Loss , Tobias Limmer and
  Alexander von Gernler.

  It generates randomart based on a hexadecimal string.
  """

  def main(args) do
    Bishop.CLI.run(args)
  end

  @doc """
  Generate randomart for a hexadecimal string.

  Example:
    iex> Bishop.walkhex "d4:d3:fd:ca:c4:d3:e9:94:97:cc:52:21:3b:e4:ba:e9"
    -------------------
    |             o . |
    |         . .o.o .|
    |        . o .+.. |
    |       .   ...=o+|
    |        S  . .+B+|
    |            oo+o.|
    |           o  o. |
    |          .      |
    |           E     |
    -------------------
    :ok
  """
  def walkhex(string, size={w, h} // {17, 9}) do
    start = {div(w, 2), div(h, 2)}

    string
    |> hexstring_to_directions
    |> _walk_directions(size, start)
  end

  def hexstring_to_directions(string) do
    string
    |> String.replace(":", "")
    |> String.downcase
    |> _hexstring_to_quartets
    |> _reorder_quartets
    |> _quartets_to_directions
  end

  defp _hexstring_to_quartets(string) do
    String.codepoints(string)
    |> Enum.map(function(_hexchar_to_quartets/1))
    |> List.flatten
  end

  defp _hexchar_to_quartets(<< c :: utf8 >>) do
    _hexchar_to_value(c)
    |> _value_to_quartet
  end

  defp _hexchar_to_value(c) when c >= ?0 and c <= ?9, do: c - ?0
  defp _hexchar_to_value(c), do: 10 + c - ?a

  defp _value_to_quartet(value) do
    [div(value, 4), rem(value, 4)]
  end

  defp _reorder_quartets([]), do: []
  defp _reorder_quartets([d,c,b,a | tail]), do: [a, b, c, d | _reorder_quartets(tail)]

  defp _quartets_to_directions(quartets) do
    Enum.map quartets, elem(@directions, &1)
  end

  @doc """
  Generate randomart for a series of randomized directions.

  Example using seed to get reproducible "random" values::
  iex> :random.seed 1000, 2000, 3000
  iex> Bishop.walk_randomly 100
  -------------------
  |                 |
  |.                |
  |.* o.     .      |
  |+ Bo.    + .     |
  |.+o...  S B . .  |
  |o.+o  o+ + * o   |
  |.o.. ...o . o    |
  |o. ..  +         |
  |o  E..o..        |
  -------------------
  :ok
  """

  def walk_randomly(n // 10, size // {17, 9}, start // {8, 4}) do
    _gen_directions(n)
    |> _walk_directions(size, start)
  end

  defp _gen_directions(n) do
    Enum.map 1..n, fn _ -> random_direction end
  end

  def random_direction do
    index = :random.uniform(tuple_size(@directions)) - 1
    elem(@directions, index)
  end

  defp _walk_directions(directions, size, start) do
    directions
    |> _dir_to_position(size, start)
    |> _fill_dict(start)
    |> _draw_map(size)
  end

  defp _dir_to_position(dirs, size, start) do
    Enum.map_reduce dirs, [start, size], fn (d, [pos, size]) ->
      newpos = move(d, pos, size)
      {newpos, [newpos, size]}
    end
  end

  def move(:nw, {0, 0}, _), do: {0, 0}
  def move(:nw, {0, y}, _), do: {0, y-1}
  def move(:nw, {x, 0}, _), do: {x-1, 0}
  def move(:nw, {x, y}, _), do: {x-1, y-1}

  def move(:ne, {x, 0}, {w, _}) when (x+1) === w, do: {x, 0}
  def move(:ne, {x, y}, {w, _}) when (x+1) === w, do: {x, y-1}
  def move(:ne, {x, 0}, _), do: {x+1, 0}
  def move(:ne, {x, y}, _), do: {x+1, y-1}

  def move(:sw, {0, y}, {_, h}) when (y+1) === h, do: {0, y}
  def move(:sw, {x, y}, {_, h}) when (y+1) === h, do: {x-1, y}
  def move(:sw, {0, y}, _), do: {0, y+1}
  def move(:sw, {x, y}, _), do: {x-1, y+1}

  def move(:se, {x, y}, {w, h}) when (x+1) === w and (y+1) === h, do: {x, y}
  def move(:se, {x, y}, {w, _}) when (x+1) === w, do: {x, y+1}
  def move(:se, {x, y}, {_, h}) when (y+1) === h, do: {x+1, y}
  def move(:se, {x, y}, _), do: {x+1, y+1}

  defp _fill_dict({positions, [last, _size]}, start) do
    Enum.reduce(positions, HashDict.new, fn (v, d) -> _add_count d, v end)
    |> HashDict.put(start, :start)
    |> HashDict.put(last, :end)
  end

  defp _add_count(dict, key) do
    new_value = 1 + HashDict.get dict, key, 0
    HashDict.put dict, key, new_value
  end

  defp _draw_map(dict, {w, h}) do
    IO.puts ['+', List.duplicate('-', w), '+']
    Enum.map 0..(h-1), fn (y) ->
      IO.write "|"
      Enum.map 0..(w-1), fn (x) ->
        HashDict.get(dict, {x, y}, 0)
        |> symbol
        |> IO.write
      end
      IO.puts "|"
    end
    IO.puts ['+', List.duplicate('-', w), '+']
  end

  Enum.each @symbols, fn (code, value) ->
    defp :symbol, [value], [], do: [code]
  end
  defp symbol(:start), do: @startsymbol
  defp symbol(:end), do: @endsymbol

end
