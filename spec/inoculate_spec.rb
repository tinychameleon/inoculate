# frozen_string_literal: true

RSpec.describe "Inoculate" do
  context "constants" do
    it "has a version number" do
      expect(Inoculate::VERSION).not_to be nil
    end
  end
end
