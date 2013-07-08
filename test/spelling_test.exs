Code.require_file "test_helper.exs", __DIR__

defmodule SpellingTest do
  use ExUnit.Case

  test "all the things" do
    {:ok, text} = File.read("data/test1.txt")
    lines = String.split(text, "\n")
    [_|t] = Enum.map(lines, fn(line) -> String.split(line, " ") end)

    Enum.each(t, fn(training_set) ->
      [correct|incorrects] = training_set
      Enum.each(incorrects, fn(incorrect) ->
        assert Spelling.correct(incorrect) == correct
      end)
    end)
  end
end
