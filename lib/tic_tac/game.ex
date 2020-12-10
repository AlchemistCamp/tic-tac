defmodule TicTac.Game do
  alias __MODULE__

  @board_size Board.size()
  @max_pos Board.max_pos()

  defstruct [:board, :current_player, :winner, :move]

  def end_turn(%Game{winner: winner, current_player: player} = game) do
    if winner do
      Board.print(game.board)
      player_str = player |> to_string() |> String.upcase()
      "Game over. #{player_str} is victorious!"
    else
      player = other_player(player)
      main_loop(%Game{game | move: nil, current_player: player})
    end
  end

  def get_move(%Game{} = game) do
    Board.print(game.board)

    move =
      IO.gets("Choose your next square (1-#{@max_pos}) ")
      |> String.trim()
      |> Integer.parse()

    case move do
      {move, _} when move in 1..@max_pos -> %Game{game | move: move}
      _ -> get_move(game)
    end
  end

  def play_move(%Game{} = game) do
    case Board.at(game.board, game.move) do
      %{val: nil} ->
        update_square(game)

      _ ->
        IO.puts("Square is occupied!")
        player = other_player(game.current_player)
        %Game{game | current_player: player}
    end
  end

  def main_loop(%Game{} = game) do
    game
    |> get_move()
    |> play_move()
    |> win_check()
    |> end_turn()
  end

  def new(first_player) do
    %Game{board: Board.new(), current_player: first_player}
  end

  def other_player(:x), do: :o
  def other_player(:o), do: :x
  def other_player(_), do: :error

  def start(player1) when player1 in [:x, :o] do
    new(player1) |> main_loop()
  end

  def start(_), do: "Invalid player!"

  def update_square(%Game{board: b, current_player: player, move: move} = game) do
    new_squares = Square.update_at(b.squares, move, player)
    %Game{game | board: %Board{b | squares: new_squares}}
  end

  def win_check(%Game{} = game) do
    has_winner =
      line_check(game, :row) or
        line_check(game, :col) or
        line_check(game, :asc_right) or
        line_check(game, :desc_left)

    %Game{game | winner: has_winner}
  end

  # Win check-related utilities
  def line_check(%Game{} = game, direction) do
    get_line(game.board.squares, direction, game.move)
    |> check_squares(game.current_player)
  end

  def check_squares(squares, player) do
    Enum.all?(squares, fn square -> square.val == player end)
  end

  def col_filter(square, pos), do: square.x == Square.x(pos)
  def row_filter(square, pos), do: square.y == Square.y(pos)
  def desc_left_filter(square), do: square.x - square.y == 0
  def asc_right_filter(square), do: square.x + square.y == @board_size + 1

  def get_line(squares, direction, pos) do
    filter =
      case direction do
        :col -> fn square -> col_filter(square, pos) end
        :row -> fn square -> row_filter(square, pos) end
        :asc_right -> fn square -> asc_right_filter(square) end
        :desc_left -> fn square -> desc_left_filter(square) end
      end

    Enum.filter(squares, filter)
  end
end
