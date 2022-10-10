# frozen_string_literal: true

# Inoculate is a small, thread-safe dependency injection library configured entirely with Ruby.
# It provides several life-cycles and provides dependency access through private accessors.
#
# @since 0.1.0
module Inoculate
  # The main configuration entrypoint for Inoculate. Use this to set up named dependencies.
  #
  # @note This method is not thread safe.
  #
  # @example A simple dependency configuration
  #   Inoculate.initialize do |config|
  #     config.transient(:http) { Faraday }
  #   end
  #
  # @example An environment-based dynamic dependency configuration
  #   Inoculate.initialize do |config|
  #     http_service = ENV["test"] ? -> { class_double(Faraday) } : -> { Faraday }
  #     config.transient(:http, http_service)
  #   end
  #
  # @yieldparam config [Configurer] a configuration object to register dependencies
  #
  # @since 0.1.0
  def self.initialize
    yield Configurer.new(manufacturer)
  end

  # @!visibility private
  def self.manufacturer
    @manufacturer ||= Manufacturer.new
  end
end
