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
      {_, unanswered}, {_, ongoing}, {_, _ended}
    ] = Summary.conversations
    assert Enum.count(unanswered ) == 0
    assert Enum.count(ongoing    ) == 1
  end

  test "gets conversations with all their tags" do
    TestApp.Repo.insert!(Fixtures.conversation_with_tags(["bug", "bad"]))
    [{_, [new_unanswered | _]}, _, _] = Summary.conversations
    assert Enum.map(new_unanswered.tags, fn (tag) -> tag.name end) == ["bug", "bad"]
  end

end
