defmodule Nwords do
  use GenServer.Behaviour

  def init([]) do
    { :ok, HadhDict.new }
  end

  def handle_call({:retrieve, word}, _from, state) do
    { :reply, state[word] }
  end

  def handle_cast({ :add_word, word }, state) do
    { :noreply, train([word], state) }
  end

  def train([], acc) do
    acc
  end

  def train([ h | t ], acc) do
    [ h | t ] = features
    current_count = acc[h]
    new_count = (current_count || 0) + 1
    train t, Dict.put(acc, h, new_count)
  end
end
