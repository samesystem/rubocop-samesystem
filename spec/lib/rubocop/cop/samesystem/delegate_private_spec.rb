# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Samesystem::DelegatePrivate do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) do
    {}
  end

  context 'when no delegate is provided' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        class User
        end
      RUBY
    end
  end

  context 'when delegate is provided in public scope without "private: true"' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        class User
          delegate :name, to: :user
        end
      RUBY
    end
  end

  context 'when delegate is provided in public scope with "private: true"' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class User
          delegate :name, to: :user, private: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ private `delegate` should be put in private section
        end
      RUBY
    end
  end

  context 'when delegate is provided in private scope without "private: true"' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class User
          private

          delegate :name, to: :user
          ^^^^^^^^^^^^^^^^^^^^^^^^^ `delegate` in private section should have `private: true` option
        end
      RUBY
    end
  end

  context 'when delegate is provided in private scope with "private: true"' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        class User
          private

          delegate :name, to: :user, private: true
        end
      RUBY
    end
  end

  context 'when delegate is provided in public scope without "private: true" in outer class' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        class User
          class InnerUser
            private
            def foo; end
          end

          delegate :name, to: :user
        end
      RUBY
    end
  end

  context 'when `private: true` is in explicit public scope' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        class User
          private

          def foo
          end

          public

          delegate :name, to: :user
        end
      RUBY
    end
  end

  context 'when private scope is set on method, but `private: true` is used in public scope' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        class User
          private def foo
          end

          delegate :name, to: :user
        end
      RUBY
    end
  end
end
