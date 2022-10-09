# frozen_string_literal: true

RSpec.describe "Inoculate::Configurer" do
  # noinspection RubyMismatchedArgumentType
  subject(:configurer) { Inoculate::Configurer.new(manufacturer) }
  let(:manufacturer) { spy("manufacturer") }

  it "allows transient registrations" do
    callable = -> { 1 }
    configurer.transient(:service, callable)
    expect(manufacturer).to have_received(:transient).with(:service, callable)
  end

  it "allows transient registrations with blocks" do
    callable = -> { 1 }
    configurer.transient(:service, &callable)
    expect(manufacturer).to have_received(:transient).with(:service, nil, &callable)
  end
end
