# frozen_string_literal: true

RSpec.describe "Inoculate" do
  context "constants" do
    it "has a version number" do
      expect(Inoculate::VERSION).not_to be nil
    end
  end

  skip "initialization" do
    it "requires a block" do
      expect { Inoculate.initialize }.to raise_error Inoculate::Errors::RequiresBlock
    end

    it "provides a container configuration object to the block" do
      actual = nil
      Inoculate.initialize { |c| actual = c }
      expect(actual).to be_an_instance_of Inoculate::Architect
    end
  end
end
