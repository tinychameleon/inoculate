# frozen_string_literal: true

module Inoculate
  # The main configuration entrypoint for Inoculate. Use this to set up named dependencies.
  # @note This method is not thread safe.
  # @example A simple dependency configuration
  #   Inoculate.initialize do |c|
  #     # TODO
  #   end
  # @yield TODO
  # @raise (Errors::RequiresBlock) when no block is given
  def self.initialize
    yield
  end
end
