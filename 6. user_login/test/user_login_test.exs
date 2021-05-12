defmodule UserLoginTest do
  use ExUnit.Case

  alias UserLogin

  describe "UserLogin.get_quote()" do
    test "success" do
      single_quote = UserLogin.get_quote()

      assert is_binary(single_quote)
    end
  end
end
