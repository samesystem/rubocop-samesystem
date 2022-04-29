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
      #   travel_to(Date.current)
      #
      #   # good
      #   travel_to(Date.current) { ... }
      #
      #   # good
      #   travel_to(Date.current, &block)
      #
      class TravelToUsage < Cop
        MSG = 'Provide block to avoid time leaks'

        def on_send(node)
          return unless node.method_name == :travel_to
          return if contains_block?(node)

          add_offense(node)
        end

        def contains_block?(node)
          node.block_node || node.arguments.last&.block_pass_type?
        end
      end
    end
  end
end
