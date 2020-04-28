# frozen_string_literal: true

# TODO: when finished, run `rake generate_cops_documentation` to update the docs
module RuboCop
  module Cop
    module Samesystem
      # @example EnforcedStyle: single line comments
      #   # Please begin your comments with capital letter if it begins with
      #   # word character, leave single space after # and end your comments
      #   # with period sign or other proper punctuation (?, !, ;).
      #
      #   # bad
      #   #This one is bad (missing space after #).
      #
      #   # bad
      #   # This one is missing period at the end
      #
      #   # bad
      #   # this one begins with lowercase letter.
      #
      #   # bad
      #   my_variable = :assigned # same line comments must be formatted too
      #
      #   # good
      #   # This is well formated comment.
      #
      #   # good
      #   # 1 good comment too! It starts with non-word character!
      #
      #   # good
      #   my_variable = :assigned # Well formatted comment.
      #
      # @example EnforcedStyle: multi line comments
      #   # It goes the same with multi line comments, just you can skip
      #   # punctuation at the end of the lines (except last line).
      #
      #   # bad
      #   # this multiline starts with not capital letter
      #   # and ends without punctuation
      #
      #   # bad
      #   # This one starts properly
      #   # continues well
      #   # But has no punctuation at the end!
      #
      #   # good
      #   # This one
      #   # is well formatted
      #
      #   # good
      #   # Well formatted comment too! You can see
      #   # that middle lines does not have to start with capital letters
      #   # like last lines. But last line must have punctuation.
      #
      class CommentFormat < Cop
        include RangeHelp

        MSG = 'Wrong comment format. Please use this: "# Capital letter, period sign."'
        COMMENT_TYPE = :tCOMMENT

        def investigate(processed_source)
          return if processed_source.tokens.empty?

          tokens = processed_source.tokens
          multiline = false
          tokens.each_with_index do |token, index|
            next unless token.type == COMMENT_TYPE

            multiline = if multiline == false
              investigate_single_comment(token, tokens[index + 1])
            else
              investigate_multiline_comment(token, tokens[index + 1])
            end
          end
        end

        private

        def investigate_single_comment(current_token, next_token)
          if beginning_of_multiline_comment?(current_token, next_token)
            if !special_comment?(current_token.text) && invalid_start?(current_token.text)
              add_offense(current_token, location: current_token.pos)
            end
            return true
          else
            if invalid_comment?(current_token.text)
              add_offense(current_token, location: current_token.pos)
            end
            return false
          end
        end

        def investigate_multiline_comment(current_token, next_token)
          if end_of_multiline_comment?(next_token)
            if !special_comment?(current_token.text) && invalid_end?(current_token.text)
              add_offense(current_token, location: current_token.pos)
            end
            multiline = false
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
          return false if text.end_with?('.', ';', '?', '!')

          true
        end

        def special_comment?(text)
          return true if text.start_with?('# rubocop')
          return true if text.start_with?('# frozen_string_literal')

          false
        end

        def beginning_of_multiline_comment?(current_token, next_token)
          next_token&.type == COMMENT_TYPE && whole_line_comment?(current_token)
        end

        def end_of_multiline_comment?(next_token)
          next_token&.type != COMMENT_TYPE
        end

        def whole_line_comment?(current_token)
          # Checks if comment starts at the new line and is not located at the
          # end of code line, like:
          #
          # # Whole line comment.
          #
          # and not:
          #
          # something = 'text' # End of code line comment.

          current_token.space_before?.nil? || current_token.space_before?.to_s == "\n"
        end
      end
    end
  end
end
