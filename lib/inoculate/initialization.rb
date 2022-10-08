# frozen_string_literal: true

# TODO
module Inoculate
  # The main configuration entrypoint for Inoculate. Use this to set up named dependencies.
  # @note This method is not thread safe.
  # @example A simple dependency configuration
  #   Inoculate.initialize do |c|
  #     # TODO
  #   end
  # @yield TODO
  def self.initialize
    yield
  end
end
