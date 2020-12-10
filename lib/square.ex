defmodule Square do
  alias __MODULE__

  @board_size Board.size()
  @max_pos Board.max_pos()

  @enforce_keys [:pos]
  defstruct [:x, :y, :val, :pos]

  def new(pos) when pos > 0 and pos <= @max_pos do
    %Square{pos: pos, y: y(pos), x: x(pos)}
  end

  def x(%Square{pos: pos}), do: x(pos)
  def x(pos), do: rem(pos - 1, @board_size) + 1

  def y(%Square{pos: pos}), do: y(pos)
  def y(pos), do: div(pos - 1, @board_size) + 1

  def update_at(squares, pos, value) do
    Enum.map(squares, fn square ->
      if square.pos == pos do
        %Square{square | val: value}
      else
        square
      end
    end)
  end
end
