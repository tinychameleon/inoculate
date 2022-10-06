# frozen_string_literal: true

module Inoculate
  # The main configuration entrypoint for Inoculate. Use this to set up named dependencies.
  # @note This method is not thread safe.
  # @example A simple dependency configuration
  #   Inoculate.initialize do |c|
  #     # TODO
  #   end
  # @yield (Architect) a configuration object to manage dependency names and life-cycles
  # @raise (Errors::InitializationRequiresBlock) when no block is given
  def self.initialize
    raise Errors::InitializationRequiresBlock unless block_given?

    architect = Architect.new
    yield architect
  end
end
