defmodule Consult.Token do

  def sign_user_id(user_id) do
    Phoenix.Token.sign(Consult.endpoint, "user_id", user_id)
  end

  def verify_user_id(user_id_token) do
    {:ok, user_id} =  Phoenix.Token.verify(
      Consult.endpoint, "user_id", user_id_token
    )
    user_id
  end

end
