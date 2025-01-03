require "test_helper"

class ToolboxTest < ActiveSupport::TestCase
  test "tools returns information on all the tools" do
    assert Toolbox.tools.length > 2
    assert Toolbox::OpenMeteo.tools.first[:function].values.all? { |value| value.present? }
    assert Toolbox::OpenMeteo.tools.first[:function][:description].length > 100
  end

  test "tools includes gmail if enabled" do
    stub_features(google_tools: true) do
      Current.set(user: users(:keith)) do
        assert users(:keith).gmail_credential
        assert Toolbox.descendants.include? Toolbox::Gmail
      end
    end
  end

  test "tool excludes gmail if disabled" do
    stub_features(google_tools: false) do
      Current.set(user: users(:keith)) do
        assert users(:keith).gmail_credential
        refute Toolbox.descendants.include? Toolbox::Gmail
      end
    end

    stub_features(google_tools: true) do
      Current.set(user: users(:rob)) do
        refute users(:rob).gmail_credential
        refute Toolbox.descendants.include? Toolbox::Gmail
      end
    end
  end

  test "tools contain only web search in ubicloud mode" do
    stub_features(ubicloud_mode: true, web_search: true) do
      new_user = User.create!(first_name: "First", last_name: "Last")
      Current.user = new_user
      assert Toolbox.tools.length == 1
      assert Toolbox.descendants.include? Toolbox::WebSearch
    end

    stub_features(ubicloud_mode: true, web_search: true) do
      Current.user = users(:keith)
      new_user = User.create!(first_name: "First", last_name: "Last")
      Current.user = new_user
      new_user.update!(preferences: { web_search: false })
      refute Toolbox.tools.any?
    end

    stub_features(ubicloud_mode: true, web_search: false) do
      Current.user = users(:keith)
      new_user = User.create!(first_name: "First", last_name: "Last")
      Current.user = new_user
      new_user.update!(preferences: { web_search: true })
      refute Toolbox.tools.any?
    end
  end

  test "describe directive within a tool sets the function description" do
    tool = Toolbox::HelloWorld.tools.find { |t| t[:function][:name] == "helloworld_hi" }
    assert_equal "This is a description for hi", tool.dig(:function, :description)
  end

  test "tools get a default description if describe is not used" do
    tool = Toolbox::HelloWorld.tools.find { |t| t[:function][:name] == "helloworld_get_eligibility" }
    assert_equal "Get eligibility given birthdate and gender", tool.dig(:function, :description)
  end

  test "call executes a tool" do
    assert_equal "Hello, World!", Toolbox.call("helloworld_hi", { name: "World" })
  end
end
