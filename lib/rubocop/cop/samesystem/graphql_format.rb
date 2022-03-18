# frozen_string_literal: true

module RuboCop
  module Cop
    module Samesystem
      # @example EnforcedStyle: bar (default)
      #   # Description of the `bar` style.
      #
      #   # bad
      #   [1, 2, 3].each { |it| puts it }
      #
      #   # bad
      #   it = fetch_calendar_lines(user)
      #
      #   # good
      #   [1, 2, 3].each { |number| puts number }
      #
      #   # good
      #   user_calendar_lines = fetch_calendar_lines(user)
      #
      class GraphqlFormat < Cop
        include ConfigurableFormatting

        EXPECTED_ARGUMENT_NAME = :c

        FORMATS = {
          it:  /[^it]/,
        }.freeze

        MSG = 'Use descriptive block parameter name or use numbered parameter "_1" instead.'.freeze

        def on_block(node)
          return unless graphql_block?(node)

          return unless validate_graphql_arguments_count(node)
          return unless validate_graphql_argument_name(node)

          validate_graphql_attributes(node)
        end

        private

        def validate_graphql_arguments_count(node)
          return true if node.arguments.count == 1

          add_offense(node, message: '`graphql` block should have single argument')
          false
        end

        def validate_graphql_argument_name(node)
          argument = node.arguments.first
          return true unless argument

          argument_name = argument.children.first
          return true if !argument_name || argument_name == EXPECTED_ARGUMENT_NAME

          add_offense(argument, message: "`graphql` block should have argument named `#{EXPECTED_ARGUMENT_NAME}`")
          false
        end

        def validate_graphql_attributes(node)
          attribute_nodes = node.children[2..].select { graphql_attribute?(_1) }
          attribute_nodes.each do |attribute_node|
            validate_graphql_attribute(attribute_node)
          end
        end

        def validate_graphql_attribute(attribute_node)
          return true if attribute_node.children.count < 4

          second_argument = attribute_node.children[3]
          return true unless second_argument.hash_type?

          add_offense(attribute_node, message: "`#{EXPECTED_ARGUMENT_NAME}.attribute` must be defined using chainable syntax such as `#{EXPECTED_ARGUMENT_NAME}.attribute(:name).type('String')`")
          false
        end

        def graphql_attribute?(inner_node)
          return false unless inner_node.send_type?
          return false unless graphql_config_variable?(inner_node)

          inner_node.method_name == :attribute
        end

        def graphql_config_variable?(inner_node)
          receiver = inner_node.receiver
          receiver.lvar_type? && receiver.node_parts == [EXPECTED_ARGUMENT_NAME]
        end

        def graphql_block?(node)
          node.send_node.method_name == :graphql
        end
      end
    end
  end
end
