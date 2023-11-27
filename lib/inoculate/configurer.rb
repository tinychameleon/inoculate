# frozen_string_literal: true

module Inoculate
	# Configure dependencies through a restricted API during initialization.
	#
	# @since 0.1.0
	class Configurer
		def initialize(manufacturer)
			@manufacturer = manufacturer
		end

		# Register a transient dependency.
		# @see Manufacturer#transient
		#
		# @since 0.1.0
		def transient(name, &block)
			manufacturer.transient(name, &block)
			nil
		end

		# Register an instance dependency.
		# @see Manufacturer#instance
		#
		# @since 0.3.0
		def instance(name, &block)
			manufacturer.instance(name, &block)
			nil
		end

		# Register a singleton dependency.
		# @see Manufacturer#singleton
		#
		# @since 0.4.0
		def singleton(name, &block)
			manufacturer.singleton(name, &block)
			nil
		end

		# Register a thread singleton dependency.
		# @see Manufacturer#thread_singleton
		#
		# @since 0.5.0
		def thread_singleton(name, &block)
			manufacturer.thread_singleton(name, &block)
			nil
		end

		private

			attr_reader :manufacturer
	end
end
