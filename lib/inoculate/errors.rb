# frozen_string_literal: true

module Inoculate
  # A namespace for error types.
  module Errors
    # Base type for all Inoculate errors.
    class Error < StandardError; end

    # Raised when the user attempts to register a dependency with a name that can't be converted to a symbol.
    class InvalidName < Error; end

    # Raised when the user attempts to depend on an unknown dependency.
    class UnknownName < Error; end

    # Raised when the user attempts to register a dependency with a builder that can't be called.
    class RequiresCallable < Error; end
  end
end
