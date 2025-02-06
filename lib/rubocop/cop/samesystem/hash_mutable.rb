# frozen_string_literal: true

module RuboCop
  module Cop
    module Samesystem
      # @example HashMutable: bar (default)
      #   # Description of the `bar` style.
      #
      #   # bad
      #   Hash.new({})
      #
      #   # bad
      #   Hash.new([])
      #
      #   # good
      #   Hash.new { |h, k| h[k] = {} }
      #
      #   # good
      #   Hash.new { |h, k| h[k] = [] }
      #
      class HashMutable < ::RuboCop::Cop::Base
        include RuboCop::Cop::FrozenStringLiteral

        def_node_matcher :hash_with_default?, <<~PATTERN
          (send (const nil? :Hash) :new _)
        PATTERN

        def_node_matcher :string_type?, '(:str _)'

        # @!method operation_produces_immutable_object?(node)
        def_node_matcher :produces_immutable_object?, <<~PATTERN
          {
            (send {float int} {:+ :- :* :** :/ :% :<<} _)
            (send !{(str _) array} {:+ :- :* :** :/ :%} {float int})
            (send _ {:== :=== :!= :<= :>= :< :>} _)
            (send _ {:count :length :size :to_i :to_f :freeze :deep_freeze} ...)
            (block (send _ {:count :length :size} ...) ...)
          }
        PATTERN

        UPCASE_CASE = /^[\dA-Z_]+[!?=]?$/.freeze

        MSG = 'Ensure that default value of Hash returns immutable or a new object'

        def on_send(node)
          return unless hash_with_default?(node)

          _receiver_node, _method_name, arg_node = *node
          return if immutable_literal?(arg_node) || constant?(arg_node) || produces_immutable_object?(arg_node)

          add_offense(node)
        end

        private

        def immutable_literal?(node)
          (frozen_string_literals_enabled? && string_type?(node)) || strip_parenthesis(node).immutable_literal?
        end

        def strip_parenthesis(node)
          if node.begin_type? && node.children.first
            node.children.first
          else
            node
          end
        end

        # Implying that constant will always return .frozen => true
        def constant?(node)
          *_, last_node = *node

          last_node.to_s.match?(UPCASE_CASE)
        end
      end
    end
  end
end
