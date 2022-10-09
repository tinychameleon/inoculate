# frozen_string_literal: true

module Inoculate
  # Configure dependencies through a restricted API.
  class Configurer
    def initialize(manufacturer)
      @manufacturer = manufacturer
    end

    # Register a transient dependency.
    # @see Manufacturer#transient
    def transient(name, builder = nil, &block)
      manufacturer.transient(name, builder, &block)
    end

    private

    attr_reader :manufacturer
  end
end
