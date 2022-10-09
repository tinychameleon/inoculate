# frozen_string_literal: true

module Inoculate
  # Configure dependencies through a restricted API.
  class Configurer
    def initialize(factory)
      @factory = factory
    end

    # Register a transient dependency.
    # @see Manufacturer::Factory#transient
    def transient(name, builder = nil, &block)
      @factory.transient(name, builder, &block)
    end
  end
end
