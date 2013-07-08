defmodule Spelling do
  def words(text) do
    Regex.split(%r/[^a-z]+/, text)
  end

  def train(features) do
    :gen_server.start_link { :local, Nwords }, Nwords, [], []
    Enum.each(features, fn(word) ->
      :gen_server.cast Nwords, { :add_word, word } end)
  end

  def nwords(key), do: :gen_server.call(Nwords, {:retrieve, key})
  def nwords_has_key(key), do: :gen_server.call(Nwords, {:has_key, key})
  def seed, do: file |> words |> train

  defp file do
    {:ok, text} = File.read("data/big.txt")
    #"the big brown dog jumped over the lazy fox"
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
                                       end)
                          end)
    List.flatten(deletes ++ transposes ++ replaces ++ inserts) # Might need to be a set
  end

  def known_edits2(word) do
    Enum.map(edits1(word), fn(e1) -> Enum.filter(edits1(e1),
                                            fn(item) -> nwords_has_key(item) end) end)
  end

  def known(words) do
    Enum.filter(words, fn(word) -> nwords_has_key(word) end)
  end

  def correct(word) do
    if Enum.count(known(edits1(word))) > 0 do
      candidates = known(edits1(word))
    end
    if Enum.count(known([word])) > 0 do
      candidates = known([word])
    end
    if Enum.count(known_edits2(word)) > 0 do
      candidates = known_edits2(word)
    else
      candidates = [word]
    end
    occurrences = Enum.map(candidates, fn(candidate) -> {candidate, nwords(candidate)} end)
    sorted_occurrences = Enum.sort(occurrences, fn({_, count1}, {_, count2}) -> count1 > count2 end)
    [h|t] = sorted_occurrences
    {words,_} = h
    words
  end

  defp alphabet do
    String.split("a b c d e f g h i j k l m n o p q r s t u v w x y z", " ")
  end
end

#Spelling.seed

