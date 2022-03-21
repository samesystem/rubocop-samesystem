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

        SHORTCUT_SUGGESTIONS = {
          'graphql::types::iso8601date' => 'Date',
          '::graphql::types::iso8601date' => 'Date',
          'date' => 'Date',

          'int' => 'Integer',
          'integer' => 'Integer',

          'float' => 'Float',
          'decimal' => 'Float',
          'double' => 'Float',

          'bool' => 'Boolean',
          'boolean' => 'Boolean',

          '::graphql::types::json' => 'JSON',
          'graphql::types::json' => 'JSON',

          'id' => 'ID',

          'datetime' => 'DateTime',
          '::graphql::types::iso8601datetime' => 'DateTime',
          'graphql::types::iso8601datetime' => 'DateTime',

          'string' => 'String',
          'str' => 'String',
          'text' => 'String',
        }

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
            validate_graphql_attribute(attribute_node) && validate_attribute_type(attribute_node)
          end
        end

        def validate_graphql_attribute(attribute_node)
          return true if attribute_node.children.count < 4

          second_argument = attribute_node.children[3]
          return true unless second_argument.hash_type?

          add_offense(attribute_node, message: "`#{EXPECTED_ARGUMENT_NAME}.attribute` must be defined using chainable syntax such as `#{EXPECTED_ARGUMENT_NAME}.attribute(:name).type('String')`")
          false
        end

        def validate_attribute_type(node)
          type_node = nested_method_node(node, :type)
          return true unless type_node

          argument_node = type_node.first_argument
          return true unless argument_node

          validate_type_arg_type(argument_node) && validate_type_arg_shortcuts(argument_node)
        end

        def nested_method_node(outer_node, method_name)
          method_node = outer_node

          while method_node && method_node.send_type? && method_node.method_name != :type
            method_node = method_node.receiver
          end

          method_node
        end

        def validate_type_arg_type(type_arg_node)
          return true if type_arg_node.str_type?

          add_offense(type_arg_node, message: "`.type` argument must be a string such as `.type('User')`")
          false
        end

        def validate_type_arg_shortcuts(type_arg_node)
          original_value = type_arg_node.value
          type_value = original_value.gsub(/[\[!\]]/, '')
          suggestion = SHORTCUT_SUGGESTIONS[type_value.downcase]

          return true unless suggestion
          return true if suggestion == type_value

          full_suggestion = type_arg_node.value.sub(type_value, suggestion)
          add_offense(type_arg_node, message: "Use #{full_suggestion.inspect} instead")
          false
        end

        def graphql_attribute?(inner_node)
          config_variable = graphql_config_variable(inner_node)
          return false unless config_variable

          config_variable.parent.method_name == :attribute
        end

        def graphql_config_variable(inner_node)
          config_variable = inner_node.receiver
          config_variable = config_variable.receiver while config_variable.send_type?

          return nil unless config_variable.lvar_type?
          return nil if config_variable.node_parts != [EXPECTED_ARGUMENT_NAME]

          config_variable
        end

        def graphql_config_variable?(inner_node)
          receiver = inner_node.receiver
          receiver = receiver.receiver while receiver.send_type?

          receiver.lvar_type? && receiver.node_parts == [EXPECTED_ARGUMENT_NAME]
        end

        def graphql_block?(node)
          node.send_node.method_name == :graphql
        end
      end
    end
  end
end
