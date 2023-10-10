# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Samesystem::ConstantNaming do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) do
    {
      'Samesystem/ConstantNaming' => {
        'UndesirableNames' => undesirable_names_config
      }
    }
  end

  let(:undesirable_names_config) do
    {
      'BAD_NAME' => {
        'Message' => 'Use GOOD_NAME instead of BAD_NAME'
      }
    }
  end

  describe 'bad constant name' do
    context 'when method is called on constant' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          BAD_NAME.test(true)
          ^^^^^^^^ Use GOOD_NAME instead of BAD_NAME
        RUBY
      end
    end

    context 'when constant is used as a variable' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          MyService.call(name: BAD_NAME)
                               ^^^^^^^^ Use GOOD_NAME instead of BAD_NAME
        RUBY
      end
    end

    context 'when constant is used as a hash' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          BAD_NAME['name']
          ^^^^^^^^ Use GOOD_NAME instead of BAD_NAME
        RUBY
      end
    end

    context 'when multiple bad constants are used' do
      let(:undesirable_names_config) do
        super().merge(
          'OTHER_BAD_CONSTANT' => {
            'Message' => 'Use GOOD_CONSTANT instead of OTHER_BAD_CONSTANT'
          }
        )
      end

      it 'registers multiple offenses' do
        expect_offense(<<~RUBY)
          BAD_NAME.test(OTHER_BAD_CONSTANT)
                        ^^^^^^^^^^^^^^^^^^ Use GOOD_CONSTANT instead of OTHER_BAD_CONSTANT
          ^^^^^^^^ Use GOOD_NAME instead of BAD_NAME
        RUBY
      end
    end
  end

  describe 'good constant name' do
    context 'when method is called on constant' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          GOOD_NAME.test(true)
        RUBY
      end
    end

    context 'when constant is used as a variable' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          MyService.call(name: GOOD_NAME)
        RUBY
      end
    end
  end
end
