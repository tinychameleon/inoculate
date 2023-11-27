# frozen_string_literal: true

# An Instance life cycle runs the dependency block once.
#
#	@example
#		i = Instance.new { Object.new }
#		puts i.obtain.object_id #=> 13080
#		puts i.obtain.object_id #=> 13080
class Inoculate::Lifecycle::Instance
	def initialize(&block)
		@factory = block
	end

	# Obtain a new dependency once for the lifetime of this Instance.
	# @return [Object] whatever the given block returns
	def obtain
		@obtain ||= factory.call
	end

	private

		attr_reader :factory
end
