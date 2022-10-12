# frozen_string_literal: true

require "digest"

module Inoculate
  # Registers and builds dependency injection modules.
  # @todo singleton life cycle
  # @todo instance life cycle
  # @todo thread singleton life cycle
  #
  # @since 0.1.0
  class Manufacturer
    # The set of registered blueprints for dependency injection modules.
    # @return [Hash<Symbol, Hash>]
    #
    # @since 0.1.0
    attr_reader :registered_blueprints

    def initialize
      @registered_blueprints = {}
    end

    # Register a transient dependency.
    #
    # A transient dependency gets created anew every time it is retrieved through the accessor.
    #
    # @example With a block
    #   manufacturer.transient(:sha1_hasher) { Digest::SHA1.new }
    #
    # @example With a Proc
    #   manufacturer.transient(:sha1_hasher, &-> { Digest::SHA1.new })
    #
    # @param name [Symbol, #to_sym] the dependency name which will be used to access it
    # @param block [Block, Proc] a factory method to build the dependency
    #
    # @raise [Errors::RequiresCallable] if no block is provided
    # @raise [Errors::InvalidName] if the name is not a symbol, cannot be converted to a symbol,
    #                              or is not a valid attribute name
    # @raise [Errors::AlreadyRegistered] if the name has been registered previously
    #
    # @since 0.1.0
    def transient(name, &block)
      validate_builder_name name
      raise Errors::AlreadyRegistered if @registered_blueprints.has_key? name
      raise Errors::RequiresCallable if block.nil?

      blueprint_name = name.to_sym
      @registered_blueprints[blueprint_name] = {
        lifecycle: :transient,
        factory: block,
        accessor_module: build_module(blueprint_name, :transient, block)
      }
    end

    private

    def build_module(name, lifecycle, builder)
      module_name = "I#{Digest::SHA1.hexdigest(name.to_s)}"
      Providers.module_eval do
        const_set(module_name, Module.new do
          private define_method(name) { builder.call }
        end)
      end
    end

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
