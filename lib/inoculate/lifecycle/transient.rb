# frozen_string_literal: true

# A Transient life cycle runs the dependency block for each call.
#
#	@example
#		t = Transient.new { Object.new }
#		puts t.obtain.object_id #=> 13080
#		puts t.obtain.object_id #=> 15540
class Inoculate::Lifecycle::Transient
	def initialize(&block)
		@factory = block
	end

	# Obtain a new dependency for each call.
	#	@return [Object] whatever the given block returns
	def obtain
		factory.call
	end

	private

		attr_reader :factory
end
