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
      class NamingMatters < Cop
        include ConfigurableFormatting

        FORMATS = {
          naming_matters:  /[^it]/,
        }.freeze

        MSG = 'Please use descriptive variable names.'

        def on_arg(node)
          name, = *node
          check_name(node, name, node.loc.name)
        end
        alias on_lvasgn on_arg
      end
    end
  end
end
