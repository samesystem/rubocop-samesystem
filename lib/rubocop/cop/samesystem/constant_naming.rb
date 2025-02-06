# frozen_string_literal: true

module RuboCop
  module Cop
    module Samesystem
      # Cop that checks for the use of constants that are not allowed
      #
      # @example ConstantNaming: { 'UndesirableNames' => { 'BAD_NAME' => { 'Message' => 'Do not use BAD_NAME' } } }
      #
      #   # bad
      #   BAD_NAME
      #
      #   # good
      #   GOOD_NAME
      class ConstantNaming < ::RuboCop::Cop::Base
        CONST_NODE_REGEXP = /\(const (nil)? :([\w\d_]+)\)/.freeze

        def on_const(node)
          constant_name = node.const_name
          return unless undesirable?(constant_name)

          add_wrong_name_offense(node, constant_name)
        end

        private

        def add_wrong_name_offense(node, bad_name)
          message = undesirable_names.fetch(bad_name).fetch('Message')
          add_offense(node, message: message)
        end

        def undesirable_names
          @undesirable_names ||= config.for_cop(self).fetch('UndesirableNames', {})
        end

        def undesirable?(name)
          undesirable_names.key?(name)
        end
      end
    end
  end
end
