# CodeCityCLI

A command line tool to download, test, and submit exercises from Code City

## Installation

Install it yourself as:

    $ gem install codecitycli

## Usage

### Configuration

To configure the directory that the tool uses:

    $ codecitycli config --directory=YOUR_DIRECTORY

Configuration is stored in the home directory at ~/.codecity.config

### Authentication

To log in, run:

    $ codecitycli login --as=USER_TYPE YOUR_EMAIL YOUR_PASSWORD

*the `as` option defaults to `student`, but you can use `instructor`, `developer`, or `admin` as well to match your account type*

---

To log out, simply run:

    $ codecitycli logout

### Doing Exercises

Run this to fetch an exercise from a course you are enrolled in:

    $ codecitycli fetch COURSE_ID/LESSON_ID/EXERCISE_ID

This will place the test file and the exercise files in the folder `course_name/lesson_name/exercise_name` within the directory specified in the configuration.

---

To test the exercise locally, run:

    $ codecitycli test COURSE_ID/LESSON_ID/EXERCISE_ID

---

Finally, to submit your completed solution, type:

    $ codecitycli push COURSE_ID/LESSON_ID/EXERCISE_ID SOLUTION_FILE

### Other

As an admin, developer, or instructor, run this to generate a new token:

    $ codecitycli token EMAIL USER_TYPE

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Roadmap

- Interpret exercise ids as a hex string that is parsed by the tool

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jonathanbuchanan/codecitycli.

## License

This project is available under the [MIT License](./LICENSE.txt)
