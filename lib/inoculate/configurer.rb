# frozen_string_literal: true

module Inoculate
  # Configure dependencies through a restricted API during initialization.
  #
  # @since 0.1.0
  class Configurer
    def initialize(manufacturer)
      @manufacturer = manufacturer
    end

    # Register a transient dependency.
    # @see Manufacturer#transient
    #
    # @since 0.1.0
    def transient(name, builder = nil, &block)
      manufacturer.transient(name, builder, &block)
    end

    private

    attr_reader :manufacturer
  end
end
