# frozen_string_literal: true

# TODO: when finished, run `rake generate_cops_documentation` to update the docs
module RuboCop
  module Cop
    module Samesystem
      # TODO: Write cop description and example of bad / good code. For every
      # `SupportedStyle` and unique configuration, there needs to be examples.
      # Examples must have valid Ruby syntax. Do not use upticks.
      #
      # @example EnforcedStyle: bar (default)
      #   # Description of the `bar` style.
      #
      #   # bad
      #   bad_bar_method
      #
      #   # bad
      #   bad_bar_method(args)
      #
      #   # good
      #   good_bar_method
      #
      #   # good
      #   good_bar_method(args)
      #
      # @example EnforcedStyle: foo
      #   # Description of the `foo` style.
      #
      #   # bad
      #   bad_foo_method
      #
      #   # bad
      #   bad_foo_method(args)
      #
      #   # good
      #   good_foo_method
      #
      #   # good
      #   good_foo_method(args)
      #
      class CommentFormat < Cop
        include RangeHelp

        MSG = 'Comments should begin with space, then capital letter or non-word character and end with period.'
        COMMENT_TYPE = :tCOMMENT

        def investigate(processed_source)
          process_comments(processed_source.tokens)
        end

        private

        def process_comments(tokens)
          return if tokens.empty?

          multiline = 0
          tokens.each_with_index do |token, index|
            if token.type == COMMENT_TYPE
              if multiline == 0
                multiline = 1
                if tokens[index + 1]&.type == COMMENT_TYPE
                  if !special_comment?(token.text) && invalid_start?(token.text)
                    add_offense(token, location: token.pos)
                  end
                else
                  if invalid_comment?(token.text)
                    add_offense(token, location: token.pos)
                  end
                end
              else
                if tokens[index + 1]&.type != COMMENT_TYPE
                  if !special_comment?(token.text) && invalid_end?(token.text)
                    add_offense(token, location: token.pos)
                  end
                  multiline = 0
                end
              end
            end
          end
        end

        def invalid_comment?(text)
          return false if special_comment?(text)
          return false unless invalid_start?(text) || invalid_end?(text)

          true
        end

        def invalid_start?(text)
          return false if text.start_with?(/# [A-Z\d\W_]/)

          true
        end

        def invalid_end?(text)
          return false if text.end_with?('.')

          true
        end

        def special_comment?(text)
          return true if text.start_with?('# rubocop')
          return true if text.start_with?('# frozen_string_literal')

          false
        end

        def location(comment)
          expression = comment.loc.expression
          range_between(
            expression.begin_pos,
            expression.end_pos
          )
        end
      end
    end
  end
end
