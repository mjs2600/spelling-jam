defmodule Spelling do
  def words(text) do
    Regex.split(%r/[^a-z]+/, text)
  end

  def train(features) do
    train features, HashDict.new
  end

  def train([], acc) do
    acc
  end

  def train(features, acc) do
    [ h | t ] = features
    current_count = acc[h]
    new_count = (current_count || 0) + 1
    train t, Dict.put(acc, h, new_count)
  end

  def nwords, do: file |> words |> train

  defp file do
    {:ok, text} = File.read("data/big.txt")
    text
  end

  def correct(input) do
    "access"
  end

end
