# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Samesystem::VariableNaming, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) do
    {
      'Samesystem/VariableNaming' => {
        'EnforcedStyle' => 'it',
        'SupportedStyles' => ['it']
      }
    }
  end

  it 'registers an offense when using `it` inside code block' do
    expect_offense(<<~RUBY)
      1..2.each { |it| it.present? }
                   ^^ Please use descriptive variable names.
    RUBY
  end

  it 'registers an offense when using `it` as a variable name' do
    expect_offense(<<~RUBY)
      it = 1
      ^^ Please use descriptive variable names.
    RUBY
  end

  it 'does not register an offense when using any other variable name inside '\
     'code block' do
    expect_no_offenses(<<~RUBY)
      1..2.each { |number| number.present? }
    RUBY
  end

  it 'does not register an offense when using any other variable name' do
    expect_no_offenses(<<~RUBY)
      its_something = 1
    RUBY
  end
end
