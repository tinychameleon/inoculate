# frozen_string_literal: true

module Inoculate
  # Delivers requested dependencies to user classes.
  #
  # The default method +inoculate_with+ is named to avoid collisions with other
  # libraries. You can alias it to something that makes your codebase legible.
  #
  # @example Getting Dependencies
  #   class HealthChecker
  #     include Inoculate::Porter
  #     inoculate_with :http_service
  #
  #     def healthy?
  #       http_service.get("/health").ok?
  #     end
  #   end
  #
  # @example With Aliasing Include
  #   class Base
  #     include Inoculate::Porter[:depend_on]
  #   end
  #
  #   class Child < Base
  #     depend_on :http_service
  #   end
  #
  # @since 0.1.0
  module Porter
    # Create a dependency injection module with your chosen method name.
    #
    # @param method_name [Symbol] the dependency injection method name
    # @return [Module] a dependency injection module for inclusion in classes.
    #
    # @since 0.1.0
    def self.[](method_name)
      m = Module.new do
        define_method(method_name) do |*names|
          names.each do |name|
            mod = Inoculate.manufacturer.registered_blueprints.dig(name, :accessor_module)
            raise Errors::UnknownName if mod.nil?

            include(mod)
          end
        end
      end

      inclusion = Module.new
      inclusion.singleton_class.define_method(:included) do |base|
        base.extend m
      end
      inclusion
    end

    # Including this module makes the default +inoculate_with+ method available.
    #
    # @param base [Class] the class this module is included within
    #
    # @since 0.1.0
    def self.included(base)
      base.include self[:inoculate_with]
    end
  end
end
