require "test_helper"

class NewsletterConfigTest < ActiveSupport::TestCase
  test "defines required columns" do
    columns = NewsletterConfig.columns_hash

    assert_not columns.fetch("account_id").null
    assert_not columns.fetch("cadence").null
    assert_not columns.fetch("template_key").null
    assert_not columns.fetch("tone").null
    assert_not columns.fetch("story_count").null
    assert_not columns.fetch("autopilot_enabled").null
  end

  test "applies database defaults" do
    config = NewsletterConfig.new(
      account_id: accounts(:one).id,
      cadence: "weekly",
      template_key: "weekly_default"
    )

    assert_equal "balanced", config.tone
    assert_equal 5, config.story_count
    assert_equal false, config.autopilot_enabled
    assert_equal "UTC", config.default_send_timezone
    assert_equal 9, config.default_send_hour
    assert_equal 0, config.default_send_minute
    assert_equal 1, config.default_send_weekday
  end
end
