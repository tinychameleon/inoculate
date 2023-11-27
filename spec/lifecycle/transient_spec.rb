# frozen_string_literal: true

require "spec_helper"

RSpec.describe Inoculate::Lifecycle::Transient do
	subject(:lifecycle) do
		described_class.new { Object.new }
	end

	it "obtains a new dependency each time" do
		expect(lifecycle.obtain.object_id).not_to eq(lifecycle.obtain.object_id)
	end
end
