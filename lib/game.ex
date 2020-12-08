defmodule TicTac.Game do
  alias __MODULE__
  alias TicTac.Board

  defstruct [:board, :next_player, :winner]

  def new do
    %Game{board: Board.new()}
  end
end
