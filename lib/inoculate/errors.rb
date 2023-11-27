# frozen_string_literal: true

module Inoculate
	# A namespace for error types.
	#
	# @since 0.1.0
	module Errors
		# Base type for all Inoculate errors.
		#
		# @since 0.1.0
		class Error < StandardError; end

		# Raised when the user attempts to register a dependency with a name that can't be converted to a symbol.
		#
		# @since 0.1.0
		class InvalidName < Error; end

		# Raised when the user attempts to register a name again.
		#
		# @since 0.1.0
		class AlreadyRegistered < Error; end

		# Raised when the user attempts to depend on an unknown dependency.
		#
		# @since 0.1.0
		class UnknownName < Error; end

		# Raised when the user attempts to register a dependency with a builder that can't be called.
		#
		# @since 0.1.0
		class RequiresCallable < Error; end
	end
end
