require "test_helper"

class AIBackend::OpenAITestUbicloud < ActiveSupport::TestCase
  setup do
    stub_settings(
      default_ubicloud_model: "llama-3-3-70b-it",
    )

    @conversation = conversations(:attachments)
    @assistant = assistants(:ubicloud_asst)
    @assistant.language_model.update!(supports_tools: false) # this will change the TestClient response so we want to be selective about this
    @openai = AIBackend::OpenAI.new(
      users(:taylor),
      @assistant,
      @conversation,
      @conversation.latest_message_for_version(:latest)
    )
    TestClient::OpenAI.new(access_token: "abc")
  end

  test "initializing client works" do
    assert @openai.client.present?
  end

  test "ubicloud url is properly set" do
    assert_equal "https://llama-3-3-70b-it.ai.ubicloud.com/", @openai.client.uri_base
  end
end
