# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Samesystem::HashMutable, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'with Numeric' do
    context 'with float' do
      it 'does not register offense' do
        expect_no_offenses(<<~RUBY)
          foo = Hash.new(1.0)
        RUBY
      end
    end

    context 'with integer' do
      it 'does not register offense' do
        expect_no_offenses(<<~RUBY)
          foo = Hash.new(0)
        RUBY
      end
    end
  end

  context 'with math operations' do
    context 'when numeric' do
      it 'does not register offense' do
        expect_no_offenses(<<~RUBY)
          foo = Hash.new(5 + 4)
        RUBY
      end
    end

    context 'when not numeric' do
      it 'does not register offense' do
        expect_offense(<<~RUBY)
          foo = Hash.new(5 + 4 + bar)
                ^^^^^^^^^^^^^^^^^^^^^ Samesystem/HashMutable: Ensure that default value of Hash returns immutable or a new object
        RUBY
      end
    end
  end

  context 'with methods that return Numeric' do
    it 'does not register offense' do
      expect_no_offenses(<<~RUBY)
        foo = Hash.new([1, 2, 3].count)
      RUBY
    end

    it 'does not register offense' do
      expect_no_offenses(<<~RUBY)
        foo = '0.0'.to_f
      RUBY
    end
  end

  context 'with symbol' do
    it 'does not register offense' do
      expect_no_offenses(<<~RUBY)
        foo = Hash.new(:foo)
      RUBY
    end
  end

  context 'with constants' do
    it 'does not register offense' do
      expect_no_offenses(<<~RUBY)
        foo = Hash.new(Math::PI)
      RUBY
    end

    it 'does not register offense' do
      expect_no_offenses(<<~RUBY)
        foo = Hash.new(SameSystem::Calendar::Deep::VERY_SPECIAL_NUMBER)
      RUBY
    end
  end

  context 'when initializing default value using a block' do
    it 'does not register offense' do
      expect_no_offenses(<<~RUBY)
        foo = Hash.new { |h, k| h[k] = {} }
      RUBY
    end
  end

  context 'with string' do
    context 'when frozen_string_literal is enabled' do
      it 'does not register offense' do
        expect_no_offenses(<<~RUBY)
          # frozen_string_literal: true

          foo = Hash.new('string')
        RUBY
      end
    end

    context 'when freezing string' do
      it 'does not register offense' do
        expect_no_offenses(<<~RUBY)
          foo = Hash.new('string'.freeze)
        RUBY
      end
    end

    context 'when frozen_string_literal is not enabled' do
      it 'registers offense when initializing hash' do
        expect_offense(<<~RUBY)
          foo = Hash.new('string')
                ^^^^^^^^^^^^^^^^^^ Samesystem/HashMutable: Ensure that default value of Hash returns immutable or a new object
        RUBY
      end
    end
  end

  context 'when initializing with potentially mutable object' do
    it 'registers offense when initializing hash' do
      expect_offense(<<~RUBY)
        foo = Hash.new(bar)
              ^^^^^^^^^^^^^ Samesystem/HashMutable: Ensure that default value of Hash returns immutable or a new object
      RUBY
    end

    it 'registers offense when initializing hash' do
      expect_offense(<<~RUBY)
        foo = Hash.new([])
              ^^^^^^^^^^^^ Samesystem/HashMutable: Ensure that default value of Hash returns immutable or a new object
      RUBY
    end

    it 'registers offense when initializing hash' do
      expect_offense(<<~RUBY)
        foo = Hash.new({})
              ^^^^^^^^^^^^ Samesystem/HashMutable: Ensure that default value of Hash returns immutable or a new object
      RUBY
    end
  end
end
