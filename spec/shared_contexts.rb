# frozen_string_literal: true

RSpec.shared_context "clean providers" do
  after do
    Inoculate::Manufacturer::Providers.constants.each do |c|
      Inoculate::Manufacturer::Providers.send(:remove_const, c)
    end
  end
end
