# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Samesystem::TravelToUsage do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when block is passed as argument is called with block' do
    it 'registers no offenses' do
      expect_no_offenses(<<~RUBY)
        travel_to(Date.current, &example)
      RUBY
    end
  end

  context 'when block is passed as inline block (with curly brackets)' do
    it 'registers no offenses' do
      expect_no_offenses(<<~RUBY)
        travel_to(Date.current) {}
      RUBY
    end
  end

  context 'when travel_to is called with block' do
    it 'registers no offenses' do
      expect_no_offenses(<<~RUBY)
        travel_to(Date.current) do
        end
      RUBY
    end
  end

  context 'when travel_to is called without block' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        before do
          travel_to(Date.current)
          ^^^^^^^^^^^^^^^^^^^^^^^ Samesystem/TravelToUsage: Provide block to avoid time leaks
        end
      RUBY
    end
  end
end
