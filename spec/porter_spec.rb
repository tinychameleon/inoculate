# frozen_string_literal: true

require_relative "./shared_contexts"

RSpec.describe "Inoculate::Porter" do
  include_context "clean providers"

  before(:all) do
    Inoculate.initialize do |config|
      config.transient(:a) { 1 }
      config.transient(:b) { 2 }
      config.transient(:c) { 3 }
    end
  end

  context "default usage" do
    subject(:instance) do
      # noinspection RbsMissingTypeSignature,RubyResolve
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

  context "using aliases" do
    subject(:instance) do
      # noinspection RbsMissingTypeSignature,RubyResolve
      class AliasedInjectionExample # rubocop:disable Lint/ConstantDefinitionInBlock
        include Inoculate::Porter[:inject]
        inject :b, :c
      end

      # noinspection RbsMissingTypeSignature,RubyResolve
      class AliasDoesNotPersistExample # rubocop:disable Lint/ConstantDefinitionInBlock
        include Inoculate::Porter
        inoculate_with :a
      end

      AliasedInjectionExample.new
    end

    it "delivers dependencies" do
      expect(instance.private_methods).to include(:b, :c)
      expect(instance.private_methods).not_to include(:a)
    end
  end
end
