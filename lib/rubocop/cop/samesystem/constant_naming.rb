# frozen_string_literal: true

module RuboCop
  module Cop
    module Samesystem
      # Cop that checks for the use of constants that are not allowed
      #
      # @example ConstantNaming: { 'PreferredNames' => { 'BAD_NAME' => 'GOOD_NAME' } }
      #
      #   # bad
      #   BAD_NAME
      #
      #   # good
      #   GOOD_NAME
      class ConstantNaming < RuboCop::Cop::Cop
        MSG = 'Use %<good_name>s instead of %<bad_name>s'

        CONST_NODE_REGEXP = /\(const (nil)? :([\w\d_]+)\)/.freeze

        def on_const(node)
          preferred_names = config.for_cop(self).fetch('PreferredNames', [])

          constant_name = node.const_name
          good_name = preferred_names[constant_name]
          return if good_name.nil?

          add_wrong_name_offense(node, constant_name, good_name)
        end

        private

        def add_wrong_name_offense(node, bad_name, good_name)
          message = format(MSG, good_name: good_name, bad_name: bad_name)
          add_offense(node, message: message)
        end
      end
    end
  end
end
