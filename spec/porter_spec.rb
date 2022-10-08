# frozen_string_literal: true

RSpec.describe "Inoculate::Porter" do
  subject(:instance) do
    Inoculate.factory.transient(:a) { 1 }
    Inoculate.factory.transient(:b) { 2 }
    Inoculate.factory.transient(:c) { 3 }

    # noinspection RbsMissingTypeSignature
    class InjectionExample # rubocop:disable Lint/ConstantDefinitionInBlock
      include Inoculate::Porter
      inoculate_with :a, :c

    end

    InjectionExample.new
  end

  it "delivers dependencies" do
    expect(instance.private_methods).to include(:a, :c)
    expect(instance.private_methods).not_to include(:b)
  end
end
