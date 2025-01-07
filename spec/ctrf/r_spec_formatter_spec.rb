# frozen_string_literal: true

require 'json'

RSpec.describe Ctrf::RSpecFormatter do
  let(:output) { StringIO.new }
  let(:formatter) { described_class.new(output) }
  let(:example) { nil }

  before do
    formatter.start(nil)
    formatter.example_started(example)
  end

  describe 'passing example' do
    let(:example) { example_notification(new_example({ status: :passed })) }

    before do
      formatter.example_finished(example)
      formatter.stop(example)
      output.rewind
    end

    it 'is expected to have 1 pass' do
      str = output.read
      expect(str).to be_json.with_content('passed').at_path('results.tests.0.status')
      expect(str).to be_json.with_content(1).at_path('results.summary.passed')
    end
  end

  describe 'failing example' do
    let(:example) { example_notification(new_example({ status: :failed })) }

    before do
      formatter.example_finished(example)
      formatter.stop(example)
      output.rewind
    end

    it 'is expected to have 1 failed' do
      str = output.read
      expect(str).to be_json.with_content('failed').at_path('results.tests.0.status')
      expect(str).to be_json.with_content(1).at_path('results.summary.failed')
    end
  end

  describe 'pending example' do
    let(:example) { example_notification(new_example({ status: :pending })) }

    before do
      formatter.example_finished(example)
      formatter.stop(example)
      output.rewind
    end

    it 'is expected to have 1 pending' do
      str = output.read
      expect(str).to be_json.with_content('pending').at_path('results.tests.0.status')
      expect(str).to be_json.with_content(1).at_path('results.summary.pending')
    end
  end
end
