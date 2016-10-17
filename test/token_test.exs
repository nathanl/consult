defmodule Consult.TokenTest do
  use ExUnit.Case

  test "signs and verifies a numeric user id" do
    user_id = 99
    token = Consult.Token.sign_user_id(user_id)
    assert user_id == Consult.Token.verify_user_id(token)
  end

  test "signs and verifies a nil user id" do
    user_id = nil
    token = Consult.Token.sign_user_id(user_id)
    assert user_id == Consult.Token.verify_user_id(token)
  end

end
