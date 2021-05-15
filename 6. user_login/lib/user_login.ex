defmodule UserLogin do
  @moduledoc false
  use Agent

  alias ErrorCounter
  alias Colors

  #! ENTRYPOINT function
  def main() do
    ErrorCounter.start()

    username = IO.gets("\nWhat is your username? \n") |> String.trim()
    password = IO.gets("\nWhat is your password? \n") |> String.trim()

    creds_validation(username, password)
    |> access()
  end

  defp creds_validation(username, password) do
    parse()
    |> find_user(username, password)
  end

  #! PARSE local credentials.json to proper JSON format
  defp parse(filename \\ "credentials.json") do
    case File.read(filename) do
      {:ok, body} ->
        decode_json(body)

      {:error, reason} ->
        {:error, "#{:file.format_error(reason)}"}
    end
  end

  #! finding a User in JSON file
  defp find_user({:ok, list_of_maps}, username, password) do
    success = "\nACCESS GRANTED \n"
    denied = "ACCESS DENIED: try again \n"

    Enum.reduce_while(list_of_maps, "", fn map, _acc ->
      if map["username"] == username and map["password_hash"] == password,
        do: {:halt, {:ok, success}},
        else: {:cont, {:error, denied}}
    end)
  end

  defp find_user({:error, error}, _username, _password), do: {:error, error}

  #! All ACCESS variations
  defp access({:ok, "\nACCESS GRANTED \n" = message}) do
    ErrorCounter.stop()
    IO.puts(Colors.yellow() <> "#{message}" <> Colors.reset())
    IO.puts("REVEALING DEEP DARK SECRET... \n\n*** \n")
    get_quote()
  end

  defp access({:error, "no such file or directory"}), do: IO.puts("no such file or directory")
  defp access({:error, "json file is corrupted"}), do: IO.puts("json file is corrupted")

  defp access({:error, error}) do
    ErrorCounter.update()
    count = ErrorCounter.get()

    case count do
      2 ->
        error_message(error, count)
        main()

      1 ->
        error_message(error, count)
        main()

      0 ->
        error_massage()
    end
  end

  defp error_massage() do
    ErrorCounter.stop()

    IO.puts(
      Colors.red() <>
        "*** ACCESS DENIED *** \n" <>
        Colors.reset()
    )

    IO.puts("We can't find that username and password, but you can try again or sign up")
  end

  defp error_message(error, count) when count == 2 do
    IO.puts(error)

    IO.puts(
      Colors.red() <>
        "*** You have #{count} more tries remaining *** \n" <>
        Colors.reset()
    )
  end

  defp error_message(error, count) do
    IO.puts(error)

    IO.puts(
      Colors.red() <>
        "*** You have #{count} more try remaining *** \n" <>
        Colors.reset()
    )
  end

  #! Managing to decode json file credentials.json and HTTP request
  defp decode_json(body) do
    {:ok, [first_el | _] = list_of_maps} = Jason.decode(body)

    cond do
      # when decoding credentials.json
      Map.has_key?(first_el, "username") ->
        {:ok, list_of_maps}

      # when decoding HTTP response
      true ->
        %{"text" => random_quote} = Enum.random(list_of_maps)
        random_quote
    end
  end

  #! HTTTP request to get a single quote
  def get_quote() do
    :httpc.request(:get, {'https://type.fit/api/quotes', []}, [], [])
    |> case do
      {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} -> decode_json(body)
      {:error, _} -> "I WILL REVEAL MY DEEP DARK SECRET NEXT TIME..."
    end
  end
end
