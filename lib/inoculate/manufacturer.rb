# frozen_string_literal: true

require "digest"

module Inoculate
  # Registers and builds dependency injection modules.
  # @todo building and registration needs to be thread-safe
  # @since 0.1.0
  class Manufacturer
    # The set of registered blueprints for dependency injection modules.
    # @return [Hash<Symbol, Hash>]
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
    #   manufacturer.transient(:sha1_hasher, -> { Digest::SHA1.new })
    #
    # @example With anything Callable
    #   class HashingBuilder
    #     def call = Digest::SHA1.new
    #   end
    #   manufacturer.transient(:sha1_hasher, HashingBuilder.new)
    #
    # @param name [Symbol, #to_sym] the dependency name which will be used to access it
    # @param builder [#call] the callable to build the dependency
    # @param block [Proc, nil] an alternative builder callable
    #
    # @raise [Errors::RequiresCallable] if no builder or block is provided
    # @raise [Errors::InvalidName] if the name is not a symbol, cannot be converted to a symbol,
    #                              or is not a valid attribute name
    # @raise [Errors::AlreadyRegistered] if the name has been registered previously
    def transient(name, builder = nil, &block)
      validate_builder_name name
      raise Errors::AlreadyRegistered if @registered_blueprints.has_key? name
      raise Errors::RequiresCallable unless builder.respond_to?(:call) || block

      @registered_blueprints[name.to_sym] = {lifecycle: :transient, builder: builder || block, accessor_module: nil}
    end

    # Build the accessor module associated with a dependency name.
    #
    # @param name [Symbol] the dependency name to build an accessor module for
    #
    # @raise [Errors::UnknownName] if the dependency name is not registered
    #
    # @return [Module] the accessor module for accessing instances of the dependency
    def build(name)
      blueprint = @registered_blueprints[name]
      raise Errors::UnknownName if blueprint.nil?
      return blueprint[:accessor_module] unless blueprint[:accessor_module].nil?

      module_name = "I#{Digest::SHA1.hexdigest(name.to_s)}"
      builder = blueprint[:builder]
      blueprint[:accessor_module] = Providers.module_eval do
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
