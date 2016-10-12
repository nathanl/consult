defmodule Consult.ConversationSummaryTest do
  use Consult.ModelCase
  alias Consult.ConversationSummary, as: Summary

  test "lists conversations by category" do
    TestApp.Repo.insert!(Fixtures.unanswered_conversation)
    TestApp.Repo.insert!(Fixtures.ongoing_conversation)
    TestApp.Repo.insert!(Fixtures.ongoing_conversation)
    TestApp.Repo.insert!(Fixtures.ended_conversation)

    [
      {"Unanswered", unanswered}, {"Ongoing", ongoing}, {"Ended", ended}
    ] = Summary.conversations
    assert Enum.count(unanswered ) == 1
    assert Enum.count(ongoing    ) == 2
    assert Enum.count(ended      ) == 1
  end

  test "for 'unanswered' vs 'ongoing', checks unique participants by id AND name" do
    TestApp.Repo.insert!(Fixtures.ongoing_conversation(%{rep_id: nil}))
    [
      {"Unanswered", unanswered}, {"Ongoing", ongoing}, {"Ended", ended}
    ] = Summary.conversations
    assert Enum.count(unanswered ) == 0
    assert Enum.count(ongoing    ) == 1
  end

end
