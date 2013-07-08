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

  def edits1(word) do
    length = String.length(word)
    range = 1..(length)
    s = Enum.map(range, fn(index) ->
      {String.slice(word, 0, index), String.slice(word, index, length)}
    end)
    deletes = Enum.filter_map(s,
                fn({_, b}) -> b != "" end,
                fn({a, b}) -> "#{a}#{String.slice(b, 1, String.length(b))}" end)
    transposes = Enum.filter_map(s,
                fn({_, b}) -> String.length(b) > 1 end,
                fn({a, b}) -> "#{a}#{String.slice(b, 1, 2)}#{String.slice(b, 0, 1)}#{String.slice(b,2,String.length(b))}" end)
    replaces = Enum.filter_map(s,
                fn({_, b}) -> b != "" end,
                fn({a, b}) -> Enum.map(alphabet, fn(c) ->
                                "#{a}#{c}#{String.slice(b,1,String.length(b))}"
                              end)
               end)
    inserts = Enum.map(s, fn({a, b}) -> Enum.map(alphabet, fn(c) ->
                                          "#{a}#{b}#{c}"
                                       end
                          end)
    deletes ++ transposes ++ replaces ++ inserts # Might need to be a set
  end

  def known_edits2(word) do
    
  end

  def correct(input) do
    "access"
  end

  defp alphabet do
    "abcdefghijklmnopqrstuvwxyz"
  end
end
