# frozen_string_literal: true

module Inoculate
  # @todo This should be refactored into a better API.
  def self.factory
    @factory ||= Manufacturer::Factory.new
  end

  # Delivers requested dependencies to user classes.
  #
  # The sole method {ClassMethods#inoculate_with} is named to avoid collisions with other
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
  # @example With Aliasing
  #   class Base
  #     include Inoculate::Porter
  #     class << self
  #       alias_method :depend_on, :inoculate_with
  #     end
  #   end
  #
  #   class Child < Base
  #     depend_on :http_service
  #   end
  #
  # @since 0.1.0
  module Porter
    # @!visibility private
    def self.included(base)
      base.extend ClassMethods
    end

    # Holds class methods to inject into user class scopes.
    module ClassMethods
      # Injects requested dependencies into the user class.
      #
      # @param names [*Symbol] dependency names to inject
      #
      # @raise [Errors::UnknownName] if a dependency name is not registered
      def inoculate_with(*names)
        names.each do |name|
          include(Inoculate.factory.build(name))
        end
      end
    end
  end
end
