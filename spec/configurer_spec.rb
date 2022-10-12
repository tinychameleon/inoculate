# frozen_string_literal: true

RSpec.describe "Inoculate::Configurer" do
  # noinspection RubyMismatchedArgumentType
  subject(:configurer) { Inoculate::Configurer.new(manufacturer) }
  let(:manufacturer) { spy("manufacturer") }

  it "allows transient registrations" do
    callable = -> { 1 }
    expect(configurer.transient(:service, &callable)).to be_nil
    expect(manufacturer).to have_received(:transient).with(:service, &callable)
  end

  it "allows instance registrations" do
    callable = -> { 1 }
    expect(configurer.instance(:service, &callable)).to be_nil
    expect(manufacturer).to have_received(:instance).with(:service, &callable)
  end

  it "allows singleton registrations" do
    callable = -> { 1 }
    expect(configurer.singleton(:service, &callable)).to be_nil
    expect(manufacturer).to have_received(:singleton).with(:service, &callable)
  end
end
