require 'json'

module Ctrf
  class RSpecFormatter
    RSpec::Core::Formatters.register self, :start, :stop, :example_started, :example_finished

    attr_reader :output

    def initialize(output)
      @output = output
    end

    def start(_notification)
      @tests = {}
      @run_start = Time.now.to_i
    end

    def example_started(notification)
      @retries = 0

      # Set up the object for use if it doesn't exist already
      # It might, if retries
      return if @tests.key?(notification.example.hash)

      @tests[notification.example.hash] = {
        name: notification.example.full_description,
        suite: notification.example.example_group.name,
        # We use id here because it's location + test scope, e.g. what we need to rerun the test
        # Otherwise, this could is the location of the `it` - even if that's in a helper file unrelated to the test
        filePath: notification.example.id,
        extra: {
          hash: notification.example.hash
        }
      }
    end

    # Gets hit if rspec-retry is enabled, for flaky support
    def retry(example)
      @retries += 1

      # We add the previous traces here, because we only hit example_finished once
      test = @tests[example.hash]
      test[:extra][:previous_traces] = [] unless test[:extra].key?(:previous_traces)
      backtrace_formatter = RSpec.configuration.backtrace_formatter
      return unless example.exception

      test[:extra][:previous_traces].push("#{example.exception.detailed_message}\n" + backtrace_formatter.format_backtrace(
        example.exception.backtrace, example.metadata
      ).join("\n"))
    end

    def example_finished(notification)
      test = @tests[notification.example.hash]

      test[:duration] = notification.example.execution_result.run_time * 1000
      test[:start] = notification.example.execution_result.started_at.to_i
      test[:stop] = notification.example.execution_result.finished_at.to_i

      test[:status] = notification.example.execution_result.status.to_s
      test[:rawStatus] = notification.example.execution_result.status

      # If we passed but retries is >0, the test is flaky
      test[:flaky] = test[:status] == 'passed' && @retries > 0
      test[:retries] = @retries

      # Attach error information, if any
      exception = notification.example.exception
      test[:message] = exception.detailed_message if exception

      # If this wasn't the first run, move the trace to extra
      if test.key?(:trace)
        test[:extra][:previous_traces] = [] unless test[:extra].key?(:previous_traces)
        test.delete(:trace)
      end
      test[:trace] = notification.formatted_backtrace.join("\n") if exception
    end

    def stop(_notification)
      # Build the final result object
      result = {
        results: {
          tool: {
            name: 'rspec'
          },
          summary: {
            tests: @tests.count,
            passed: @tests.values.select { |test| test[:status] == 'passed' }.count,
            failed: @tests.values.select { |test| test[:status] == 'failed' }.count,
            pending: @tests.values.select { |test| test[:status] == 'pending' }.count,
            skipped: @tests.values.select { |test| test[:status] == 'skipped' }.count,
            other: @tests.values.select { |test| test[:status] == 'other' }.count,
            start: @run_start,
            stop: Time.now.to_i
          },
          tests: @tests.values
        }
      }

      @output.write(JSON.pretty_generate(result))
    end
  end
end
