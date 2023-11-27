# frozen_string_literal: true

require_relative "shared_contexts"

RSpec.describe "Inoculate::Manufacturer" do
	subject(:manufacturer) { Inoculate::Manufacturer.new }

	include_context "clean providers"

	context "initialization" do
		it "has no registered blueprints" do
			expect(manufacturer.registered_blueprints).to be_empty
		end
	end

	context "builders" do
		context "registering" do
			%i[transient instance singleton thread_singleton].each do |lifecycle|
				it "#{lifecycle} does not silently shadow registered names" do
					subject.send(lifecycle, :service, &-> { 1 })
					expect { subject.send(lifecycle, :service, &-> { 2 }) }.
						to raise_error Inoculate::Errors::AlreadyRegistered
				end
			end
		end

		RSpec.shared_examples "life cycle checks" do |lifecycle|
			it "can be registered" do
				callable = -> {}
				subject.send(lifecycle, :service, &callable)
				actual = subject.registered_blueprints[:service]
				expect(actual[:lifecycle]).to eq lifecycle
				expect(actual[:factory]).to eq callable
				expect(actual[:accessor_module]).to be_an_instance_of(Module)
			end

			it "can be registered with a block" do
				subject.send(lifecycle, :service) { "empty" }
				expect(subject.registered_blueprints[:service][:factory]).to be_an_instance_of(Proc)
			end

			it "supports name which convert to symbols" do
				subject.send(lifecycle, "service") { "empty" }
				expect(subject.registered_blueprints).to have_key :service
			end

			it "does not allow other names" do
				expect { subject.send(lifecycle, 1, &-> {}) }.
					to raise_error Inoculate::Errors::InvalidName
			end

			it "does not allow names which can't be attr_reader parameters" do
				expect { subject.send(lifecycle, :@service, &-> {}) }.
					to raise_error Inoculate::Errors::InvalidName
			end

			it "does not allow nil blocks" do
				expect { subject.send(lifecycle, :service) }.
					to raise_error Inoculate::Errors::RequiresCallable
			end
		end

		context "transient" do
			include_examples "life cycle checks", :transient
		end

		context "instance" do
			include_examples "life cycle checks", :instance
		end

		context "singleton" do
			include_examples "life cycle checks", :singleton
		end

		context "thread_singleton" do
			include_examples "life cycle checks", :thread_singleton
		end
	end

	context "building" do
		# noinspection RubyMismatchedArgumentType
		let(:accessor_module) { manufacturer.send(lifecycle, name) { Object.new }[:accessor_module] }
		let(:name) { :service }

		include_context "clean providers"

		RSpec.shared_examples "dependency provider module" do
			it "creates a provider module based on the dependency name" do
				expect(accessor_module.name).to eq "Inoculate::Providers::I4cf5bc59bee9e1c44c6254b5f84e7f066bd8e5fe"
				expect(accessor_module.private_instance_methods).to include(name)
			end
		end

		context "transient" do
			subject(:dependent) { Class.new.include(accessor_module).new }
			let(:lifecycle) { :transient }

			include_examples "dependency provider module"

			it "creates a new object instance every call" do
				expect(dependent.send(name).object_id).not_to eq dependent.send(name).object_id
			end
		end

		context "instance" do
			subject(:dependent) { Class.new.include(accessor_module) }
			let(:lifecycle) { :instance }

			include_examples "dependency provider module"

			it "creates a new object once per instance" do
				d1 = dependent.new
				expect(d1.send(name).object_id).to eq d1.send(name).object_id

				d2 = dependent.new
				expect(d1.send(name).object_id).not_to eq d2.send(name).object_id
			end
		end

		context "singleton" do
			subject(:dependent) { Class.new.include(accessor_module) }
			subject(:other_dependent) { Class.new.include(accessor_module) }
			let(:lifecycle) { :singleton }

			include_examples "dependency provider module"

			it "creates a new object once" do
				d1 = dependent.new
				expect(d1.send(name).object_id).to eq d1.send(name).object_id

				d2 = dependent.new
				expect(d1.send(name).object_id).to eq d2.send(name).object_id

				od1 = other_dependent.new
				expect(d1.send(name).object_id).to eq od1.send(name).object_id

				other_thread_object_id = nil
				Thread.new { other_thread_object_id = other_dependent.new.send(name).object_id }.
					join
				expect(d1.send(name).object_id).to eq other_thread_object_id
			end
		end

		context "thread_singleton" do
			subject(:dependent) { Class.new.include(accessor_module) }
			subject(:other_dependent) { Class.new.include(accessor_module) }
			let(:lifecycle) { :thread_singleton }

			include_examples "dependency provider module"

			it "creates a new object once per thread" do
				d1 = dependent.new
				expect(d1.send(name).object_id).to eq d1.send(name).object_id

				d2 = dependent.new
				expect(d1.send(name).object_id).to eq d2.send(name).object_id

				od1 = other_dependent.new
				expect(d1.send(name).object_id).to eq od1.send(name).object_id

				other_thread_object_id = nil
				Thread.new { other_thread_object_id = other_dependent.new.send(name).object_id }.
					join
				expect(d1.send(name).object_id).not_to eq other_thread_object_id
			end
		end
	end
end
