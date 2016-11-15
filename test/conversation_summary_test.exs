defmodule Consult.ConversationSummaryTest do
  use Consult.ModelCase
  alias Consult.ConversationSummary, as: Summary

  test "lists conversations by category" do
    TestApp.Repo.insert!(Fixtures.unanswered_conversation)
    TestApp.Repo.insert!(Fixtures.conversation_owned_by(%{rep_id: "1"}))
    TestApp.Repo.insert!(Fixtures.conversation_owned_by(%{rep_id: "1"}))
    TestApp.Repo.insert!(Fixtures.conversation_owned_by(%{rep_id: "2"}))
    TestApp.Repo.insert!(Fixtures.ended_conversation)

    [
      {"Unanswered", unanswered},
      {"Owned by Me", owned_by_me},
      {"Owned by Other Reps", owned_by_others},
      {"Ended", ended}
    ] = Summary.conversations("1")
    assert Enum.count(unanswered      ) == 1
    assert Enum.count(owned_by_me     ) == 2
    assert Enum.count(owned_by_others ) == 1
    assert Enum.count(ended           ) == 1
  end

end
