# frozen_string_literal: true

RSpec.describe "Inoculate::Configurer" do
  # noinspection RubyMismatchedArgumentType
  subject(:configurer) { Inoculate::Configurer.new(factory) }
  let(:factory) { spy("factory") }

  it "allows transient registrations" do
    callable = -> { 1 }
    configurer.transient(:service, callable)
    expect(factory).to have_received(:transient).with(:service, callable)
  end

  it "allows transient registrations with blocks" do
    callable = -> { 1 }
    configurer.transient(:service, &callable)
    expect(factory).to have_received(:transient).with(:service, nil, &callable)
  end
end
