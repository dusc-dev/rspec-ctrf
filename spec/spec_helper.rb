# frozen_string_literal: true

require 'ctrf/r_spec_formatter'
require 'rspec-json_matchers'

RSpec.configure do |config|
  config.include RSpec::JsonMatchers::Matchers
end

def example_notification(specific_example = new_example)
  RSpec::Core::Notifications::ExampleNotification.for specific_example
end

def new_example(metadata = {})
  metadata = metadata.dup
  result = RSpec::Core::Example::ExecutionResult.new
  result.started_at = Time.now
  result.record_finished(metadata.delete(:status) { :passed }, Time.now)
  result.exception = Exception.new if result.status == :failed

  instance_double(RSpec::Core::Example,
                  id: 'file.spec',
                  description: 'Example',
                  full_description: 'Example',
                  example_group: group,
                  execution_result: result,
                  exception: result.exception,
                  location: '',
                  location_rerun_argument: '',
                  metadata: {
                    shared_group_inclusion_backtrace: []
                  }.merge(metadata))
end

def examples(n)
  Array.new(n) { new_example }
end

def group
  group = class_double RSpec::Core::ExampleGroup, description: 'Group'
  allow(group).to receive(:parent_groups) { [group] }
  group
end
