# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Samesystem::GraphqlFormat do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when no graphql block is provided' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        class User
          include GraphqlRails::Model
        end
      RUBY
    end
  end

  context 'when block argument name is correct' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        class User
          graphql do |c|
            c.attribute(:name).type('String')
          end
        end
      RUBY
    end
  end

  context 'when wrong graphql block argument is given' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        # class User
          graphql do |wrong|
                      ^^^^^ `graphql` block should have argument named `c`
            wrong.attribute(:name).type('String')
          end
        # end
      RUBY
    end
  end

  context 'when graphql block without arguments is given' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class User
          graphql do
          ^^^^^^^^^^ `graphql` block should have single argument
          end
        end
      RUBY
    end
  end

  context 'when graphql block with multiple arguments is given' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class User
          graphql do |c, d|
          ^^^^^^^^^^^^^^^^^ `graphql` block should have single argument
          end
        end
      RUBY
    end
  end

  context 'when attribute with hash-style (non-chainable) syntax' do
    context 'when graphql block has multiple attribute calls' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class User
            graphql do |c|
              c.attribute :id, type: 'String'
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `c.attribute` must be defined using chainable syntax such as `c.attribute(:name).type('String')`
              c.attribute(:name)
            end
          end
        RUBY
      end
    end

    context 'when graphql block has single attribute' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          class User
            graphql do |c|
              c.attribute :first_name, type: 'String!'
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `c.attribute` must be defined using chainable syntax such as `c.attribute(:name).type('String')`
            end
          end
        RUBY
      end
    end
  end

  context 'when type is defined as non-string' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class User
          graphql do |c|
            c.attribute(:first_name).type(:String!)
                                          ^^^^^^^^ `.type` argument must be a string such as `.type('User')`
          end
        end
      RUBY
    end
  end

  context 'when type argument is not valid and there are other methods used' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class User
          graphql do |c|
            c.attribute(:friends_count)
             .required
             .type(:Integer)
                   ^^^^^^^^ `.type` argument must be a string such as `.type('User')`
             .property(:friends_number)

          end
        end
      RUBY
    end
  end

  context 'when type argument is not valid and there are other arguments' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class User
          graphql do |c|
            c.attribute(:first_name).type('String')
            c.attribute(:friends_count).type(:Integer)
                                             ^^^^^^^^ `.type` argument must be a string such as `.type('User')`
          end
        end
      RUBY
    end
  end


  context 'when shortcut types are used' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class User
          graphql do |c|
            c.attribute(:admin).type('[bool!]!')
                                     ^^^^^^^^^^ Use "[Boolean!]!" instead
          end
        end
      RUBY
    end
  end

  context 'when graphql block has attributes with chainable syntax' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        class User
          graphql do |c|
            c.attribute(:first_name).type('String!')
          end
        end
      RUBY
    end
  end

  context 'with empty block' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        class User
          graphql do |c|
          end
        end
      RUBY
    end
  end
end
