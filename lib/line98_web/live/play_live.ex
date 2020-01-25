defmodule Line98Web.PlayLive do
  use Phoenix.LiveView
  alias Line98Web.PlayView
  alias Line98.Game
  alias Line98.Ball

  def render(assigns) do
    PlayView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(100, self(), :update_path)

    board = Game.new()
    {:ok, assign(socket, board: board, selected_cell: nil)}
  end

  def handle_event("again", _, socket) do
    board = Game.new()
    {:noreply, assign(socket, board: board, selected_cell: nil)}
  end

  def handle_event("cell", %{"select-x" => x, "select-y" => y}, socket) do
    coordinates = {String.to_integer(x), String.to_integer(y)}
    board = socket.assigns.board

    new_board =
      case board.selected_field do
        nil -> Game.select(board, coordinates)
        _ -> Game.move(board, coordinates)
      end

    {:noreply, assign(socket, board: new_board, selected_cell: coordinates)}
  end

  def handle_info(:update_path, socket) do
    board = socket.assigns.board

    cond do
      length(board.path) > 1 ->
        [current_coordinate, to_coodinate | _] = board.path
        new_balls = Ball.move_ball_to_cell(board.balls, current_coordinate, to_coodinate)
        [_ | tail] = board.path

        {:noreply, assign(socket, board: %Game{board | balls: new_balls, path: tail})}

      length(board.path) == 1 ->
        new_balls = Ball.grow_and_generate_balls(board.balls)
        new_board =
          %Game{board | balls: new_balls, path: [], to: nil}
          |> Game.calculate_scores()

        {:noreply, assign(socket, board: new_board)}

      true ->
        {:noreply, assign(socket, board: board)}
    end
  end
end
