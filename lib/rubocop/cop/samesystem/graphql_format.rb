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
          require 'pry'; binding.pry
          return unless graphql_block?(node)

          return unless validate_graphql_arguments_count(node)
          return unless validate_graphql_argument_name(node)

          validate_graphql_attributes(node)
        end

        private

        def validate_graphql_arguments_count(node)
          return true if node.arguments.count == 1

          add_offence(node, location: node.location, message: 'GraphQL block should have single argument')
          false
        end

        def validate_graphql_argument_name(node)
          argument_name = node.arguments.map(&:name).first
          return true if !argument_name || argument_name == EXPECTED_ARGUMENT_NAME

          add_offence(node, location: node.location, message: "GraphQL block should have argument named #{EXPECTED_ARGUMENT_NAME.to_s.inspect}")
          false
        end

        def validate_graphql_attributes(node)
          attribute_nodes = node.body.children.select(&:send_type?).select { graphql_attribute?(_1) }
          attribute_nodes.each do |attribute_node|
            validate_graphql_attribute(attribute_node)
          end
        end

        def validate_graphql_attribute(attribute_node)
        end

        def graphql_attribute?(inner_node)
          require 'pry'; binding.pry
          return unless graphql_config_variable?(inner_node)

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
