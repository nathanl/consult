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

  @tag :skip
  test "includes the first and last message from the user" do
    TestApp.Repo.insert!(Fixtures.ended_conversation)
    [_, _, {_, [ended|_]}] = Summary.conversations
    assert ended.first_user_message_name == "Alex"
    assert Regex.match?(~r/How quickly/, ended.first_user_message_content)
    assert ended.last_user_message_name == "Alex"
    assert Regex.match?(~r/probably fine/, ended.last_user_message_content)
  end

  test "gets conversations with all their tags" do
    TestApp.Repo.insert!(Fixtures.conversation_with_tags(["bug", "bad"]))
    [{_, [new_unanswered | _]}, _, _] = Summary.conversations
    assert Enum.map(new_unanswered.tags, fn (tag) -> tag.name end) == ["bug", "bad"]
  end

end
