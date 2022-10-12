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
      validate_dependency_name name
      raise Errors::AlreadyRegistered if @registered_blueprints.has_key? name
      raise Errors::RequiresCallable if block.nil?

      blueprint_name = name.to_sym
      @registered_blueprints[blueprint_name] = {
        lifecycle: :transient,
        factory: block,
        accessor_module: build_module(blueprint_name, :transient, block)
      }
    end

    # Register an instance dependency.
    #
    # An instance dependency gets created once for each instance of a dependent class.
    #
    # @example With a block
    #   manufacturer.instance(:sha1_hasher) { Digest::SHA1.new }
    #
    # @example With a Proc
    #   manufacturer.instance(:sha1_hasher, &-> { Digest::SHA1.new })
    #
    # @param name [Symbol, #to_sym] the dependency name which will be used to access it
    # @param block [Block, Proc] a factory method to build the dependency
    #
    # @raise [Errors::RequiresCallable] if no block is provided
    # @raise [Errors::InvalidName] if the name is not a symbol, cannot be converted to a symbol,
    #                              or is not a valid attribute name
    # @raise [Errors::AlreadyRegistered] if the name has been registered previously
    #
    # @since 0.3.0
    def instance(name, &block)
      validate_dependency_name name
      raise Errors::AlreadyRegistered if @registered_blueprints.has_key? name
      raise Errors::RequiresCallable if block.nil?

      blueprint_name = name.to_sym
      @registered_blueprints[blueprint_name] = {
        lifecycle: :instance,
        factory: block,
        accessor_module: build_module(blueprint_name, :instance, block)
      }
    end

    private

    def build_module(name, lifecycle, factory)
      module_name = "I#{Digest::SHA1.hexdigest(name.to_s)}"
      module_body =
        case lifecycle
        when :transient then build_transient(name, factory)
        when :instance then build_instance(name, factory)
        else raise ArgumentError, "Life cycle #{lifecycle} is not valid. Something has gone very wrong."
        end

      Providers.module_eval { const_set(module_name, module_body) }
    end

    def build_transient(name, factory)
      Module.new do
        private define_method(name) { factory.call }
      end
    end

    def build_instance(name, factory)
      cache_variable_name = "@icache_#{Digest::SHA1.hexdigest(name.to_s)}"
      Module.new do
        define_method(name) do
          instance_variable_set(cache_variable_name, factory.call) unless instance_variable_defined?(cache_variable_name)
          instance_variable_get(cache_variable_name)
        end
        private name
      end
    end

    def validate_dependency_name(name)
      raise Errors::InvalidName, "name must be a symbol or convert to one" unless name.respond_to? :to_sym
      begin
        Module.new { attr_reader name }
      rescue NameError
        raise Errors::InvalidName, "name must be a valid attr_reader"
      end
    end
  end
end
