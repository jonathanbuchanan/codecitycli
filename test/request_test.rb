require "test_helper"

class RequestTest < Minitest::Test
  def test_request_prefix
    config_mock = Minitest::Mock.new
    config_mock.expect(:organization, nil)
    Config.stub(:instance, config_mock) do
      assert_raises ValidationError do
        Request.request_prefix
      end
    end
    config_mock.verify
  end
end
