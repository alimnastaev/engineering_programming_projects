defmodule UserLogin do
  @moduledoc false

  #! ENTRYPOINT function
  def main() do
    username = IO.gets("What is your username?\n") |> String.trim()
    password = IO.gets("What is your password?\n") |> String.trim()

    creds_validation(username, password)
    |> access()
  end

  defp creds_validation(username, password) do
    parse()
    |> find_user(username, password)
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
    IO.puts(message)
    IO.puts("REVEALING DEEP DARK SECRET... \n\n*** \n")
    get_quote()
  end

  defp access({:error, "no such file or directory"}), do: IO.puts("no such file or directory")
  defp access({:error, "json file is corrupted"}), do: IO.puts("json file is corrupted")

  defp access({:error, error}) do
    IO.puts(error)
    main()
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

  #! Managing to decode json file credentials.json and HTTP request
  defp decode_json(body) do
    {:ok, [head | _] = list_of_maps} = Jason.decode(body)

    cond do
      # when decoding credentials.json
      Map.has_key?(head, "username") ->
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
