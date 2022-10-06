# frozen_string_literal: true

module Inoculate
  # A namespace for error types.
  module Errors
    # Base type for all Inoculate errors.
    class Error < StandardError; end

    # Raised when the Inoculate initialization method is not provided a block.
    class InitializationRequiresBlock < Error; end
  end
end
