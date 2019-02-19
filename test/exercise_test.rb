require "test_helper"

class ExerciseTest < Minitest::Test
  def test_fetch_exercise
    user_mock = Minitest::Mock.new
    user_mock.expect(:account, OpenStruct.new(token: OpenStruct.new(headers: {})))

    # Nil response
    Request.stub(:get, nil) do
      assert_raises APIError do
        Exercise.fetch(3, 6, 2, user_mock)
      end
    end

    user_mock.expect(:account, OpenStruct.new(token: OpenStruct.new(headers: {})))

    # Empty Response
    Request.stub(:get, {}) do
      assert_raises APIError do
        Exercise.fetch(4, 7, 3, user_mock)
      end
    end

    user_mock.expect(:account, OpenStruct.new(token: OpenStruct.new(headers: {})))

    # Full response
    Request.stub(:get, { body: { course_id: 7, lesson_id: 2, exercise_id: 1, title: "title", instructions: "instructions", test_url: "a", exercise_url: "b", point_value: 10.77 }}) do
      # Rethrows the error
      assert_raises ConnectionError do
        Faraday.stubs(:get).raises(Faraday::ClientError, "error")
        exercise = Exercise.fetch(12, 4, 99, user_mock)
        assert exercise.course_id == 7
        assert exercise.lesson_id == 2
        assert exercise.exercise_id == 1
        assert exercise.title == "title"
        assert exercise.instructions == "instructions"
        assert exercise.test_url == "a"
        assert exercise.exercise_url == "b"
        assert exercise.point_value == 10.77
      end
    end

    user_mock.verify
  end

  def test_test_exercise
    exercise = Exercise.new(test_url: "asdf")

    File.stub(:open, "
print (\"hello world\\n\")
return submission.split.first
      ") do
      result = exercise.test "submission"
      assert result == "print"
    end
  end

  def test_push_exercise
    user_mock = Minitest::Mock.new

    assert_raises ValidationError do
      exercise = Exercise.new({})
      exercise.push(nil, user_mock)
    end

    user_mock.expect(:account, OpenStruct.new(token: OpenStruct.new(headers: {})))

    assert_raises ValidationError do
      exercise = Exercise.new({})
      exercise.push("./afilethatdoesnotexist.txt", user_mock)
    end

    File.stub(:open, "asdf") do
      Request.stub(:post, nil) do
        exercise = Exercise.new({})
        exercise.push("", user_mock)
      end
    end

    user_mock.verify
  end
end
