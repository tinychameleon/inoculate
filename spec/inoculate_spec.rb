# frozen_string_literal: true

RSpec.describe "Inoculate" do
	context "constants" do
		it "has a version number" do
			expect(Inoculate::VERSION).not_to be nil
		end
	end

	context "initialization" do
		subject(:lib) { Inoculate }

		it "initializes a manufacturer once" do
			expect(lib.manufacturer).to be_an_instance_of Inoculate::Manufacturer
			expect(lib.manufacturer.object_id).to eq lib.manufacturer.object_id
		end

		it "yields a configuration object" do
			expect { |b| lib.initialize(&b) }.
				to yield_with_args(an_instance_of(Inoculate::Configurer))
		end
	end
end
