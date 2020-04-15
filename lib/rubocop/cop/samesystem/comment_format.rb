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

        def investigate(processed_source)
          processed_source.each_comment do |comment|
            next if comment.text.start_with?(/# [A-Z\d\W_]/) && comment.text.end_with?('.')
            next if comment.text.start_with?('# rubocop')
            next if comment.text.start_with?('# frozen_string_literal')
            add_offense(comment, location: location(comment))
          end
        end

        private

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
