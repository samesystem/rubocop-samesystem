# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Samesystem::CommentFormat do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  describe 'wrong comment style' do
    context 'when comment starts with lowercase letter' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          # test
          ^^^^^^ Wrong comment format. Please use this: "# Capital letter, period sign."
        RUBY
      end
    end

    context 'when comment has no period at the end of it' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          # Test
          ^^^^^^ Wrong comment format. Please use this: "# Capital letter, period sign."
        RUBY
      end
    end

    context 'when comment has no space before first character' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          #Test.
          ^^^^^^ Wrong comment format. Please use this: "# Capital letter, period sign."
        RUBY
      end
    end

    context 'when multiple multi and single line comments' do
      it 'registers an offense for single comment before multiline' do
        expect_offense(<<~RUBY)
          a = 1 # Not multiline
                ^^^^^^^^^^^^^^^ Wrong comment format. Please use this: "# Capital letter, period sign."
          # First line of ML comment
          # second line of ML comment.
        RUBY
      end
    end
  end

  describe 'correct comment style' do
    context 'when comment starts with capital letter and ends with period' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          # Test.
        RUBY
      end
    end

    context 'when comment starts with number' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          # 5Test.
        RUBY
      end
    end

    context 'when comment starts with other character' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          # !!!Test.
        RUBY
      end
    end

    context 'when inline comment' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          assign_me = 'to this' # Test.
        RUBY
      end
    end

    context 'when multiline comment' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          # Another comment
          # which has multiple lines.

          a = 1 # Not multiline.
          # First line of ML
          # middle
          # second line of ML.
        RUBY
      end
    end

    context 'when rubocop comments' do
      it 'does not register an offense if comment starts with rubocop' do
        expect_no_offenses(<<~RUBY)
          # rubocop:disable ...
        RUBY
      end

      it 'does not register an offense if frozen_string_literal comment' do
        expect_no_offenses(<<~RUBY)
          # frozen_string_literal
        RUBY
      end
    end

    context 'when ends with other proper punctuation' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          # Propper comment!
          a = 1
          # Propper comment?
          b = 2
          # Propper comment;
        RUBY
      end
    end
  end
end
