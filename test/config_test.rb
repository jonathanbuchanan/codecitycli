require "test_helper"

class ConfigTest < Minitest::Test
  def test_config_load
    # Loading a blank file
    YAML.stub(:load, nil) do
      Config.instance.load

      assert Config.instance.user_type == nil
      assert Config.instance.user_id == nil
      assert Config.instance.organization == nil
      assert Config.instance.token == nil
      assert Config.instance.directory == Dir.home
    end

    # Loading a full file
    YAML.stub(:load, { user_type: "a", user_id: "b", organization: "c", token: "d", directory: "e" }) do
      Config.instance.load

      assert Config.instance.user_type == "a"
      assert Config.instance.user_id == "b"
      assert Config.instance.organization == "c"
      assert Config.instance.token == "d"
      assert Config.instance.directory == "e"
    end
  end

  def test_config_save
    # Generates correct string
    Config.instance.user_type = "a"
    Config.instance.user_id = "b"
    Config.instance.organization = "c"
    Config.instance.token = "d"
    Config.instance.directory = "e"
    save_mock = MiniTest::Mock.new
    save_mock.expect(:write, nil, ["---\n:user_type: a\n:user_id: b\n:organization: c\n:token: d\n:directory: e\n"])
    File.stub(:open, save_mock) do
      Config.instance.save
    end
    save_mock.verify
  end
end
