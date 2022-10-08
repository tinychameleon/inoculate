# frozen_string_literal: true

require "digest"

module Inoculate
  module Manufacturer
    # TODO
    class Factory
      attr_reader :registered_builders

      # TODO
      def initialize
        @registered_builders = {}
      end

      # TODO
      def transient(name, builder = nil, &block)
        validate_builder_name name
        raise Errors::RequiresCallable unless builder.respond_to?(:call) || block
        @registered_builders[name.to_sym] = {lifecycle: :transient, builder: builder || block, accessor_module: nil}
      end

      # TODO
      def build(name)
        builder = @registered_builders.dig(name, :builder)
        module_name = "I#{Digest::SHA1.hexdigest(name.to_s)}"
        Providers.module_eval do
          const_set(module_name, Module.new do
            define_method(name) { builder.call }
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
