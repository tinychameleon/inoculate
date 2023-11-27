# frozen_string_literal: true

require "spec_helper"

RSpec.describe Inoculate::Lifecycle::Instance do
	subject(:lifecycle) do
		described_class.new { Object.new }
	end

	define_negated_matcher :exist, :be_nil

	it "obtains a new dependency once" do
		object_id = lifecycle.obtain.object_id
		expect(lifecycle.obtain).to exist.and have_attributes(object_id:)
	end
end
