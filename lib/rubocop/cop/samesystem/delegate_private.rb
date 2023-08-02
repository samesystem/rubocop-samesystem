# frozen_string_literal: true

module RuboCop
  module Cop
    module Samesystem
      # @example DelegatePrivate
      #   # bad
      #   class Foo
      #     def bar=Bar.new
      #
      #     private
      #
      #     delegate :baz, to: :bar
      #   end
      #
      #   # bad
      #   class Foo
      #     delegate :baz, to: :bar, private: true
      #
      #     def bar=Bar.new
      #   end
      #
      #   # good
      #   class Foo
      #     def bar=Bar.new
      #
      #     private
      #
      #     delegate :baz, to: :bar, private: true
      #   end
      class DelegatePrivate < Cop
        def on_send(node)
          mark_scope(node)
          return unless delegate_node?(node)

          if private_scope?(node) && !private_delegate?(node)
            add_offense(node, message: '`delegate` in private section should have `private: true` option')
          elsif public_scope?(node) && private_delegate?(node)
            add_offense(node, message: 'private `delegate` should be put in private section')
          end
        end

        private

        def private_delegate?(node)
          node.arguments.select(&:hash_type?).each do |hash_node|
            hash_node.each_pair do |key_node, value_node|
              return true if key_node.value == :private && value_node.true_type?
            end
          end

          false
        end

        def mark_scope(node)
          receiver_node, method_name, arg_node = *node
          return if receiver_node || arg_node

          @private_ranges ||= []

          if method_name == :private
            add_private_range(node)
          elsif method_name == :public
            cut_private_range_from(node.location.first_line)
          end
        end

        def delegate_node?(node)
          return false if node.receiver

          node.method_name == :delegate
        end

        def private_scope?(node)
          @private_ranges&.any? { |range| range.include?(node.location.first_line) }
        end

        def public_scope?(node)
          !private_scope?(node)
        end

        def add_private_range(node)
          @private_ranges ||= []
          @private_ranges += [node.location.first_line..node.parent.last_line]
        end

        def cut_private_range_from(from_line)
          @private_ranges ||= []
          @private_ranges = @private_ranges.each.with_object([]) do |range, new_ranges|
            next if range.begin > from_line

            new_range = range.include?(from_line) ? (range.begin...from_line) : range
            new_ranges << new_range
          end
        end
      end
    end
  end
end
