defmodule Line98.Ball do
  @colors ["red", "green", "blue"]

  def colors, do: @colors

  def build(balls \\ %{}, type, times) do
    new_balls = for n <- random_cells(balls, times), into: %{}, do: {n, {random_color(), type}}
    new_balls |> Map.merge(balls)
  end

  defp random_cells(balls, times) do
    1..times
    |> Enum.reduce([], fn _, acc ->
      # add avoid cells
      List.insert_at(acc, 0, {:rand.uniform(10), :rand.uniform(10)})
    end)
  end

  def grow(balls) do
    balls
    |> Map.keys()
    |> Enum.reduce(%{}, fn id, acc ->
      {color, type} = balls[id]

      case type == "dot" do
        true -> Map.put(acc, id, {color, "ball"})
        _ -> Map.put(acc, id, {color, type})
      end
    end)
  end

  def get_by_horizontal(balls, line) do
    for {{_, ^line}, {_, "ball"}} = ball <- balls, do: ball
  end

  def get_by_vertical(balls, line) do
    for {{^line, _}, {_, "ball"}} = ball <- balls, do: ball
  end

  def group_by_color_vertical(balls, line) do
    balls
    |> get_by_vertical(line)
    |> group_by_color()
    |> IO.inspect(label: "group_by_color_vertical")
  end

  def group_by_color_horizontal(balls, line) do
    balls
    |> get_by_horizontal(line)
    |> group_by_color()
    |> IO.inspect(label: "group_by_color_horizontal")
  end

  def vertical_ids(balls, line) do
    for {{^line, y}, {_, "ball"}} <- balls, do: y
  end

  def horizontal_ids(balls, line) do
    for {{x, ^line}, {_, "ball"}} <- balls, do: x
  end

  def group_by_color(balls) do
    balls
    |> Enum.group_by(fn {{x, y}, {color, type}} -> color end)
  end

  def walls(balls, selected_field) do
    coordinates =
      Map.keys(balls)
      |> Enum.filter(&(&1 != selected_field))

    for n <- coordinates, into: MapSet.new(), do: n
  end

  def avoid_cells(balls, coordinate) do
    balls
    |> Map.keys()
    |> Enum.member?(coordinate)
  end

  defp random_color() do
    colors()
    |> Enum.shuffle()
    |> List.first()
  end
end
