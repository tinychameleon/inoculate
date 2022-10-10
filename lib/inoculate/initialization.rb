# frozen_string_literal: true

# TODO
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
  def self.initialize
    yield Configurer.new(manufacturer)
  end

  # @private
  def self.manufacturer
    @manufacturer ||= Manufacturer.new
  end
end
