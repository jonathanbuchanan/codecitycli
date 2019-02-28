require "test_helper"
include CodeCityCLI

class UserTest < Minitest::Test
  def test_user_type
    assert User.new(user_type: :student).account.class == Student
    assert User.new(user_type: :instructor).account.class == Instructor
    assert User.new(user_type: :developer).account.class == Developer
    assert User.new(user_type: :admin).account.class == Admin
    assert_raises ValidationError do
      User.new(user_type: :not_a_valid_user_type)
    end
  end

  def test_authenticate
    # Trying to authenticate without a email or password produces an error
    assert_raises ValidationError do
      Student.new.authenticate
    end

    # Only email still produces an error
    assert_raises ValidationError do
      Student.new(email: "test.user@test.com").authenticate
    end

    # Only password still produces an error
    assert_raises ValidationError do
      Student.new(password: "password").authenticate
    end

    # A nil response produces an API error
    Request.stub(:post, {}) do
      assert_raises APIError do
        Student.new(email: "a", password: "b").authenticate
      end
    end

    # A response without a success flag produces an API error
    Request.stub(:post, { body: {} }) do
      assert_raises APIError do
        Student.new(email: "a", password: "b").authenticate
      end
    end

    # A response with a success flag of false produces authentication error
    Request.stub(:post, { body: { success: false }}) do
      assert_raises AuthenticationError do
        Student.new(email: "a", password: "b").authenticate
      end
    end

    # Response must have header
    Request.stub(:post, { body: { success: true }}) do
      assert_raises APIError do
        Student.new(email: "a", password: "b").authenticate
      end
    end

    # Header cannot be blank
    Request.stub(:post, { body: { success: true }, headers: {}}) do
      assert_raises APIError do
        Student.new(email: "a", password: "b").authenticate
      end
    end

    Request.stub(:post, { body: { success: true }, headers: { client: "b", expiry: "c", uid: "d"}}) do
      assert_raises APIError do
        Student.new(email: "a", password: "b").authenticate
      end
    end

    Request.stub(:post, { body: { success: true }, headers: { 'access-token' => "a", expiry: "c", uid: "d"}}) do
      assert_raises APIError do
        Student.new(email: "a", password: "b").authenticate
      end
    end

    Request.stub(:post, { body: { success: true }, headers: { 'access-token' => "a", client: "b", uid: "d"}}) do
      assert_raises APIError do
        Student.new(email: "a", password: "b").authenticate
      end
    end

    Request.stub(:post, { body: { success: true }, headers: { 'access-token' => "a", client: "b", expiry: "c"}}) do
      assert_raises APIError do
        Student.new(email: "a", password: "b").authenticate
      end
    end

    Request.stub(:post, { body: { success: true }, headers: { 'access-token' => "a", client: "b", expiry: "d", uid: "d"}}) do
      assert Student.new(email: "a", password: "b").authenticate != nil
    end
  end

  def test_auth_token_headers
    token = AuthToken.new('access-token' => "asdf", client: "theclient", expiry: "1000", uid: "email")
    headers = token.headers
    assert headers['access-token'] == "asdf"
    assert headers['client'] == "theclient"
    assert headers['expiry'] == "1000"
    assert headers['uid'] == "email"
  end
end
