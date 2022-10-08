# frozen_string_literal: true

require "digest"

module Inoculate
  module Manufacturer
    # Registers and builds dependency injection modules.
    # @since 0.1.0
    class Factory
      # The set of registered builders for dependency injection modules.
      # @return [Hash<Symbol, Hash>]
      attr_reader :registered_builders

      def initialize
        @registered_builders = {}
      end

      # Register a transient dependency.
      #
      # A transient dependency gets created anew every time it is retrieved through the accessor.
      #
      # @example With a block
      #   factory.transient(:sha1_hasher) { Digest::SHA1.new }
      #
      # @example With a Proc
      #   factory.transient(:sha1_hasher, -> { Digest::SHA1.new })
      #
      # @example With anything Callable
      #   class HashingBuilder
      #     def call = Digest::SHA1.new
      #   end
      #   factory.transient(:sha1_hasher, HashingBuilder.new)
      #
      # @param name [Symbol, #to_sym] the dependency name which will be used to access it
      # @param builder [#call] the callable to build the dependency
      # @param block [Proc, nil] an alternative builder callable
      #
      # @raise [Errors::RequiresCallable] if no builder or block is provided
      # @raise [Errors::InvalidName] if the name is not a symbol, cannot be converted to a symbol,
      #                              or is not a valid attribute name
      def transient(name, builder = nil, &block)
        validate_builder_name name
        raise Errors::RequiresCallable unless builder.respond_to?(:call) || block
        @registered_builders[name.to_sym] = {lifecycle: :transient, builder: builder || block, accessor_module: nil}
      end

      # Build the accessor module associated with a dependency name.
      #
      # @param name [Symbol] the dependency name to build an accessor module for
      # @return [Module] the accessor module for accessing instances of the dependency
      def build(name)
        builder = @registered_builders.dig(name, :builder)
        module_name = "I#{Digest::SHA1.hexdigest(name.to_s)}"
        Providers.module_eval do
          const_set(module_name, Module.new do
            private define_method(name) { builder.call }
          end)
        end
      end

      private

      def validate_builder_name(name)
        raise Errors::InvalidName, "name must be a symbol or convert to one" unless name.respond_to? :to_sym
        begin
          Module.new { attr_reader name }
        rescue NameError
          raise Errors::InvalidName, "name must be a valid attr_reader"
        end
      end
    end
  end
end
