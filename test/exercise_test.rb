require "test_helper"

class ExerciseTest < Minitest::Test
  def test_fetch_exercise
    user_mock = Minitest::Mock.new
    user_mock.expect(:account, OpenStruct.new(token: OpenStruct.new(headers: {})))

    Request.stub(:get, nil) do
      assert_raises APIError do
        Exercise.fetch(3, 6, 2, user_mock)
      end
    end

    user_mock.expect(:account, OpenStruct.new(token: OpenStruct.new(headers: {})))

    Request.stub(:get, {}) do
      assert_raises APIError do
        Exercise.fetch(4, 7, 3, user_mock)
      end
    end

    user_mock.expect(:account, OpenStruct.new(token: OpenStruct.new(headers: {})))

    Request.stub(:get, { body: { test_path: "a", exercise_path: "b", test_name: "c", exercise_name: "d" }}) do
      exercise = Exercise.fetch(12, 4, 99, user_mock)
      assert exercise.test_path == "a"
      assert exercise.exercise_path == "b"
      assert exercise.test_name == "c"
      assert exercise.exercise_name == "d"
    end
  end

  def test_test_exercise
  end

  def test_push_exercise
    user_mock = Minitest::Mock.new
    user_mock.expect(:account, OpenStruct.new(token: OpenStruct.new(headers: {})))
    Request.stub(:post, nil) do
      exercise = Exercise.new({})
      exercise.push("", user_mock)
    end
  end
end
