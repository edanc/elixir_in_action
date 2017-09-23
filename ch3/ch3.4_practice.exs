defmodule Action do
  # returns the length of each line
  def large_lines!(path) do
    File.stream!(path)
    |> Stream.map(&String.length(&1))
    |> Enum.to_list
  end

  def longest_line_length(path) do
    File.stream!(path)
    |> Stream.map(&String.length(&1))
    |> Enum.max
  end

  def longest_line!(path) do
    File.stream!(path)
    |> Enum.reduce("", &output_longer_line/2)
  end

  defp output_longer_line(line1, line2) do
    if String.length(line1) > String.length(line2) do
      line1
    else
      line2
    end
  end

  def words_per_line!(path) do
    File.stream!(path)
    |> Enum.map(&word_count_for_line/1)
  end

  defp word_count_for_line(string) do
    string
    |> String.split
    |> length
  end
end
