# frozen_string_literal: true

RSpec.describe "Inoculate::Manufacturer::Factory" do
  subject(:factory) { Inoculate::Manufacturer::Factory.new }

  context "initialization" do
    it "has no registered builders" do
      expect(factory.registered_builders).to be_empty
    end
  end

  context "builders" do
    context "transients" do
      it "can be registered" do
        callable = -> {}
        subject.transient(:service, callable)
        expect(subject.registered_builders[:service]).to eq(lifecycle: :transient, builder: callable, accessor_module: nil)
      end

      it "can be registered with a block" do
        subject.transient(:service) {}
        expect(subject.registered_builders[:service][:builder]).to be_an_instance_of(Proc)
      end

      it "can be registered with anything callable" do
        callable = Class.new do
          def call
          end
        end
        subject.transient(:service, callable.new)
        expect(subject.registered_builders[:service][:builder]).to be_an_instance_of(callable)
      end

      it "supports name which convert to symbols" do
        subject.transient("service", -> {})
        expect(subject.registered_builders).to have_key :service
      end

      it "does not allow other names" do
        expect { subject.transient(1, -> {}) }.to raise_error Inoculate::Errors::InvalidName
      end

      it "does not allow names which can't be attr_reader parameters" do
        expect { subject.transient(:@service, -> {}) }.to raise_error Inoculate::Errors::InvalidName
      end

      it "does not allow un-callable builders" do
        expect { subject.transient(:service, 1) }.to raise_error Inoculate::Errors::RequiresCallable
      end
    end
  end

  context "building" do
    context "transients" do
      # noinspection RubyMismatchedArgumentType
      subject(:accessor_module) { factory.build(name) }
      let(:name) { :service }
      let(:builder_spy) { spy("object") }

      before do
        # noinspection RubyMismatchedArgumentType
        factory.transient(name) { builder_spy.new }
      end

      it "creates a provider module based on the builder name" do
        expect(accessor_module.name).to eq "Inoculate::Manufacturer::Providers::I4cf5bc59bee9e1c44c6254b5f84e7f066bd8e5fe"
        expect(accessor_module.instance_methods).to include(name)
      end

      context "instance inclusion" do
        subject(:instance) { Class.new.include(accessor_module).new }

        it "creates a new object instance every call" do
          expect(instance.send(name).object_id).not_to eq instance.send(name)
          expect(builder_spy).to have_received(:new).twice
        end
      end
    end
  end
end
