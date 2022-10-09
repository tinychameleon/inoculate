# frozen_string_literal: true

# TODO
module Inoculate
  attr_reader :manufacturer

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
    @manufacturer = Manufacturer.new
    yield Configurer.new(@manufacturer)
  end
end
